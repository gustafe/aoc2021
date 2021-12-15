#! /usr/bin/env perl
# Advent of Code 2021 Day 15 - Chiton - part 2
# https://adventofcode.com/2021/day/15
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d15
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum max/;
use Data::Dump qw/dump/;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
use Array::Heap::PriorityQueue::Numeric;
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
my $r     = 0;
my $max_c = 0;
for my $line (@input) {
    my $c = 0;
    for my $n ( split( '', $line ) ) {
        $Map->{$r}{$c} = $n;
        $c++;
    }
    $max_c = $c;
    $r++;
}
my $max_r = max( keys %$Map ) + 1;

# build bigger map for part 2
# extend down
for my $r ( $max_r .. 5 * $max_r - 1 ) {
    for my $c ( 0 .. $max_c - 1 ) {
        my $new_val = $Map->{ $r - $max_r }{$c} + 1;
        $new_val = 1 if $new_val > 9;
        $Map->{$r}{$c} = $new_val;
    }
}

# extend to the right
for my $r ( sort { $a <=> $b } keys %$Map ) {
    for my $c ( $max_c .. 5 * $max_c - 1 ) {
        my $new_val = $Map->{$r}{ $c - $max_c } + 1;
        $new_val = 1 if $new_val > 9;
        $Map->{$r}{$c} = $new_val;
    }
}

my $goal = $testing ? [ 49, 49 ] : [ 499, 499 ];
my $pq   = Array::Heap::PriorityQueue::Numeric->new();
$pq->add( [ 0, 0 ], 0 );
my $came_from;
my $cost_so_far;
$came_from->{0}{0}   = undef;
$cost_so_far->{0}{0} = 0;
SEARCH:

while ( $pq->peek ) {
    my $cur = $pq->get();
    if ( $cur->[0] == $goal->[0] and $cur->[1] == $goal->[1] ) {
        $ans{2} = $cost_so_far->{ $goal->[0] }{ $goal->[1] };
        last SEARCH;
    }

    # try to move
    for my $d ( [ -1, 0 ], [ 0, -1 ], [ 1, 0 ], [ 0, 1 ] ) {
        my $dr        = $cur->[0] + $d->[0];
        my $dc        = $cur->[1] + $d->[1];
        my $manhattan = abs( $goal->[0] - $dr ) + abs( $goal->[1] + $dc );
        next unless exists $Map->{$dr}{$dc};
        my $cur_cost = $cost_so_far->{ $cur->[0] }{ $cur->[1] };
        my $new_cost = $cur_cost + $Map->{$dr}{$dc};

        if ( !exists $cost_so_far->{$dr}{$dc}
            or $new_cost < $cost_so_far->{$dr}{$dc} )
        {
            $cost_so_far->{$dr}{$dc} = $new_cost;
            $pq->add( [ $dr, $dc ], $new_cost + $manhattan );
            $came_from->{$dr}{$dc} = $cur;
        }
    }
}

### FINALIZE - tests and run time
is($ans{2}, 2800, "Part 2: ".$ans{2});
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
    for my $r ( sort { $a <=> $b } keys %$Map ) {
        for my $c ( sort { $a <=> $b } keys %{ $Map->{$r} } ) {
            print $Map->{$r}{$c};
        }
        print "\n";
    }
}
