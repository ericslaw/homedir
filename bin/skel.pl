sub slurp {return unless -f $_[0];do{local(@ARGV)=$_[0]; my @lines=map {s/[\r\n]+//;$_} <>;return (wantarray) ? @lines : join"\n",@lines }}
# slurp dos/unix file, silently ignore missing files
sub spew  {if(open(my $fh,'>',shift @_)){print $fh @_;close($fh)}} # spew(file,content) - write to file, opposite of slurp
