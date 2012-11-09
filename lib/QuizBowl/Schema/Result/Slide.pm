package QuizBowl::Schema::Result::Slide;

# ABSTRACT: Slides

use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::Result';

__PACKAGE__->table('slide');

__PACKAGE__->add_columns(
	slide_id => {
		data_type         => 'int',
		is_auto_increment => 1,
	},
	name => {
		data_type   => 'citext',
		is_nullable => 0,
	},
	url => {
		data_type   => 'citext',
		is_nullable => 0,
	},
);

__PACKAGE__->set_primary_key('slide_id');

__PACKAGE__->track_create->track_last_mod;

__PACKAGE__->meta->make_immutable;

1;

