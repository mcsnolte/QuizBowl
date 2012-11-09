package QuizBowl::Web::Controller::API::User;

# ABSTRACT: Endpoints for User

use Moose;
use namespace::autoclean;

BEGIN { extends 'QuizBowl::Web::Controller::REST'; }

use Try::Tiny;

=head1 ENDPOINTS

=cut

sub setup_base : Chained('/') PathPart('api/user') CaptureArgs(0) {
	my $self = shift;
	my $c    = shift;

	$c->stash->{'users_rs'} = $c->model('DB::User')->search( {}, { prefetch => 'school' } );
}

=head2 /api/user/

=cut

sub base : Chained('setup_base') PathPart('') Args(0) ActionClass('REST') {
}

=head3 GET /api/user/

Fetch a list of users.

=cut

sub base_GET : Private {
	my $self = shift;
	my $c    = shift;

	my $data_r = $self->ext_REST_data( $c, $c->stash->{'users_rs'} );

	$self->status_ok( $c, entity => $data_r );
}

=head3 POST /api/user/

Create a new user.

=cut

sub base_POST {
	my $self = shift;
	my $c    = shift;

	try {
		my $user = $c->stash->{'users_rs'}->create( $c->req->data );
		my $data_r = $self->ext_REST_data( $c, $user );

		$self->status_created(
			$c,
			location => $c->uri_for( $self->action_for('user'), [ $user->id ] ),
			entity => $data_r
		);
	}
	catch {
		$c->log->error($_);
		$self->status_bad_request( $c, message => 'Error creating the user' );
	};
}

sub setup_user : Chained('setup_base') PathPart('') CaptureArgs(1) {
	my $self    = shift;
	my $c       = shift;
	my $user_id = shift;

	if ( $user_id !~ m/^\d+$/ ) {
		$self->status_bad_request( $c, message => 'User ID must be an integer' );
		$c->detach();
	}

	my $user = $c->stash->{'users_rs'}->find($user_id);
	unless ( defined $user ) {
		$self->status_not_found( $c, message => 'User not found' );
		$c->detach();
	}
	$c->stash->{'user'} = $user;
}

=head2 /api/user/:user_id

=cut

sub user : Chained('setup_user') PathPart('') Args(0) ActionClass('REST') {
}

=head3 GET /api/user/:user_id

Fetch a specific user.

=cut

sub user_GET {
	my $self = shift;
	my $c    = shift;

	my $data_r = $self->ext_REST_data( $c, $c->stash->{'user'} );

	$self->status_ok( $c, entity => $data_r );
}

=head3 PUT /api/user/:user_id

Update a specific user.

=cut

sub user_PUT {
	my $self = shift;
	my $c    = shift;

	try {
		my $data_r = $self->ext_REST_data( $c, $c->stash->{'user'}->save( $c->req->data ) );
		$self->status_ok( $c, entity => $data_r );
	}
	catch {
		$c->log->error($_);
		$self->status_bad_request( $c, message => 'Error saving the user' );
	};

}

__PACKAGE__->meta->make_immutable();

1;

