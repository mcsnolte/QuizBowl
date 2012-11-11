package QuizBowl::Web::Controller::Root;

# ABSTRACT: Root Controller for QuizBowl::Web

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config( namespace => '' );

sub auto : Private() {
	my ( $self, $c ) = @_;

	# Allow override for content type
	$c->stash->{_content_type_override} = $c->req->param("_content_type");
	return 1;
}

sub index : Path : Args(0) {
	my ( $self, $c ) = @_;
}

sub login : Local {
	my ( $self, $c ) = @_;
	if (
		$c->req->param('email')
		&& $c->authenticate(
			{
				password   => $c->req->param('password'),
				dbix_class => { searchargs => [ { email => $c->req->param('email'), } ] },
			}
		)
	  )
	{
		my $login = $c->user->add_to_logins(
			{
				login_ip   => $c->req->address,
				session_id => $c->sessionid,
				user_agent => $c->req->user_agent,
			}
		);
		$c->res->redirect('/');
	}
	elsif ( $c->req->method eq 'POST' ) {
		$c->stash( { 'login_fail' => 1 } );
	}
}

sub logout : Local {
	my ( $self, $c ) = @_;
	$c->logout;
	$c->delete_session;
	$c->res->redirect('/');
}

sub player : Local : Args(0) {
	my ( $self, $c ) = @_;
	$c->res->redirect('/') unless $c->user_exists && !$c->user->is_admin;
}

sub presenter : Local {
	my ( $self, $c ) = @_;
}

sub admin : Local {
	my ( $self, $c ) = @_;
	$c->res->redirect('/') unless $c->user_exists && $c->user->is_admin;
}

sub question : Local {
       my ( $self, $c ) = @_;
       $c->res->redirect('/') unless $c->user_exists && $c->user->is_admin;
}

sub event : Local {
       my ( $self, $c ) = @_;
       $c->res->redirect('/') unless $c->user_exists && $c->user->is_admin;
}

sub bad_request : Private {
	my ( $self, $c ) = @_;
	$c->res->body('Bad request');
	$c->res->status('400');
}

sub access_denied : Private {
	my ( $self, $c ) = @_;
	$c->res->body('Access deined');
	$c->res->status('403');
}

sub default : Path {
	my ( $self, $c ) = @_;
	$c->response->body('Page not found');
	$c->response->status(404);
}

sub end : ActionClass('RenderView') {
}

__PACKAGE__->meta->make_immutable;

1;

