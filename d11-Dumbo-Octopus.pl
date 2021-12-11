#! /usr/bin/env perl
# Advent of Code 2021 Day 11 - Dumbo Octopus - complete solution
# https://adventofcode.com/2021/day/11
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d11
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
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my $Map;
my %ans;
sub dump_map;
my $r = 0;
for my $line (@input) {
    my $c = 0;
    for my $v ( split( "", $line ) ) {
        $Map->{$r}{$c} = { v => $v, sweep => 0 };
        $c++;
    }
    $r++;
}

#dump_map;
my $step = 1;

my $LIMIT       = 200;
my $flash_count = 0;
my $has_synced  = 0;
while ( !$has_synced ) {

    # initial step, raise all levels by one
    for my $r ( keys %$Map ) {
        for my $c ( keys %{ $Map->{$r} } ) {
            $Map->{$r}{$c}{v}++;
        }
    }

    # sweep until all changes have been effected
    my $has_changed = 1;
    my $sweep_count = 0;
    while ($has_changed) {
        my $changes = 0;
        for my $r ( keys %$Map ) {
            for my $c ( keys %{ $Map->{$r} } ) {

                # will a recent flash change this cell's level ?
                next if $Map->{$r}{$c}{v} > 9;
                for my $d (
			   [ -1, -1 ], [ -1, 0 ], [ -1, 1 ],
			   [  0, -1 ],            [  0, 1 ],
			   [  1, -1 ], [  1, 0 ], [  1, 1 ]
                    )
                {
                    my ( $dr, $dc ) = ( $r + $d->[0], $c + $d->[1] );

                    if (    defined $Map->{$dr}{$dc}
                        and $Map->{$dr}{$dc}{v} > 9
                        and $Map->{$dr}{$dc}{sweep} == $sweep_count )
                    {

                        $Map->{$r}{$c}{v}++;
                        $Map->{$r}{$c}{sweep} = $sweep_count + 1;
                        $changes++;
                    }
                }
            }
        }
        $sweep_count++;
        $has_changed = 0 if $changes == 0;
    }

    # reset values for next step, count flashes;
    my $step_flashes = 0;
    for my $r ( keys %$Map ) {
        for my $c ( keys %{ $Map->{$r} } ) {
            if ( $Map->{$r}{$c}{v} > 9 ) {
                $Map->{$r}{$c}{v} = 0;
                $step_flashes++;
            }
            $Map->{$r}{$c}{sweep} = 0;
        }
    }
    if ( $step_flashes == 100 ) {
        $has_synced = 1;
        $ans{2} = $step;
    }
    $flash_count += $step_flashes;
    $ans{1} = $flash_count if $step == 100;
    $step++;
}

### FINALIZE - tests and run time
if ($testing) {
    is( $ans{1}, 1656, "Part 1: " . $ans{1} );
    is( $ans{2},  195, "Part 2: " . $ans{2} );
}
else {
    is( $ans{1}, 1652, "Part 1: " . $ans{1} );
    is( $ans{2},  220, "Part 2: " . $ans{2} );
}

done_testing();
say sec_to_hms( tv_interval($start_time) );

### SUBS
sub dump_map {
    for my $r ( sort { $a <=> $b } keys %$Map ) {
        for my $c ( sort { $a <=> $b } keys %{ $Map->{$r} } ) {
            print $Map->{$r}{$c}{v};
        }
        print "\n";
    }
}

sub sec_to_hms {
    my ($s) = @_;
    return sprintf(
        "Duration: %02dh%02dm%02ds (%.3f ms)",
        int( $s / ( 60 * 60 ) ),
        ( $s / 60 ) % 60,
        $s % 60, $s * 1000
    );
}
