package QuizBowl::Web;

# ABSTRACT: Quiz Bowl web server

use utf8;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
  -Debug
  ConfigLoader
  Static::Simple
  Session
  Session::State::Cookie
  Session::Store::DBIC
  Authentication
  /;

extends 'Catalyst';

# Configure the application.
#
# Note that settings in quizbowl_web.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
	name     => 'QuizBowl::Web',
	encoding => 'UTF-8',

	# Disable deprecated behavior needed by old applications
	disable_component_resolution_regex_fallback => 1,
	'Plugin::Session'                           => {
		dbic_class => 'DB::Session',
		expires    => 60 * 60 * 24 * 7 * 2,    # 2 weeks
		id_field   => 'session_id',
	},
	default_view => 'TT',
	'View::TT'   => { INCLUDE_PATH => __PACKAGE__->path_to('templates'), },
);

# Start the application
__PACKAGE__->setup();


1;

