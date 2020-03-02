#!/usr/bin/perl -l
use strict;
use List::Util qw(shuffle);
my $s = @ARGV ? shift @ARGV : 1;
#push @ARGV, qw( /usr/share/dict/words ) unless @ARGV;
my @samples = shuffle map { chomp $_; $_ } <>;
splice @samples, $s;
print join "\n", @samples;
