#!/usr/bin/perl
# tab.pl - csv table manipulation - normalize and visualize columnar data
# --include=pattern     # built in grep include/exclude
# --exclude=pattern
# --delim=pattern       # set delimiter
# --norm=RANGE          # set normal - defaults to 0-99 if not RANGE specified
# --sort=COLSPEC        # sort column by number (starting at 1), use negative numbers to sort in reverse
# --pad=N               # add extra N spaces between columns
# --bar=WIDTH           # draw barchart of normalized values WIDTH chars wide after each line
# --max=W               # input/output maximum of W columns
#
use strict;
use Scalar::Util qw(looks_like_number);
use Data::Dumper;$Data::Dumper::Sortkeys=1;$Data::Dumper::Indent=1;
use Getopt::Long;


my $sep=',';     # separator pattern
my $delim=',';   # output delim char
my @data;
my @max;
my @min;
my @len;
my $bar;
my $sort;
my $incl;
my $excl;
my $norm;
my $minwidth;
my $spacer;
my $maxcol;
my $zero = "0"; # how to handle zero cell values - if set, replace cells with zero with this value

sub trim {
    my($str)= @_;
    $str =~ s/^\s+|\s+$//g;
    return $str;
}
GetOptions(
    "g|grep|in|include=s" => \$incl,
    "gv|grepv|vgrep|ex|exclude=s" => \$excl,
    "id|sep=s" => \$sep,
    "maxcol=i" => \$maxcol,
    "d|od|delim=s" => \$delim,
    "x|bar:s" => \$bar,
    "s|sort=i" => \$sort,
    "n|norm|normalize:1" => \$norm,             # what is normalize again?
    "w|width|mw|minwidth:1" => \$minwidth,
    "pad|space:1" => \$spacer,
    "z|zero=s" => \$zero,
    
);
$sep ||= $delim;
$bar-- if $bar>0;
my $sortrev = -1 if $sort < 0;
$sort = abs($sort) - 1 if defined $sort;

while(<>){
    chomp;
    next if $incl && $_ !~ $incl;
    next if $excl && $_ =~ $excl;
    my @F = split $sep, $_, $maxcol;
    foreach ( 0 .. $#F ){
        $F[$_] = trim $F[$_];
        $F[$_] = sprintf "%.3f", $F[$_] if $F[$_] =~ /^\s*-?\d*\.\d+\s*$/; # reformat float precision to ensure width calculations are accurate
        $len[$_] = length $norm if $norm > length $F[$_];
        $len[$_] = length $F[$_] if !defined $len[$_] || length $F[$_] > $len[$_];
        # why do I care about max value (vs max length?)
        $max[$_] = $F[$_] if !defined $max[$_] || $F[$_] > $max[$_];
        $min[$_] = $F[$_] if !defined $min[$_] || $F[$_] < $min[$_];
    }
    push @data, [ @F ];
}

# sorting
#@data = sort { $a->[$sort] <=> $b->[$sort] || $a->[$sort] cmp $b->[$sort] } @data if defined $sort;
@data = reverse @data if $sortrev;

# normalize and format
@data =
    map {
        my @F = @{$_};
        foreach ( 0 .. $#F ){
            # normalize
            if ( $norm ){
                my $range = $max[$_] - $min[$_];
                my $value = ($range) ? $norm*($F[$_]-$min[$_])/$range : $F[$_];
                $F[$_] = $value;
            }
            # format
            my $minwid = ( $len[$_] > $minwidth ) ? $len[$_]+$spacer : $minwidth+$spacer;
            $F[$_] =  ( $F[$_] =~ /^\s*-?\d*\.\d+\s*$/ ) ? sprintf( "%$minwid.3f", $F[$_] )
                    : ( $F[$_] =~ /^\s*-?\d+\s*$/ )      ? sprintf( "%*d",  "$minwid", $F[$_] )
                    :                                      sprintf( "%*s", "-$minwid.$minwid", $F[$_] );
        }
        # optionally append barchart
        my $baridx = (defined $bar && $bar =~ /l|last|nf|NF|^$/) ? $#F : $bar;  # allow NF or lastfield or blank to be last column
#       push @F, substr("x"x999,0,$F[$baridx]);
        $F[$#F] =~ s/\s+$//; # trim last field of whitespace
        \@F;
    }
    @data;

printf "%s\n", join "\n", map { join $delim, map {$_ eq "0" ? $zero : $_ } @{$_} } @data;
