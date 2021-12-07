#! /usr/bin/env perl
# Advent of Code 2021 Day 7 - The Treachery of Whales - complete solution
# https://adventofcode.com/2021/day/7
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d07
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum min max/;
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
my @positions = split( ',', $input[0] );
sub median;
sub cost_per_position;
my $median  = median(@positions);
my $average = ( sum @positions ) / scalar @positions;

# this is an optimization, instead of checking every possible position
# we just search around the range of [median,int(average)], as in my
# case these values are the solutions for part 1 and part 2
# respectively

my %ans = ( 1 => 100_000_000, 2 => 100_000_000 );
for my $t (min($median, int $average) - 5 .. max($median, int $average) + 5) {
    my $res = cost_per_position($t);
    # check if result is smaller than what we already have
    map { $ans{$_} = $res->[$_-1] < $ans{$_} ? $res->[$_-1] : $ans{$_}} (1,2);
}

### FINALIZE - tests and run time
is( $ans{1}, 337488,   "Part 1: " . $ans{1} );
is( $ans{2}, 89647695, "Part 2: " . $ans{2} );
done_testing();
say sec_to_hms( tv_interval($start_time) );

### SUBS
sub median {    # https://www.perlmonks.org/?node_id=90772
    my @sorted = sort { $a <=> $b } @_;
    ( $sorted[ $#sorted / 2 + 0.1 ] + $sorted[ $#sorted / 2 + 0.6 ] ) / 2;
}

sub cost_per_position {
    my ($goal) = @_;
    my @costs = ( 0, 0 );
    for my $p (@positions) {
        my $d = abs( $goal - $p );
	# part 1
        $costs[0] += $d;
	# part 2
        $costs[1] += $d * ( $d + 1 ) / 2;
    }
    return \@costs;
}

sub sec_to_hms {
    my ($s) = @_;
    return sprintf(
        "Duration: %02dh%02dm%02ds (%.3f ms)",
        int( $s / ( 60 * 60 ) ), ( $s / 60 ) % 60, $s % 60, $s * 1000 );
}

