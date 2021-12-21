#! /usr/bin/env perl
# Advent of Code 2021 Day 21 - Dirac Dice - complete solution
# https://adventofcode.com/2021/day/21.pl
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d21
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum any all min max/;
use Test::More;
use Memoize;
use Time::HiRes qw/gettimeofday tv_interval/;
sub sec_to_hms;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array

my $testing = 0;
my $debug   = 0;
my %ans;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my %players;
for my $idx ( 0, 1 ) {
    $input[$idx] =~ m/^.*(\d+).*(\d+)$/;
    $players{$1} = { pos => $2, score => 0 };
}
sub dump_players;
my $rolls = 0;
GAME:
while (1) {

    #   say "==> $rolls" if $debug;
    for my $p ( 1, 2 ) {
        my $moves;
        for my $d ( 1 .. 3 ) {
            $rolls++;
            my $diceval = $rolls % 100;
            $moves += $diceval == 0 ? 100 : $diceval;
        }
        my $target = ( $players{$p}->{pos} + $moves ) % 10;
        $players{$p}->{score} += $target == 0 ? 10 : $target;
        last GAME if $players{$p}->{score} >= 1000;
        $players{$p}->{pos} = $target;

    }
}

$ans{1} = $rolls * min( map { $players{$_}->{score} } 1, 2 );

sub ucount;
memoize 'ucount';

# reset position from input
for my $idx ( 0, 1 ) {
    $input[$idx] =~ m/^.*(\d+).*(\d+)$/;
    $players{$1} = { pos => $2, score => 0 };
}

$ans{2} = max( ucount( 3, $players{1}->{pos}, $players{2}->{pos}, 0, 0 ) );

### FINALIZE - tests and run time
is( $ans{1},          989352, "Part 1: " . $ans{1} );
is( $ans{2}, 430229563871565, "Part 2: " . $ans{2} );
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

sub dump_players {
    for my $p ( 1, 2 ) {
        printf(
            "Player %d: pos %2d score %3d\n",
            $p,
            $players{$p}->{pos},
            $players{$p}->{score}
        );
    }
}

sub ucount {
    # Credit: /u/EffectivePriority986
    # https://www.reddit.com/r/adventofcode/comments/rl6p8y/2021_day_21_solutions/hpe68q2/
    # assume turn is for player 1
    # in: rolls remaining for p1, p1 pos, p2 pos, p1 score, p2 score
    my ( $r, $p1, $p2, $s1, $s2 ) = @_;
    my ( $u1, $u2 );
    say join( ' ', ( $r, $p1, $p2, $s1, $s2 ) ) if $debug;
    unless ($r) {
        $s1 += $p1;
        if ( $s1 >= 21 ) {
            return ( 1, 0 );
        }
	# switch players 
        ( $u2, $u1 ) = ucount( 3, $p2, $p1, $s2, $s1 );
        return ( $u1, $u2 );
    }
    for my $d ( 1 .. 3 ) {
        my $np1 = $p1 + $d;
        $np1 = $np1 % 10 || 10;
        my ( $du1, $du2 ) = ucount( $r - 1, $np1, $p2, $s1, $s2 );
        $u1 += $du1;
        $u2 += $du2;

    }
    return ( $u1, $u2 );
}
