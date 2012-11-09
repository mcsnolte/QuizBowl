package QuizBowl::Schema;

# ABSTRACT: DB schema for math quiz bowl

use Moose;
use MooseX::NonMoose;
extends 'DBIx::Class::Schema';

use QuizBowl::QueryProfiler;
use QuizBowl::Config;

has 'current_user_id' => (
	is         => 'rw',
	isa        => 'Int',
	lazy_build => 1,
);
sub _build_current_user_id { 0 }

sub auto_connect {
	my $class = shift;
	return $class->connect( QuizBowl::Config->get->{'Model::DB'}->{connect_info} );
}

sub connection {
	my $self     = shift;
	my $response = $self->next::method(@_);
	if ( $ENV{DBIC_TRACE} ) {
		$response->storage->auto_savepoint(1);
		$response->storage->debug(1);
		$response->storage->debugobj( QuizBowl::QueryProfiler->new );
	}
	return $response;
}

__PACKAGE__->load_namespaces;

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

