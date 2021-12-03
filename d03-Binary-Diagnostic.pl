#! /usr/bin/env perl
# Advent of Code 2021 Day 3 - Binary Diagnostic - complete solution
# https://adventofcode.com/2021/day/3
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d03
# License: https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';
# useful modules
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
use utf8;
sub sec_to_hms;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array

my $testing = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my @data;
my %freq;
for my $line (@input) {
    my @values = split( //, $line );
    push @data, \@values;
    map { $freq{$_}->{ $values[$_] }++ } ( 0 .. $#values );
}

sub filter_by_index {
    no warnings 'uninitialized';
    my ( $idx, $oxy, $cdx ) = @_;

    my $new_oxy;
    my $new_cdx;

    # oxygen values, columns that have the most common values are to be kept
    my @col;
    for my $i ( keys %$oxy ) {
        push @col, $data[$i]->[$idx];
    }
    my $most_common;
    my @vals;
    $vals[0] = grep { $_ == 0 } @col;
    $vals[1] = grep { $_ == 1 } @col;
    $most_common = $vals[1] >= $vals[0] ? 1 : 0;
    if ( scalar keys %$oxy == 1 ) {
        $new_oxy = $oxy;
    }
    else {
	map {$new_oxy->{$_}++ if $data[$_][$idx]==$most_common } keys %$oxy;
    }

    # C02: columns with the least common values are to be kept

    @col = ();
    for my $i ( keys %$cdx ) {
        push @col, $data[$i]->[$idx];
    }

    my $least_common;
    $vals[0] = grep { $_ == 0 } @col;
    $vals[1] = grep { $_ == 1 } @col;
    $least_common = $vals[0] <= $vals[1] ? 0 : 1;
    if ( scalar keys %$cdx == 1 ) {
        $new_cdx = $cdx;
    }
    else {
	map {$new_cdx->{$_}++ if $data[$_][$idx]==$least_common} keys %$cdx;
    }

    return [ $new_oxy, $new_cdx ];
}
## Part 1

my ( $𝛾, $ε );
for my $i ( 0 .. ( scalar keys %freq ) - 1 ) {
    if ( $freq{$i}->{0} > $freq{$i}->{1} ) {
        $𝛾 .= 0;
        $ε .= 1;
    }
    elsif ( $freq{$i}->{1} > $freq{$i}->{0} ) {
        $𝛾 .= 1;
        $ε .= 0;
    }
}
my $part1 = oct( "0b" . $𝛾 ) * oct( "0b" . $ε );
## Part 2

# initial setup, mark all rows as valid
my $oxy = { map { $_ => 1 } ( 0 .. $#data ) };
my $cdx = { map { $_ => 1 } ( 0 .. $#data ) };

for my $idx ( 0 .. scalar @{ $data[0] } - 1 ) {
    ( $oxy, $cdx ) = @{ filter_by_index( $idx, $oxy, $cdx ) };
}

my $part2 = oct( "0b" . join( '', @{ $data[ ( keys %$oxy )[0] ] } ) ) *
            oct( "0b" . join( '', @{ $data[ ( keys %$cdx )[0] ] } ) );

### FINALIZE - tests and run time
is( $part1, 2003336, "Part 1: $part1" );
is( $part2, 1877139, "Part 2: $part2" );
done_testing();
say sec_to_hms( tv_interval($start_time) );

### SUBS
sub sec_to_hms {  
    my ($s) = @_;
    return sprintf("Duration: %02dh%02dm%02ds (%.3f ms)",
    int( $s / ( 60 * 60 ) ), ( $s / 60 ) % 60, $s % 60, $s * 1000 );
}
