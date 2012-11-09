package QuizBowl::Schema::Result::UserLogin;

# ABSTRACT: Set of Users

use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::Result';

__PACKAGE__->table('user_login');
__PACKAGE__->add_columns(
	user_login_id => {
		data_type         => 'int',
		is_auto_increment => 1,
	},
	login_ip   => { data_type => 'cidr' },
	session_id => { data_type => 'varchar', is_nullable => 1 },
	user_agent => { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->set_primary_key(qw{user_login_id});

__PACKAGE__->track_create;

1;

