package QuizBowl::Web::Controller::REST;

# ABSTRACT: Base REST Controller

use utf8;
use Moose;
use namespace::autoclean;
BEGIN { extends 'Catalyst::Controller::REST' }
with 'Catalyst::TraitFor::Controller::DBIC::DoesPaging';
with 'Catalyst::TraitFor::Controller::DoesExtPaging';

use Try::Tiny;

__PACKAGE__->config(
	'stash_key'              => 'rest',
	'content_type_stash_key' => '_content_type_override',
	'default'                => 'application/json',
	'map'                    => {
		'text/html'                => 'YAML::HTML',
		'text/xml'                 => 'XML::Simple',
		'application/xml'          => 'XML::Simple',
		'text/x-yaml'              => 'YAML',
		'application/json'         => 'JSON',
		'text/x-json'              => 'JSON',
		'text/x-data-dumper'       => [ 'Data::Serializer', 'Data::Dumper' ],
		'text/x-data-denter'       => [ 'Data::Serializer', 'Data::Denter' ],
		'text/x-data-taxi'         => [ 'Data::Serializer', 'Data::Taxi' ],
		'application/x-storable'   => [ 'Data::Serializer', 'Storable' ],
		'application/x-freezethaw' => [ 'Data::Serializer', 'FreezeThaw' ],
		'text/x-config-general'    => [ 'Data::Serializer', 'Config::General' ],
		'text/x-php-serialization' => [ 'Data::Serializer', 'PHP::Serialization' ],
	},
);

=head2 ext_REST_data

=cut

sub ext_REST_data {
	my $self = shift;
	my $c    = shift;
	my $r    = shift;                  # either DBIC ResultSet or Row
	my $meth = shift // 'REST_data';

	my $data_r;
	try {
		if ( $r->isa('DBIx::Class::ResultSet') ) {
			my $searched_rs = $self->search( $c, $r );
			my $paginated_rs = $self->page_and_sort( $c, $searched_rs );
			$data_r = $self->ext_paginate( $paginated_rs, $meth );
		}
		elsif ( $r->isa('DBIx::Class::Row') ) {
			$data_r = { data => $r->$meth() };
		}
		$data_r->{'success'} = 1;
	}
	catch {
		$data_r = { data => { error => $_ }, success => 0, };
	};

	return $data_r;
}

1;
