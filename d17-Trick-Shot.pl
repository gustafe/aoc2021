#! /usr/bin/env perl
# Advent of Code 2021 Day 17 - Trick Shot -  complete solution
# https://adventofcode.com/2021/day/17
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d17
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
my %ans;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my $target;
if ( $input[0] =~ m/x=(\d+)..(\d+), y=-(\d+)..-(\d+)/ ) {
    $target = {
        x => { min => $1, max => $2 },
        y => { min => $3 * (-1), max => $4 * (-1) }
    };
}

# part 1: only need to consider y. Each y(t) is a triangular number,
# so y(t) = t*(t+1)/2. If we launch upwards we will have v=0 at the
# apex. The next y's after that will have to cross the x-axis and hit
# the target box. So the highest point will be y_min*(y_min+1)/2

$ans{1} = $target->{y}{min} * ( $target->{y}{min} + 1 ) / 2;

# part 2: just brute force the solution space
my @hits;
my $count = 0;
for my $vx ( 0 .. $target->{x}{max} )
{    # any faster and we overshoot at step 1
    for my $vy ( $target->{y}{min} .. 105 )
    {    # upper range found by inspection

        my $v = { x => $vx, y => $vy };
        if ( hit($v) ) {
            push @hits, $v;
        }
    }
}

$ans{2} = scalar @hits;
is( $ans{1}, 5565, "Part 1: " . $ans{1} );
is( $ans{2}, 2118, "Part 2: " . $ans{2} );
### FINALIZE - tests and run time
# is();
done_testing();
say sec_to_hms( tv_interval($start_time) );

### SUBS

sub hit {

    my ($v) = @_;
    my ( $x, $y ) = ( 0, 0 );
    my $hit   = 0;
    my $max_y = $target->{y}{min};
    while ( $y > $target->{y}{min} and $x <= $target->{x}{max} ) {
        $x = $x + $v->{x};
        $y = $y + $v->{y};

        if (    $x >= $target->{x}{min}
            and $x <= $target->{x}{max}
            and $y <= $target->{y}{max}
            and $y >= $target->{y}{min} )
        {
            $hit = 1;
            last;
        }

        if ( $v->{x} > 0 ) {
            $v->{x}--;
        }
        elsif ( $v->{x} < 0 ) {
            $v->{x}++;
        }
        $v->{y}--;
    }
    if ($hit) {
        return $v;
    }
    else {
        return undef;
    }
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
