#! /usr/bin/env perl
# Advent of Code 2021 Day 24 - Arithmetic Logic Unit - complete solution
# https://adventofcode.com/2021/day/24
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d24
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
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }

### CODE

=pod 

For the solution, I followed the excellent explanation here:

L<https://github.com/dphilipson/advent-of-code-2021/blob/master/src/days/day24.rs>

(via comment L<https://www.reddit.com/r/adventofcode/comments/rnejv5/2021_day_24_solutions/hps7skz/> by /u/snakebehindme)

As per the explanation, my values for {DIV}, {VALUE} and {OFFSET} were

(push) 13, 6 => PUSH  input[0] +  6
(push) 15, 7 => PUSH  input[1] +  7
(push) 15,10 => PUSH  input[2] + 10
(push) 11, 2 => PUSH  input[3] +  2
(pop)  -7,15 => POP:  input[4] must be == popped_value - 7
(push) 10, 8 => PUSH  input[5] +  8
(push) 10, 1 => PUSH  input[6] +  1
(pop)  -5,10 => POP:  input[7] must be == popped_value - 5
(push) 15, 5 => PUSH  input[8] +  5
(pop)  -3, 3 => POP:  input[9] must be == popped_value - 3
(pop)   0, 5 => POP: input[10] must be == popped_value - 0
(pop)  -5,11 => POP: input[11] must be == popped_value - 5
(pop)  -9,12 => POP: input[12] must be == popped_value - 9
(pop)   0,10 => POP: input[13] must be == popped_value - 0

Running the "stack" and matching each input value with the requirements above gives the following conditions that have to be met:

 input[0] = input[13] - 6
 input[2] = input[11] - 5
 input[4] =  input[3] - 5
 input[5] = input[10] - 8
 input[7] =  input[6] - 4
 input[8] =  input[9] - 2
input[12] =  input[1] - 2

Combining these to give the highest and lowest possible combination leads to

Part 1: 39494195799979
Part 2: 13161151139617

The code was used to validate these values.

=cut

my %reg;
my %cmd = (
    inp  => sub { my ( $in, $r ) = @_; $reg{$r} = $in },
    oper => \&oper,
    eql  => \&eql,
);

my @testprogs = (
    [ 'inp x', 'mul x -1' ],
    [ 'inp z', 'inp x', 'mul z 3', 'eql z x' ],
    [   'inp w',   'add z w', 'mod z 2', 'div w 2', 'add y w', 'mod y 2',
        'div w 2', 'add x w', 'mod x 2', 'div w 2', 'mod w 2'
    ],
);
my @tinputs = ( [7], [ 3, 9 ], [13] );
my @tchecks = (
    { w => 0, x => -7, y => 0, z => 0 },
    { w => 0, x => 9,  y => 0, z => 1 },
    { w => 1, x => 1,  y => 0, z => 1 }
);

for my $t (@testprogs) {
    my $prog;
    %reg = ( w => 0, x => 0, y => 0, z => 0 );

    for my $s (@$t) {
        push @$prog, [ split( /\s+/, $s ) ];
    }
    my $in = shift @tinputs;

    for my $l (@$prog) {
        if ( $l->[0] eq 'inp' ) {
            $cmd{inp}->( shift @$in, $l->[1] );
        }
        elsif ( $l->[0] eq 'eql' ) {
            $cmd{eql}->( $l->[1], $l->[2] );
        }
        else {
            $cmd{oper}->(@$l);
        }
    }
    my $check = shift @tchecks;
    my $nok   = 0;
    for my $k ( keys %reg ) {
        $nok++ unless $reg{$k} == $check->{$k};
    }
    is( $nok, 0, "test ok" );

}
my $prog;
%reg = ( w => 0, x => 0, y => 0, z => 0 );
for my $l (@input) {
    push @$prog, [ split /\s+/, $l ];
}
for my $ans ( '39494195799979', '13161151139617' ) {
    %reg = ( w => 0, x => 0, y => 0, z => 0 );
    my @vals = split( '', $ans );
    for my $s (@$prog) {
        if ( $s->[0] eq 'inp' ) {
            $cmd{inp}->( shift @vals, $s->[1] );

        }
        elsif ( $s->[0] eq 'eql' ) {
            $cmd{eql}->( $s->[1], $s->[2] );
        }
        else {
            $cmd{oper}->(@$s);
        }
    }
    is( $reg{z}, 0, "input $ans is correct" );

}
### FINALIZE - tests and run time
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

sub oper {
    my ( $op, $i, $j ) = @_;

    if ( exists $reg{$j} ) {
        $j = $reg{$j};

    }
    if ( $op eq 'add' ) {

        $reg{$i} = $reg{$i} + $j;
    }
    elsif ( $op eq 'mul' ) {
        $reg{$i} = $reg{$i} * $j;
    }
    elsif ( $op eq 'div' ) {
        $reg{$i} = int( $reg{$i} / $j );
    }
    elsif ( $op eq 'mod' ) {
        $reg{$i} = $reg{$i} % $j;
    }
}

sub eql {
    my ( $i, $j ) = @_;
    if ( exists $reg{$j} ) {
        $j = $reg{$j};
    }
    if ( $reg{$i} == $j ) {
        $reg{$i} = 1;
    }
    else {
        $reg{$i} = 0;
    }
}
