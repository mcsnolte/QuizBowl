package QuizBowl::Schema::ResultSet::User;

# ABSTRACT: Set of Users

use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::ResultSet';

=head1 METHODS

=head2 find_by_session

=cut

sub find_by_session {
	my $self       = shift;
	my $session_id = shift;

	return $self->search(
		{ 'logins.session_id' => $session_id, },
		{
			join     => 'logins',
			order_by => { '-desc' => 'logins.create_date' }
		}
	)->first();
}

=head2 controller_search

Searching for L<Catalyst::TraitFor::Controller::DBIC::DoesPaging>.

=cut

sub controller_search {
	my $self   = shift;
	my $params = shift;

	my $me = $self->current_source_alias;

	return $self->_build_search(
		{
			first_name => sub {
				return { "$me.first_name" => { -like => q{%} . shift(@_) . q{%} } }, {};
			},
			last_name => sub {
				return { "$me.last_name" => { -like => q{%} . shift(@_) . q{%} } }, {};
			},
			email => sub {
				return { "$me.email" => { -like => q{%} . shift(@_) . q{%} } }, {};
			},
			is_admin => sub {
				return { "$me.is_admin" => ( shift(@_) ? 1 : 0 ) }, {};
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
		{
			first_name => sub {
				my $direction = shift;
				return {}, { order_by => { "-$direction" => [ "$me.first_name", "$me.last_name" ] }, };
			},
			last_name => sub {
				my $direction = shift;
				return {}, { order_by => { "-$direction" => [ "$me.last_name", "$me.first_name" ] }, };
			},
		},
		sub {
			my $param     = shift;
			my $direction = shift;
			return {}, { order_by => { "-$direction" => "$me.$param" }, };
		},
		$params
	);
}

1;

