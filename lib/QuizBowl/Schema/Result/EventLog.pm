package QuizBowl::Schema::Result::EventLog;

# ABSTRACT: Event Log

use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::Result';

__PACKAGE__->table('event_log');

__PACKAGE__->add_columns(
	event_log_id => {
		data_type         => 'int',
		is_auto_increment => 1,
	},
	event_id => {
		data_type   => 'int',
		is_nullable => 0,
	},
	type => {
		data_type   => 'citext',
		is_nullable => 0,
	},
	data => {
		data_type        => 'text',
		is_nullable      => 1,
		serializer_class => 'JSON',
	}
);

__PACKAGE__->set_primary_key('event_log_id');

__PACKAGE__->track_create;

__PACKAGE__->belongs_to(
	'event' => 'QuizBowl::Schema::Result::Event',
	'event_id'
);

__PACKAGE__->meta->make_immutable;

1;

