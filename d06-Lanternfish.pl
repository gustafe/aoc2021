#! /usr/bin/env perl
# Advent of Code 2021 Day 6 - Lanternfish - complete solution
# https://adventofcode.com/2021/day/6
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d06
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
my $part2   = shift @ARGV // 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my %generations;
for my $f ( split( ',', $input[0] ) ) {
    $generations{$f}++;
}
sub dump_state;
my $days  = 1;
my $limit = $part2 ? 256 : 80;
while ( $days <= $limit ) {
    my %new = ();
    for my $cohort ( sort keys %generations ) {
        if ( $cohort == 0 ) {
            $new{6} = $generations{0};
            $new{8} = $generations{0};
        }
        else {
            $new{ $cohort - 1 } += $generations{$cohort};
        }
    }
    %generations = %new;
    $days++;
}
my $ans = 0;
for my $cohort ( keys %generations ) {
    $ans += $generations{$cohort};
}
if ($part2) { is( $ans, 1617359101538, "Part 2: $ans" ) }
       else { is( $ans,        356190, "Part 1: $ans" ) }
### FINALIZE - tests and run time
# is();
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

sub dump_state {
    my ($state) = @_;
    for my $c ( sort { $a <=> $b } keys %$state ) {
        printf( "%2d: %3d ", $c, $state->{$c} );
    }
    print "\n";
}
