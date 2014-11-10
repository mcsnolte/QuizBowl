package QuizBowl::Schema::ResultSet::Question;

# ABSTRACT: Set of Questions

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
			question => sub {
				return { "$me.question" => { -like => q{%} . shift(@_) . q{%} } }, {};
			},
			answer => sub {
				return { "$me.answer" => { -like => q{%} . shift(@_) . q{%} } }, {};
			},
			answer_value => sub {

				# exact
				return { "$me.answer_value" => { -like => shift(@_) } }, {};
			},
			question_type_value => sub {
				return { "$me.question_type_value" => { -like => q{%} . shift(@_) . q{%} } }, {};
			},
			explanation => sub {
				return { "$me.explanation" => { -like => q{%} . shift(@_) . q{%} } }, {};
			},
			points => sub {
				return { "$me.points" => shift }, {};
			},
			level_id => sub {
				return { "$me.level_id" => shift }, {};
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

