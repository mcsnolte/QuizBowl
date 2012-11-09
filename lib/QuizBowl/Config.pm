package QuizBowl::Config;

# ABSTRACT: Singleton for accessing QuizBowl (Web) config


use Moose;
use MooseX::ClassAttribute;
use Config::JFDI;

class_has 'config' => (
	isa        => 'HashRef',
	is         => 'ro',
	reader     => 'get',       # Sugar?
	lazy_build => 1,
);

sub _build_config {
	my $config = Config::JFDI->new( name => 'QuizBowl::Web' );
	return $config->get();
}

1;

