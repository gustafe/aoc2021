#! /usr/bin/env perl
# Advent of Code 2021 Day 5 - Hydrothermal Venture - complete solution
# https://adventofcode.com/2021/day/5
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d05
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';

# useful modules
use List::Util qw/sum max min/;
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
my @lines;
my ( $x1, $y1, $x2, $y2 );
for my $in (@input) {
    if ( $in =~ m/^(\d+),(\d+) -> (\d+),(\d+)$/ ) {
        ( $x1, $y1, $x2, $y2 ) = ( $1, $2, $3, $4 );
    }
    else {
        die "can't parse line: $in";
    }

    push @lines, { x1 => $x1, y1 => $y1, x2 => $x2, y2 => $y2 };
}
my $Map;
sub horizontal; sub vertical;
sub SE; sub NE; sub SW; sub NW;
my %paint = (
    horizontal => \&horizontal,
    vertical   => \&vertical,
    SE         => \&SE,
    NE         => \&NE,
    SW         => \&SW,
    NW         => \&NW,
);

for my $L (@lines) {
    if ( $L->{x1} == $L->{x2} ) {
        $paint{horizontal}->($L);
    }
    elsif ( $L->{y1} == $L->{y2} ) {
        $paint{vertical}->($L);
    }
    elsif ( $L->{x1} < $L->{x2} and $L->{y1} < $L->{y2} and $part2 ) {
        # direction SE - increasing X, increasing Y
        $paint{SE}->($L);
    }
    elsif ( $L->{x1} < $L->{x2} and $L->{y1} > $L->{y2} and $part2 ) {
        # direction NE - increasing X, decreacsing Y
        $paint{NE}->($L);
    }
    elsif ( $L->{x1} > $L->{x2} and $L->{y1} < $L->{y2} and $part2 ) {
        # direction SW - decreasing X, increasing Y
        $paint{SW}->($L);
    }
    elsif ( $L->{x1} > $L->{x2} and $L->{y1} > $L->{y2} and $part2 ) {
        # direction NW - decreasing X, decreasing Y
        $paint{NW}->($L);
    }
}
sub dump_map;

my $count;
for my $x ( keys %$Map ) {
    for my $y ( keys %{ $Map->{$x} } ) {
        $count++ if $Map->{$x}->{$y} >= 2;
    }
}
my $ans = $count;
### FINALIZE - tests and run time
if ($part2) {
    is( $ans, 18442, "Part 2: $ans" );
}
else {
    is( $ans, 4745, "Part 1: $ans" );
}

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

sub horizontal {
    my ($L) = @_;
    my ( $from, $to ) = (
        min( map { $L->{ 'y' . $_ } } qw/1 2/ ),
        max( map { $L->{ 'y' . $_ } } qw/1 2/ )
    );
    for my $dy ( $from .. $to ) {
        $Map->{ $L->{x1} }->{$dy}++;
    }
}

sub vertical {
    my ($L) = @_;
    my ( $from, $to ) = (
        min( map { $L->{ 'x' . $_ } } qw/1 2/ ),
        max( map { $L->{ 'x' . $_ } } qw/1 2/ )
    );
    for my $dx ( $from .. $to ) {
        $Map->{$dx}->{ $L->{y1} }++;
    }
}

sub SE {
    my ($L) = @_;
    my $dy = 0;
    for my $x ( $L->{x1} .. $L->{x2} ) {
        $Map->{$x}{ $L->{y1} + $dy }++;
        $dy++;
    }
}

sub NE {
    my ($L) = @_;
    my $dy = $L->{y1};
    for my $x ( $L->{x1} .. $L->{x2} ) {
        $Map->{$x}{$dy}++;
        $dy--;
    }

}

sub SW {
    my ($L) = @_;
    my $dy = 0;
    for my $x ( $L->{x2} .. $L->{x1} ) {
        $Map->{$x}{ $L->{y2} - $dy }++;
        $dy++;
    }
}

sub NW {
    my ($L) = @_;
    my $dy = 0;
    for my $x ( $L->{x2} .. $L->{x1} ) {
        $Map->{$x}{ $L->{y2} + $dy }++;
        $dy++;
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
