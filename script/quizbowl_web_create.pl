#!/usr/bin/env perl

# PODNAME: quizbowl_web_create.pl
# ABSTRACT: Create a new Catalyst Component

use strict;
use warnings;

use Catalyst::ScriptRunner;
Catalyst::ScriptRunner->run('QuizBowl::Web', 'Create');

1;


__END__
=pod

=head1 NAME

quizbowl_web_create.pl - Create a new Catalyst Component

=head1 VERSION

version 0.001

=head1 SYNOPSIS

quizbowl_web_create.pl [options] model|view|controller name [helper] [options]

 Options:
   --force        don't create a .new file where a file to be created exists
   --mechanize    use Test::WWW::Mechanize::Catalyst for tests if available
   --help         display this help and exits

 Examples:
   quizbowl_web_create.pl controller My::Controller
   quizbowl_web_create.pl -mechanize controller My::Controller
   quizbowl_web_create.pl view My::View
   quizbowl_web_create.pl view HTML TT
   quizbowl_web_create.pl model My::Model
   quizbowl_web_create.pl model SomeDB DBIC::Schema MyApp::Schema create=dynamic\
   dbi:SQLite:/tmp/my.db
   quizbowl_web_create.pl model AnotherDB DBIC::Schema MyApp::Schema create=static\
   [Loader opts like db_schema, naming] dbi:Pg:dbname=foo root 4321
   [connect_info opts like quote_char, name_sep]

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro
   perldoc Catalyst::Helper::Model::DBIC::Schema
   perldoc Catalyst::Model::DBIC::Schema
   perldoc Catalyst::View::TT

=head1 DESCRIPTION

Create a new Catalyst Component.

Existing component files are not overwritten.  If any of the component files
to be created already exist the file will be written with a '.new' suffix.
This behavior can be suppressed with the C<-force> option.

=head1 NAME

quizbowl_web_create.pl - Create a new Catalyst Component

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

