package QuizBowl::Schema::ResultSet::Event;

# ABSTRACT: Set of Events

use utf8;
use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::ResultSet';

=head1 METHODS

=head2 controller_search

Searching for L<Catalyst::TraitFor::Controller::DBIC::DoesPaging>.

=cut

sub controller_search {
	my $self   = shift;
	my $params = shift;

	my $me = $self->current_source_alias;

	return $self->_build_search(
		{
			name => sub {
				return { "$me.event" => { -like => q{%} . shift(@_) . q{%} } }, {};
			},
		},
		$params
	);
}

=head2 controller_sort

Sorting for L<Catalyst::TraitFor::Controller::DBIC::DoesPaging>.

=cut

sub controller_sort {
	my $self   = shift;
	my $params = shift;

	my $me = $self->current_source_alias;

	unless ( $params->{dir} && $params->{sort} ) {
		$params->{dir}  = 'desc';
		$params->{sort} = 'create_date';
	}

	return $self->_build_sort(
		{},
		sub {
			my $param     = shift;
			my $direction = shift;
			return {}, { order_by => { "-$direction" => "$me.$param" }, };
		},
		$params
	);
}

1;

