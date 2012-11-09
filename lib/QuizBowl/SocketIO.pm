package QuizBowl::SocketIO;

# ABSTRACT: SocketIO app

use Moose;
use MooseX::ClassAttribute;

use QuizBowl::Core;
use JSON;
use Data::Dumper::Concise;

class_has 'event' => (
	is      => 'rw',
	isa     => 'Object',
	default => sub {
		return QuizBowl::Core->schema->resultset('Event')->find(1);
	}
);

class_has 'users' => (
	is         => 'rw',
	isa        => 'HashRef',
	lazy_build => 1,
);

class_has 'users_by_score' => (
	is         => 'rw',
	isa        => 'ArrayRef[Int]',
	lazy_build => 1,
);

sub _build_users_by_score {
	my $self = shift;
	my @users;

	my $players_rs = QuizBowl::SocketIO->event->registered_teams->search(
		{},
		{
			'select' => [ 'team.name', 'players.user_id', { sum => 'submissions.points', } ],
			'as'     => [qw/team_name user_id score/],
			group_by => [ 1, 2 ],
			order_by => \'3 DESC NULLS LAST, 1',
			join => [ 'team', { players => { submissions => 'event_question', }, } ],
			result_class => 'DBIx::Class::ResultClass::HashRefInflator',
		}
	);
	foreach my $user ( $players_rs->all() ) {
		push @users, $user->{'user_id'};
		QuizBowl::SocketIO->users->{ $user->{'user_id'} }->{score} = $user->{'score'} // 0;
	}
	return \@users;
}

sub _set_scores {
	my $self = shift;
	QuizBowl::SocketIO->users_by_score( $self->_build_users_by_score );
}

class_has 'event_question' => (
	is         => 'rw',
	isa        => 'Maybe[QuizBowl::Schema::Result::EventQuestion]',
	lazy_build => 1,
);

# Set to last started, but not yet closed, question (if any)
sub _build_event_question {
	my $self = shift;
	$self->event->questions->search(
		{
			start_timestamp => { '!=' => undef },
			close_timestamp => undef,
		},
		{ order_by => { '-desc' => 'start_timestamp' }, }
	)->first();
}

sub _build_users {
	my $self = shift;
	my $teams_rs = QuizBowl::SocketIO->event->registered_teams->search( {}, { prefetch => 'players' } );
	my %users;
	while ( my $team = $teams_rs->next() ) {
		my $players_rs = $team->players_rs;
		while ( my $user = $players_rs->next() ) {
			$users{ $user->id } = {
				name           => $user->name,
				session_id     => undef,
				connected      => 0,
				roll_call_ackd => 0,
				is_admin       => 0,
				answer         => '',
				score          => 0,
			};
		}
	}
	return \%users;
}

sub run {
	my $self = shift;
	return sub {
		my $self = shift;
		$self->on( 'user message'      => \&user_message );
		$self->on( 'register'          => \&register );
		$self->on( 'request roll call' => \&request_roll_call );
		$self->on( 'ack roll call'     => \&ack_roll_call );
		$self->on( 'start round'       => \&start_round );
		$self->on( 'close round'       => \&close_round );
		$self->on( 'submit answer'     => \&submit_answer );
		$self->on( 'calc points'       => \&calc_points );
		$self->on( 'reveal results'    => \&reveal_results );
		$self->on( 'disconnect'        => \&disconnect );
	};
}

# IM Chat
sub user_message {
	my $self    = shift;
	my $message = shift;
	$self->get(
		'name' => sub {
			my ( $self, $err, $name ) = @_;
			$self->broadcast->emit( 'user message', $name, $message );
		}
	);

}

# Auth users/presenters
sub register {
	my $self = shift;
	my ( $session_id, $cb ) = @_;

	if ( $session_id eq 'presenter' ) {
		$cb->( { success => 1 } );
	}
	elsif ( my $user = QuizBowl::Core->schema->resultset('User')->find_by_session($session_id) ) {
		$self->set( user_id => $user->id, );
		$self->set( name    => $user->name, );
		QuizBowl::SocketIO->users->{ $user->id } = {
			%{ QuizBowl::SocketIO->users->{ $user->id } // {} },
			name           => $user->name,
			session_id     => $session_id,
			connected      => 1,
			roll_call_ackd => 0,
			is_admin       => $user->is_admin,
		};

		# in progress?
		my %round_info = ( round_started => 0 );
		my $eq = QuizBowl::SocketIO->event_question;
		$eq->discard_changes() if defined $eq;
		if ( defined $eq && defined $eq->start_timestamp && !defined $eq->close_timestamp ) {
			%round_info = (
				round_started => 1,
				round_data    => {
					sequence        => $eq->sequence,
					round_number    => $eq->round_number,
					question_type   => $eq->question->question_type_value,
					level_id        => $eq->question->level_id,
					question        => $eq->question->question,
					start_timestamp => $eq->start_timestamp->iso8601,
				}
			);
		}
		$cb->( { success => 1, name => $user->name, %round_info } );
		$self->broadcast->emit( 'growl', $user->name . ' connected' );
	}
	else {
		$cb->( { success => 0 } );
	}
	QuizBowl::SocketIO->_set_scores();
	emit_user_list($self);
}

sub request_roll_call {
	my $self = shift;
	foreach my $user_id ( keys %{ QuizBowl::SocketIO->users } ) {
		QuizBowl::SocketIO->users->{$user_id}->{roll_call_ackd} = 0;
	}
	QuizBowl::SocketIO->_set_scores();
	emit_user_list($self);
	$self->sockets->emit('roll call requested');
}

sub ack_roll_call {
	my $self = shift;
	$self->get(
		'user_id' => sub {
			my ( $self, $err, $user_id ) = @_;
			print STDERR "$user_id is ack'ing roll call\n";
			return unless $user_id && QuizBowl::SocketIO->users->{$user_id};
			QuizBowl::SocketIO->users->{$user_id}->{roll_call_ackd} = 1;
			emit_user_list($self);
			$self->broadcast->emit( 'growl', sprintf( '%s is ready!', QuizBowl::SocketIO->users->{$user_id}->{name} ) );
		}
	);
}

sub start_round {
	my $self              = shift;
	my $event_question_id = shift;
	my $cb                = shift;

	my $eq = QuizBowl::SocketIO->event->questions->search( { event_question_id => $event_question_id },
		{ prefetch => 'question' } )->first();

	unless ( defined $eq ) {
		$cb->( { not_found => 1 } );
		return;
	}

	# Close any other started questions, only want one at a time
	QuizBowl::SocketIO->event->questions->search(
		{
			event_question_id => { '!=' => $event_question_id },
			start_timestamp   => { '!=' => undef },
			close_timestamp   => undef,
		}
	)->update( { close_timestamp => \'now()' } );

	log_event( 'round started', { event_question_id => $event_question_id, } );

	foreach my $user_id ( keys %{ QuizBowl::SocketIO->users } ) {
		QuizBowl::SocketIO->users->{$user_id}->{answer} = '';
	}

	$eq->update(
		{
			start_timestamp => \'now()',
			close_timestamp => undef,
		}
	);
	$eq->discard_changes();
	QuizBowl::SocketIO->event_question($eq);

	$self->sockets->emit(
		'round started',
		{
			sequence        => $eq->sequence,
			round_number    => $eq->round_number,
			question_type   => $eq->question->question_type_value,
			level_id        => $eq->question->level_id,
			question        => $eq->question->question,
			start_timestamp => $eq->start_timestamp->iso8601,
		}
	);

	$cb->( { start_timestamp => $eq->start_timestamp->iso8601 } );
}

sub close_round {
	my $self   = shift;
	my $data_r = shift;

	my $event_question_id = $data_r->{event_question_id} || QuizBowl::Socket->event_question->id;
	my $seconds           = $data_r->{seconds_to_close}  || 0;

	if ($seconds) {
		$self->broadcast->emit( 'growl', sprintf( 'Round will close in %i seconds', $seconds ) );
	}
	else {
		my $q = QuizBowl::Core->schema->resultset('EventQuestion')->find($event_question_id);
		$q->update( { close_timestamp => \'now()', } ) if defined $q;
		$self->sockets->emit(
			'round closed',
			{
				event_question_id => $event_question_id,
				seconds_to_close  => $seconds,
			}
		);

		log_event(
			'round closed',
			{
				event_question_id => $event_question_id,
				seconds_to_close  => $seconds,
			}
		);

	}
}

sub calc_points {
	my $self              = shift;
	my $event_question_id = shift;
	my $cb                = shift;

	my $eq = QuizBowl::Core->schema->resultset('EventQuestion')->find($event_question_id);
	unless ( defined $eq ) {
		$cb->( { not_found => 1 } );
		return;
	}
	my $submissions_rs = $eq->submissions->search( { is_correct => 1, }, { order_by => 'time_to_answer' } );
	my $tiers = 5;
	while ( my $submission = $submissions_rs->next() ) {
		$submission->update( { points => $eq->question->points * $tiers } );
		$tiers-- if $tiers > 1;
	}
	$cb->( { success => 1, event_question_id => $event_question_id } );
}

sub submit_answer {
	my $self   = shift;
	my $answer = shift;

	# Get timestamp as early as possible
	my $dbh = QuizBowl::Core->schema->storage->dbh;
	my ( $now, $time_to_answer ) = $dbh->selectrow_array(
		'SELECT now(), EXTRACT(EPOCH FROM now() - (
			SELECT start_timestamp FROM event_question WHERE event_question_id = ? )
		)',
		undef, QuizBowl::SocketIO->event_question->id,
	);
	print STDERR "Answer submitted: $answer\n";
	$self->get(
		'user_id' => sub {
			my ( $self, $err, $user_id ) = @_;
			return unless $user_id && QuizBowl::SocketIO->users->{$user_id};

			# Store submission
			my $submission = QuizBowl::Core->schema->resultset('Submission')->update_or_create(
				{
					event_question_id => QuizBowl::SocketIO->event_question->id,
					create_user_id    => $user_id,
				}
			);
			my $is_correct = is_correct( QuizBowl::SocketIO->event_question->question->answer_value, $answer );
			my $start_time = QuizBowl::SocketIO->event_question->start_timestamp;
			$submission->update(
				{
					time_to_answer => $time_to_answer,
					answer         => $answer,
					is_correct     => $is_correct,
					points         => $is_correct ? QuizBowl::SocketIO->event_question->question->points : 0,
					create_date => $submission->create_date || $now,
					last_mod_date => $now,
				}
			);

			QuizBowl::SocketIO->users->{$user_id}->{answer} = $answer;
			$self->sockets->emit(
				'answer submitted',
				{
					user_id           => $user_id,
					users             => QuizBowl::SocketIO->users,
					event_question_id => QuizBowl::SocketIO->event_question->id,
				}
			);
			emit_user_list($self);
		}
	);
}

sub reveal_results {
	my $self              = shift;
	my $event_question_id = shift;
	my $cb                = shift;

	my $eq = QuizBowl::SocketIO->event->questions->search( { event_question_id => $event_question_id },
		{ prefetch => 'question' } )->first();

	unless ( defined $eq ) {
		$cb->( { not_found => 1 } );
		return;
	}

	my $submissions_rs = $eq->submissions->search(
		{},
		{
			prefetch => { create_user => 'team', },
			order_by => [ 'me.time_to_answer', { '-desc' => 'me.points' }, 'team.name' ],
		}
	);
	my @results;
	while ( my $submission = $submissions_rs->next() ) {
		push @results,
		  {
			name           => $submission->create_user->name,
			team           => defined $submission->create_user->team ? $submission->create_user->team->name : undef,
			answer         => $submission->answer,
			time_to_answer => $submission->time_to_answer,
			is_correct     => $submission->is_correct,
			points         => $submission->points,
		  };
	}

	$self->sockets->emit(
		'results revealed',
		{
			round_number => $eq->round_number,
			level_id     => $eq->question->level_id,
			question     => { $eq->question->get_columns },
			results      => \@results
		}
	);
}

sub disconnect {
	my $self = shift;
	$self->get(
		'user_id' => sub {
			my ( $self, $err, $user_id ) = @_;
			return unless $user_id;

			QuizBowl::SocketIO->users->{$user_id}->{connected}      = 0;
			QuizBowl::SocketIO->users->{$user_id}->{roll_call_ackd} = 0;
			$self->broadcast->emit( 'growl', QuizBowl::SocketIO->users->{$user_id}->{name} . ' disconnected' );
			emit_user_list($self);

			log_event(
				'disconncted',
				{
					user_id => $user_id,
					name    => QuizBowl::SocketIO->users->{$user_id}->{name},
				}
			);
		}
	);
}

sub is_correct {
	my $correct = shift;
	my $value   = shift;

	# trim
	$correct =~ s/(^\s+|\s+$)//g;
	$value   =~ s/(^\s+|\s+$)//g;

	# labels at the end
	$value =~ s/\D+$//;

	return $correct ~~ $value ? 1 : 0;
}

sub emit_user_list {
	my $io = shift;
	$io->sockets->emit( 'user list updated',
		{ users => QuizBowl::SocketIO->users, users_by_score => QuizBowl::SocketIO->users_by_score } );
}

sub log_event {
	my $type = shift;
	my $data = shift;
	QuizBowl::SocketIO->event->add_to_log_entries(
		{
			type => $type,
			data => $data,
		}
	);
}

1;

