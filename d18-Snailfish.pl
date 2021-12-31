#! /usr/bin/env perl
# Advent of Code 2021 Day 18 - Snailfish - complete solution
# https://adventofcode.com/2021/day/18
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d18
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum any all/;
use Data::Dump qw/dump/;
use POSIX qw [ceil floor];

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
sub explode;
sub mysplit;
sub reduce;
sub add;
sub dump_snf;
sub magnitude;

my @homework;
my %ans;

for my $line (@input) {
    push @homework, [ split( '', $line ) ];
}

# part 1
my $t1 = $homework[0];
my $sum;
for my $idx ( 1 .. $#homework ) {
    my $t2 = $homework[$idx];
    $sum = add( $t1, $t2 );
    $t1  = $sum;
}
$ans{1} = magnitude($sum);
is( $ans{1}, 4417, "Part 1: $ans{1}" );

# part 2
my $max_mag = 0;
for my $i ( keys @homework ) {
    say "==> $i" if $i%10==0;
    for my $j ( keys @homework ) {
        next if $i == $j;
        my ( $mag1, $mag2 ) = (
            magnitude( add( $homework[$i], $homework[$j] ) ),
            magnitude( add( $homework[$i], $homework[$j] ) )
        );
        $max_mag = $mag1 if $mag1 > $max_mag;
        $max_mag = $mag2 if $mag2 > $max_mag;
    }
}

$ans{2} = $max_mag;
is( $ans{2}, 4796, "Part 2: $ans{2}" );
### FINALIZE - tests and run time

done_testing();
say sec_to_hms( tv_interval($start_time) );

### SUBS
sub sec_to_hms {
    my ($s) = @_;
    return sprintf(
        "Duration: %02dh%02dm%02ds (%.3f ms)",
        int( $s / ( 60 * 60 ) ), ( $s / 60 ) % 60, $s % 60, $s * 1000 );
}

sub explode {
    my ($snf) = @_;

    my $depth = 0;
    for my $idx ( keys @$snf ) {

        my $part = $snf->[$idx];
        if ( $part eq '[' ) {
            $depth++;
            next;
        }
        if ( $part eq ']' ) {
            $depth--;
            next;
        }
        next if $part eq ',';
        if ( $depth > 4 ) {

            my $left  = $part;
            my $i     = $idx;
            my $right = $snf->[ $i + 2 ];
            my $j     = $i;
            next unless all { $_ =~ /\d+/ } ( $left, $right );
            say join( '', @{$snf}[ $i - 1 .. $i + 3 ] ) if $debug;
            while ( --$j >= 0 ) {
                next if ( any { $snf->[$j] eq $_ } ( '[', ',', ']' ) );
                $snf->[$j] += $left;
                last;
            }
            my $k = $i + 2;
            while ( ++$k < @$snf ) {
                next if ( any { $snf->[$k] eq $_ } ( '[', ',', ']' ) );
                $snf->[$k] += $right;
                last;
            }
            splice @$snf, $i - 1, 5, 0;
            return $snf;
        }

    }
    return undef;
}

sub mysplit {
    my ($snf) = @_;
    for my $idx ( keys @$snf ) {
        my $part = $snf->[$idx];
        next
            if ( any { $snf->[$idx] eq $_ } ( '[', ',', ']' ) or $part < 10 );
        splice @$snf, $idx, 1,
            (
            '[', floor( $snf->[$idx] / 2 ),
            ',', ceil( $snf->[$idx] / 2 ), ']'
            );
        return $snf;
    }
    return undef;
}

sub reduce {
    my ($snf) = @_;
    my @stack;
    push @stack, 'spl';
    push @stack, 'exp';
    while (@stack) {
        my $act = pop @stack;
        my $res;
        if ( $act eq 'exp' ) {
            say "=> explode" if $debug;
            $res = explode($snf);
            if ($res) {
                $snf = $res;
                push @stack, 'exp';
            }
            dump_snf($snf) if $debug;
        }
        elsif ( $act eq 'spl' ) {
            say "==> split" if $debug;
            $res = mysplit($snf);
            if ($res) {
                $snf = $res;
                push @stack, 'spl';
                push @stack, 'exp';
            }
            dump_snf($snf) if $debug;

        }
    }
    return $snf;
}

sub add {    # input: two snailfish numbers
    my ( $t1, $t2 ) = @_;
    my $snf = [ '[', @$t1, ',', @$t2, ']' ];
    dump_snf($snf) if $debug;
    my $res = reduce($snf);
    return $res;
}

sub dump_snf {
    my ($snf) = @_;
    my @arr;
    my $depth = 0;
    for my $idx ( keys @$snf ) {
        my $part = $snf->[$idx];
        print $part;
        if ( $part eq '[' ) {
            $depth++;
            $arr[$idx] = $depth;
            next;
        }
        if ( $part eq ']' ) {
            $depth--;
            $arr[$idx] = $depth;
            next;
        }
    }
    print "\n";
    for my $idx ( keys @$snf ) {
        print $arr[$idx] ? $arr[$idx] : '.';
    }

    print "\n";
}

sub magnitude {
    no warnings 'uninitialized';

    my ($snf) = @_;
    while ( scalar @$snf > 2 ) {
        for my $idx ( keys @$snf ) {
            if (    $snf->[$idx] eq '['
                and $snf->[ $idx + 1 ] =~ /\d+/
                and $snf->[ $idx + 2 ] eq ','
                and $snf->[ $idx + 3 ] =~ /\d+/
                and $snf->[ $idx + 4 ] eq ']' )
            {
                my $mag = 3 * $snf->[ $idx + 1 ] + 2 * $snf->[ $idx + 3 ];
                splice @$snf, $idx, 5, $mag;
            }
        }
    }
    return $snf->[0];
}
