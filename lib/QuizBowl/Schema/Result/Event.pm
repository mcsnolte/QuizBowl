package QuizBowl::Schema::Result::Event;

# ABSTRACT: Events

use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::Result';

__PACKAGE__->table('event');

__PACKAGE__->add_columns(
	event_id => {
		data_type         => 'int',
		is_auto_increment => 1,
	},
	name => {
		data_type   => 'citext',
		is_nullable => 0,
	},
	start_time => {
		data_type   => 'timestamp with time zone',
		is_nullable => 0,
	},
	end_time => {
		data_type   => 'timestamp with time zone',
		is_nullable => 0,
	},
);

__PACKAGE__->set_primary_key('event_id');

__PACKAGE__->track_create->track_last_mod;

__PACKAGE__->has_many(
	log_entries => 'QuizBowl::Schema::Result::EventLog',
	{ 'foreign.event_id' => 'self.event_id', },
);

__PACKAGE__->has_many(
	questions => 'QuizBowl::Schema::Result::EventQuestion',
	{ 'foreign.event_id' => 'self.event_id', },
);

__PACKAGE__->has_many(
	registered_teams => 'QuizBowl::Schema::Result::EventTeam',
	{ 'foreign.event_id' => 'self.event_id', },
);

__PACKAGE__->many_to_many( teams => 'registered_teams', 'team' );

__PACKAGE__->has_many(
	registered_players => 'QuizBowl::Schema::Result::EventUser',
	{ 'foreign.event_id' => 'self.event_id', },
);

__PACKAGE__->many_to_many( players => 'registered_players', 'player' );

sub save_questions {
	my $self   = shift;
	my $data_r = shift;

	my $schema = $self->result_source->schema;

	my $questions_rs = $self->questions;
	my @questions = ref $data_r eq 'ARRAY' ? @{$data_r} : ($data_r);
	my @event_question_ids;
	$schema->txn_do(
		sub {
			foreach my $question_r (@questions) {
				my $question = $questions_rs->update_or_create($question_r);
				push @event_question_ids, $question->event_question_id;
			}
			$self->questions->search(
				{
					'me.event_question_id' => { '-not_in' => \@event_question_ids }    #
				}
			)->delete();
		}
	);
}

__PACKAGE__->meta->make_immutable;

1;

