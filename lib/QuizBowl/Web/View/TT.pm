package QuizBowl::Web::View::TT;

# ABSTRACT: TT View for QuizBowl::Web

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
	TEMPLATE_EXTENSION => '.tt',
	render_die         => 1,
);

1;

