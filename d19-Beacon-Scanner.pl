#! /usr/bin/env perl
# Advent of Code 2021 Day 19 - Beacon Scanner - complete solution
# https://adventofcode.com/2021/day/19
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d19
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################

use Modern::Perl '2015';

# useful modules
use List::Util qw/sum/;
use Data::Dump qw/dump/;
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

my %data;
my $scanner_id = undef;
for my $line (@input) {
    if ( $line =~ m/^--- scanner (\d+) ---$/ ) {
        $scanner_id = $1;
    }
    else {
        my $coord = [ split( /,/, $line ) ];
        push @{ $data{$scanner_id} }, $coord
            if defined $scanner_id and scalar @$coord;
    }
}

# load all tranformation matrices (copied from this site:
# https://www.euclideanspace.com/maths/algebra/matrix/transforms/examples/index.htm)
my $transforms;
my @list;
while (<DATA>) {
    chomp;
    s/\r//gm;
    push @list, $_;
}
while (@list) {

    # grab 3 lines + empty
    my $m;
    for ( 1 .. 3 ) {
        push @$m, [ split( /\s+/, shift @list ) ];
    }
    push @$transforms, $m;
    shift @list;
}
my $seen;
my @check = ( { id => 0, beacons => $data{0}, pos => "0,0,0" } );
my @res;
while (@check) {

    # this rigmarole is to avoid modifying datastructures in the loop
    my $next    = shift @check;
    my $s1      = $next->{id};
    my $beacons = $next->{beacons};
    push @res, $next;
    for my $s2 ( sort { $a <=> $b } keys %data ) {
        next if $s1 == $s2;
        next if $seen->{$s1}{$s2} or $seen->{$s2}{$s1};
        $seen->{$s1}{$s2}++; $seen->{$s2}{$s1}++;

        say "comp $s1 $s2" if $debug;
        my $rotations;
        for my $v ( @{ $data{$s2} } ) {
            push @$rotations, rotate_vec($v);
        }

        my $matches;

        for my $R (@$rotations) {
            my $rot = 0;
            for my $c (@$R) {
                for my $v (@$beacons) {
                    $matches->{$rot}{x}{ $v->[0] - $c->[0] }++;
                    $matches->{$rot}{y}{ $v->[1] - $c->[1] }++;
                    $matches->{$rot}{z}{ $v->[2] - $c->[2] }++;
                }
                $rot++;
            }
        }
        my $summary;
        for my $rot ( sort { $a <=> $b } keys %{$matches} ) {
            for my $axis (qw/x y z/) {
                for my $d ( keys %{ $matches->{$rot}{$axis} } ) {

                    $summary->{$rot}{$axis} = $d
                        if $matches->{$rot}{$axis}{$d} >= 12;
                }
            }
        }
        dump $summary if $debug;

        my ($sought) = grep {
            $summary->{$_}{x} and $summary->{$_}{y} and $summary->{$_}{z}
        } keys %$summary;
        next unless $sought;

        say "$s2 <-> $s1: $sought" if $debug;
        my $rotated;
        for my $v (@$rotations) {
            push @$rotated, $v->[$sought];
        }
        my $scanner_pos
            = join( ',', map { $summary->{$sought}{$_} } qw/x y z/ );
        my $rot_and_shift;
        for my $coord (@$rotated) {
            push @$rot_and_shift,
                [
                $coord->[0] + $summary->{$sought}->{x},
                $coord->[1] + $summary->{$sought}->{y},
                $coord->[2] + $summary->{$sought}->{z}
                ];
        }
        push @check,
            { id => $s2, beacons => $rot_and_shift, pos => $scanner_pos };

    }
}
my %all_beacons;
for my $sc (@res) {

    for my $v ( @{ $sc->{beacons} } ) {
        my $str = join( ',', @$v );

        $all_beacons{$str}++;

    }
}

my $max_dist = 0;
sub manhattan;
for my $set1 (@res) {
    for my $set2 (@res) {
        next if $set1->{id} == $set2->{id};
        my $d = manhattan( $set1->{pos}, $set2->{pos} );
        $max_dist = $d if $d > $max_dist;
    }
}

### FINALIZE - tests and run time
is( scalar keys %all_beacons,   315, "Part 1: " . scalar keys %all_beacons );
is( $max_dist,                13192, "Part 2: $max_dist" );
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

sub rotate_vec {    # given a 3 element arrayref, return all 24 rotations
    my ($v) = @_;
    my $res;
    for my $m (@$transforms) {
        push @$res,
            [
            $m->[0][0] * $v->[0]
                + $m->[0][1] * $v->[1]
                + $m->[0][2] * $v->[2],
            $m->[1][0] * $v->[0]
                + $m->[1][1] * $v->[1]
                + $m->[1][2] * $v->[2],
            $m->[2][0] * $v->[0] + $m->[2][1] * $v->[1] + $m->[2][2] * $v->[2]
            ];
    }
    return $res;
}

sub manhattan {
    my ( $p1, $p2 ) = @_;
    my @p1 = split( ',', $p1 );
    my @p2 = split( ',', $p2 );
    return sum( map { abs( $p2[$_] - $p1[$_] ) } ( 0 .. 2 ) );
}

__DATA__
1	0	0
0	1	0
0	0	1

1	0	0
0	0	-1
0	1	0

1	0	0
0	-1	0
0	0	-1

1	0	0
0	0	1
0	-1	0

0	-1	0
1	0	0
0	0	1

0	0	1
1	0	0
0	1	0

0	1	0
1	0	0
0	0	-1

0	0	-1
1	0	0
0	-1	0

-1	0	0
0	-1	0
0	0	1

-1	0	0
0	0	-1
0	-1	0

-1	0	0
0	1	0
0	0	-1

-1	0	0
0	0	1
0	1	0

0	1	0
-1	0	0
0	0	1

0	0	1
-1	0	0
0	-1	0

0	-1	0
-1	0	0
0	0	-1

0	0	-1
-1	0	0
0	1	0

0	0	-1
0	1	0
1	0	0

0	1	0
0	0	1
1	0	0

0	0	1
0	-1	0
1	0	0

0	-1	0
0	0	-1
1	0	0

0	0	-1
0	-1	0
-1	0	0

0	-1	0
0	0	1
-1	0	0

0	0	1
0	1	0
-1	0	0

0	1	0
0	0	-1
-1	0	0

