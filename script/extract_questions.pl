#!/usr/bin/env perl

# ABSTRACT: Extract QuizBowl Questions from Google Doc HTML
# PODNAME: extract_questions.pl

use strict;
use warnings;

use Data::Dumper::Concise;
use Dir::Self;

my $event_dir = '/static/images/event/1';
my $filename = 'MathBowlQuestions2011.html';

my $q_file = __DIR__ . '/../docs/' . $filename;

die('Can haz questions?') unless -f $q_file;

open my $in, '<', $q_file or die('come on!');
my $html = join( '', <$in> );
close $in;

$html =~ m{<body.*?>(.+)</body}s or die('No body');
my $body = $1;

my @questions;

while ( $body =~ m{<h1.*?span>(.+?) Questions.*?</h1>(.*?)(?=<h1|$)}sg ) {
	my $type   = $1;
	my $q_html = $2;

	my $level = 0;    # team
	if ( $type =~ m/(\d+)/ ) {
		$level = $1;    # grade
	}
	my $level_id = $level > 0 ? 'grade_' . $level : 'team';

	# rid empty spans
	$q_html =~ s|\s*<p[^>]*>\s*<span>\s*</span>\s*</p>\s*||g;
	
	# rid HRs
	$q_html =~ s/\s*<hr[^>]*?>\s*//g;
	
	# correct image paths
	#$q_html =~ s|src="images|src="$event_dir|g;

	print <<EOS;
	<div id="$level_id">
EOS

	while (
		$q_html =~ m/
		Question\s*
		(\d+)   # 1. Capture number
		.*?<\/p>\s*
		(.*?)   # 2. Capture question
		<p[^>]*?><span[^>]*?>
		\s*Answer\s*\d+.*?<\/p>\s*
		(.*?)   # 3. Capture answer
		\s*
		(?=<p[^>]*?><span[^>]*?>\s*Question|$) # look ahead to next q or end
		/sgx
	  )
	{
		my $num = $1;
		my $q   = $2;
		my $a   = $3;

		my $a_val = $a;

		# get textual answer if possible
		$a_val =~ s/<[^>]*>//g;
		$a_val =~ s/[\r\n\t]//g;
		$a_val =~ s/&nbsp;/ /g;

		push @questions, {
			question            => $q,
			answer              => $a,
			answer_value        => $a_val,
			question_type_value => 'text',
			level_id            => $level,
			explanation         => '',
		};

		$q =~ s/<(?!img)[^>]*>//g;
		$q =~ s/&nbsp;/ /g;
		$a =~ s/<[^>]*>//g;
		$a =~ s/&nbsp;/ /g;
		
		print <<EOS;
			<div id="question_$num">
				<p class="question">
					$q
				</p>
				<p class="answer">
					$a
				</p>
				<p class="value">
					$a_val
				</p>
				<p class="explanation">
				</p>
			</div>
EOS
	}
	print <<EOS;
	</div>
EOS
}

#print Dumper \@questions;

__END__
=pod

=head1 NAME

extract_questions.pl - Extract QuizBowl Questions from Google Doc HTML

=head1 VERSION

version 0.001

=head1 AUTHOR

Steve Nolte <iam@stevenolte.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steve Nolte.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

