#!/usr/bin/perl -l
# simple perl script to find references in C# code referencing statsD methods relevant to datadog custom metrics
use strict;
use File::Find;
no warnings 'File::Find';

sub find_metric {
    next unless $File::Find::name =~ /.cs$/;
    local @ARGV = ( $_ );
    my @lines = map {chomp;$_} <>;
    for(my $i=0; $i<$#lines; $i++){
        next unless $lines[$i] =~ /statsD\.(Event|Counter|Increment|Decrement|Distribution|Gauge|Histogram|Set|Timer|Time)\b\(/;
        my $line = join" ", @lines[$i .. $i+8];
        my $type=$1;
        my $name=$1 if $line=~/"([^"]*)"/;
        $name =~ s/,/./g;
        my $n = $i+1;
        print join",", $type,"olo.$name",$File::Find::name,$n;
    }
}

push @ARGV, glob(".") unless @ARGV;
find( \&find_metric, @ARGV );
