package QuizBowl::Schema::Result::User;

# ABSTRACT: Users

use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::Result';

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

sub name {
	my $self = shift;
	return $self->first_name . ' ' . $self->last_name;
}

sub set_password {
	my $self     = shift;
	my $password = shift;

	my $pw = Crypt::SaltedHash->new( algorithm => 'SHA-1' );
	$pw->add($password);

	$self->password( $pw->generate );
}

around 'save' => sub {
	my $orig = shift;
	my $self = shift;

	my $password = delete $_[0]->{password};
	$self->$orig(@_);
	if ( $password && $password ne '**********' ) {
		$self->set_password($password);
		$self->update();
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

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

