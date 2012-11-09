package QuizBowl::Schema::Result::Team;

# ABSTRACT: Teams

use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::Result';

__PACKAGE__->table('team');

__PACKAGE__->add_columns(
	team_id => {
		data_type         => 'int',
		is_auto_increment => 1,
	},
	school_id => {
		data_type   => 'int',
		is_nullable => 1,
	},
	name => {
		data_type   => 'citext',
		is_nullable => 0,
	},
	mascot => {
		data_type   => 'citext',
		is_nullable => 1,
	},
);

__PACKAGE__->set_primary_key('team_id');

__PACKAGE__->add_unique_constraint( unique_team => ['name'], );

__PACKAGE__->track_create->track_last_mod;

__PACKAGE__->belongs_to(
	'school' => 'QuizBowl::Schema::Result::School',
	'school_id',
	{ join_type => 'left' },
);

__PACKAGE__->has_many(
	'users' => 'QuizBowl::Schema::Result::User',
	{ 'foreign.team_id' => 'self.team_id' },
);

around 'REST_data' => sub {
	my $orig = shift;
	my $self = shift;

	my $data_r = $self->$orig(@_);
	$data_r->{'users'} = [ map { $_->REST_data } $self->users->all ];
	return $data_r;
};

__PACKAGE__->meta->make_immutable;

1;

