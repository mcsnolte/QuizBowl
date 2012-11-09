package QuizBowl::Schema::Result::Submission;

# ABSTRACT: User Submissions

use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::Result';

__PACKAGE__->table('submission');

__PACKAGE__->add_columns(
	submission_id => {
		data_type         => 'int',
		is_auto_increment => 1,
	},
	event_question_id => {
		data_type   => 'int',
		is_nullable => 0,
	},
	answer => {
		data_type   => 'citext',
		is_nullable => 1,
	},
	time_to_answer => {
		data_type     => 'numeric',
		is_nullable   => 0,
		default_value => 0,
	},
	is_correct => {
		data_type   => 'boolean',
		is_nullable => 1,
	},
	points => {
		data_type   => 'int',
		is_nullable => 1,
	},

	#	replacement_submission_id => {
	#		data_type   => 'int',
	#		is_nullable => 1,
	#	},
);

__PACKAGE__->set_primary_key('submission_id');

__PACKAGE__->track_create->track_last_mod;

__PACKAGE__->belongs_to(
	'event_question' => 'QuizBowl::Schema::Result::EventQuestion',
	'event_question_id'
);

#
#__PACKAGE__->belongs_to(
#	'replacement' => 'QuizBowl::Schema::Result::Submission',
#	'replacement_submission_id'
#);

around 'REST_data' => sub {
	my $orig = shift;
	my $self = shift;

	my $data_r = $self->$orig(@_);
	$data_r->{'event_question'}               = $self->event_question->REST_data();
	$data_r->{'event_question'}->{'question'} = $self->event_question->question->REST_data();
	$data_r->{'create_user'}                  = $self->create_user->REST_data();
	return $data_r;
};

__PACKAGE__->meta->make_immutable;

1;

