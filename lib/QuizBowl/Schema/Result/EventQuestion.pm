package QuizBowl::Schema::Result::EventQuestion;

# ABSTRACT: Questions for Events

use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::Result';

__PACKAGE__->table('event_question');

__PACKAGE__->add_columns(
	event_question_id => {
		data_type         => 'int',
		is_auto_increment => 1,
	},
	event_id => {
		data_type   => 'int',
		is_nullable => 0,
	},
	question_id => {
		data_type   => 'int',
		is_nullable => 0,
	},
	round_number => {
		data_type   => 'int',
		is_nullable => 0,
	},
	sequence => {
		data_type   => 'int',
		is_nullable => 0,
	},
	start_timestamp => {
		data_type   => 'timestamp with time zone',
		is_nullable => 1,
	},
	close_timestamp => {
		data_type   => 'timestamp with time zone',
		is_nullable => 1,
	},
);

__PACKAGE__->set_primary_key('event_question_id');

__PACKAGE__->track_create;

__PACKAGE__->belongs_to(
	'event' => 'QuizBowl::Schema::Result::Event',
	'event_id'
);

__PACKAGE__->belongs_to(
	'question' => 'QuizBowl::Schema::Result::Question',
	'question_id'
);

__PACKAGE__->has_many(
	'submissions' => 'QuizBowl::Schema::Result::Submission',
	'event_question_id'
);

around 'REST_data' => sub {
	my $orig = shift;
	my $self = shift;

	my $data_r = $self->$orig(@_);
	$data_r->{'question'} = $self->question->REST_data();
	return $data_r;
};

__PACKAGE__->meta->make_immutable;

1;

