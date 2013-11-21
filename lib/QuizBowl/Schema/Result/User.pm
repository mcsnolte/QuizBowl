package QuizBowl::Schema::Result::User;

# ABSTRACT: Users

use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::Result';

use Try::Tiny;
use Crypt::SaltedHash;

__PACKAGE__->table('user_account');

__PACKAGE__->add_columns(
	user_id => {
		data_type         => 'int',
		is_auto_increment => 1,
	},
	team_id => {
		data_type   => 'int',
		is_nullable => 1,
	},
	school_id => {
		data_type   => 'int',
		is_nullable => 1,
	},
	email => {
		data_type   => 'citext',
		is_nullable => 0,
	},
	first_name => {
		data_type   => 'citext',
		is_nullable => 0,
	},
	last_name => {
		data_type   => 'citext',
		is_nullable => 0,
	},
	password => {
		data_type   => 'varchar',
		is_nullable => 1,
	},
	is_admin => {
		data_type     => 'boolean',
		is_nullable   => 0,
		default_value => 0,
	},
);

__PACKAGE__->set_primary_key('user_id');

__PACKAGE__->add_unique_constraint( unique_email => ['email'], );

__PACKAGE__->track_create->track_last_mod;

__PACKAGE__->belongs_to(
	'team' => 'QuizBowl::Schema::Result::Team',
	'team_id',
	{ join_type => 'left' },
);

__PACKAGE__->belongs_to(
	'school' => 'QuizBowl::Schema::Result::School',
	'school_id',
	{ join_type => 'left' },
);

__PACKAGE__->has_many(
	logins => 'QuizBowl::Schema::Result::UserLogin',
	'create_user_id',
);

__PACKAGE__->has_many(
	submissions => 'QuizBowl::Schema::Result::Submission',
	'create_user_id',
);

__PACKAGE__->has_many(
	event_registrations => 'QuizBowl::Schema::Result::EventUser',
	'user_id',
);

__PACKAGE__->many_to_many(
	registered_events => 'event_registrations',
	'player',
);

sub name {
	my $self = shift;
	return $self->first_name . ' ' . $self->last_name;
}

sub email_with_name {
	my $self = shift;
	return sprintf( '"%s" <%s>', $self->name, $self->email );
}

sub set_password {
	my $self     = shift;
	my $password = shift;

	my $pw = Crypt::SaltedHash->new( algorithm => 'SHA-1' );
	$pw->add($password);

	$self->password( $pw->generate );

	return $self;
}

around 'save' => sub {
	my $orig = shift;
	my $self = shift;
	my $fd_r = shift;

	die "First name is required\n" unless $fd_r->{first_name};
	die "Last name is required\n"  unless $fd_r->{last_name};
	die "Email is required\n"      unless $fd_r->{email};
	die "Password is required\n"   unless $fd_r->{password};

	my $password = delete $fd_r->{password};

	try {
		$self->$orig($fd_r);
	}
	catch {
		if ( $_ =~ m/duplicate key value violates unique constraint "unique_email"/ ) {
			die "That email address is already taken\n";
		}
	};
	if ( $password && $password ne '**********' ) {
		$self->set_password($password);
		$self->update_or_insert();
	}
	return $self;
};

around 'REST_data' => sub {
	my $orig = shift;
	my $self = shift;

	my $data_r = $self->$orig(@_);
	$data_r->{'name'}     = $self->name();
	$data_r->{'password'} = '**********';
	$data_r->{'school'}   = $self->school ? $self->school->REST_data() : {};
	return $data_r;
};

sub is_player_for {
	my $self = shift;
	my $event_id = shift // 0;

	return $self->event_registrations->search( { 'me.event_id' => $event_id } )->count() > 0;
}

sub register_for {
	my $self  = shift;
	my $event = shift;

	die('Event does not exist') unless defined $event;

	my $registration = $self->event_registrations->find_or_create( { 'me.event_id' => $event->id, } );
	return $registration;
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

