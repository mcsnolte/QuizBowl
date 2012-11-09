package QuizBowl::Web::Controller::API::Event;

# ABSTRACT: Endpoints for Event

use Moose;
use namespace::autoclean;

BEGIN { extends 'QuizBowl::Web::Controller::REST'; }

use Try::Tiny;

=head1 ENDPOINTS

=cut

sub setup_base : Chained('/') PathPart('api/event') CaptureArgs(0) {
	my $self = shift;
	my $c    = shift;

	$c->stash->{'events_rs'} = $c->model('DB::Event');
}

=head2 /api/event/

=cut

sub base : Chained('setup_base') PathPart('') Args(0) ActionClass('REST') {
}

=head3 GET /api/event/

Fetch a list of events.

=cut

sub base_GET : Private {
	my $self = shift;
	my $c    = shift;

	my $data_r = $self->ext_REST_data( $c, $c->stash->{'events_rs'} );

	$self->status_ok( $c, entity => $data_r );
}

=head3 POST /api/event/

Create a new event.

=cut

sub base_POST {
	my $self = shift;
	my $c    = shift;

	try {
		my $event = $c->stash->{'events_rs'}->create( $c->req->data );
		my $data_r = $self->ext_REST_data( $c, $event );

		$self->status_created(
			$c,
			location => $c->req->uri,
			location => $c->uri_for( $self->action_for('event'), [ $event->id ] ),
			entity   => $data_r
		);
	}
	catch {
		$c->log->error($_);
		$self->status_bad_request( $c, message => 'Error creating the event' );
	};
}

sub setup_event : Chained('setup_base') PathPart('') CaptureArgs(1) {
	my $self     = shift;
	my $c        = shift;
	my $event_id = shift;

	if ( $event_id !~ m/^\d+$/ ) {
		$self->status_bad_request( $c, message => 'Event ID must be an integer' );
		$c->detach();
	}

	my $event = $c->stash->{'events_rs'}->find($event_id);
	unless ( defined $event ) {
		$self->status_not_found( $c, message => 'Event not found' );
		$c->detach();
	}
	$c->stash->{'event'} = $event;
}

=head2 /api/event/:event_id

=cut

sub event : Chained('setup_event') PathPart('') Args(0) ActionClass('REST') {
}

=head3 GET /api/event/:event_id

Fetch a specific event.

=cut

sub event_GET {
	my $self = shift;
	my $c    = shift;

	my $data_r = $self->ext_REST_data( $c, $c->stash->{'event'} );

	$self->status_ok( $c, entity => $data_r );
}

=head3 PUT /api/event/:event_id

Update a specific event.

=cut

sub event_PUT {
	my $self = shift;
	my $c    = shift;

	try {
		my $data_r = $self->ext_REST_data( $c, $c->stash->{'event'}->save( $c->req->data ) );
		$self->status_ok( $c, entity => $data_r );
	}
	catch {
		$c->log->error($_);
		$self->status_bad_request( $c, message => 'Error saving the event' );
	};

}

=head2 /api/event/:event_id/questions

=cut

sub event_questions : Chained('setup_event') PathPart('questions') Args(0) ActionClass('REST') {
	my $self = shift;
	my $c    = shift;
	$c->stash->{'event_questions_rs'} = $c->stash->{'event'}->questions->search( {}, { prefetch => 'question' } );
}

=head3 GET /api/event/:event_id/questions

Fetch questions for a specific event.

=cut

sub event_questions_GET {
	my $self = shift;
	my $c    = shift;

	my $data_r = $self->ext_REST_data( $c, $c->stash->{'event_questions_rs'} );

	$self->status_ok( $c, entity => $data_r );
}

=head3 PUT /api/event/:event_id/questions

Update questions for a specific event.

=cut

sub event_questions_PUT {
	my $self = shift;
	my $c    = shift;

	$c->stash->{'event'}->save_questions( $c->req->data );

	$self->event_questions_GET($c);
}

__PACKAGE__->meta->make_immutable();

1;

