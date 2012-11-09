#!/usr/bin/env perl

# PODNAME: quizbowl_web_server.pl
# ABSTRACT: Catalyst Test Server

BEGIN {
    $ENV{CATALYST_SCRIPT_GEN} = 40;
}

use Catalyst::ScriptRunner;
Catalyst::ScriptRunner->run('QuizBowl::Web', 'Server');

1;



__END__
=pod

=head1 NAME

quizbowl_web_server.pl - Catalyst Test Server

=head1 VERSION

version 0.001

=head1 SYNOPSIS

quizbowl_web_server.pl [options]

   -d --debug           force debug mode
   -f --fork            handle each request in a new process
                        (defaults to false)
   -? --help            display this help and exits
   -h --host            host (defaults to all)
   -p --port            port (defaults to 3000)
   -k --keepalive       enable keep-alive connections
   -r --restart         restart when files get modified
                        (defaults to false)
   -rd --restart_delay  delay between file checks
                        (ignored if you have Linux::Inotify2 installed)
   -rr --restart_regex  regex match files that trigger
                        a restart when modified
                        (defaults to '\.yml$|\.yaml$|\.conf|\.pm$')
   --restart_directory  the directory to search for
                        modified files, can be set multiple times
                        (defaults to '[SCRIPT_DIR]/..')
   --follow_symlinks    follow symlinks in search directories
                        (defaults to false. this is a no-op on Win32)
   --background         run the process in the background
   --pidfile            specify filename for pid file

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Run a Catalyst Testserver for this application.

=head1 NAME

quizbowl_web_server.pl - Catalyst Test Server

=head1 AUTHORS

Catalyst Contributors, see Catalyst.pm

=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Steve Nolte <iam@stevenolte.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steve Nolte.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

