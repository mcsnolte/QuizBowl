#!/usr/bin/env perl

# PODNAME: quizbowl_web_test.pl
# ABSTRACT: Catalyst Test

use Catalyst::ScriptRunner;
Catalyst::ScriptRunner->run('QuizBowl::Web', 'Test');

1;


__END__
=pod

=head1 NAME

quizbowl_web_test.pl - Catalyst Test

=head1 VERSION

version 0.001

=head1 SYNOPSIS

quizbowl_web_test.pl [options] uri

 Options:
   --help    display this help and exits

 Examples:
   quizbowl_web_test.pl http://localhost/some_action
   quizbowl_web_test.pl /some_action

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Run a Catalyst action from the command line.

=head1 NAME

quizbowl_web_test.pl - Catalyst Test

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

