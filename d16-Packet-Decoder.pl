#! /usr/bin/env perl
#! /usr/bin/env perl
# Advent of Code 2021 Day 16 - Packet Decoder - complete solution
# https://adventofcode.com/2021/day/16
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d16
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum min max product all/;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
sub sec_to_hms;
no warnings 'portable';
my $start_time = [gettimeofday];
#### INIT - load input data from file into array

my $testing = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

sub decode;

my %actions = (
    4 => 'literal number',
    0 => sub { sum @_ },
    1 => sub { product @_ },
    2 => sub { min @_ },
    3 => sub { max @_ },
    5 => sub { $_[0] > $_[1] ? 1 : 0 },
    6 => sub { $_[0] < $_[1] ? 1 : 0 },
    7 => sub { $_[0] == $_[1] ? 1 : 0 },

);

my @test_p1 = (
    'D2FE28',                     '38006F45291200',
    'EE00D40C823060',             '8A004A801A8002F478',
    '620080001611562C8802118E34', 'C0015000016115A2E0802F182340',
    'A0016C880162017C3686B18A3D4780',
);
my @ans_p1 = ( 6, 9, 14, 16, 12, 23, 31 );
my @test_p2
    = qw/C200B40A82 04005AC33890 880086C3E88112 CE00C43D881120 D8005AC2A8F0 F600BC2D8F 9C005AC2F8F0 9C0141080250320F1802104A08/;
my @ans_p2 = qw/3 54 7 9 1 0 0 1/;
### CODE
my $version_sum;
my $idx = 0;
say "==> Part 1 <==";
for my $line ( @test_p1, $input[0] ) {
    chomp $line;
    $version_sum = 0;
    my $B;
    for ( split( '', $line ) ) {
        push @$B, split( '', sprintf( "%04b", hex($_) ) );
    }

    my @res;
    push( @res, decode($B) );
    if ( $idx < scalar @ans_p1 ) {
        is( $version_sum, $ans_p1[$idx], "Test $idx: ok" );
    }
    else {
        is( $version_sum, 866, "Part 1: $version_sum" );
    }
    $idx++;
}
say "==> Part 2 <==";
$idx = 0;
for my $line ( @test_p2, $input[0] ) {
    chomp $line;
    $version_sum = 0;
    my $B;
    for ( split( '', $line ) ) {
        push @$B, split( '', sprintf( "%04b", hex($_) ) );
    }

    my @res;
    decode( $B, 0, \@res );

    if ( $idx < scalar @ans_p2 ) {
        is( $res[0], $ans_p2[$idx], "Test $idx: ok" );
    }
    else {
        is( $res[0], 1392637195518, "Part 2: $res[0]" );
    }
    $idx++;
}

### FINALIZE - tests and run time

done_testing();
say sec_to_hms( tv_interval($start_time) );
### SUBS
sub decode {
    my ( $in, $reps, $vals ) = @_;
    my $visits = 0;
    while (@$in) {
        last if all { $_ == 0 } @$in;
        last if $reps and $reps == $visits;

        my $version = oct( '0b' . join( '', splice( @$in, 0, 3 ) ) );
        $version_sum += $version;
        my $id = oct( '0b' . join( '', splice( @$in, 0, 3 ) ) );
        $visits++;
        if ( $id == 4 ) {

            # literal number
            my $next = 1;
            my @num;
            while ($next) {
                my @chunk = splice( @$in, 0, 5 );
                $next = shift @chunk;
                push @num, @chunk;
            }
            push @$vals, oct( '0b' . join( '', @num ) );
        }
        else {
            my @subvals;
            my $lenid = shift @$in;
            if ($lenid) {    # 11
                my $n = oct( '0b' . join( '', splice( @$in, 0, 11 ) ) );
                decode( $in, $n, \@subvals );
            }
            else {           # 15
                my $len = oct( '0b' . join( '', splice( @$in, 0, 15 ) ) );
                my $sub = [ splice( @$in, 0, $len ) ];
                decode( $sub, 0, \@subvals );

            }
            push @$vals, $actions{$id}->(@subvals);
        }
    }
    return $in;
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
