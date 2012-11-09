package QuizBowl::QueryProfiler;

# ABSTRACT: Profiler for use with DBIx::Class

use strict;
use warnings;
use parent 'DBIx::Class::Storage::Statistics';

use Time::HiRes qw(time);
use SQL::Abstract::Tree;
use Term::ANSIColor qw(colored);
use Devel::StackTrace;

our %start;
our %query;
our $query_count = 0;
our $formatter = SQL::Abstract::Tree->new({ profile => 'console' });


sub query_start {
	my $self = shift;
	my $sql = shift;
	my $query_num = $query{$sql} ||= ++$query_count;
	my @params = @_;
	
	$self->print( colored("Q$query_num:", 'black on_yellow') . ' ' . $formatter->format( $sql, \@params ) . "\n" );
	$start{$sql} = time;
}


sub query_end {
	my $self = shift;
	my $sql = shift;
	my $start = delete $start{$sql};
	my $elapsed;
	$elapsed = sprintf( '%0.4f', time - $start ) if $start;
	my $query_num = delete $query{$sql} || '?';

	my $color;
	if( !defined $elapsed ) {
		$color = 'red on_yellow';
		$elapsed = 'unknown';
	}
	elsif( $elapsed < 0.01 ) {
		$color = 'green';
	}
	elsif( $elapsed < 0.1 ) {
		$color = 'yellow';
	}
	else {
		$color = 'red';
	}

	$elapsed = colored( $elapsed, $color );
	$self->print( colored("Q$query_num:", 'black on_yellow') . " Execution took $elapsed seconds.\n" );
}

1;

