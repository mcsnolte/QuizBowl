package QuizBowl::Web::Controller::API::School;

# ABSTRACT: Endpoints for School

use utf8;
use Moose;
use namespace::autoclean;

BEGIN { extends 'QuizBowl::Web::Controller::REST'; }

use Try::Tiny;

=head1 ENDPOINTS

=cut

sub setup_base : Chained('/') PathPart('api/school') CaptureArgs(0) {
	my $self = shift;
	my $c    = shift;

	$c->stash->{'schools_rs'} = $c->model('DB::School');
}

=head2 /api/school/

=cut

sub base : Chained('setup_base') PathPart('') Args(0) ActionClass('REST') {
}

=head3 GET /api/school/

Fetch a list of schools.

=cut

sub base_GET : Private {
	my $self = shift;
	my $c    = shift;

	my $data_r = $self->ext_REST_data( $c, $c->stash->{'schools_rs'} );

	$self->status_ok( $c, entity => $data_r );
}

=head3 POST /api/school/

Create a new school.

=cut

sub base_POST {
	my $self = shift;
	my $c    = shift;

	try {
		my $school = $c->stash->{'schools_rs'}->create( $c->req->data );
		my $data_r = $self->ext_REST_data( $c, $school );

		$self->status_created(
			$c,
			location => $c->uri_for( $self->action_for('school'), [ $school->id ] ),
			entity => $data_r
		);
	}
	catch {
		$c->log->error($_);
		$self->status_bad_request( $c, message => 'Error creating the school' );
	};
}

sub setup_school : Chained('setup_base') PathPart('') CaptureArgs(1) {
	my $self      = shift;
	my $c         = shift;
	my $school_id = shift;

	if ( $school_id !~ m/^\d+$/ ) {
		$self->status_bad_request( $c, message => 'School ID must be an integer' );
		$c->detach();
	}

	my $school = $c->stash->{'schools_rs'}->find($school_id);
	unless ( defined $school ) {
		$self->status_not_found( $c, message => 'School not found' );
		$c->detach();
	}
	$c->stash->{'school'} = $school;
}

=head2 /api/school/:school_id

=cut

sub school : Chained('setup_school') PathPart('') Args(0) ActionClass('REST') {
}

=head3 GET /api/school/:school_id

Fetch a specific school.

=cut

sub school_GET {
	my $self = shift;
	my $c    = shift;

	my $data_r = $self->ext_REST_data( $c, $c->stash->{'school'} );

	$self->status_ok( $c, entity => $data_r );
}

=head3 PUT /api/school/:school_id

Update a specific school.

=cut

sub school_PUT {
	my $self = shift;
	my $c    = shift;

	try {
		my $data_r = $self->ext_REST_data( $c, $c->stash->{'school'}->save( $c->req->data ) );
		$self->status_ok( $c, entity => $data_r );
	}
	catch {
		$c->log->error($_);
		$self->status_bad_request( $c, message => 'Error saving the school' );
	};

}

__PACKAGE__->meta->make_immutable();

1;

1;

