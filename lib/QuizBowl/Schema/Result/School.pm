package QuizBowl::Schema::Result::School;

# ABSTRACT: Schools

use Moose;
use MooseX::NonMoose;
extends 'QuizBowl::Schema::Result';

__PACKAGE__->table('school');

__PACKAGE__->add_columns(
	school_id => {
		data_type         => 'int',
		is_auto_increment => 1,
	},
	name => {
		data_type   => 'citext',
		is_nullable => 0,
	},
	mascot => {
		data_type   => 'citext',
		is_nullable => 1,
	},
	nickname => {
		data_type   => 'citext',
		is_nullable => 1,
	},
	city => {
		data_type   => 'citext',
		is_nullable => 1,
	},
	state_abbrev => {
		data_type   => 'varchar',
		is_nullable => 1,
	}
);

__PACKAGE__->set_primary_key('school_id');

__PACKAGE__->add_unique_constraint( unique_school => ['name'], );

__PACKAGE__->track_create->track_last_mod;

__PACKAGE__->has_many(
	'teams' => 'QuizBowl::Schema::Result::Team',
	'school_id',
);

__PACKAGE__->meta->make_immutable;

1;

