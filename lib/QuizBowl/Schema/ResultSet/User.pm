package QuizBowl::Schema::ResultSet::User;

# ABSTRACT: Set of Users

use utf8;
use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::ResultSet';

use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Email::Simple::Creator;
use UUID::Tiny ':std';

=head1 METHODS

=head2 password_help

=cut

sub password_help {
	my $self     = shift;
	my $base_uri = shift;
	my $address  = shift;

	my $user = $self->search( { email => $address }, { rows => 1 } )->single();
	die "Email not registered\n" unless defined $user;

	my $token = create_uuid_as_string(UUID_V4);
	$user->update( { password => $token } );

	my $uri = $base_uri->clone();
	$uri->query_form( { _k => $token } );

	my $email = Email::Simple->create(
		header => [
			To      => $user->email_with_name,
			From    => 'system@example.com',
			Subject => 'Quiz Bowl Password Help',
		],
		body => sprintf( 'Reset password %s', $uri->as_string() ),
	);

	sendmail($email);
}

sub reset_password {
	my $self = shift;
	my $fd_r = shift;

	die "Password is required\n" unless $fd_r->{password};

	my $user = $self->search( { password => $fd_r->{_k} }, { rows => 1 } )->single();
	die "User not found\n" unless defined $user;

	$user->set_password( $fd_r->{password} )->update();

	return $user;
}

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

