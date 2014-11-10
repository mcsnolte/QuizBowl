package QuizBowl::Web::Controller::API::Slide;

# ABSTRACT: Endpoints for Slide

use utf8;
use Moose;
use namespace::autoclean;

BEGIN { extends 'QuizBowl::Web::Controller::REST'; }

use Try::Tiny;

=head1 ENDPOINTS

=cut

sub setup_base : Chained('/') PathPart('api/slide') CaptureArgs(0) {
	my $self = shift;
	my $c    = shift;

	$c->stash->{'slides_rs'} = $c->model('DB::Slide');
}

=head2 /api/slide/

=cut

sub base : Chained('setup_base') PathPart('') Args(0) ActionClass('REST') {
}

=head3 GET /api/slide/

Fetch a list of slides.

=cut

sub base_GET : Private {
	my $self = shift;
	my $c    = shift;

	my $data_r = $self->ext_REST_data( $c, $c->stash->{'slides_rs'} );

	$self->status_ok( $c, entity => $data_r );
}

=head3 POST /api/slide/

Create a new slide.

=cut

sub base_POST {
	my $self = shift;
	my $c    = shift;

	try {
		my $slide = $c->stash->{'slides_rs'}->create( $c->req->data );
		my $data_r = $self->ext_REST_data( $c, $slide );

		$self->status_created(
			$c,
			location => $c->uri_for( $self->action_for('slide'), [ $slide->id ] ),
			entity => $data_r
		);
	}
	catch {
		$c->log->error($_);
		$self->status_bad_request( $c, message => 'Error creating the slide' );
	};
}

sub setup_slide : Chained('setup_base') PathPart('') CaptureArgs(1) {
	my $self     = shift;
	my $c        = shift;
	my $slide_id = shift;

	if ( $slide_id !~ m/^\d+$/ ) {
		$self->status_bad_request( $c, message => 'Slide ID must be an integer' );
		$c->detach();
	}

	my $slide = $c->stash->{'slides_rs'}->find($slide_id);
	unless ( defined $slide ) {
		$self->status_not_found( $c, message => 'Slide not found' );
		$c->detach();
	}
	$c->stash->{'slide'} = $slide;
}

=head2 /api/slide/:slide_id

=cut

sub slide : Chained('setup_slide') PathPart('') Args(0) ActionClass('REST') {
}

=head3 GET /api/slide/:slide_id

Fetch a specific slide.

=cut

sub slide_GET {
	my $self = shift;
	my $c    = shift;

	my $data_r = $self->ext_REST_data( $c, $c->stash->{'slide'} );

	$self->status_ok( $c, entity => $data_r );
}

=head3 PUT /api/slide/:slide_id

Update a specific slide.

=cut

sub slide_PUT {
	my $self = shift;
	my $c    = shift;

	try {
		my $data_r = $self->ext_REST_data( $c, $c->stash->{'slide'}->save( $c->req->data ) );
		$self->status_ok( $c, entity => $data_r );
	}
	catch {
		$c->log->error($_);
		$self->status_bad_request( $c, message => 'Error saving the slide' );
	};

}

__PACKAGE__->meta->make_immutable();

1;

1;

