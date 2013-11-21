package QuizBowl::Web::Controller::Event;

# ABSTRACT: Controller for Events

use Moose;
use namespace::autoclean;

use Try::Tiny;

BEGIN { extends 'Catalyst::Controller' }

sub setup_base : Chained('/') PathPart('event') CaptureArgs(0) {
	my ( $self, $c ) = @_;

	$c->stash(
		{
			events_rs => $c->model('DB::Event')->search_rs(
				{
					#'me.create_user_id' => $c->user->id,
					#'me.start_time'     => { '>=' => \'current_date', },
				},    #
				{ order_by => [ 'me.start_time', 'me.create_date' ], }
			)
		}
	);
}

sub index : Chained('setup_base') PathPart('') Args(0) {
}

sub setup_event : Chained('setup_base') PathPart('') CaptureArgs(1) {
	my ( $self, $c, $event_id ) = @_;

	my $event = $c->stash->{events_rs}->find($event_id);

	$c->detach('/default') unless defined $event;

	$c->stash( { event => $event } );
}

sub run : Chained('setup_event') Args(0) {
	my ( $self, $c ) = @_;
}

sub edit : Chained('setup_event') Args(0) {
	my ( $self, $c ) = @_;
}

sub play : Chained('setup_event') Args(0) {
	my ( $self, $c ) = @_;
}

sub register : Chained('setup_event') Args(0) {
	my ( $self, $c ) = @_;
	$c->user->register_for( $c->stash->{event} );
	$c->res->redirect(
		$c->uri_for_action(
			'/event/index',    #
			{ registered => $c->stash->{event}->id }
		)
	);
}

sub watch : Chained('setup_event') Args(0) {
	my ( $self, $c ) = @_;
}

__PACKAGE__->meta->make_immutable;

1;

