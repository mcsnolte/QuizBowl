package QuizBowl::Web::Controller::API::Team;

# ABSTRACT: Endpoints for Team

use utf8;
use Moose;
use namespace::autoclean;

BEGIN { extends 'QuizBowl::Web::Controller::REST'; }

use Try::Tiny;

=head1 ENDPOINTS

=cut

sub setup_base : Chained('/') PathPart('api/team') CaptureArgs(0) {
	my $self = shift;
	my $c    = shift;

	$c->stash->{'teams_rs'} = $c->model('DB::Team')->search( {}, { prefetch => { 'users' => 'school' } } );
}

=head2 /api/team/

=cut

sub base : Chained('setup_base') PathPart('') Args(0) ActionClass('REST') {
}

=head3 GET /api/team/

Fetch a list of teams.

=cut

sub base_GET : Private {
	my $self = shift;
	my $c    = shift;

	my $data_r = $self->ext_REST_data( $c, $c->stash->{'teams_rs'} );

	$self->status_ok( $c, entity => $data_r );
}

=head3 POST /api/team/

Create a new team.

=cut

sub base_POST {
	my $self = shift;
	my $c    = shift;

	try {
		my $team = $c->stash->{'teams_rs'}->create( $c->req->data );
		my $data_r = $self->ext_REST_data( $c, $team );

		$self->status_created(
			$c,
			location => $c->uri_for( $self->action_for('team'), [ $team->id ] ),
			entity => $data_r
		);
	}
	catch {
		$c->log->error($_);
		$self->status_bad_request( $c, message => 'Error creating the team' );
	};
}

sub setup_team : Chained('setup_base') PathPart('') CaptureArgs(1) {
	my $self    = shift;
	my $c       = shift;
	my $team_id = shift;

	if ( $team_id !~ m/^\d+$/ ) {
		$self->status_bad_request( $c, message => 'Team ID must be an integer' );
		$c->detach();
	}

	my $team = $c->stash->{'teams_rs'}->find($team_id);
	unless ( defined $team ) {
		$self->status_not_found( $c, message => 'Team not found' );
		$c->detach();
	}
	$c->stash->{'team'} = $team;
}

=head2 /api/team/:team_id

=cut

sub team : Chained('setup_team') PathPart('') Args(0) ActionClass('REST') {
}

=head3 GET /api/team/:team_id

Fetch a specific team.

=cut

sub team_GET {
	my $self = shift;
	my $c    = shift;

	my $data_r = $self->ext_REST_data( $c, $c->stash->{'team'} );

	$self->status_ok( $c, entity => $data_r );
}

=head3 PUT /api/team/:team_id

Update a specific team.

=cut

sub team_PUT {
	my $self = shift;
	my $c    = shift;

	try {
		my $data_r = $self->ext_REST_data( $c, $c->stash->{'team'}->save( $c->req->data ) );
		$self->status_ok( $c, entity => $data_r );
	}
	catch {
		$c->log->error($_);
		$self->status_bad_request( $c, message => 'Error saving the team' );
	};

}

__PACKAGE__->meta->make_immutable();

1;

1;

