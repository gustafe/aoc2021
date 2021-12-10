#! /usr/bin/env perl
# Advent of Code 2021 Day 10 - Syntax Scoring - complete solution
# https://adventofcode.com/2021/day/10
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d10
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
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE

my %closers    = ( ']' => '[', ')' => '(', '}' => '{',  '>' => '<' );
my %openers = reverse %closers;
my %scores     = ( ')' => 3,   ']' => 57,  '}' => 1197, '>' => 25137 );
my %autoscores = ( ')' => 1,   ']' => 2,   '}' => 3,    '>' => 4 );
my @part2;
sub parse_line;
my $score = 0;

for my $line (@input) {
    my $ret = parse_line($line);
    if ( $ret !~ /1/ ) {
        $score += $scores{$ret};
    }
}

@part2 = sort { $a <=> $b } @part2;

my $part2 = $part2[ int( ( scalar @part2 ) / 2 ) ];
### FINALIZE - tests and run time
is( $score, 318081,     "Part 1: $score" );
is( $part2, 4361305341, "Part 2: $part2" );
done_testing();
say sec_to_hms( tv_interval($start_time) );

### SUBS
sub parse_line {
    my ($l) = @_;
    my @l = split( '', $l );
    my @stack;
LOOP:
    for my $t (@l) {

        if ( exists $closers{$t} ) {    # found a closing token
            my $c = pop @stack;
            return $t unless ( $closers{$t} eq $c );
        }
        else {
            push @stack, $t;
        }
    }

    # part 2
    if ( scalar @stack > 1 ) { 
        my @autocomplete = map { $openers{$_} } reverse @stack;
        my $total        = 0;
        for my $c (@autocomplete) {
            $total *= 5;
            $total += $autoscores{$c};
        }
        push @part2, $total;
    }

    return 1;
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
