#! /usr/bin/env perl
# Advent of Code 2021 Day 16 - Packet Decoder - part 1
# https://adventofcode.com/2021/day/16
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d16
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum min max product/;
use Data::Dump qw/dump/;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
sub sec_to_hms;
no warnings 'portable';
my $start_time = [gettimeofday];
#### INIT - load input data from file into array

my $testing = 0;
my $debug   = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

sub decode;

my @test_p1 = (
    'D2FE28',                     '38006F45291200',
    'EE00D40C823060',             '8A004A801A8002F478',
    '620080001611562C8802118E34', 'C0015000016115A2E0802F182340',
    'A0016C880162017C3686B18A3D4780',
);
my @ans_p1 = ( 6, 9, 14, 16, 12, 23, 31 );
### CODE
my $version_sum;
my $idx = 0;

for my $line ( @test_p1, $input[0] ) {
    chomp $line;
    say $line if $debug;
    $version_sum = 0;
    my $B;
    for ( split( '', $line ) ) {
        push @$B, split( '', sprintf( "%04b", hex($_) ) );
    }

    my @res;
    push( @res, decode($B) );
    if ( $idx < scalar @ans_p1 ) {
        is( $version_sum, $ans_p1[$idx], "Test $ans_p1[$idx]: ok" );
    }
    else {
        is( $version_sum, 866, "Part 1: $version_sum" );
    }
    $idx++;
}

### FINALIZE - tests and run time
# is();
done_testing();
say sec_to_hms( tv_interval($start_time) );
### SUBS
sub decode {
    my ($in) = @_;
    my $res;

    while (@$in) {

        my $version = oct( '0b' . join( '', splice( @$in, 0, 3 ) ) );
        $version_sum += $version;
        my $id = oct( '0b' . join( '', splice( @$in, 0, 3 ) ) );
        say "(V: $version I: $id)" if $debug;
        if ( $id == 4 ) {

            # literal number
            my $next = 1;
            my @num;
            while ($next) {
                my @chunk = splice( @$in, 0, 5 );
                $next = shift @chunk;
                push @num, @chunk;
            }
            $res = oct( '0b' . join( '', @num ) );
            say "(Num: $res)" if $debug;
        }
        else {
            my @vals;
            my $lenid = shift @$in;
            if ($lenid) {    # 11
                my $n = oct( '0b' . join( '', splice( @$in, 0, 11 ) ) );
                say "(Rep: $n)" if $debug;
                for ( 1 .. $n ) {
                    push @vals, decode($in);
                }
            }
            else {           # 15
                my $len = oct( '0b' . join( '', splice( @$in, 0, 15 ) ) );
                say "(L: $len)" if $debug;
                my $sub = [ splice( @$in, 0, $len ) ];
                say "  ", join( '', @$sub ) if $debug;
                push @vals, decode($sub);

            }

        }

    }

    return $res;
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

