package QuizBowl::Schema::Result::EventUser;

# ABSTRACT: Users for Events

use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::Result';

__PACKAGE__->table('event_user');

__PACKAGE__->add_columns(
	event_id => {
		data_type   => 'int',
		is_nullable => 0,
	},
	user_id => {
		data_type   => 'int',
		is_nullable => 0,
	},
);

__PACKAGE__->set_primary_key(qw/event_id user_id/);

__PACKAGE__->track_create;

__PACKAGE__->belongs_to(
	'event' => 'QuizBowl::Schema::Result::Event',
	'event_id'
);

__PACKAGE__->belongs_to(
	'player' => 'QuizBowl::Schema::Result::User',
	'user_id'
);

__PACKAGE__->meta->make_immutable;

1;

