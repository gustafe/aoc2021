#! /usr/bin/env perl
# Advent of Code 2021 Day 00 - Template - commented template
# https://gerikson.com/blog/comp/adventofcode/Advent-of-Code-2021.html#d00
# https://gerikson.com/files/AoC2021/UNLICENSE
###########################################################
use Modern::Perl '2015';
# useful modules
use List::Util qw/sum/;  # this module also has min, max, all etc
use Data::Dump qw/dump/; # simpler interface than Data::Dumper, does sorting
use Test::More; # simple testing harness
use Time::HiRes qw/gettimeofday tv_interval/;
sub sec_to_hms; # predeclare subs, but keep the definition at the end of the file

my $start_time = [gettimeofday]; # include reading and parsing in the total runtime
#### INIT - load input data from file into array

my $testing = 0; # set to true to get test data
my @input;
my $file = $testing ? 'test.txt' : 'input.txt'; 
open( my $fh, '<', "$file" );
while (<$fh>) { chomp; s/\r//gm; push @input, $_; } # file content is now in @input

### CODE
# add your awesome solution here!

### FINALIZE - tests and run time
is($file, 'input.txt', "File that has been read: ".$file); # use this to verify your answers between runs
done_testing();
say sec_to_hms(tv_interval($start_time));

### SUBS
sub sec_to_hms {  
    my ($s) = @_;
    return sprintf("Duration: %02dh%02dm%02ds (%.3f ms)",
    int( $s / ( 60 * 60 ) ), ( $s / 60 ) % 60, $s % 60, $s * 1000 );
}
