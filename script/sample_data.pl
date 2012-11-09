#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use QuizBowl::Core;

my $schema = QuizBowl::Core->schema;
my @users  = $schema->resultset('User')->populate(
	[
		{
			email      => 'admin@example.com',
			first_name => 'System',
			last_name  => 'Admin',
			password   => '{SSHA}MgjsrRjnD6gUCh+ilS0rnNeCzA5uQ71d',
			is_admin   => 1,
		},
	]
);

# Copy and paste out of Google Doc
my $team_data = <<'EOS';
Crown of Life	Warren	Bulldogs
Cross of Glory	Washington	Cougars
Divine Grace	Lake Orion	Panthers
St. Paul's	Livonia	Chargers
Peace	Livonia	Panthers
St. John's	Westland	Leopards
Zion Monroe	Monroe	Warriors
St. Stephen	Adrian	Cardinals
Trinity	Jenera	Tigers
St. Peter's	Plymouth	Eagles
EOS

my @teams =
  map {
	my @d = split( /\t/, $_ );
	my $email = lc $d[0];
	$email =~ s/\s+/_/g;
	$email =~ s/\W//g;
	{ school => $d[0], city => $d[1], mascot => $d[2], email => $email }
  }
  split( /\n/, $team_data );

my @schools = $schema->resultset('School')->populate(
	[
		map {
			{
				name         => $_->{school},
				mascot       => $_->{mascot},
				city         => $_->{city},
				state_abbrev => 'MI',
				teams        => [
					{
						name  => $_->{school},
						users => [
							{
								email      => $_->{email} . '@example.com',
								first_name => $_->{school},
								last_name  => 'Team',
								password   => '{SSHA}MgjsrRjnD6gUCh+ilS0rnNeCzA5uQ71d',
							}
						]
					}
				]
			}
		  } @teams

	]
);

# back update users on schools
my $teams_rs = $schema->resultset('Team')->search( {}, { prefetch => 'users' } );
while ( my $team = $teams_rs->next() ) {
	$team->users->update( { school_id => $team->school_id } );
}
my @questions = $schema->resultset('Question')->populate(
	[
		{
			level_id            => "5",
			question            => "What is the product of all four digits of the year 2011?",
			points              => "1",
			answer              => "0",
			answer_value        => "0",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "5",
			question            => "\$\\frac{5075}{25}=\$",
			points              => "1",
			answer              => "203",
			answer_value        => "203",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id => "5",
			question =>
"Today, the difference between my parents' ages is 10 years.  Four years ago, what was the difference between their ages?",
			points              => "1",
			answer              => "10 years",
			answer_value        => "10",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id => "5",
			question =>
"ABCD is a square.  BEC is an equilateral triangle.  What is the perimeter of shape ABECD?\n<br>\n<img height=\"154\" src=\"/static/images/event/1/image40.png\" width=\"233\">",
			points              => "1",
			answer              => "20 in.",
			answer_value        => "20",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "5",
			question            => "What is \$\\frac{3}{5}\$ of 10?",
			points              => "1",
			answer              => "6",
			answer_value        => "6",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "5",
			question            => "\$7-6\\frac{7}{8}=\$",
			points              => "1",
			answer              => "\$\\frac{1}{8}\$",
			answer_value        => ".125",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id => "5",
			question =>
"Write \$(8 \\times 10,000) + (1 \\times 1,000) + (7 \\times 100) + (4 \\times 1)\$ in standard notation.",
			points              => "1",
			answer              => "81,704",
			answer_value        => "81704",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "5",
			question            => "\$\\frac{1}{2}\\div\\frac{2}{3}=\$",
			points              => "1",
			answer              => "\$\\frac{3}{4}\$",
			answer_value        => ".75",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "6",
			question            => "\$12\\frac{1}{2}\$% of 80 =",
			points              => "1",
			answer              => "10",
			answer_value        => "10",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "6",
			question            => "There are 10 chickens and 10 cows.  How many legs are there?",
			points              => "1",
			answer              => "60",
			answer_value        => "60",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "6",
			question            => "How many prime numbers are between 20 and 30?",
			points              => "1",
			answer              => "2",
			answer_value        => "2",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id => "6",
			question =>
"Sue had an average of exactly 84 after 2 tests.  She scored 96 on the 3rd test.  What is her average for all 3 tests?",
			points              => "1",
			answer              => "88",
			answer_value        => "88",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "6",
			question            => "Write the reduced fraction for 45%",
			points              => "1",
			answer              => "\$\\frac{9}{20}\$",
			answer_value        => ".45",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id => "6",
			question =>
			  "Find the area.\n<br>\n<img height=\"98\" src=\"/static/images/event/1/image45.png\" width=\"177\">",
			points              => "1",
			answer              => "16 square cm",
			answer_value        => "16",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "6",
			question            => "\$3+3\\div3+3\\times3=\$",
			points              => "1",
			answer              => "13",
			answer_value        => "13",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "6",
			question            => "\$\\frac{2}{3}+\\frac{1}{6}=\$",
			points              => "1",
			answer              => "\$\\frac{5}{6}\$",
			answer_value        => "5/6",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "7",
			question            => "What percent of 30 is 6?",
			points              => "1",
			answer              => "20%",
			answer_value        => "20",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id => "7",
			question =>
"A man spent \$\\frac{2}{3}\$ of his money and then lost \$\\frac{2}{3}\$ of his remaining money, leaving him with \$18.  With how much money did he start?",
			points              => "1",
			answer              => "\$162",
			answer_value        => "162",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "7",
			question            => "List the single digit whole numbers that are factors of 36,270.",
			points              => "1",
			answer              => "1, 2, 3, 5, 6, 9",
			answer_value        => "1, 2, 3, 5, 6, 9",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "7",
			question            => "What is the largest prime number that is a factor of 364.",
			points              => "1",
			answer              => "13",
			answer_value        => "13",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "7",
			question            => "Round \$283.\\overline{56}\$ to the nearest hundredth.",
			points              => "1",
			answer              => "283.57",
			answer_value        => "283.57",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "7",
			question            => "\$\\frac{8^2}{2^3}=\$",
			points              => "1",
			answer              => "8",
			answer_value        => "8",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id => "7",
			question =>
"Find the perimeter.\n<br>\n<img height=\"239\" src=\"/static/images/event/1/image46.png\" width=\"238\">",
			points              => "1",
			answer              => "86 units",
			answer_value        => "86",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "7",
			question            => "5 ft    7 in. \$-\$ 3 ft  10 in.",
			points              => "1",
			answer              => "1 ft 9 in.",
			answer_value        => "1 ft 9 in.",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "8",
			question            => "1.23 + 0.046 =",
			points              => "1",
			answer              => "1.276",
			answer_value        => "1.276",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id => "8",
			question =>
"What is the area of the shaded portion of this grid.\n<br>\n<img height=\"146\" src=\"/static/images/event/1/image42.png\" width=\"146\">",
			points              => "1",
			answer              => "3 square units",
			answer_value        => "3",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "8",
			question            => "What is 80% of 21?",
			points              => "1",
			answer              => "16.8",
			answer_value        => "16.8",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "8",
			question            => "\$(-3)-(-1)-(-8)-(2)=\$",
			points              => "1",
			answer              => "4",
			answer_value        => "4",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "8",
			question            => "Change \$6\\frac{2}{3}\$% to a reduced fraction.",
			points              => "1",
			answer              => "\$\\frac{1}{15}\$",
			answer_value        => "1/15",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "8",
			question            => "Solve for \$x\$.\n<br>\n\$-3x+5=7x-11-2x\$",
			points              => "1",
			answer              => "2",
			answer_value        => "2",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "8",
			question            => "What percent of 44 is 55?",
			points              => "1",
			answer              => "125%",
			answer_value        => "125",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "8",
			question            => "Evaluate for \$m=3\$ and \$n=-2\$.\n<br>\n\$m^2+4mn+n^2\$",
			points              => "1",
			answer              => "-19",
			answer_value        => "-19",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "team",
			question            => "How many prime numbers are between 1 and 40?",
			points              => "1",
			answer              => "12",
			answer_value        => "12",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id => "team",
			question =>
"The average of four numbers is 10.  Three of the four numbers are 2, 14, and 7.  What is the fourth number?",
			points              => "1",
			answer              => "17",
			answer_value        => "17",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "team",
			question            => "\$\\frac{9}{25}\\div\\frac{27}{15}=\$",
			points              => "1",
			answer              => "\$\\frac{1}{5}\$",
			answer_value        => ".2",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id => "team",
			question =>
			  "Find the area.\n<br>\n<img height=\"129\" src=\"/static/images/event/1/image44.png\" width=\"223\">",
			points              => "1",
			answer              => "40 square units",
			answer_value        => "40",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "team",
			question            => "\$41-3\\cdot 5+4\\cdot 6=\$",
			points              => "1",
			answer              => "50",
			answer_value        => "50",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "team",
			question            => "\$7\\frac{1}{5}-6\\frac{2}{3}=\$",
			points              => "1",
			answer              => "\$\\frac{8}{15}\$",
			answer_value        => "8/15",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "team",
			question            => "XLIV =",
			points              => "2",
			answer              => "44",
			answer_value        => "44",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "team",
			question            => "\$2^2-2^3[2^2(3-2^2)+2^2(3-1)]=\$",
			points              => "2",
			answer              => "-28",
			answer_value        => "-28",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "team",
			question            => "Evaluate for \$m=-3\$ and \$n=2\$.\n<br>\n\$3^2mn^5mn^{-2}m^{-2}(-1)^5\$",
			points              => "2",
			answer              => "-72",
			answer_value        => "-72",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id => "team",
			question => "Find m.\n<br>\n<img height=\"124\" src=\"/static/images/event/1/image41.png\" width=\"96\">",
			points   => "2",
			answer   => "3 units",
			answer_value        => "3",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "team",
			question            => "Solve for \$x\$.\n<br>\n\$2x-4+3x=x+24\$",
			points              => "2",
			answer              => "7",
			answer_value        => "7",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "team",
			question            => "If \$5x-2=5\$, what is the value of \$10x-3\$?",
			points              => "2",
			answer              => "11",
			answer_value        => "11",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "team",
			question            => "Factor completely: \n<br>\n\$2ax^2-20ax+42a\$",
			points              => "3",
			answer              => "\$2a(x-7)(x-3)\$",
			answer_value        => "2a(x-7)(x-3)",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id => "team",
			question =>
"Find 3 consecutive <b>\n<u>\neven\n</u>\n</b>\nintegers such that 4 times the sum of the first and third is 16 greater than 7 times the second.",
			points              => "3",
			answer              => "14, 16, 18",
			answer_value        => "14, 16, 18",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "team",
			question            => "Solve for \$x\$.\n<br>\n\$\\frac{2x}{7}-\\frac{3x}{2}=\\frac{1}{3}\$",
			points              => "3",
			answer              => "\$-\\frac{14}{51}\$",
			answer_value        => "-14/51",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "team",
			question            => "Solve for \$p\$.\n<br>\n\$4p+3a-5=6a+p\$",
			points              => "3",
			answer              => "\$p=a+\\frac{5}{3}\$",
			answer_value        => "a+5/3",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id => "team",
			question =>
			  "Find the area.\n<br>\n<img height=\"114\" src=\"/static/images/event/1/image43.png\" width=\"218\">",
			points              => "3",
			answer              => "92 square units",
			answer_value        => "92",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "team",
			question            => "Solve the following system of equations:\n<br>\n\$x-9y=17\$\n<br>\n\$-4x+7y=19\$",
			points              => "3",
			answer              => "\$x = -10\$ and \$y = -3\$, or \$(-10, -3)\$",
			answer_value        => "-10, -3",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "practice",
			question            => "2 + 2 =",
			points              => "0",
			answer              => "4",
			answer_value        => "4",
			explanation         => "",
			question_type_value => "text",
		},
		{
			level_id            => "practice",
			question            => "\$\\frac{1}{3} + \\frac{1}{3} =\$",
			points              => "0",
			answer              => "\$\\frac{2}{3}\$",
			answer_value        => '2/3',
			explanation         => "",
			question_type_value => "text",
		},
	]
);

# Split questions up, one per round from each level
my $seq   = 1;
my $round = 1;
my @event_questions;

foreach my $practice (@questions) {
	next unless $practice->level_id eq 'practice';
	push @event_questions,
	  {
		question_id  => $practice->id,
		round_number => 0,
		sequence     => 0,
		create_user_id => 0,
	  };
}

# 8 player questions
foreach my $i ( 0 .. 7 ) {

	# 4 grade levels
	foreach my $j ( 0 .. 3 ) {
		my $qid = $questions[ $i + $j * 8 ]->id;
		push @event_questions,
		  {
			question_id  => $qid,
			round_number => $round,
			sequence     => $seq++,
			create_user_id => 0,
		  };
	}

	next if $seq > 42;

	# 6 team q's per point total, distribute to first 6 player questions
	foreach my $j ( 0 .. 2 ) {
		my $qid = $questions[ $j * 6 + 8 * 4 + $i ]->id;
		push @event_questions,
		  {
			question_id  => $qid,
			round_number => $round,
			sequence     => $seq++,
			create_user_id => 0,
		  };
	}

	$round++;
}

my ($event) = $schema->resultset('Event')->populate(
	[
		{
			name             => 'GMLSAL Quiz Bowl 2011',
			start_time       => \'now()',
			end_time         => \"now() + INTERVAL '1 hour'",
			registered_teams => [ map { { team_id => $_->team_id, } } $schema->resultset('Team')->all() ],
		}
	]
);
$event->questions->populate(\@event_questions);

my @screens = $schema->resultset('Slide')->populate(
	[
		{
			"name" => "Screen 1 Thumbnail",
			"url"  => "/static/images/slides/nature-20004329.jpg"
		},
		{
			"name" => "Screen 2 Thumbnail",
			"url"  => "/static/images/slides/nature-21056610.jpg"
		},
		{
			"name" => "Screen 3 Thumbnail",
			"url"  => "/static/images/slides/nature-23787168.jpg"
		}
	]
);

