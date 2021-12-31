#! /usr/bin/env perl
# Advent of Code 2021 Day 18 - Snailfish - testing
# https://adventofcode.com/2021/day/18
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d18
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################

use Modern::Perl '2015';
# useful modules
use List::Util qw/sum any all/;
use Data::Dump qw/dump/;
use POSIX qw [ceil floor];

use Test::More;
use Time::HiRes qw/gettimeofday tv_interval/;
sub sec_to_hms;

my $start_time = [gettimeofday];
#### INIT - load input data from file into array

my $testing = 1;
my $debug = 0;
my @input;
my $file = $testing ? 'test.txt' : 'input.txt';
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; }
### CODE
sub explode;
sub mysplit;
sub reduce;
sub add;
sub dump_snf;
sub magnitude;
# insert test cases here 
my @test_explode = ('[[[[[9,8],1],2],3],4]',
		    '[7,[6,[5,[4,[3,2]]]]]',
		    '[[6,[5,[4,[3,2]]]],1]',
		    '[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]',
		    '[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]');
my @ans_explode = ('[[[[0,9],2],3],4]',
		   '[7,[6,[5,[7,0]]]]',
		   '[[6,[5,[7,0]]],3]',
		   '[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]',
		   '[[3,[2,[8,0]]],[9,[5,[7,0]]]]' );
for my $idx (keys @test_explode) {
    my $str = $test_explode[$idx];
    my $res = explode( [split('', $str)]);
    is( join('',@$res), $ans_explode[$idx], "explode ok");
}
my $str ='[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]';
my $snf = [split('', $str)];
my $res = reduce($snf);
is(join('',@$res),'[[[[0,7],4],[[7,8],[6,0]]],[8,1]]', "sum 1 ok");
my @arr = ('[[[[4,3],4],4],[7,[[8,4],9]]]','[1,1]');
$res = add( $arr[0], $arr[1]);
is(join('',@$res),'[[[[0,7],4],[[7,8],[6,0]]],[8,1]]', "sum 2 ok");
my @sum_ans = ('[[[[1,1],[2,2]],[3,3]],[4,4]]','[[[[3,0],[5,3]],[4,4]],[5,5]]','[[[[5,0],[7,4]],[5,5]],[6,6]]');
for my $end (4..6) {
    my @list;
    for my $i (1..$end) {
	push @list, "[$i,$i]";
    }
    my $t1 = shift @list;
    my $res;
    while (@list) {
	my $t2 = shift @list;
	$res = add( $t1, $t2);
	$t1 = join('',@$res);
    }
    is( $t1, $sum_ans[$end-4], "add example  ok");
}
my @long;
while (<DATA>) {
    chomp;
    push @long, $_;
}
my $t1 = shift @long;
$res = undef;
while (@long) {
    my $t2 = shift @long;
    $res = add( $t1, $t2 );
    $t1 = join('',@$res);
}
is(join('',@$res), '[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]', "long example ok");

my %mag_tests =('[[1,2],[[3,4],5]]' => 143,
'[[[[0,7],4],[[7,8],[6,0]]],[8,1]]' => 1384,
'[[[[1,1],[2,2]],[3,3]],[4,4]]' => 445,
'[[[[3,0],[5,3]],[4,4]],[5,5]]' => 791,
'[[[[5,0],[7,4]],[5,5]],[6,6]]' => 1137,
'[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]' => 3488);

for my $m (sort keys %mag_tests) {
    my $snf = [split('',$m)];
    my $res = magnitude( $snf);
    is( $res, $mag_tests{$m}, "magnitude $mag_tests{$m}");

}
$t1 = shift @input;
$res = undef;
while (@input) {
    my $t2 = shift @input;
    $res = add( $t1, $t2 );
    $t1 = join('', @$res);
}
### FINALIZE - tests and run time
is(magnitude( $res ),4140 ,"final test");

done_testing();
say sec_to_hms(tv_interval($start_time));

### SUBS
sub sec_to_hms {  
    my ($s) = @_;
    return sprintf("Duration: %02dh%02dm%02ds (%.3f ms)",
    int( $s / ( 60 * 60 ) ), ( $s / 60 ) % 60, $s % 60, $s * 1000 );
}

sub explode {
    my ( $snf ) = @_;

    my $depth= 0;
    for my $idx (keys @$snf) {

	my $part = $snf->[$idx];
	if ($part eq '[' ) {
	    $depth++;
	    next;
	}
	if ($part eq ']') {
	    $depth--;
	    next;
	}
	next if $part eq ',';
	if ($depth>4) {

	    my $left = $part;
	    my $i= $idx;
	    my $right = $snf->[$i+2];
	    my $j = $i;
	    next unless all { $_ =~ /\d+/} ($left, $right);
	    say join('', @{$snf}[$i-1..$i+3]) if $debug;
	    while (--$j >= 0) {
		next if ( any {$snf->[$j] eq $_} ('[',',',']'));
		$snf->[$j] += $left;
		last;
	    }
	    my $k = $i+2;
	    while (++$k < @$snf) {
		next if (any {$snf->[$k] eq $_} ('[',',',']'));
		$snf->[$k] += $right;
		last;
	    }
	    splice @$snf, $i-1,5, 0;
	    return $snf;
	}
	
    }
    return undef;
}

sub mysplit {
    my ( $snf ) = @_;
    for my $idx (keys @$snf) {
	my $part = $snf->[$idx];
	next if (any {$snf->[$idx] eq $_} ('[',',',']') or $part < 10);
	splice @$snf, $idx, 1,('[',floor( $snf->[$idx]/2),',',ceil($snf->[$idx]/2), ']');
	return $snf;
    }
    return undef;
}
sub reduce {
    my ( $snf ) = @_;
    my @stack;
    push @stack, 'spl';
    push @stack, 'exp';
    while (@stack) {
	my $act = pop @stack;
	my $res;
	if ($act eq 'exp') {
	    say "=> explode" if $debug;
	    $res = explode( $snf );
	    if ($res) {
		$snf=$res;

		push @stack, 'exp';
	    }
	    dump_snf( $snf ) if $debug;
	} elsif ($act eq 'spl') {
	    say "==> split" if  $debug;
	    $res = mysplit( $snf );
	    if ($res) {
		$snf=$res;
		push @stack, 'spl';
		push @stack, 'exp';
	    }
	    		dump_snf($snf) if $debug;

	}
    }
    return $snf;
}
sub add { # input: two strings representing snailfish numbers
    my ( $t1, $t2 ) = @_;
    my $snf = [split('','['.$t1.','.$t2.']')];
    dump_snf($snf) if $debug;
    my $res = reduce( $snf);
    return $res;
}

sub dump_snf {
    my ( $snf ) = @_;
    my @arr;
    my $depth =0;
    for my $idx (keys @$snf) {
	my $part = $snf->[$idx];
	print $part;
	if ($part eq '[') {
	    $depth++;
	    $arr[$idx]=$depth;
	    next;
	}
	if ($part eq ']') {
	    $depth--;
	    $arr[$idx]=$depth;
	    next;
	}
    }
    print "\n";
    for my $idx (keys @$snf) {
	print $arr[$idx]?$arr[$idx]:'.';
    }

    print "\n";
}

sub magnitude {
    no warnings 'uninitialized';

    my ( $snf ) = @_;
    while (scalar @$snf >2) {
	for my $idx (keys @$snf) {
	    if ($snf->[$idx] eq '[' and $snf->[$idx+1] =~ /\d+/ and $snf->[$idx+2] eq ',' and $snf->[$idx+3] =~ /\d+/ and $snf->[$idx+4] eq ']') {
		my $mag = 3 * $snf->[$idx+1] + 2 * $snf->[$idx+3];
		splice @$snf, $idx, 5, $mag;
	    }
	}
    }
    return $snf->[0];
}

__DATA__
[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
[7,[5,[[3,8],[1,4]]]]
[[2,[2,2]],[8,[8,1]]]
[2,9]
[1,[[[9,3],9],[[9,0],[0,7]]]]
[[[5,[7,4]],7],1]
[[[[4,2],2],6],[8,7]]
