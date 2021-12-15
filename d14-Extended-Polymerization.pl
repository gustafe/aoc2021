#! /usr/bin/env perl
# Advent of Code 2021 Day 14 - Extended Polymerization - complete solution
# https://adventofcode.com/2021/day/14
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d14
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
sub sec_to_hms;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array

my $testing = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my $template = shift @input;
shift @input;
my %rules;
my @ans;
for my $line (@input) {
    if ( $line =~ m/(.*) -> (.*)/ ) {
        $rules{$1} = $2;
    }
}
my $step       = 1;
my @initial    = split( "", $template );
# we save this because it will be included in every subsequent string 
my $first_elem = $initial[0];

my %pairs;
for my $idx ( 0 .. $#initial - 1 ) {
    $pairs{ $initial[$idx] . $initial[ $idx + 1 ] }++;
}
my $end = $initial[-1];

my $LIMIT = 40;
while ( $step <= $LIMIT ) {

    # count elements and add
    my %elements;
    $elements{$first_elem} = 1;

    my %next;

    for my $k ( keys %pairs ) {
        if ( $rules{$k} ) {
            my @in = split( '', $k );
	    # add new combinations to following sequence
            $next{ $in[0] . $rules{$k} } += $pairs{$k};
            $next{ $rules{$k} . $in[1] } += $pairs{$k};

	    # add up the elements, only newly added middle and right -
	    # the left element is already counted in the previous pair
	    
            $elements{ $rules{$k} } += $pairs{$k};
            $elements{ $in[1] } += $pairs{$k};
        }
    }
    # output all the big numbers 
    my @freq = sort { $elements{$b} <=> $elements{$a} } keys %elements;
    printf(
        "%2d %14d %14d %14d\n",
        (   $step,
            $elements{ $freq[0] },
            $elements{ $freq[-1] },
            $elements{ $freq[0] } - $elements{ $freq[-1] }
        )
    );
    if ( $step == 10 or $step == 40 ) {
        push @ans, $elements{ $freq[0] } - $elements{ $freq[-1] };
    }
    %pairs = %next;
    $step++;
}

### FINALIZE - tests and run time

if ($testing) {
    is( $ans[0],          1588, "Part 1: " . $ans[0] );
    is( $ans[1], 2188189693529, "Part 2: " . $ans[1] );
}
else {
    is( $ans[0],          2321, "Part 1: " . $ans[0] );
    is( $ans[1], 2399822193707, "Part 2: " . $ans[1] );
}

done_testing();
say sec_to_hms( tv_interval($start_time) );

### SUBS
sub sec_to_hms {
    my ($s) = @_;
    return sprintf(
        "Duration: %02dh%02dm%02ds (%.3f ms)",
        int( $s / ( 60 * 60 ) ),
        ( $s / 60 ) % 60,
        $s % 60, $s * 1000
    );
}
