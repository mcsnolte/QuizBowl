package QuizBowl::Schema::Result::Session;

# ABSTRACT: Users

use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::Result';

__PACKAGE__->table('session');

__PACKAGE__->add_columns(
	session_id   => { data_type => 'varchar', },
	session_data => {
		data_type   => 'text',
		is_nullable => 1,
	},
	expires => {
		data_type   => 'int',
		is_nullable => 1,
	},
);

__PACKAGE__->set_primary_key('session_id');

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

