#! /usr/bin/env perl
# Advent of Code 2021 Day 23 - Amphipod - complete solution
# https://adventofcode.com/2021/day/23
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d23
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum none all/;
use Data::Dump qw/dump/;
use Test::More;
use Clone qw/clone/;
use Time::HiRes qw/gettimeofday tv_interval/;
use Array::Heap::PriorityQueue::Numeric;
sub sec_to_hms;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array

my $testing = 0;
my $debug   = 0;
my $part2   = shift @ARGV // 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my %amphipods = (
    A => { name => 'amber',  home_col => 3, cost => 1 },
    B => { name => 'bronze', home_col => 5, cost => 10 },
    C => { name => 'copper', home_col => 7, cost => 100 },
    D => { name => 'desert', home_col => 9, cost => 1000 }
);
my $Map;
my $state;
my $pos;
my $R = 0;
my $C = 0;

if ($part2) {
    splice( @input, 3, 0, ( '  #D#C#B#A#', '  #D#B#A#C#' ) );
}

for my $line (@input) {
    $C = 0;
    for my $t ( split( '', $line ) ) {
        $Map->{$R}{$C} = $t;
        if ( $t =~ m/[ABCD]/ ) {
            $state->{$R}{$C} = $t;
            $Map->{$R}{$C}   = '.';
        }
        $C++;
    }
    $R++;
}
sub move_and_cost;
sub dump_map;
sub serialize_state;
sub deserialize_state;

my $st = serialize_state($state);
say "R=$R, C=$C" if $debug;
dump_map($st) if $debug;
dump $state   if $debug;

my $goal_state = {
    2 => { 3 => "A", 5 => "B", 7 => "C", 9 => "D" },
    3 => { 3 => "A", 5 => "B", 7 => "C", 9 => "D" },
};
if ($part2) {
    $goal_state->{4} = { 3 => "A", 5 => "B", 7 => "C", 9 => "D" };
    $goal_state->{5} = { 3 => "A", 5 => "B", 7 => "C", 9 => "D" };
}

my $goal = serialize_state($goal_state);
my $pq   = Array::Heap::PriorityQueue::Numeric->new();
$pq->add( $st, 0 );
my $cost_so_far;
$cost_so_far->{$st} = 0;
my $ans;
my $round=0;
SEARCH:
while ( $pq->peek ) {
    my $cur = $pq->get();
    if ( $cur eq $goal ) {
        $ans = $cost_so_far->{$goal};
        last SEARCH;
    }

    # generate new states
    my $ret = move_and_cost($cur);
    next unless $ret;
    my @moves = @{$ret};
    for my $move (@moves) {

        my $new_cost = $cost_so_far->{$cur} + $move->{cost};
        if ( !exists $cost_so_far->{ $move->{state} }
            or $new_cost < $cost_so_far->{ $move->{state} } )
        {
            $cost_so_far->{ $move->{state} } = $new_cost;
            $pq->add( $move->{state}, $new_cost );
        }

    }
    $round++;

}
say "Rounds: $round";
### FINALIZE - tests and run time
if ( !$part2 ) {

    if ($testing) {
        is( $ans, 12521, "TESTING Part 1: $ans" );

    }
    else {
        is( $ans, 18300, "Part 1: $ans" );
    }
}
else {
    is( $ans, 50190, "Part 2: $ans" );
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

sub move_and_cost {

    # in: a state string
    # out: a list of new state strings with costs
    my ($str) = @_;
    my $st = deserialize_state($str);

    my $ret;

    # scan the map, generate possible targets
    my @to_try;
    for my $r ( sort { $a <=> $b } keys %{$st} ) {
        for my $c ( sort { $a <=> $b } keys %{ $st->{$r} } ) {
            if ( $r == 1 ) {    # hallway, valid targets are burrows
                my $col = $amphipods{ $st->{$r}{$c} }->{home_col};

                for my $lvl ( 2 .. $R - 2 )
                {               # test every level in target burrow
                    if (none { exists $st->{$_}{$col} } ( 2 .. $lvl )
                        and all { exists $st->{$_}{$col}
			and $st->{$_}{$col} eq
				    $st->{$r}{$c}}( $lvl + 1 .. $R - 2 )) {
                        push @to_try,
                            { from => [ $r, $c ], to => [ $lvl, $col ] };
                    }
                }
            }
            else {    # we are starting from a burrow, see if we can move
                my $col = $amphipods{ $st->{$r}{$c} }->{home_col};
                if ($c == $col
                    and all { exists $st->{$_}{$c}
		    and $st->{$_}{$c} eq
				$st->{$r}{$c}} ( $r + 1 .. $R - 2 )){
                    # already in a target state, don't move
                    next;
                }
                elsif ( $c == $col and exists $st->{ $r - 1 }{$c} )
                {    #blocked from moving out
                    next;
                }
                my $can_goto_burrow = 0;
                for my $lvl ( 2 .. $R - 2 )
                {    # test every level in target burrow
                    if (none { exists $st->{$_}{$col} } ( 2 .. $lvl )
                        and all { exists $st->{$_}{$col}
			and $st->{$_}{$col}
				    eq $st->{$r}{$c}}( $lvl + 1 .. $R - 2 )) {
                        push @to_try,
                            { from => [ $r, $c ], to => [ $lvl, $col ] };
                        $can_goto_burrow++;
                    }
                }
                if ( !$can_goto_burrow ) {   # we need to move to the corridor
                    for my $tc ( 1, 2, 4, 6, 8, 10, 11 ) {
                        next if exists $st->{1}{$tc};    # occupied
                        push @to_try,
                            { from => [ $r, $c ], to => [ 1, $tc ] };
                    }
                }
            }
        }
    }

    # use BFS to check paths
    return undef unless @to_try;
    for my $try (@to_try) {
        my @queue = ( [ 0, $try->{from} ] );
        my %seen;
        my $shortest = undef;
    BFS:
        while (@queue) {
            my $cur  = shift @queue;
            my $step = $cur->[0];
            my ( $r, $c ) = @{ $cur->[1] };
            next if exists $seen{$r}{$c};
            $seen{$r}{$c}++;

            $step += 1;
            for my $d ( [ -1, 0 ], [ 1, 0 ], [ 0, -1 ], [ 0, 1 ] ) {
                my ( $dr, $dc ) = ( $r + $d->[0], $c + $d->[1] );
                if ( $Map->{$dr}{$dc} ne '.' or exists $st->{$dr}{$dc} ) {
                    next;
                }
                if ( $dr == $try->{to}[0] and $dc == $try->{to}[1] )
                {    # reached target
                    $shortest = $step;
                    last BFS;
                }
                push @queue, [ $step, [ $dr, $dc ] ];
            }
        }
        if ($shortest) {    # we have found a path

            # update the state for this move
            my ( $rf, $cf ) = map { $try->{from}[$_] } ( 0, 1 );
            my $type = $st->{$rf}{$cf};
            my ( $rt, $ct ) = map { $try->{to}[$_] } ( 0, 1 );
            my $cost = $shortest * $amphipods{$type}->{cost};

            my $new_st = clone $st;
            delete $new_st->{$rf}{$cf};
            $new_st->{$rt}{$ct} = $type;

            push @$ret, { cost => $cost, state => serialize_state($new_st) };
        }
    }
    return $ret if $ret;
}

sub dump_map {
    my ($str) = @_;
    my $st = deserialize_state($str);
    for my $r ( sort { $a <=> $b } keys %$Map ) {
        for my $c ( sort { $a <=> $b } keys %{ $Map->{$r} } ) {
            if ( $st->{$r}{$c} ) {
                print $st->{$r}{$c};
            }
            else {
                print $Map->{$r}{$c};
            }

        }
        print "\n";
    }
}

sub serialize_state {
    my ($st) = @_;
    my @ar;
    for my $r ( sort { $a <=> $b } keys %$st ) {
        for my $c ( sort { $a <=> $b } keys %{ $st->{$r} } ) {
            push @ar, join( ',', $r, $c, $st->{$r}{$c} );
        }
    }
    return join( ';', @ar );
}

sub deserialize_state {
    my ($str) = @_;
    my $st;
    for my $el ( split( ';', $str ) ) {
        my ( $r, $c, $t ) = split( ',', $el );
        $st->{$r}{$c} = $t;
    }
    return $st;
}
