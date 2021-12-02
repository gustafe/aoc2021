#! /usr/bin/env perl
# Advent of Code 2021 Day 2 - Dive! - complete solution
# Problem link: https://adventofcode.com/2021/day/2
#   Discussion: https://gerikson.com/blog/comp/Advent-of-Code-2021.html#d02
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
my $file = $testing ? 'test.txt' : 'input.txt';
### CODE
my %pos = (
    1 => { x => 0, y => 0 },
    2 => { x => 0, y => 0, aim => 0 }
);

my %actions = (
    forward => sub {
        $pos{1}->{x} += $_[0];
        $pos{2}->{x} += $_[0];
        $pos{2}->{y} += $_[0] * $pos{2}->{aim};
    },
    down => sub { $pos{1}->{y} += $_[0]; $pos{2}->{aim} += $_[0] },
    up   => sub { $pos{1}->{y} -= $_[0]; $pos{2}->{aim} -= $_[0] }
);

open( my $fh, '<', "$file" );
while (<$fh>) {
    chomp;
    s/\r//gm;
    my ( $cmd, $amt ) = split( / /, $_ );
    if ( exists $actions{$cmd} ) {
        $actions{$cmd}->($amt);
    }
    else {
        warn "unknown command: $cmd";
    }
}

my $part1 = $pos{1}->{x} * $pos{1}->{y};
my $part2 = $pos{2}->{x} * $pos{2}->{y};
### FINALIZE - tests and run time
is( $part1, 1714680,    "Part 1: $part1" );
is( $part2, 1963088820, "Part 2: $part2" );
done_testing();
say sec_to_hms( tv_interval($start_time) );

### SUBS
sub sec_to_hms {  
    my ($s) = @_;
    return sprintf("Duration: %02dh%02dm%02ds (%.3f ms)",
    int( $s / ( 60 * 60 ) ), ( $s / 60 ) % 60, $s % 60, $s * 1000 );
}
