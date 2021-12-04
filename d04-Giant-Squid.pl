#! /usr/bin/env perl
# Advent of Code 2021 Day 4 - Giant Squid - complete solution
# https://adventofcode.com/2021/day/4
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d04
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
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
{
    local $/ = "";
    while (<$fh>) { chomp; s/\r//gm; push @input, $_; }
}

### CODE
my @draws;
my %boards;
my %positions;
my %ans;
my $count = 0;
for my $chunk (@input) {
    if ( $count == 0 ) {    # first line is draws
        @draws = split( /,/, $chunk );
    }
    else {
        my @rows  = split( /\n/, $chunk );
        my $rownr = 1;
        for my $r (@rows) {
            my @cols  = split( " ", $r );
            my $colnr = 1;
            for my $number (@cols) {
                $boards{$count}{$rownr}{$colnr} = { number => $number };
                $positions{$number}{$count}{$rownr}{$colnr} = 1;
                $colnr++;
            }
            $rownr++;
        }
    }
    $count++;
}
sub calculate_board;
sub dump_board;
# initialize the %has_won hash with zeros
my %has_won = map { $_ => 0 } keys %boards;
while (@draws) {
    my $draw = shift @draws;

    for my $board ( keys %{ $positions{$draw} } ) {
        for my $row ( keys %{ $positions{$draw}{$board} } ) {
            for my $col ( keys %{ $positions{$draw}{$board}{$row} } ) {
                $boards{$board}{$row}{$col}{marked}++;
            }
        }
    }
    for my $board ( keys %boards ) {

        # check rows
        for my $row ( 1 .. 5 ) {
            my $marked_count = 0;
            for my $col ( 1 .. 5 ) {
                $marked_count++ if $boards{$board}{$row}{$col}{marked};
            }
            if ( $marked_count == 5 ) {
                 $has_won{$board}++;
            }

        }

        # check columns
        for my $col ( 1 .. 5 ) {
            my $marked_count = 0;
            for my $row ( 1 .. 5 ) {
                $marked_count++ if $boards{$board}{$row}{$col}{marked};
            }
            if ( $marked_count == 5 ) {
                 $has_won{$board}++;
            }

        }

    }
    # what is the number of wins? 
    my %reverse = reverse %has_won;
    # either 1 or 0 wins == first board
    if ( scalar keys %reverse == 2 and exists $reverse{1} ) {
        say "First board to win: draw $draw led to win on " . $reverse{1};
        $ans{1} = $draw * calculate_board( $reverse{1} );

    }
    # every board has won at least once
    elsif ( !exists $reverse{0} ) {
	# get the board with least wins (and hope it's unique)
        my $last_won
            = ( sort { $has_won{$a} <=> $has_won{$b} } keys %has_won )[0];
        say "Final board to win: draw $draw led to win on " . $last_won;
        $ans{2} = $draw * calculate_board($last_won);
        last;
    }
}

### FINALIZE - tests and run time
is( $ans{1}, 8442, "Part 1: " . $ans{1} );
is( $ans{2}, 4590, "Part 2: " . $ans{2} );
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

sub calculate_board {
    my ($board) = @_;
    my $sum = 0;
    for my $row ( keys %{ $boards{$board} } ) {
        for my $col ( keys %{ $boards{$board}{$row} } ) {
            $sum += $boards{$board}{$row}{$col}{number}
                unless $boards{$board}{$row}{$col}{marked};
        }
    }
    return $sum;
}

sub dump_board {
    my ($b) = @_;
    for my $r ( 1 .. 5 ) {
        for my $c ( 1 .. 5 ) {
            my $num = $boards{$b}{$r}{$c}{number};
            my $string;
            if ( $boards{$b}{$r}{$c}{marked} ) {
                $string = "[$num]";
            }
            else {
                $string = $num;
            }
            printf "%4s", $string;
        }
        print "\n";
    }
}
