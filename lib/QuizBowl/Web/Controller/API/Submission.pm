package QuizBowl::Web::Controller::API::Submission;

# ABSTRACT: Endpoints for Submission

use Moose;
use namespace::autoclean;

BEGIN { extends 'QuizBowl::Web::Controller::REST'; }

use Try::Tiny;

=head1 ENDPOINTS

=cut

sub setup_base : Chained('/') PathPart('api/submission') CaptureArgs(0) {
	my $self = shift;
	my $c    = shift;

	$c->stash->{'submissions_rs'} = $c->model('DB::Submission')->search(
		{},
		{
			prefetch => [
				{ event_question => 'question' },    #
				'create_user'
			],
		}
	);
}

=head2 /api/submission/

=cut

sub base : Chained('setup_base') PathPart('') Args(0) ActionClass('REST') {
}

=head3 GET /api/submission/

Fetch a list of submissions.

=cut

sub base_GET : Private {
	my $self = shift;
	my $c    = shift;

	my $data_r = $self->ext_REST_data( $c, $c->stash->{'submissions_rs'} );

	$self->status_ok( $c, entity => $data_r );
}

=head3 POST /api/submission/

Create a new submission.

=cut

sub base_POST {
	my $self = shift;
	my $c    = shift;

	try {
		my $submission = $c->stash->{'submissions_rs'}->create( $c->req->data );
		my $data_r = $self->ext_REST_data( $c, $submission, 'REST_minimal' );

		$self->status_created(
			$c,
			location => $c->uri_for( $self->action_for('submission'), [ $submission->id ] ),
			entity => $data_r
		);
	}
	catch {
		$c->log->error($_);
		$self->status_bad_request( $c, message => 'Error creating the submission' );
	};
}

sub setup_submission : Chained('setup_base') PathPart('') CaptureArgs(1) {
	my $self          = shift;
	my $c             = shift;
	my $submission_id = shift;

	if ( $submission_id !~ m/^\d+$/ ) {
		$self->status_bad_request( $c, message => 'Submission ID must be an integer' );
		$c->detach();
	}

	my $submission = $c->stash->{'submissions_rs'}->find($submission_id);
	unless ( defined $submission ) {
		$self->status_not_found( $c, message => 'Submission not found' );
		$c->detach();
	}
	$c->stash->{'submission'} = $submission;
}

=head2 /api/submission/:submission_id

=cut

sub submission : Chained('setup_submission') PathPart('') Args(0) ActionClass('REST') {
}

=head3 GET /api/submission/:submission_id

Fetch a specific submission.

=cut

sub submission_GET {
	my $self = shift;
	my $c    = shift;

	my $data_r = $self->ext_REST_data( $c, $c->stash->{'submission'} );

	$self->status_ok( $c, entity => $data_r );
}

=head3 PUT /api/submission/:submission_id

Update a specific submission.

=cut

sub submission_PUT {
	my $self = shift;
	my $c    = shift;

	try {
		my $data_r = $self->ext_REST_data( $c, $c->stash->{'submission'}->save( $c->req->data->{'data'} ) );
		$self->status_ok( $c, entity => $data_r );
	}
	catch {
		$c->log->error($_);
		$self->status_bad_request( $c, message => 'Error saving the submission' );
	};

}

__PACKAGE__->meta->make_immutable();

1;

1;

