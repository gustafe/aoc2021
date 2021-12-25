#! /usr/bin/env perl
# Advent of Code 2021 Day 25 - Sea Cucumber - complete solution
# https://adventofcode.com/2021/day/25
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d25
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
my $debug   = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my $Map;
sub dump_map;

my ( $R, $C ) = ( 0, 0 );
for my $line (@input) {
    $C = 0;
    for my $t ( split( '', $line ) ) {
        $Map->{$R}{$C} = $t unless $t eq '.';
        $C++;
    }
    $R++;

}
dump_map if $debug;

my $moved = 1;
my $steps = 0;
while ($moved) {
    no warnings 'uninitialized';
    say "==> $steps" if $steps % 25 == 0;

    $moved = 0;

    # east herd
    my $seen;
    for my $r ( sort { $a <=> $b } keys %$Map ) {
        for my $c ( sort { $a <=> $b } keys %{ $Map->{$r} } ) {
            if ( $Map->{$r}{$c} eq '>' and !defined $seen->{$r}{$c} ) {
                my $dc = ( $c + 1 ) % $C;
                if (    !defined $Map->{$r}{$dc}
                    and $Map->{$r}{$dc} ne '>'
                    and $Map->{$r}{$dc} ne 'v'
                    and !$seen->{$r}{$dc} )
                {
                    delete $Map->{$r}{$c};
                    $seen->{$r}{$c}++;
                    $Map->{$r}{$dc} = '>';
                    $seen->{$r}{$dc}++;
                    $moved++;
                }
            }
        }
    }

    # south herd
    $seen = undef;

    for my $r ( sort { $a <=> $b } keys %$Map ) {
        for my $c ( sort { $a <=> $b } keys %{ $Map->{$r} } ) {
            if ( $Map->{$r}{$c} eq 'v' and !defined $seen->{$r}{$c} ) {
                my $dr = ( $r + 1 ) % $R;
                if (    !defined $Map->{$dr}{$c}
                    and $Map->{$dr}{$c} ne '>'
                    and $Map->{$dr}{$c} ne 'v'
                    and !$seen->{$dr}{$c} )
                {
                    delete $Map->{$r}{$c};
                    $seen->{$r}{$c}++;
                    $Map->{$dr}{$c} = 'v';
                    $seen->{$dr}{$c}++;
                    $moved++;
                }
            }
        }
    }

    $steps++;
    if ($debug) {
        say "After $steps steps:";
        dump_map;
        print "\n";
    }

}

#say $steps;
### FINALIZE - tests and run time
is( $steps, 305, "Part 1: $steps" );
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

sub dump_map {
    for my $r ( 0 .. $R - 1 ) {
        for my $c ( 0 .. $C - 1 ) {
            print $Map->{$r}{$c} ? $Map->{$r}{$c} : '.';
        }
        print "\n";
    }
}
