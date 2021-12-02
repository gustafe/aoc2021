#! /usr/bin/env perl
# Advent of Code 2021 Day 1 - Sonar Sweep - complete solution
# Problem link: https://adventofcode.com/2021/day/1
#   Discussion: https://gerikson.com/blog/comp/Advent-of-Code-2021.html#d01
#      License: https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/reduce/;
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
my %ans;

# Part 1: use `reduce` here just because we can
# $a and $b are set to the initial entries in the list, then $a is set
# to the result. So we return $b last
my $res = reduce {
    if ( $b > $a ) { $ans{1}++ }
    $b
} @input;

# Part 2: our requirement: d[i]+d[i+1]+d[i+2] < d[i+1]+d[i+2]+d[i+3]
#         this reduces to:             d[i+3] > d[i]
for my $idx ( 0 .. $#input - 3 ) {
    $ans{2}++ if ( $input[ $idx + 3 ] > $input[ $idx  ] );
}

### FINALIZE - tests and run time
is( $ans{1}, 1655, "Part 1: $ans{1}" );
is( $ans{2}, 1683, "Part 2: $ans{2}" );
done_testing();
say sec_to_hms( tv_interval($start_time) );

### SUBS
sub sec_to_hms { my ($s) = @_;
    return sprintf("Duration: %02dh%02dm%02ds (%.3f ms)",
    int($s/(60*60)),($s/60)%60,$s%60,$s*1000);
}
