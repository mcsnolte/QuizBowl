package QuizBowl::Schema::Result;

# ABSTRACT: Result base class

use Moose;
use MooseX::NonMoose;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components(
	qw/
	  UserStamp
	  TimeStamp
	  InflateColumn::DateTime
	  InflateColumn::Serializer
	  UUIDColumns
	  /
);

=head1 METHODS

=head2 REST_data

=cut

sub REST_data {
	my $self = shift;
	return { $self->get_columns() };
}

=head2 REST_minimal

=cut

sub REST_minimal {
	my $self = shift;
	return { $self->get_columns() };
}

=head2 save

=cut

sub save {
	my $self   = shift;
	my $data_r = shift;

	my $is_new = $self->in_storage ? 0 : 1;

	my %data =
	  map { $_ => $data_r->{$_} }    #
	  grep { exists $data_r->{$_} }  #
	  $self->result_source->columns;

	$self->set_columns( \%data );
	$self->update_or_insert();
	$self->discard_changes() if $is_new;

	return $self;
}

=head2 track_create

=cut

sub track_create {
	my $package = shift;

	$package->add_columns(
		create_user_id => {
			data_type            => 'int',
			store_user_on_create => 1,
		},
		create_date => {
			data_type     => 'timestamp with time zone',
			default_value => \'now()',
		},
	);
	$package->belongs_to(
		create_user => 'QuizBowl::Schema::Result::User',
		'create_user_id',
		{ add_fk_index => 1 }
	);
	return $package;
}

=head2 track_last_mod

=cut

sub track_last_mod {
	my $package = shift;
	$package->add_columns(
		last_mod_user_id => {
			data_type            => 'int',
			store_user_on_create => 1,
			store_user_on_update => 1,
		},
		last_mod_date => {
			data_type     => 'timestamp with time zone',
			default_value => \'now()',
			set_on_update => 1,
		},
	);
	$package->belongs_to(
		last_mod_user => 'QuizBowl::Schema::Result::User',
		'last_mod_user_id',
		{ add_fk_index => 1 }
	);
	return $package;
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

