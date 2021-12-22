#! /usr/bin/env perl
# Advent of Code 2021 Day 22 - Reactor Reboot - part 1
# https://adventofcode.com/2021/day/22
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d22
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dump qw/dump/;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
sub sec_to_hms;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array

my $testing = 0;
my $debug   = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my @ranges;
for my $line (@input) {
    if ( $line
        =~ m/^(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)$/
        )
    {
        push @ranges,
            { cmd => $1, x => [ $2, $3 ], y => [ $4, $5 ], z => [ $6, $7 ] };
    }
    else {
        warn "can't parse: $line";
    }
}
dump @ranges if $debug;
my $Map;
for my $r (@ranges) {
    next
        unless ( $r->{x}[0] >= -50
        and $r->{x}[1] <= 50
        and $r->{y}[0] >= -50
        and $r->{y}[1] <= 50
        and $r->{z}[0] >= -50
        and $r->{z}[1] <= 50 );
    dump $r if $debug;
    for my $x ( $r->{x}[0] .. $r->{x}[1] ) {
        for my $y ( $r->{y}[0] .. $r->{y}[1] ) {
            for my $z ( $r->{z}[0] .. $r->{z}[1] ) {
                if ( $r->{cmd} eq 'on' ) {
                    $Map->{$x}{$y}{$z} = 1;
                }
                else {
                    $Map->{$x}{$y}{$z} = 0;
                }
            }
        }
    }
}
my $count = 0;
for my $x ( -50 .. 50 ) {
    for my $y ( -50 .. 50 ) {
        for my $z ( -50 .. 50 ) {
            $count++ if ( $Map->{$x}{$y}{$z} and $Map->{$x}{$y}{$z} == 1 );
        }
    }
}

### FINALIZE - tests and run time
is($count, 642125, "Part 1: $count");
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
