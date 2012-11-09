package QuizBowl::Schema::Result::Question;

# ABSTRACT: Questions

use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::Result';

__PACKAGE__->table('question');

__PACKAGE__->add_columns(
	question_id => {
		data_type         => 'int',
		is_auto_increment => 1,
	},
	question => {
		data_type   => 'citext',
		is_nullable => 0,
	},
	options => {
		data_type        => 'text',
		is_nullable      => 1,
		serializer_class => 'JSON',
	},
	answer => {
		data_type   => 'citext',
		is_nullable => 1,
	},
	answer_value => {
		data_type   => 'citext',
		is_nullable => 1,
	},
	question_type_value => {
		data_type     => 'varchar',
		is_nullable   => 0,
		default_value => 'text',
	},
	explanation => {
		data_type   => 'citext',
		is_nullable => 1,
	},
	points => {
		data_type   => 'int',
		is_nullable => 1,
	},
	level_id => {
		data_type   => 'varchar',
		is_nullable => 1,
	},
);

__PACKAGE__->set_primary_key('question_id');

__PACKAGE__->track_create->track_last_mod;

__PACKAGE__->belongs_to(
	'question_type' => 'QuizBowl::Schema::Result::QuestionType',
	'question_type_value'
);

__PACKAGE__->meta->make_immutable;

1;

