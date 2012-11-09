#!/usr/bin/env perl

# PODNAME: quizbowl_web_fastcgi.pl
# ABSTRACT: Catalyst FastCGI

use Catalyst::ScriptRunner;
Catalyst::ScriptRunner->run('QuizBowl::Web', 'FastCGI');

1;


__END__
=pod

=head1 NAME

quizbowl_web_fastcgi.pl - Catalyst FastCGI

=head1 VERSION

version 0.001

=head1 SYNOPSIS

quizbowl_web_fastcgi.pl [options]

 Options:
   -? -help      display this help and exits
   -l --listen   Socket path to listen on
                 (defaults to standard input)
                 can be HOST:PORT, :PORT or a
                 filesystem path
   -n --nproc    specify number of processes to keep
                 to serve requests (defaults to 1,
                 requires -listen)
   -p --pidfile  specify filename for pid file
                 (requires -listen)
   -d --daemon   daemonize (requires -listen)
   -M --manager  specify alternate process manager
                 (FCGI::ProcManager sub-class)
                 or empty string to disable
   -e --keeperr  send error messages to STDOUT, not
                 to the webserver
   --proc_title  Set the process title (is possible)

=head1 DESCRIPTION

Run a Catalyst application as fastcgi.

=head1 NAME

quizbowl_web_fastcgi.pl - Catalyst FastCGI

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

