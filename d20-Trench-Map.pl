#! /usr/bin/env perl
# Advent of Code 2021 Day 20 - Trench Map - complete solution
# https://adventofcode.com/2021/day/20
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d20
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';
# useful modules
use List::Util qw/sum min max/;
use Clone qw/clone/;
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
my @rule = split( '', $input[0] );
my $Map;

sub count_map;
for my $r ( 2 .. $#input ) {
    my $c = 0;
    for my $p ( split( '', $input[$r] ) ) {
        $Map->{ $r - 2 }{$c} = $p;
        $c++;
    }
}

# ENHANCE
for my $N ( 1 .. 50 ) {
    my $newM;

    # add a border around the map
    my $min_r = min keys %$Map;
    my $max_r = max keys %$Map;
    my ( $min_c, $max_c ) = ( 10e6, -1 );
    for my $r ( keys %$Map ) {
        $min_c = min( keys %{ $Map->{$r} } )
            if min( keys %{ $Map->{$r} } ) < $min_c;
        $max_c = max( keys %{ $Map->{$r} } )
            if max( keys %{ $Map->{$r} } ) > $max_c;
    }
    for my $r ( $min_r - 1 .. $max_r + 1 ) {
        for my $c ( $min_c - 1 .. $max_c + 1 ) {
            my $digit;
            for my $d (
		       [ -1, -1 ], [ -1, 0 ], [ -1, 1 ],
		       [  0, -1 ], [  0, 0 ], [  0, 1 ],
		       [  1, -1 ], [  1, 0 ], [  1, 1 ]
                )
            {
                my ( $rd, $cd ) = ( $r + $d->[0], $c + $d->[1] );

                # This is the key issue. For my input, index 0 mean
                # "light the pixel" while the last index mean "turn it
                # off". So every second iteration the infinite outside
                # "changes signs"
                if ( !$Map->{$rd}{$cd} ) {
                    if ( $N % 2 == 0 ) {
                        $digit .= '1';
                    }
                    else {
                        $digit .= '0';
                    }
                }
                elsif ( $Map->{$rd}{$cd} eq '#' ) {
                    $digit .= '1';
                }
                elsif ( $Map->{$rd}{$cd} eq '.' ) {
                    $digit .= '0';
                }
            }
            my $index = oct( '0b' . $digit );
            $newM->{$r}{$c} = $rule[$index];
        }

    }
    $Map = clone $newM;
    $ans{1} = count_map if $N == 2;
}
$ans{2} = count_map;

### FINALIZE - tests and run time
is( $ans{1}, 5846,  "Part 1: " . $ans{1} );
is( $ans{2}, 21149, "Part 2: " . $ans{2} );
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

sub count_map {
    my $count = 0;
    for my $r ( keys %$Map ) {
        for my $c ( keys %{ $Map->{$r} } ) {
            $count++ if $Map->{$r}{$c} eq '#';
        }
    }
    return $count;

}
