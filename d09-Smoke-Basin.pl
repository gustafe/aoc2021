#! /usr/bin/env perl
# Advent of Code 2021 Day 9 - Smoke Basin - complete solution
# https://adventofcode.com/2021/day/9
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d09
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';
# useful modules
use List::Util qw/sum all/;
use Data::Dump qw/dump/;
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
my $Map;
my $id= 0;
my $Basins;
my $r=1;
for my $line (@input) {
    my $c=1;
    for (split(//,$line)) {
	$Map->{$r}{$c}={ val=>$_};
	$c++;
    }
    $r++;
}
#dump $Map;
my $risk=0;
for my $r (sort {$a<=>$b} keys %$Map) {
    for my $c (sort {$a<=>$b} keys %{$Map->{$r}}) {
	my @neighbors;
	for my $dir ([-1, 0],
		     [ 1, 0],
		     [ 0,-1],
		     [ 0, 1]) {
	    if (defined $Map->{$r+$dir->[0]}{$c+$dir->[1]}) {
		push @neighbors, $Map->{$r+$dir->[0]}{$c+$dir->[1]}->{val}
	    }
	}
	if (all { $Map->{$r}{$c}->{val} < $_} @neighbors) {
#	    say "$Map->{$r}{$c}->{val} at ($r,$c) is a low";
	    #	    say join(' ',@neighbors);
	    ++$id;
	    $Basins->{$id} = {r=>$r, c=>$c};
	    $Map->{$r}{$c}->{id} = $id;

	    $risk += ($Map->{$r}{$c}->{val} + 1);
	}
    }
}
for my $id (keys %$Basins) {
    my $start = [$Basins->{$id}{r}, $Basins->{$id}{c}];
    my @queue = ($start);
    while (@queue) {
	my $cur = shift @queue;
	
	for my $dir ([-1, 0],		 [ 1, 0],		 [ 0,-1],		     [ 0, 1]) {
	    my $move = [$cur->[0]+$dir->[0], $cur->[1]+$dir->[1]];
	    if (defined $Map->{$move->[0]}{$move->[1]}) {
		if ($Map->{$move->[0]}{$move->[1]}{val} > $Map->{$cur->[0]}{$cur->[1]}{val}
		    and $Map->{$move->[0]}{$move->[1]}{val}!=9
		    and ! defined($Map->{$move->[0]}{$move->[1]}{id}))  {
		    $Map->{$move->[0]}{$move->[1]}{id} = $id;
		    push @queue, $move;
		}
	    }
	}
    }
}
my %data;
for my $r (keys %$Map) {
    for my $c (keys %{$Map->{$r}}) {
	if ($Map->{$r}{$c}{id}) {
	    $data{$Map->{$r}{$c}{id}}++
	}
    }
}
my $prod= 1;
my $count =1;
for my $id (sort {$data{$b}<=>$data{$a}} keys %data) {
    next if $count> 3;
    $prod *= $data{$id};
    
    $count++;
}
### FINALIZE - tests and run time
if ($testing) {
    is($risk,15,"Part 1: $risk");
    is( $prod, 1134, "Part 1: $prod");
} else {
    is($risk,423 , "Part 1: $risk");
    is($prod, 1198704, "Part 2: $prod");
}

done_testing();
say sec_to_hms(tv_interval($start_time));

### SUBS
sub sec_to_hms {  
    my ($s) = @_;
    return sprintf("Duration: %02dh%02dm%02ds (%.3f ms)",
    int( $s / ( 60 * 60 ) ), ( $s / 60 ) % 60, $s % 60, $s * 1000 );
}
