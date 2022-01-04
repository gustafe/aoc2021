#! /usr/bin/env perl
# Advent of Code 2021 Day 22 - Reactor Reboot - part 2
# https://adventofcode.com/2021/day/22
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d22
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum min max product/;
use Data::Dump qw/dump /;
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
sub sec_to_hms;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array

my $testing = 0;
my $debug   = 0;
my @input;
my $file = $testing ? 'test2.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE
my @instr;
for my $line (@input) {
    if ( $line =~
 m/^(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)$/
        ) {
        my $state = $1;
        push @instr, { sign => $state eq 'on' ? 1 : -1,
		       x    => { min => $2, max => $3 },
		       y    => { min => $4, max => $5 },
		       z    => { min => $6, max => $7 } };
    }
    else {
        warn "can't parse: $line";
    }
}
sub intersect;
sub get_intersection;
sub get_volume;

my @construct = shift @instr;
while (@instr) {
    my $curr = shift @instr;
    my @intersections;
    for my $comp (@construct) {
        if ( intersect( $curr, $comp ) ) {
            push @intersections, get_intersection( $curr, $comp );
        }
        else {
            next;
        }
    }
    push @construct, @intersections;

    if ( $curr->{sign} == 1 ) {
        push @construct, $curr;
    }
}

my $sum;
for my $b (@construct) {
    $sum += get_volume($b) * $b->{sign};
}
say $sum;
### FINALIZE - tests and run time
is($sum, 1235164413198198, "Part 2: $sum");
done_testing();
say sec_to_hms( tv_interval($start_time) );

### SUBS
sub sec_to_hms {
    my ($s) = @_;
    return sprintf(
        "Duration: %02dh%02dm%02ds (%.3f ms)",
        int( $s / ( 60 * 60 ) ), ( $s / 60 ) % 60, $s % 60, $s * 1000 );
}

sub intersect {
    my ( $b1, $b2 ) = @_;
    if (($b1->{x}{min} <= $b2->{x}{max} and $b1->{x}{max} >= $b2->{x}{min}) and
        ($b1->{y}{min} <= $b2->{y}{max} and $b1->{y}{max} >= $b2->{y}{min}) and
        ( $b1->{z}{min} <= $b2->{z}{max} and $b1->{z}{max} >= $b2->{z}{min} ))
      {
	  return 1;
      }
    else {
        return 0;
    }
}

sub get_intersection {
    my ( $b1, $b2 ) = @_;

    my $min_x = max( $b1->{x}{min}, $b2->{x}{min} );
    my $max_x = min( $b1->{x}{max}, $b2->{x}{max} );

    my $min_y = max( $b1->{y}{min}, $b2->{y}{min} );
    my $max_y = min( $b1->{y}{max}, $b2->{y}{max} );

    my $min_z = max( $b1->{z}{min}, $b2->{z}{min} );
    my $max_z = min( $b1->{z}{max}, $b2->{z}{max} );

    my $sign = $b1->{sign} * $b2->{sign};
    if ( $b1->{sign} == $b2->{sign} ) {
	$sign = -1 * $b1->{sign};
    }
    elsif ( $b1->{sign} == 1 and $b2->{sign} == -1 ) {
	$sign = 1;
    }
    return {
        sign => $sign,
        x    => { min => $min_x, max => $max_x },
        y    => { min => $min_y, max => $max_y },
        z    => { min => $min_z, max => $max_z },
    };
}

sub get_volume {
    my ($b) = @_;
    return product( map { $b->{$_}{max} - $b->{$_}{min} + 1 } qw/ x y z / );
}
