package QuizBowl::SocketIO;

# ABSTRACT: SocketIO app

use utf8;
use Moose;
use MooseX::ClassAttribute;

use QuizBowl::Core;
use JSON;
use Gravatar::URL;

class_has 'events' => (
	is      => 'rw',
	isa     => 'HashRef',
	default => sub {
		return {};

		#{
		#    event          => $_,
		#    users          => {},
		#    users_by_score => [],
		#    event_question => undef,
		#};
	}
);

sub _prep_event {
	my $event = shift;

	if ( $event && !$event->isa('DBIx::Class::Row') && ref $event eq '' ) {
		$event = QuizBowl::Core->schema->resultset('Event')->find($event);
	}
	warn('Cannot find event') unless defined $event;

	my $event_r = {
		event          => $event,
		users          => _build_users($event),
		users_by_score => _set_scores($event),
		event_question => _build_event_question($event),
	};
	QuizBowl::SocketIO->events->{ $event->id } = $event_r;
	return $event_r;
}

sub _set_scores {
	my $event = shift;
	my @users;

	my @user_scores = $event->questions->search(
		{ 'submissions.create_user_id' => { '!=' => undef }, },
		{
			columns => [
				{ 'user_id' => 'submissions.create_user_id' },    #
				{ 'score' => { sum => 'submissions.points' } }
			],
			join         => 'submissions',
			group_by     => 1,
			result_class => 'DBIx::Class::ResultClass::HashRefInflator',
		}
	)->all();
	my %scores_for_user = map { $_->{user_id} => $_->{score} } @user_scores;

	my @players = $event->registered_players->search(
		{},
		{
			columns => [

				# TODO: rid team
				{ team    => 'player.first_name' },    #
				{ user_id => 'player.user_id' }
			],
			join         => ['player'],
			order_by     => 1,
			result_class => 'DBIx::Class::ResultClass::HashRefInflator',
		}
	)->all();

	foreach my $user (
		sort {
			( $scores_for_user{ $b->{user_id} } || 0 ) <=> ( $scores_for_user{ $a->{user_id} } || 0 )    #
			  || $a->{team} cmp $b->{team}
		} @players
	  )
	{
		push @users, $user->{user_id};
		QuizBowl::SocketIO->events->{ $event->id }->{users}->{ $user->{'user_id'} }->{score} =
		  $scores_for_user{ $user->{user_id} } // 0;
	}
	return \@users;
}

# Set to last started, but not yet closed, question (if any)
sub _build_event_question {
	my $event = shift;

	$event->questions->search(
		{
			start_timestamp => { '!=' => undef },
			close_timestamp => undef,
		},
		{ order_by => { '-desc' => 'start_timestamp' }, }
	)->first();
}

sub _build_users {
	my $event = shift;

	return {} unless defined $event;

	my $players_rs = $event->players;
	my %users;
	while ( my $user = $players_rs->next() ) {
		$users{ $user->id } = {
			name           => $user->name,
			session_id     => undef,
			connected      => 0,
			roll_call_ackd => 0,
			is_admin       => 0,
			answer         => '',
			score          => 0,
			gravatar_url   => gravatar_url( email => $user->email, size => 40 ),
		};
	}
	return \%users;
}

sub run {
	my $self = shift;

	# Initial setup
	_prep_event($_) for QuizBowl::Core->schema->resultset('Event')->all();

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
		$self->on( 'reset question'    => \&reset_question );
		$self->on( 'disconnect'        => \&disconnect );
		$self->on( 'ping'              => \&ping );
	};
}

# IM Chat
sub user_message {
	my $self    = shift;
	my $message = shift;
	$self->get(
		'event_id' => sub {
			my ( $self, $err, $event_id ) = @_;
			$self->get(
				'name' => sub {
					my ( $self, $err, $name ) = @_;
					$self->broadcast->to($event_id)->emit( 'user message', $name, $message );
				}
			);
		}
	);

}

# Auth users/presenters
sub register {
	my $self = shift;
	my ( $session_id, $event_id, $cb ) = @_;

	unless ($event_id) {
		warn('event_id required');
		$cb->( { success => 0 } );
		return;
	}

	my $event_r = QuizBowl::SocketIO->events->{$event_id} // _prep_event($event_id);
	my $event = $event_r->{event};
	if ( !defined $event ) {
		$cb->( { success => 0 } );
		return;
	}

	$self->set( event_id => $event->id, );

	if ( $session_id eq 'presenter' ) {
		$self->join( $event->id );
		$cb->( { success => 1 } );
	}
	elsif ( my $user = QuizBowl::Core->schema->resultset('User')->find_by_session($session_id) ) {
		$self->set( user_id => $user->id, );
		$self->set( name    => $user->name, );
		$self->join( $event->id );
		my $event_r = QuizBowl::SocketIO->events->{ $event->id };
		unless ( $event_r->{users}->{ $user->id } ) {
			_prep_event($event);
		}
		$event_r->{users}->{ $user->id } = {
			%{ $event_r->{users}->{ $user->id } // {} },
			name           => $user->name,
			session_id     => $session_id,
			connected      => 1,
			roll_call_ackd => 0,
			is_admin       => $user->is_admin,
		};

		# in progress?
		my %round_info = ( round_started => 0 );
		my $eq = $event_r->{event_question};
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
		$self->broadcast->to( $event->id )->emit( 'growl', $user->name . ' connected' );
	}
	else {
		$cb->( { success => 0 } );
	}

	#_set_scores($event);
	emit_user_list($self);
}

sub request_roll_call {
	my $self = shift;
	$self->get(
		'event_id' => sub {
			my ( $self, $err, $event_id ) = @_;
			return unless $event_id;

			my $event_r = QuizBowl::SocketIO->events->{$event_id};
			my $event   = $event_r->{event};
			return unless $event;

			my $users_r = $event_r->{users};
			foreach my $user_id ( keys %{$users_r} ) {
				$users_r->{$user_id}->{roll_call_ackd} = 0;
			}

			_set_scores($event);
			emit_user_list($self);
			$self->sockets->in($event_id)->emit('roll call requested');
		}
	);
}

sub ack_roll_call {
	my $self = shift;
	$self->get(
		'event_id' => sub {
			my ( $self, $err, $event_id ) = @_;
			$self->get(
				'user_id' => sub {
					my ( $self, $err, $user_id ) = @_;
					print STDERR "$user_id is ack'ing roll call\n";
					my $users_r = QuizBowl::SocketIO->events->{$event_id}->{users};
					return unless $user_id && $users_r->{$user_id};
					$users_r->{$user_id}->{roll_call_ackd} = 1;
					emit_user_list($self);
					$self->broadcast->to($event_id)
					  ->emit( 'growl', sprintf( '%s is ready!', $users_r->{$user_id}->{name} ) );
				}
			);
		}
	);
}

sub start_round {
	my $self              = shift;
	my $event_question_id = shift;
	my $cb                = shift;

	$self->get(
		'event_id' => sub {
			my ( $self, $err, $event_id ) = @_;

			my $event = QuizBowl::SocketIO->events->{$event_id}->{event};

			my $eq =
			  $event->questions->search( { event_question_id => $event_question_id }, { prefetch => 'question' } )
			  ->first();

			unless ( defined $eq ) {
				$cb->( { not_found => 1 } );
				return;
			}

			# Close any other started questions, only want one at a time
			$event->questions->search(
				{
					event_question_id => { '!=' => $event_question_id },
					start_timestamp   => { '!=' => undef },
					close_timestamp   => undef,
				}
			)->update( { close_timestamp => \'now()' } );

			log_event( $self, 'round started', { event_question_id => $event_question_id, } );

			my $users_r = QuizBowl::SocketIO->events->{$event_id}->{users};
			foreach my $user_id ( keys %{$users_r} ) {
				$users_r->{$user_id}->{answer} = '';
			}

			$eq->update(
				{
					start_timestamp => \'now()',
					close_timestamp => undef,
				}
			);
			$eq->discard_changes();
			QuizBowl::SocketIO->events->{$event_id}->{event_question} = $eq;

			$self->sockets->in($event_id)->emit(
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
	);
}

sub close_round {
	my $self   = shift;
	my $data_r = shift;

	$self->get(
		'event_id' => sub {
			my ( $self, $err, $event_id ) = @_;
			my $event_question_id = $data_r->{event_question_id};
			unless ($event_question_id) {
				warn('event_question_id is required');
				return;
			}
			my $seconds = $data_r->{seconds_to_close} || 0;

			if ($seconds) {
				$self->broadcast->to($event_id)->emit( 'growl', sprintf( 'Round will close in %i seconds', $seconds ) );
			}
			else {
				my $event = QuizBowl::SocketIO->events->{$event_id}->{event};
				my $q     = $event->questions->find($event_question_id);
				$q->update( { close_timestamp => \'now()', } ) if defined $q;
				$self->sockets->in($event_id)->emit(
					'round closed',
					{
						event_question_id => $event_question_id,
						seconds_to_close  => $seconds,
					}
				);

				log_event(
					$self,
					'round closed',
					{
						event_question_id => $event_question_id,
						seconds_to_close  => $seconds,
					}
				);

			}
		}
	);
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

	$self->get(
		'event_id' => sub {
			my ( $self, $err, $event_id ) = @_;

			my $event_r = QuizBowl::SocketIO->events->{$event_id};
			my $event   = $event_r->{event};
			my $eq      = $event_r->{event_question};

			# Get timestamp as early as possible
			my $dbh = QuizBowl::Core->schema->storage->dbh;
			my ( $now, $time_to_answer ) = $dbh->selectrow_array(
				'SELECT now(), EXTRACT(EPOCH FROM now() - (
			SELECT start_timestamp FROM event_question WHERE event_question_id = ? )
		)',
				undef, $eq->id,
			);
			print STDERR "Answer submitted: $answer\n";
			$self->get(
				'user_id' => sub {
					my ( $self, $err, $user_id ) = @_;
					return unless $user_id && $event_r->{users}->{$user_id};

					# Store submission
					my $submission = QuizBowl::Core->schema->resultset('Submission')->update_or_create(
						{
							event_question_id => $eq->id,
							create_user_id    => $user_id,
						}
					);

					my $is_correct = is_correct( $eq->question->answer_value, $answer );

					#my $start_time = QuizBowl::SocketIO->event_question->start_timestamp;
					$submission->update(
						{
							time_to_answer => $time_to_answer,
							answer         => $answer,
							is_correct     => $is_correct,
							points         => $is_correct ? $event_r->{event_question}->question->points : 0,
							create_date => $submission->create_date || $now,
							last_mod_date => $now,
						}
					);

					$event_r->{users}->{$user_id}->{answer} = $answer;
					$self->sockets->in($event_id)->emit(
						'answer submitted',
						{
							user_id           => $user_id,
							users             => $event_r->{users},
							event_question_id => $eq->id,
						}
					);
					emit_user_list($self);
				}
			);
		}
	);
}

sub reveal_results {
	my $self              = shift;
	my $event_question_id = shift;
	my $cb                = shift;

	$self->get(
		'event_id' => sub {
			my ( $self, $err, $event_id ) = @_;

			my $event_r = QuizBowl::SocketIO->events->{$event_id};
			my $event   = $event_r->{event};

			my $eq =
			  $event->questions->search( { event_question_id => $event_question_id }, { prefetch => 'question' } )
			  ->first();

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
					name   => $submission->create_user->name,
					team   => defined $submission->create_user->team ? $submission->create_user->team->name : undef,
					answer => $submission->answer,
					time_to_answer => $submission->time_to_answer,
					is_correct     => $submission->is_correct,
					points         => $submission->points,
					gravatar_url   => gravatar_url( email => $submission->create_user->email, size => 40 ),
				  };
			}

			$self->sockets->in($event_id)->emit(
				'results revealed',
				{
					round_number => $eq->round_number,
					level_id     => $eq->question->level_id,
					question     => { $eq->question->get_columns },
					results      => \@results
				}
			);
		}
	);
}

sub reset_question {
	my $self              = shift;
	my $event_question_id = shift;
	my $cb                = shift;

	$self->get(
		'event_id' => sub {
			my ( $self, $err, $event_id ) = @_;

			my $event_r = QuizBowl::SocketIO->events->{$event_id};
			my $event   = $event_r->{event};
			my $eq      = $event->questions->search( { event_question_id => $event_question_id } )->first();

			unless ( defined $eq ) {
				$cb->( { not_found => 1 } );
				return;
			}

			$eq->update(
				{
					start_timestamp => undef,
					close_timestamp => undef,
				}
			);

			$eq->submissions->delete();

			_set_scores($event);
			emit_user_list($self);

			$cb->( { success => 1, } );
		}
	);
}

sub disconnect {
	my $self = shift;
	$self->get(
		'event_id' => sub {
			my ( $self, $err, $event_id ) = @_;
			return unless $event_id;
			$self->get(
				'user_id' => sub {
					my ( $self, $err, $user_id ) = @_;
					return unless $user_id;

					my $users_r = QuizBowl::SocketIO->events->{$event_id}->{users};
					$users_r->{$user_id}->{connected}      = 0;
					$users_r->{$user_id}->{roll_call_ackd} = 0;
					$self->broadcast->to($event_id)->emit( 'growl', $users_r->{$user_id}->{name}||'Someone' . ' disconnected' );
					emit_user_list($self);

					log_event(
						$self,
						'disconnected',
						{
							user_id => $user_id,
							name    => $users_r->{$user_id}->{name},
						}
					);
				}
			);
		}
	);
}

sub ping {
	my $self = shift;
	my $msg  = shift;
	my $cb   = shift;

	$cb->( { success => 1, } );
}

sub is_correct {
	my $correct = shift;
	my $value   = shift;

	# trim
	$correct =~ s/(^\s+|\s+$)//g;
	$value =~ s/(^\s+|\s+$)//g;

	# labels at the end
	$value =~ s/\D+$//;

	return $correct ~~ $value ? 1 : 0;
}

sub emit_user_list {
	my $io = shift;

	$io->get(
		'event_id' => sub {
			my ( $self, $err, $event_id ) = @_;
			return unless $event_id;
			$io->sockets->in($event_id)->emit(
				'user list updated',
				{
					map { $_ => QuizBowl::SocketIO->events->{$event_id}->{$_} }    #
					  (qw/users users_by_score/)
				}
			);
		}
	);
}

sub log_event {
	my $io   = shift;
	my $type = shift;
	my $data = shift;

	$io->get(
		'event_id' => sub {
			my ( $self, $err, $event_id ) = @_;
			return unless $event_id;
			my $event = QuizBowl::SocketIO->events->{$event_id}->{event};
			return unless $event;
			$event->add_to_log_entries(
				{
					type => $type,
					data => $data,
				}
			);
		}
	);
}

1;

