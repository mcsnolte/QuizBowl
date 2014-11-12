#!/usr/bin/env perl

use utf8;
use lib "lib";
use QuizBowl::Web;
use QuizBowl::SocketIO;

use PocketIO;

use JSON;
use Plack::Builder;
use Plack::App::File;
use Plack::Middleware::Static;
use Dir::Self;

my $root = __DIR__ . '/root';

builder {
	mount '/' => builder {
		enable "Static",
		  path => qr/\.(?:js|css|jpe?g|gif|png|html?|swf|ico)$/,
		  root => "$root";

		enable "SimpleLogger", level => 'debug';

		QuizBowl::Web->psgi_app(@_);
	};

	mount '/socket.io/socket.io.js' => Plack::App::File->new( file => "$root/static/js/socket.io.js" )->to_app();

	mount '/socket.io/static/flashsocket/WebSocketMain.swf' =>
	  Plack::App::File->new( file => "$root/swf/WebSocketMain.swf" );

	mount '/socket.io/static/flashsocket/WebSocketMainInsecure.swf' =>
	  Plack::App::File->new( file => "$root/swf/WebSocketMainInsecure.swf" );

	mount '/socket.io' => builder {
		PocketIO->new(
			instance => QuizBowl::SocketIO->new(),

			# Can add socketio options here
			# socketio => { heartbeat_timeout => 5 },
		);
	};
};
