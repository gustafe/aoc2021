#! /usr/bin/env perl
# Advent of Code 2021 Day 8 - Seven Segment Search - complete solution
# https://adventofcode.com/2021/day/8
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d08
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/any all/;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
use Algorithm::Combinatorics qw(permutations);
sub sec_to_hms;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array

my $testing = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }
sub solve;
### CODE
my @permutations = permutations( [ 'a' .. 'g' ] );

my %patterns = (
    0 => [qw/0 1 2   4 5 6/],
    1 => [qw/    2     5  /],
    2 => [qw/0   2 3 4   6/],
    3 => [qw/0   2 3   5 6/],
    4 => [qw/  1 2 3   5  /],
    5 => [qw/0 1   3   5 6/],
    6 => [qw/0 1   3 4 5 6/],
    7 => [qw/0   2     5  /],
    9 => [qw/0 1 2 3   5 6/],
);

my $count = 0;
my @values;
my @output;
my $sum = 0;
for my $line (@input) {
    my ( $in, $out ) = split( /\|/, $line );
    @values = split( " ", $in );
    @output = split( " ", $out );
    for my $el (@output) {
        $count++
            if ( length($el) == 2
            or length($el) == 3
            or length($el) == 4
            or length($el) == 7 );
    }
    my $sol = solve(@values);
    if ( defined $sol ) {

        my $num = '';
        for my $o ( map { join( "", sort split( //, $_ ) ) } @output ) {
            $num .= $sol->{$o};
        }
        $sum += $num;
    }
}
### FINALIZE - tests and run time
is( $count, 470,    "Part 1: $count" );
is( $sum,   989396, "Part 2: $sum" );
done_testing();
say sec_to_hms( tv_interval($start_time) );

### SUBS

sub solve {

    # segment numbering:
    # +-0-+
    # 1   2
    # +-3-+
    # 4   5
    # +-6-+
    my $ret = undef;
    my @v   = @_;
    @v = sort { length($a) <=> length($b) }
        map { join( "", sort split( //, $_ ) ) } @v;

    for my $per (@permutations) {
        my %p;
	# check if the current permutation can lead to a solution
	# bail if doesn't
	
        # One, Four, Seven
        my $pattern = join( '', sort map { $per->[$_] } @{ $patterns{1} } );
        next unless $pattern eq $v[0];
        $pattern = join( '', sort map { $per->[$_] } @{ $patterns{7} } );
        next unless $pattern eq $v[1];
        $pattern = join( '', sort map { $per->[$_] } @{ $patterns{4} } );
        next unless $pattern eq $v[2];

        # Two Three Five
        my @ok = ( 0, 0, 0 );
        $pattern = join( '', sort map { $per->[$_] } @{ $patterns{2} } );
        $ok[0] = any { $pattern eq $v[$_] } qw/3 4 5/;
        $pattern = join( '', sort map { $per->[$_] } @{ $patterns{3} } );
        $ok[1] = any { $pattern eq $v[$_] } qw/3 4 5/;
        $pattern = join( '', sort map { $per->[$_] } @{ $patterns{5} } );
        $ok[2] = any { $pattern eq $v[$_] } qw/3 4 5/;
        next unless all { $_ == 1 } @ok;

        # Zero Six Nine
        @ok      = ( 0, 0, 0 );
        $pattern = join( '', sort map { $per->[$_] } @{ $patterns{0} } );
        $ok[0]   = any { $pattern eq $v[$_] } qw/6 7 8/;
        $pattern = join( '', sort map { $per->[$_] } @{ $patterns{6} } );
        $ok[1]   = any { $pattern eq $v[$_] } qw/6 7 8/;
        $pattern = join( '', sort map { $per->[$_] } @{ $patterns{9} } );
        $ok[2]   = any { $pattern eq $v[$_] } qw/6 7 8/;
        next unless all { $_ == 1 } @ok;

	# we've reached a solution, let's return a mapping of strings
	# to numbers
        $p{8} = $v[-1];

        $p{1} = $v[0];
        $p{7} = $v[1];
        $p{4} = $v[2];
	# we need to filter these to identify the unique ones 
        my @rest = @v[ 3, 4, 5, 6, 7, 8 ];
        while (@rest) {
            for my $i ( 2, 3, 5, 0, 6, 9 ) {
                if ( @rest
                    and
                    join( "", sort map { $per->[$_] } @{ $patterns{$i} } ) eq
                    $rest[0] )
                {
                    $p{$i} = shift @rest;
                }
            }
        }
        $ret = { reverse %p } if scalar keys %p == 10;
    }
    return $ret;
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
