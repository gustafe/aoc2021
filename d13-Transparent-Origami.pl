#! /usr/bin/env perl
# Advent of Code 2021 Day 13 - Transparent Origami - complete solution
# https://adventofcode.com/2021/day/13
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d13
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';
# useful modules
use List::Util qw/sum max/;
use Data::Dump qw/dump/;
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
my $Map;
my %ans;
my @instr;
sub dump_map;
sub dimensions;
for my $line (@input) {
    if ( $line =~ m/^(\d+),(\d+)$/ ) {
        $Map->{$1}{$2}++;
    }
    elsif ( $line =~ m/^fold along (.)=(\d+)$/ ) {
        push @instr, [ $1, $2 ];
    }
}
my $fold = 1;
for my $cmd (@instr) {

    my $half1;
    my $half2;
    for my $x ( keys %$Map ) {
        for my $y ( keys %{ $Map->{$x} } ) {
            if ( $cmd->[0] eq 'x' ) {
                if ( $x > $cmd->[1] ) {
                    $half2->{ $cmd->[1] - ( $x - $cmd->[1] ) }{$y}++;
                }
                else {
                    $half1->{$x}{$y}++;
                }
            }
            elsif ( $cmd->[0] eq 'y' ) {
                if ( $y > $cmd->[1] ) {
                    $half2->{$x}{ $cmd->[1] - ( $y - $cmd->[1] ) }++;
                }
                else {
                    $half1->{$x}{$y}++;
                }
            }
        }
    }

    $Map = clone $half1;

    for my $x ( keys %$half2 ) {
        for my $y ( keys %{ $half2->{$x} } ) {
            $Map->{$x}{$y}++;
        }
    }
    # part 1
    if ($fold == 1) {
	$ans{1}=0;
	for my $x ( keys %$Map ) {
	    for my $y ( keys %{ $Map->{$x} } ) {
		$ans{1}++ if $Map->{$x}{$y};
	    }
	}

    }
    $fold++;
}


my $digest = dump_map;

### FINALIZE - tests and run time
is($ans{1}, 753, "Part 1: ".$ans{1});
is( $digest, '000000110111110111000000011100011010010110001110000000111110111110111110000000010110010110011110000000110111110111000000111101111110011110000001000000011011011001100110000000110111101001011110', "Part 2 OK");

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
    my $output;
    my $digest;
    my $max_y = 0;
    for my $x ( keys %$Map ) {
        $max_y
            = max( keys %{ $Map->{$x} } ) > $max_y
            ? max( keys %{ $Map->{$x} } )
            : $max_y;
    }
    my @rows;
    for my $r ( sort { $a <=> $b } keys %$Map ) {
        for my $c ( 0 .. $max_y ) {
            $output->[$c][$r] = $Map->{$r}{$c} ? '█' : '.';
	    $digest .= $Map->{$r}{$c}?0:1;
        }
    }
    for my $r (0..(scalar @$output)-1) {
        say join( '', map { $_ ? $_ : '|' } @{$output->[$r]} );
    }
    return $digest;
}

