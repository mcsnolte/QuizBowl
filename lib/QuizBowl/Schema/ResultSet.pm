package QuizBowl::Schema::ResultSet;

# ABSTRACT: Base ResultSet class

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head1 METHODS

=head2 create

Call new_result and then save

=cut

sub create {
	my $self   = shift;
	my $data_r = shift;

	my $new_row = $self->new_result( {} );
	$new_row->save($data_r);

	return $new_row;
}

=head1 UTILITY METHODS

=head2 _build_search

Base searching for L<Catalyst::TraitFor::Controller::DBIC::DoesPaging>.

=cut

sub _build_search {
	my $self           = shift;
	my $dispatch_table = shift;
	my $q              = shift;

	my %search = ();
	my %meta   = ();

	foreach ( keys %{$q} ) {
		if ( my $fn = $dispatch_table->{$_} and $q->{$_} ) {
			my ( $tmp_search, $tmp_meta ) = $fn->( $q->{$_} );
			%search = ( %search, %{ $tmp_search || {} } );
			%meta   = ( %meta,   %{ $tmp_meta   || {} } );
		}
	}

	return $self->search( \%search, \%meta );
}

=head2 _build_sort

Base sorting for L<Catalyst::TraitFor::Controller::DBIC::DoesPaging>.

=cut

sub _build_sort {
	my $self           = shift;
	my $dispatch_table = shift;
	my $default        = shift;
	my $q              = shift;

	my %search = ();
	my %meta   = ();

	my $direction = $q->{dir};
	my $sort      = $q->{sort};

	if ( my $fn = $dispatch_table->{$sort} ) {
		my ( $tmp_search, $tmp_meta ) = $fn->($direction);
		%search = ( %search, %{ $tmp_search || {} } );
		%meta   = ( %meta,   %{ $tmp_meta   || {} } );
	}
	elsif ( $sort && $direction ) {
		my ( $tmp_search, $tmp_meta ) = $default->( $sort, $direction );
		%search = ( %search, %{ $tmp_search || {} } );
		%meta   = ( %meta,   %{ $tmp_meta   || {} } );
	}

	return $self->search( \%search, \%meta );
}

1;
