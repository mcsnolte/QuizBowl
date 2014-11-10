package QuizBowl::Web::Controller::Preview;

# ABSTRACT: Preview controller

use utf8;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

sub question : Local Args(1) {
	my ( $self, $c, $question_id ) = @_;

	if ( $question_id !~ m/^\d+$/ ) {
		$c->detach('/bad_request');
	}

	$c->stash->{question} = $c->model('DB::Question')->find($question_id) or $c->detach('/default');
}

__PACKAGE__->meta->make_immutable;

1;

