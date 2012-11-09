package QuizBowl::Web::Controller::API::Question;

# ABSTRACT: Endpoints for Question

use Moose;
use namespace::autoclean;

BEGIN { extends 'QuizBowl::Web::Controller::REST'; }

use Try::Tiny;

=head1 ENDPOINTS

=cut

sub setup_base : Chained('/') PathPart('api/question') CaptureArgs(0) {
	my $self = shift;
	my $c    = shift;

	$c->stash->{'questions_rs'} = $c->model('DB::Question');
}

=head2 /api/question/

=cut

sub base : Chained('setup_base') PathPart('') Args(0) ActionClass('REST') {
}

=head3 GET /api/question/

Fetch a list of questions.

=cut

sub base_GET : Private {
	my $self = shift;
	my $c    = shift;

	my $data_r = $self->ext_REST_data( $c, $c->stash->{'questions_rs'} );

	$self->status_ok( $c, entity => $data_r );
}

=head3 POST /api/question/

Create a new question.

=cut

sub base_POST {
	my $self = shift;
	my $c    = shift;

	try {
		my $question = $c->stash->{'questions_rs'}->create( $c->req->data );
		my $data_r = $self->ext_REST_data( $c, $question );

		$self->status_created(
			$c,
			location => $c->uri_for( $self->action_for('question'), [ $question->id ] ),
			entity   => $data_r
		);
	}
	catch {
		$c->log->error($_);
		$self->status_bad_request( $c, message => 'Error creating the question' );
	};
}

sub setup_question : Chained('setup_base') PathPart('') CaptureArgs(1) {
	my $self        = shift;
	my $c           = shift;
	my $question_id = shift;

	if ( $question_id !~ m/^\d+$/ ) {
		$self->status_bad_request( $c, message => 'Question ID must be an integer' );
		$c->detach();
	}

	my $question = $c->stash->{'questions_rs'}->find($question_id);
	unless ( defined $question ) {
		$self->status_not_found( $c, message => 'Question not found' );
		$c->detach();
	}
	$c->stash->{'question'} = $question;
}

=head2 /api/question/:question_id

=cut

sub question : Chained('setup_question') PathPart('') Args(0) ActionClass('REST') {
}

=head3 GET /api/question/:question_id

Fetch a specific question.

=cut

sub question_GET {
	my $self = shift;
	my $c    = shift;

	my $data_r = $self->ext_REST_data( $c, $c->stash->{'question'} );

	$self->status_ok( $c, entity => $data_r );
}

=head3 PUT /api/question/:question_id

Update a specific question.

=cut

sub question_PUT {
	my $self = shift;
	my $c    = shift;

	try {
		my $data_r = $self->ext_REST_data( $c, $c->stash->{'question'}->save( $c->req->data ) );
		$self->status_ok( $c, entity => $data_r );
	}
	catch {
		$c->log->error($_);
		$self->status_bad_request( $c, message => 'Error saving the question' );
	};

}

__PACKAGE__->meta->make_immutable();

1;

1;

