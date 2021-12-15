#! /usr/bin/env perl
# Advent of Code 2021 Day 14 - Extended Polymerization - part 1
# https://adventofcode.com/2021/day/14
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d14
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
my $template = shift @input;
shift @input;
my %rules;
for my $line (@input) {
    if ( $line =~ m/(.*) -> (.*)/ ) {
        $rules{$1} = $2;
    }
}
my $step    = 1;
my @initial = split( "", $template );
my $LIMIT   = 10;
while ( $step <= $LIMIT ) {
    my @next;
    my $idx = 0;
    while ( $idx < $#initial ) {
        my $pair = $initial[$idx] . $initial[ $idx + 1 ];

        if ( $rules{$pair} ) {
            push @next, ( $initial[$idx], $rules{$pair} );
            $idx += 1;
        }
        else {
            $idx++;
        }
    }
    push @next, $initial[-1];
    @initial = @next;

    $step++;
}
my %freq;
for my $c (@initial) {
    $freq{$c}++;
}
my @res = ( sort { $freq{$b} <=> $freq{$a} } keys %freq );
my ( $most, $least ) = ( $freq{ $res[0] }, $freq{ $res[-1] } );
my $ans1 = $most - $least;

### FINALIZE - tests and run time
is( $ans1, 2321, "Part 1: $ans1" );
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
