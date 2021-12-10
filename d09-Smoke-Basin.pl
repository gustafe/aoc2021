#! /usr/bin/env perl
# Advent of Code 2021 Day 9 - Smoke Basin - complete solution
# https://adventofcode.com/2021/day/9
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d09
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/all product/;
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
my $Map;
my $id = 0;
my $Basins;

# We use a hash-of-hashes construct for the map, because it makes
# checking the boundaries much easier

my $r = 1;
for my $line (@input) {
    my $c = 1;
    for ( split( //, $line ) ) {
        $Map->{$r}{$c} = { val => $_ };
        $c++;
    }
    $r++;
}

my $risk = 0;

# Part 1: search for low points and calculate the total risk level
for my $r ( keys %$Map ) {
    for my $c ( keys %{ $Map->{$r} } ) {
        my @neighbors;
        for my $d ( [ -1, 0 ], [ 1, 0 ], [ 0, -1 ], [ 0, 1 ] ) {
            my ( $dr, $dc ) = ( $r + $d->[0], $c + $d->[1] );
            if ( defined $Map->{$dr}{$dc} ) {
                push @neighbors, $Map->{$dr}{$dc}->{val};
            }
        }
        if ( all { $Map->{$r}{$c}->{val} < $_ } @neighbors ) {

            # we have a low point, give it an ID and add it to the
            # list of locations
            ++$id;
            $Basins->{$id} = { r => $r, c => $c };
            $Map->{$r}{$c}->{id} = $id;
            $risk += ( $Map->{$r}{$c}->{val} + 1 );
        }
    }
}

# starting at each low point, find the area that drains to it
for my $id ( keys %$Basins ) {

    # we use BFS
    my @queue = ( [ $Basins->{$id}{r}, $Basins->{$id}{c} ] );
    while (@queue) {
        my $cur = shift @queue;
        for my $d ( [ -1, 0 ], [ 1, 0 ], [ 0, -1 ], [ 0, 1 ] ) {
            my ( $dr, $dc ) = ( $cur->[0] + $d->[0], $cur->[1] + $d->[1] );

            if ( defined $Map->{$dr}{$dc} ) {

                # a point is in the basin if it is
                # - strictly higher than a neighbor
                # - not == 9
                # - not already marked as visited

                if ( $Map->{$dr}{$dc}{val}
                        > $Map->{ $cur->[0] }{ $cur->[1] }{val}
                    and $Map->{$dr}{$dc}{val} != 9
                    and !defined( $Map->{$dr}{$dc}{id} ) )
                {
                    $Map->{$dr}{$dc}{id} = $id;
                    push @queue, [ $dr, $dc ];
                }
            }
        }
    }
}
my %sizes;
for my $r ( keys %$Map ) {
    for my $c ( keys %{ $Map->{$r} } ) {
        if ( $Map->{$r}{$c}{id} ) {
            $sizes{ $Map->{$r}{$c}{id} }++;
        }
    }
}

# This horror is just to extract the values of the top basins by size
my $prod = product( map { $sizes{$_} }
        ( sort { $sizes{$b} <=> $sizes{$a} } keys %sizes )[ 0 .. 2 ] );
### FINALIZE - tests and run time
if ($testing) {
    is( $risk, 15,   "Part 1: $risk" );
    is( $prod, 1134, "Part 1: $prod" );
}
else {
    is( $risk, 423,     "Part 1: $risk" );
    is( $prod, 1198704, "Part 2: $prod" );
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
