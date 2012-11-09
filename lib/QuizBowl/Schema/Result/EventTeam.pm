package QuizBowl::Schema::Result::EventTeam;

# ABSTRACT: Teams for Events

use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::Result';

__PACKAGE__->table('event_team');

__PACKAGE__->add_columns(
	event_id => {
		data_type   => 'int',
		is_nullable => 0,
	},
	team_id => {
		data_type   => 'int',
		is_nullable => 0,
	},
);

__PACKAGE__->set_primary_key(qw/event_id team_id/);

__PACKAGE__->track_create;

__PACKAGE__->belongs_to(
	'event' => 'QuizBowl::Schema::Result::Event',
	'event_id'
);

__PACKAGE__->belongs_to(
	'team' => 'QuizBowl::Schema::Result::Team',
	'team_id'
);

__PACKAGE__->has_many(
	players => 'QuizBowl::Schema::Result::User',
	{
		'foreign.team_id'  => 'self.team_id',
	},
);

__PACKAGE__->meta->make_immutable;

1;

