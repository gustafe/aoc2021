#! /usr/bin/env perl
# Advent of Code 2021 Day 12 - Passage Pathing - complete solution
# https://adventofcode.com/2021/day/12
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d12
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
my $file = $testing ? 'test3.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my $Map;
for my $line (@input) {
    my ( $from, $to ) = $line =~ m/^(.*)-(.*)$/;

    $Map->{$from}{$to}++ unless ( $to eq 'start' or $from eq 'end' );
    $Map->{$to}{$from}++ unless ( $to eq 'end'   or $from eq 'start' );
}

# algo from /u/Abigail
# - https://abigail.github.io/HTML/AdventOfCode/2021/day-12.html
my @queue;
push @queue, [ 'start', {}, 0 ];
my ( $count1, $count2 ) = ( 0, 0 );
BFS:
while (@queue) {
    my ( $cur, $seen, $twice ) = @{ shift @queue };
    if ( $cur eq 'end' ) {

        $count1++ if !$twice;
        $count2++;
        next;
    }
    next if ( $seen->{$cur} and $cur eq lc($cur) and $twice++ );

    for my $k ( keys %{ $Map->{$cur} } ) {
        push @queue, [ $k, { %$seen, $cur => 1 }, $twice ];
    }

}
### FINALIZE - tests and run time
is( $count1,   5756, "Part 1: $count1" );
is( $count2, 144603, "Part 2: $count2" );
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
