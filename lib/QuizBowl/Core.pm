package QuizBowl::Core;

# ABSTRACT: Singleton for accessing QuizBowl (Web) config


use Moose;
use MooseX::ClassAttribute;

use QuizBowl::Config;
use QuizBowl::Schema;

class_has 'config' => (
	isa        => 'HashRef',
	is         => 'ro',
	lazy_build => 1,
);

sub _build_config {
	return QuizBowl::Config->get;
}

class_has 'schema' => (
	isa        => 'QuizBowl::Schema',
	is         => 'ro',
	lazy_build => 1,
);

sub _build_schema {
	my $self = shift;
	return QuizBowl::Schema->auto_connect();
}

1;

