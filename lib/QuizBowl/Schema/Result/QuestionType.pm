package QuizBowl::Schema::Result::QuestionType;

# ABSTRACT: Types of Questions

use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::Result';

__PACKAGE__->table('question_type');

__PACKAGE__->add_columns(
	question_type_value => {
		data_type   => 'varchar',
		is_nullable => 0,
	},
	name => {
		data_type   => 'citext',
		is_nullable => 0,
	},
	description => {
		data_type   => 'text',
		is_nullable => 0,
	},
);

__PACKAGE__->set_primary_key('question_type_value');

__PACKAGE__->has_many(
	questions => 'QuizBowl::Schema::Result::Question',
	'question_type_value',
);

__PACKAGE__->meta->make_immutable;

1;

