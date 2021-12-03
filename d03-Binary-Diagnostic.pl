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
my @data;
my %freq;

while (<$fh>) {
    chomp; s/\r//gm;
    my @values = split(//, $_);
    push @data, \@values;
    map { $freq{$_}->{ $values[$_] }++ } ( 0 .. $#values );
}

### CODE
sub filter_by_index_and_type;
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

# for each column, filter those entries that match the condition
for my $idx ( 0 .. scalar @{ $data[0] } - 1 ) {
    $oxy = filter_by_index_and_type( $idx, 'oxy', $oxy );
    $cdx = filter_by_index_and_type( $idx, 'cdx', $cdx );
}
my $part2 = oct( "0b" . join( '', @{ $data[ ( keys %$oxy )[0] ] } ) ) *
            oct( "0b" . join( '', @{ $data[ ( keys %$cdx )[0] ] } ) );

### FINALIZE - tests and run time
is( $part1, 2003336, "Part 1: $part1" );
is( $part2, 1877139, "Part 2: $part2" );
done_testing();
say sec_to_hms( tv_interval($start_time) );

### SUBS
sub filter_by_index_and_type {
    my ( $idx, $type, $filter ) = @_;
    my $new_filter;
    my @col;
    # select those rows that match the incoming filter
    for my $i ( keys %$filter ) {
        push @col, $data[$i]->[$idx];
    }
    # select number of 1s and 0s
    my @vals;
    $vals[0] = grep { $_ == 0 } @col;
    $vals[1] = grep { $_ == 1 } @col;
    my $common;
    if ( $type eq 'oxy' ) {
        $common = $vals[1] >= $vals[0] ? 1 : 0;
    }
    elsif ( $type eq 'cdx' ) {
        $common = $vals[0] <= $vals[1] ? 0 : 1;
    }
    else {
        die "unknown type: $type";
    }
    if ( scalar keys %$filter == 1 ) {
        return $filter;
    }
    else { # construct a new filter based on common values 
        map { $new_filter->{$_}++ if $data[$_][$idx] == $common }
            keys %$filter;
    }

    return $new_filter;
}
sub sec_to_hms {  
    my ($s) = @_;
    return sprintf("Duration: %02dh%02dm%02ds (%.3f ms)",
    int( $s / ( 60 * 60 ) ), ( $s / 60 ) % 60, $s % 60, $s * 1000 );
}
