#! /usr/bin/env perl
# Advent of Code 2021 Day 1 - Sonar Sweep - complete solution
# Problem link: https://adventofcode.com/2021/day/1
#   Discussion: https://gerikson.com/blog/comp/Advent-of-Code-2021.html#d01
#      License: https://gerikson.com/files/AoC2021/UNLICENSE
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
my %ans;
for my $idx ( 1 .. $#input ) {

    if ( $input[$idx] > $input[ $idx - 1 ] ) {
        $ans{1}++;
    }

    # only compare the ends of each "window" as the middles are shared
    if ( $idx <= $#input - 2 and ( $input[ $idx + 2 ] > $input[ $idx - 1 ] ) )
    {
        $ans{2}++;
    }
}

### FINALIZE - tests and run time
is( $ans{1}, 1655, "Part 1: $ans{1}" );
is( $ans{2}, 1683, "Part 2: $ans{2}" );
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
