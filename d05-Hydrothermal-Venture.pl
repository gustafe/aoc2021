#! /usr/bin/env perl
# Advent of Code 2021 Day 5 - Hydrothermal Venture - complete solution
# https://adventofcode.com/2021/day/5
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d05
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
use Math::Trig;
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
my @lines;
my %freq;
my ( $x1, $y1, $x2, $y2 );
for my $in (@input) {
    if ( $in =~ m/^(\d+),(\d+) -> (\d+),(\d+)$/ ) {
        ( $x1, $y1, $x2, $y2 ) = ( $1, $2, $3, $4 );
    }
    else {
        die "can't parse line: $in";
    }
    my $norm_x = $x2 - $x1;
    my $norm_y = $y2 - $y1;
    my $dir    = rad2deg( atan2( $norm_y, $norm_x ) );

    $dir = $dir < 0 ? 360 + $dir : $dir;
    $freq{$dir}++;
    push @lines, {x1 => $x1, y1 => $y1, x2 => $x2, y2 => $y2, dir => $dir};
}

#dump %freq;
my $Map;
sub dump_map;
sub E; sub W; sub N; sub S;
sub NE;sub NW;sub SE;sub SW;
my %paint = ( 0 => \&E , 180 => \&W , 90 => \&S ,270 => \&N,
	     45 => \&SE, 135 => \&SW,315 => \&NE,225 => \&NW );

my %part1_dirs = ( 0 => 1, 90 => 1, 180 => 1, 270 => 1 );

for my $L (@lines) {
    my $dir = $L->{dir};
    if ( !$part2 and !exists $part1_dirs{$dir} ) {next}
    $paint{$dir}->($L);
}

my $count;
for my $x ( keys %$Map ) {
    for my $y ( keys %{ $Map->{$x} } ) {
        $count++ if $Map->{$x}{$y} >= 2;
    }
}
my $ans = $count;
if ($part2) {
    is( $ans, 18442, "Part 2: $ans" );
}
else {
    is( $ans, 4745, "Part 1: $ans" );
}

done_testing;
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

sub E {
    my ($L) = @_;
    my $steps = abs( $L->{x2} - $L->{x1} );
    for ( my $i = 0; $i <= $steps; $i++ ) {
        $Map->{ $L->{x1} + $i }{ $L->{y1} }++;
    }
}

sub W {
    my ($L) = @_;
    my $steps = abs( $L->{x2} - $L->{x1} );
    for ( my $i = 0; $i <= $steps; $i++ ) {
        $Map->{ $L->{x1} - $i }{ $L->{y1} }++;
    }
}

sub N {
    my ($L) = @_;
    my $steps = abs( $L->{y2} - $L->{y1} );
    for ( my $i = 0; $i <= $steps; $i++ ) {
        $Map->{ $L->{x1} }{ $L->{y1} - $i }++;
    }
}

sub S {
    my ($L) = @_;
    my $steps = abs( $L->{y2} - $L->{y1} );
    for ( my $i = 0; $i <= $steps; $i++ ) {
        $Map->{ $L->{x1} }{ $L->{y1} + $i }++;
    }
}

sub NE {
    my ($L) = @_;
    my ( $x, $y ) = ( $L->{x1}, $L->{y1} );
    my $steps = abs( $L->{x2} - $L->{x1} );
    for ( my $i = 0; $i <= $steps; $i++ ) {
        $Map->{ $L->{x1} + $i }{ $L->{y1} - $i }++;
    }
}

sub NW {
    my ($L) = @_;
    my ( $x, $y ) = ( $L->{x1}, $L->{y1} );
    my $steps = abs( $L->{x2} - $L->{x1} );
    for ( my $i = 0; $i <= $steps; $i++ ) {
        $Map->{ $L->{x1} - $i }{ $L->{y1} - $i }++;
    }
}

sub SE {
    my ($L) = @_;
    my ( $x, $y ) = ( $L->{x1}, $L->{y1} );
    my $steps = abs( $L->{x2} - $L->{x1} );
    for ( my $i = 0; $i <= $steps; $i++ ) {
        $Map->{ $L->{x1} + $i }{ $L->{y1} + $i }++;
    }
}

sub SW {
    my ($L) = @_;
    my ( $x, $y ) = ( $L->{x1}, $L->{y1} );
    my $steps = abs( $L->{x2} - $L->{x1} );
    for ( my $i = 0; $i <= $steps; $i++ ) {
        $Map->{ $L->{x1} - $i }{ $L->{y1} + $i }++;
    }
}

sub dump_map {
    my ( $max_x, $max_y ) = ( -1,     -1 );
    my ( $min_x, $min_y ) = ( 10_000, 10_000 );
    for my $x ( keys %$Map ) {
        if ( $x > $max_x ) {
            $max_x = $x;
        }
        if ( $x < $min_x ) {
            $min_x = $x;
        }
        for my $y ( keys %{ $Map->{$x} } ) {
            if ( $y > $max_y ) {
                $max_y = $y;
            }
            if ( $y < $min_y ) {
                $min_y = $y;
            }
        }
    }

    for my $y ( $min_y .. $max_y ) {
        for my $x ( $min_x .. $max_x ) {
            print $Map->{$x}{$y} ? $Map->{$x}{$y} : '.';
        }
        print "\n";
    }
}
