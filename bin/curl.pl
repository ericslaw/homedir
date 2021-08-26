#!/usr/bin/perl -l
# curl wrapper that can fetch URLs AND cache+auth+valid 
# note: does not truly/directly handle stdin+stdout which curl could be capable of
#
use strict;
use Data::Dumper;  $Data::Dumper::Sortkeys=1;$Data::Dumper::Indent=1;$Data::Dumper::Terse=1;
sub dumper      {return join" ",grep/./, map {s/\s+/ /g;s/^\s+|\s+$//g;$_} split/\n/,Dumper @_}
use MIME::Base64;

# get options {{{
$::VERSION = 0.05;
our $opt = {    # with default options
    valid => '.',
    cache => 'cache',
    expire => defined $ENV{CURL_EXPIRE} ? $ENV{CURL_EXPIRE} : undef,
};
use Getopt::Long qw( GetOptionsFromArray :config default gnu_compat pass_through);
GetOptions( $opt, 'debug|d!', 'verbose|v:+', 'neuter|n',
    'dump:s',
    'valid:s',  # validate response with jq EXPR                default: .
    'novalid',  # disable validation
    'cache:s',  # cache enabled, optional directory specified   default: cache
    'nocache',  # disable cache manually
    'flush',    # force flush of cache                          default:                    # invalidates cache, implies do not re-cache?
    'update',   # force update even if found                    default:                    # keeps cache 'fresh' on use
    'expire:i', # purge cache if older than N days              default:
    'key=s',    # force cache key to KEY                        default: md5_hex @ARGV
) || die;
shift @ARGV if $ARGV[0] eq '--';                        # swallow '--' if used to limit curl.pl option parsing
delete $opt->{cache} if $opt->{nocache};
delete $opt->{valid} if $opt->{novalid};
print "$opt = ".dumper $opt if $opt->{dump}=~/opt/;
#}}}

sub args2str    {return join" ",map {$_=~m/\s/ ? qq("$_") : $_ } @_ if $opt->{debug}}
sub uniq        { my %seen; return grep { ! $seen{$_}++ } @_; }
sub slurp       {local(@ARGV)=@_; my @lines=map {s/[\r\n]+//;$_} <>;return (wantarray) ? @lines : join"\n",@lines }
sub spew        {if(open(my $fh,'>',shift @_)){print $fh @_;close($fh)}} # spew(file,content) - write to file, opposite of slurp
sub qxread      {
    # https://perldoc.perl.org/5.32.0/perlsec.html  almost-secure backtick... uses open-| to fork and child calls exec directly
    print join"\n",map {"> $_"} @_ if $opt->{dump}=~/qxread|curl|command|cmd|exec/;
    return if $opt->{neuter};
    if( open my $fh,"-|"){
        return wantarray? map{chomp;$_}<$fh> : join"",<$fh>
    };
    exec @_
}
sub qxwrite     { # [bin,args], input #{{{
    my $bin=shift@_;
    if(open my $fh,"|-"){
        print $fh @_;
        close $fh;  # returns true if ?
        return $?>>8;   # 0=pass, !0=FAIL
    }
    my @bin = ref $bin ? @{$bin} : ($bin);
    open(STDERR,'>','/dev/null');
    open(STDOUT,'>','/dev/null');
    exec @bin;
} #}}}

# TODO: extract info config for setup styles (custom headers vs required headers etc) separate from auth-keys)
my $curlhead = { # host => [headerlist]  {{{
    'app.datadoghq.com'     => [ 'DD-API-KEY: $DATADOG_API_KEY', 'DD-APPLICATION-KEY: $DATADOG_APP_KEY' ],
    'api.datadoghq.com'     => [ 'DD-API-KEY: $DATADOG_API_KEY', 'DD-APPLICATION-KEY: $DATADOG_APP_KEY' ],
    'api.statuspage.io'     => [ 'Authorization: OAuth $STATUSPAGE_KEY' ],
    'api.opsgenie.com'      => [ 'Authorization: GenieKey $OPSGENIE_API_KEY' ],
#   'api.pagerduty.com'     => [ 'Authorization: Token token=$PAGERDUTYKEY', 'Accept: application/vnd.pagerduty+json;version=2' ],
    'api.runscope.com'      => [ 'Authorization: Bearer RUNSCOPE_API_KEY' ],
    'api.us2.sumologic.com' => [ 'Authorization: Basic '. encode_base64("$ENV{SUMO_API_ID}:$ENV{SUMO_API_KEY}",""), 'isAdminMode: true' ],
    'api.pingdom.com'       => [ 'Authorization: Bearer $ENV{PINGDOM_API_KEY}' ],
    'ololabs.atlassian.net' => [ 'Authorization: Basic $ENV{CONFLUENCE_AUTH}' ],
    'ololabs.atlassian.net' => [ 'Authorization: Basic $JIRA_AUTH', 'Accept: application/json' ],
    'api.firehydrant.io'    => [ 'Authorization: $HYDRANTPREP' ],
}; #}}}
sub curlauth { # {{{
    my %headers;
    my %debug_headers;
    foreach my $domain ( map { $_ =~ m{^https*://([^/]+)(/|$)} ? $1 : undef } @_ ){
        foreach ( @{$curlhead->{$domain}} ){
            my $header = $_;
            my $debug_header = $_;
            if ( $header =~ m{\$(\w+)} ){   # environment variable detection
                my $var = $1;
                die "auth environment variable $var must be defined\n" unless $ENV{$var};
                $header =~ s{\$$var}{$ENV{$var}}ig;
                $debug_header =~ s{\$$var}{\$$var}ig;
            }
            $headers{$header}++;
            $debug_headers{$debug_header}++;
        }
    }
    my @headers = map { ("-H","$_") } sort uniq keys %headers;
    my @debug_headers = map { ("-H","$_") } sort uniq keys %debug_headers;
    print "d: ".join" ", map { $_=~m{[^\w:/,_=-]}i ? qq{"$_"} : $_ } qw(curl -Sskg), @debug_headers, @_ if $opt->{debug};
    print "v: ".join" ", map { $_=~m{[^\w:/,_=-]}i ? qq{"$_"} : $_ } qw(curl -Sskg), @_ if $opt->{verbose};
    my $payload = qxread "curl", "-Ssk", @headers, @_;# unless $opt->{neuter};
    return $payload;
} #}}}
sub curlcache { #{{{
    use Digest::MD5 qw(md5 md5_hex md5_base64);
    use File::Path qw(make_path);
    use File::Basename;

#   my $arg = join" ",@_;
    my $key = $opt->{key} ? $opt->{key} : md5_hex join"|", sort @_;
    # @dirs=grep/./,split/(.{4})/,$_;
    my $path = join"/", $opt->{cache} ,$key;

    unlink $path if $opt->{flush} || $opt->{update} || ( $opt->{expire} && -M $path > $opt->{expire} );
    my $isfound = $opt->{cache} && -r $path;

    my $payload = $opt->{cache} && $isfound ? slurp $path : curlauth @_;
    print "d: payload = $payload" if $opt->{debug};

    my $isvalid = $opt->{cache} && $payload && 0 == qxwrite ["jq",$opt->{valid}], $payload;
    printf "v: " ."payload %s %s\n", length $payload, $isvalid?"valid":"INVALID" if $opt->{valid} && $opt->{verbose};
    print "[$payload]" if $opt->{debug};

    if ( $opt->{cache} && $isvalid && !$opt->{flush} && ( !$isfound || $opt->{update} ) ){
        my $dir = dirname $path;
        make_path $dir unless -d $dir;
        print "v: " . "cache $path" if $opt->{verbose};
        spew $path, $payload unless $opt->{neuter};
    }

    return $payload;
} #}}}

print curlcache @ARGV;

#### test qxwrite for exit status {{{
####    sub check {
####        my $args = dumper \@_;
####        my $expect = shift @_;
####        my $exit = qxwrite @_;
####        my $status = $exit ? 0 : 1;
####        my $pass = ( $expect && $status ) || ( ! $expect && ! $status ) ? "pass" : "FAIL";
####        my $code = $?>>8;
####        my $out = "pass=$pass expect=$expect status=$status exit=$exit code=$code @=$@ !=$! E=$^E ?=$? args=$args";
####        print $out;
####    #   print join",",split/\s/,$out;
####        return $status;
####    }
####    
####    #printf"[%s]\n", curlauth @ARGV;
####    #my $valid = validjson(@ARGV);
####    #print "valid=$valid";
####    #pipejq @ARGV;
####    my $status;
####    check 1, "echo", qw(true);
####    check 0, "curl", qw(hi mom);
####    check 1, ["jq","."], qw(true);
####    check 0, ["jq","."], qw(bad);
####    check 1, ["jq","."], qw(false);
####    check 0, ["jq","bad"], qw(true);
#### }}}
