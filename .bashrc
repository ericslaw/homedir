#!/bin/bash
# .bashrc

# User specific aliases and functions

# local prompt customization if interactive (PS1 set) and promptrc exists
#
if [ -n "$PS1" -a -x $HOME/.prompt ]; then
    . $HOME/.promptrc
elif [ -n "$PS1" ]; then
    export PS1="\u@\h\$ "   # alternative default from common system settings
fi

export BASH_SILENCE_DEPRECATION_WARNING=1

#
# path
#
#export I_WANT_A_BROKEN_PS=true # lunix ps '-' is ok
OLDPATH=/bin:/usr/bin:/usr/5bin:/usr/bsd:/usr/ucb:/sbin:/usr/sbin
###### OLDPATH /usr/sbin:/usr/bsd:/sbin:/usr/5bin:/usr/ucb:/usr/bin:/bin:
PATH=${OLDPATH}
PATH=${PATH}:/usr/openwin/bin:/usr/bin/X11:/usr/local/X11/bin
PATH=${PATH}:/usr/ccs/bin:/usr/local/go/bin
PATH=/usr/local/bin:${PATH}
PATH=${PATH}:/etc:/usr/etc:/usr/local/etc
PATH=/x/data/bin:$PATH
PATH=${PATH}:/usr/local/share/dotnet/
PATH=.:${HOME}/bin/`uname`:${HOME}/bin:${PATH}:${HOME}/git/runner/bin
# set LC_ALL=C to avoid unclear 'natural' sorting issues - sort cmd should be more for computers more than humans (see natsort elsewhere)
export LC_ALL=C
export PATH PS1
#export ANT_HOME=/usr/local/ant
#export JAVA_HOME=$HOME/program_files/Java/jre6
#export PATH=$PATH:$ANT_HOME/bin:$JAVA_HOME/bin


function inch {
    perl -le 'print 0+$ARGV[0]*12 + $ARGV[1]' $@
}
function dropzone {
    sftp -o KexAlgorithms=diffie-hellman-group14-sha1 -o HostKeyAlgorithms=+ssh-dss dropzone.corp.com
}

function fage {
    perl -le 'foreach(@ARGV){$mtime=(stat($_))[9];$age=time-$mtime;print join" ",$age,$_}' $@
}

function mgrep {
    perl -MList::Util=all -ne 'BEGIN{@patt=@ARGV;@ARGV=()}$line=$_;print if all {$line =~ /$_/i} @patt' $@
}

export IGNOREEOF=5
export HISTTIMEFORMAT="%H:%M:%S "
#ulimit coredumpsize 0
# HOSTFILE (in /etc/hosts format) allows auto-comoplete of hostnames
export HOSTFILE=$HOME/etc/hosts
 

# quicky shell var to allow grep of DNS zone xfers
dns=$HOME/git/gap/data/dns.raw


# cmd to set PASS env var without exposing password
function setpass { perl -e 'print "export PASS="'; stty -echo; read PASS; export PASS; echo ""; stty echo; }

alias sssh=gosh
# mux to mux host behind bastion
function mux   { name=$1; ssh -t bastion.corp.com ssh -t mux.corp.com "/usr/local/bin/tmux -CC new-session -A -s ${name:=default}"; }

# cmd to view vim histories side-by-side
function vimhist {
    test ! -f "$1" && revs=$1 && shift
    test -z "$revs" && revs=4
    vimdiff `\ls -rt ~/.backup/$1-* $1|tail -$revs|sed -ne '1p;2p;3p;$p'|xargs ls -1t`
}
function vimhist2 {
    vimdiff `\ls -rt ~/.backup/$1-* $1|tail -7|sed -ne '1p;2p;3p;$p'|xargs ls -1t`
}
function vimhist3 {
    vimdiff `\ls -rt ~/.backup/$1-* $1|tail -10|sed -ne '1p;2p;3p;$p'|xargs ls -1t`
}
function vimdiffgit {
    git difftool --tool=vimdiff --no-prompt HEAD^^ $@
}

function findgrep {
    find . -type f -exec egrep -i "$@" /dev/null "{}" \; ;
}

##### sshkey.sh
function sshcreatekey {
    # [keyname [comments]]
    key=$1; shift;
    test -n "$key" || key="id_rsa"
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/$key -C "$@"
    # it will prompt for passphrase interactively
}
function sshpushkey {
    # [keyname] [hostlist]
    (
    tmpdir=~/tmp.$$
    mkdir -p $tmpdir
    umask 077
    mkdir -p $tmpdir/.ssh
    umask 022
    cp /dev/null $tmpdir/.ssh/authorized_keys

    key="id_rsa"
    while [ "$#" -gt 0 ]; do
        if [ -f ~/.ssh/$1.pub ]; then
            key=$1
            cat ~/.ssh/$1.pub >> $tmpdir/.ssh/authorized_keys
        else
            if [ ! -s $tmpdir/.ssh/authorized_keys -a -f ~/.ssh/id_rsa.pub ]; then
                cat ~/.ssh/id_rsa.pub >> $tmpdir/.ssh/authorized_keys
            fi
            if [ ! -s $tmpdir/.ssh/authorized_keys ]; then
                echo "ERROR: no authorized_keys to send" 1>&2
                break 
            fi
            host=$1
            ( cd $tmpdir && rsync --rsync-path="export PATH=/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin;rsync" -auR .ssh $host:. )
        fi
        shift
    done
    
    rm $tmpdir/.ssh/authorized_keys
    rmdir $tmpdir/.ssh
    rmdir $tmpdir
    )
}
function sshinit {
    # run once in your first window (before others run sshenv)

    . ~/.ssh/ssh-agent >/dev/null 2>&1
    ssh-agent -k >/dev/null 2>&1

    ssh-agent > ~/.ssh/ssh-agent
    . ~/.ssh/ssh-agent >/dev/null 2>&1

    sshkey=""
    key="id_rsa"
    if [ "x$1" == "x" -a -f ~/.ssh/$key ]; then
        # note: macos ssh-add -K flag supplies passphrase from the keychain
        ssh-add ~/.ssh/$key
        sshkey="$sshkey -i $HOME/.ssh/$key"
    fi
    for key in $@; do
        ssh-add ~/.ssh/$key
        sshkey="$sshkey -i $HOME/.ssh/$key"
    done
    echo "$sshkey" > ~/.ssh/ssh-key
}
function sshenv {
    # non-interactively inherit current environment
    test -f ~/.ssh/ssh-agent && . ~/.ssh/ssh-agent >/dev/null 2>&1
    if [ "$SSH_AGENT_PID" ]; then
        kill -0 $SSH_AGENT_PID >/dev/null 2>&1 || echo "ssh-agent NOT RUNNING" 1>&2
    fi
}
#function ssh {
#    # yes actually replace ssh with a function, so we can ensure environment is sourced first (but in a lightweight way)
#    # source existing environment first
#    sshenv >/dev/null 2>&1
#    # grab preferred keys if any were specified
#    sshargs="`cat ~/.ssh/ssh-key 2>&1`"
#    /usr/bin/ssh $sshargs $@
#}

sshenv >/dev/null 2>&1


#
# aliases
#
#/home/elaw/gettime
unalias more >/dev/null 2>&1
alias mokre=more
#unalias cd >/dev/null 2>&1
alias fix="stty sane erase '^H' intr '^C' quit '^\' kill '^U' eof '^D'"
alias ls="\ls -FCq"
alias perltidy='perltidy -ndsm -st -ce -bar -nola -l=220'
alias vi='vim -o'
#alias ssh=go
# LESS is not MORE - why cannot get -EFi to work? both -E and -F result in empty file :(
# -C    = clear screen first
# -c    = clear screen vs scroll
# -E    = quit at eof 1st time
# -e    = quit at eof 2nd time
# -F    = force quit if one screen or less
# -g    = highlight last search match only (vs all)
# -G    = suppress highlighting
# -h#   = scroll-backward limit
# -i    = ignorecase search unless Upcase search
# -I    = ignorecase always
# -j#   = jump target position; position at row # with top of screen = 1
# -J    = show match status column at left
# -m    = prompt like more
# -M    = prompt like more verbosely
# -n    = suppress line numbers
# -N    = line number from start of display
# -ofile= overwrite file if stream stdin
# -q    = quiet (no bell at eof
# -s    = squeeze blank lines
# -S    = chomp long lines (vs wrap or fold)
# note: [rR] required for git colors to show thru?  https://unix.stackexchange.com/a/64932/27057
# http://eigenjoy.com/2008/07/23/mac-os-x-color-showing-escwhatever-for-git-diff-colors-and-more/
# git config --global color.ui true
export LESS="-XEFiR"
alias more=less


# set some commands to auto-complete hostnames as arguments
complete -A hostname -o default ssh
complete -A hostname -o default go
complete -A hostname -o default gop
complete -A hostname -o default host
complete -A hostname -o default rdiff

# perl calculator
# TODO: command completion that processes math expressions before execution!
# this could occur if ' ' or if I use tab completion on 'pc' command and it auto-wraps in quotes?
function pc() { perl -le '$expr=join(" ",@ARGV);foreach(0..3){$expr=~s/(\d)\s+(\d)/$1+$2/g};printf"%s\n", 0+eval $expr' "$@"; }
function pc2() { perl -le '$expr=join(" ",@ARGV);foreach(0..3){$expr=~s/(\d)\s+(\d)/$1+$2/g};print eval $expr' "$@"; }
function atb() { perl -le '$expr=join(" ",@ARGV);$expr=~s/(\d)\s+(\d)/$1+$2/g;printf"%.5f%%\n", 100*(1-(eval $expr)/(30*86400))' "$@"; }
# perl bits display
function bits() { perl -le 'print join" ",split/(.{8,8})/,unpack"B32",pack"N*",eval {join" ",@ARGV}' $@ ;}

# wonder if readline could create matching quotes, parens, and braces using readline?
bind '"=":self-insert'          # undo# or if tab completion could recognize jq and auto-close parens+quote?

# set window title for ansi compliant terminals: note: echo -e "\e\a" dont work on OSX, -e ignored!
test -z "$TTL" || export TTL="title"
function ttl() { export TTL="$@";perl -e 'print "\033]2;$ENV{TTL}\007\033]0;$ENV{TTL}\007"'; }
#export PROMPT_COMMAND='ttl $TTL' # seems incur lag between commands

alias clear="perl -e 'print qq(\033[2J\033[H)'"
alias reset="perl -e 'print qq(\033c)'"






#alias ll='ls -lFHq'
alias df='df -k'
alias du='du -k'
alias psg='ps -ef|grep \!*'
alias mv='mv -i'
alias cp='cp -i'
alias lo='exit;logout'
alias kl='clear'
alias klkl='reset'
#alias h='history|egrep -i ".*\!*"|tail -40'
alias j='jobs'
alias xxx='chmod ugo+x \!*'
alias KJ='kill -9 %\!*'
alias ftp='ftp -i'

alias exp='perl -e "printf qq(%f\n),eval\ join(qq( ),@ARGV)"'
alias count="awk '{s+="'$1'"}END{print s}'"

#alias did='echo "`date +%y%m%d_%H%M%S`: \!*" | tee -a ~/.didlist'
#alias didlist='(egrep -i ".*\!*" ~/.didlist|grep -v GETDID|tail -40)'

alias mktarz='tar cf - \!* | compress > \!*.tar.Z'
alias lstarz='zcat \!*|tar vtf -'
alias untarz='zcat \!*|tar vxf -'
alias mktargz='tar cf - \!* | gzip -9 > \!*.tar.z'
alias lstargz='cat \!*|gunzip|tar vtf -'
alias untargz='cat \!*|gunzip|tar vxf -'

#alias trace='par -sil -SS'
#alias trace='truss -faeildD'
alias trace='strace -fFqtttTx'
alias manf='nroff -man'
alias name=$HOME/org/org.pl


# https://stedolan.github.io/jq/manual/#Colors
#export JQ_COLORS="1;30:0;39:0;39:0;39:0;32:1;39:1;39" # default
#export JQ_COLORS="1;30:0;39:0;39:0;39:0;32:1;39:1;39"
# jq monochrome, sorted
alias jq='jq -M'

ENSCRIPT="-DDuplex:true --no-header --border --nup=2 --nup-xpad=0 --nup-ypad=10 --quiet --pass-through --mark-wrapped-lines=arrow --printer-options=-h --underlay=elaw --ul-angle=270 --ul-position=-50-50"
export ENSCRIPT



# Source global definitions
#if [ -f /etc/bashrc ]; then . /etc/bashrc fi

function h {
    if [ "$1" ]; then
        history | grep "$1" | tail -40 | cat -v
    else
        history | tail -40 | cat -v
    fi
}

function when {
    if [ -z "$1" ]; then
        TZ="US/Eastern" perl -MPOSIX=strftime -pe 's{\b(\d{10,10})\d*}{strftime"$1 %Y/%m/%d-%H:%M:%S",localtime($1)}eg'
    else
        TZ="US/Eastern" perl -MPOSIX=strftime -e 'map {s{(?<!\d.)\b(\d{10,10})\d*}{print strftime"$1 %Y/%m/%d-%H:%M:%S\n",localtime($1)}eg} @ARGV' $@
#       perl -MPOSIX=strftime -e 'map {printf"%s %s %s\n",scalar localtime($1),$1,$_ if $_ =~ /} @ARGV' $@
    fi
}
function rwhen {
    perl -MTime::Local -le '$ENV{TZ}="US/Eastern";@T=reverse splice[split/\D+/,join" ",@ARGV,0,0,0],0,6;$T[4]--;print timelocal splice@T,0,6' $@
}
function age {
    perl -MPOSIX=strftime -MTime::Local -le '@T=reverse splice[split/\D+/,join" ",@ARGV,0,0,0], 0,6;$T[4]--;$then=timelocal @T;$now=time;$age=$now-$then;print strftime"%Y/%m/%d-%H:%M:%S $then",localtime $then;foreach(qw(1 60 3600 86400 604800 2628000 31536000 )){printf"%15.3f %12d\n",$age/$_,$_}' $@
}
function oldrwhen {
    perl -e 'use Date::Manip;$stamp=UnixDate(ParseDate(join(" ",@ARGV)),"%s");printf"%d %s\n",$stamp,scalar localtime($stamp)' $@
}
function dns {
    # any list of hosts starts to look sorta like /etc/hosts format
#   perl -pe 'use Net::hostent;use Socket;s/(([a-zA-Z0-9-]+)(\.\w+)*)/sprintf"%s $1",gethost($1)?inet_ntoa(${(gethost($1))->addr_list}[0]):"?"/eg' $@
    perl -I$HOME/git/gap/bin -Mdns -ple 'BEGIN{dnsinit("$ENV{HOME}/git/gap/data/dns.raw")};s/(([a-z][\w-]+)(\.\w+)*)/"$1:".dns($1)/ieg' $@
}
function rdns {
    # any IP gets a () hint on what it FQDN really is)
#   perl -pe 'sub short{return$1 if$_[0]=~/([^.]*)/}use Socket;s/(\d+\.\d+\.\d+\.\d+)/eg;sprintf"$1 %s",lc(short(gethostbyaddr(inet_aton($1),AF_INET)))/eg' $@
    perl -pe 'sub short{return(($_[0]=~/([^.]*)/)?$1:"????????")}use Socket;s/(\d+\.\d+\.\d+\.\d+)/eg;$h=lc(short(gethostbyaddr(inet_aton($1),AF_INET)));sprintf"%s",$h?"$1 $h":$1/eg' $@
}
function bits { perl -le 'print join" ",split/(.{8,8})/,unpack"B32",pack"N*",eval {join" ",@ARGV}' $@; }

# (l)ist (l)ong sym(l)inks - find where symlinks are hiding in a full path
# note the push within the map; the split breaks apart the file components, but the map accumulates them incrementally
function lll() {
    perl -MCwd=abs_path -e ' map { my @path; system "ls -ld " . join" ",
            map { push @path, "$_"; $_ ? join "/", @path : "/"; }
            split "/", abs_path( $_ ? $_ : ".") } @ARGV 
    ' $@;
}
#function lll {
#    perl -e 'use Cwd qw(abs_path);foreach(@ARGV){print"$_:\n";$p="";foreach(split"/",$_){
#    next unless $_;printf"%-40s %s %-40s\n",$p.="/$_",(-l$p)?"L":(-d$p)?"D":"F",abs_path($p);}print"\n";}' $@
#}
function pdump {
    perl -MStorable -MData::Dumper -le '$Data::Dumper::Sortkeys=$Data::Dumper::Indent=1;map{print Dumper(retrieve($_))}@ARGV' $@
}
#function natsort {
#    perl -le 'print join"",map{$_->[0]}sort{$a->[1] cmp $b->[1]}map{
#        join "",map {sprintf("%03d%s",$_,((/^\d+$/)?"":$_));} grep {/./} split/(\d+|\D+)/}<>' $@
#}

#alias rcsinit='mkdir -p RCS;ci -iu'
#alias rcsco='co -l'
#alias rcsci='ci -u'


function json {
    perl -I$HOME -MJSON -le 'print JSON::PP->new->pretty->encode(JSON::PP->new->decode(<>))' $@
}
function did {
    perl -MPOSIX=strftime -le 'print join" ",time(),strftime("%Y/%m/%d-%H:%M:%S",localtime),@ARGV' $@ | tee -a ~/.did
}
function didlist {
    tail -90 ~/.did | perl -MPOSIX=strftime -pe 's/(\d{10})/strftime("%Y-%m-%d %H:%M:%S",localtime $1)/e;'
}
#function tab {
#perl -e 'while(<>){chomp;@F=split/,|\s+/;for$x(0..$#F){$l=length($F[$x]);$max[$x]=$l if$l>$max[$x];push(@{$line[$.]},$F[$x]);}}
#for$y(0..@line){for$x(0..$#{$line[$y]}){print substr($line[$y][$x]." " x 100,0,$max[$x]).","}print"\n";}' $@
#}

function steady {
    perl -pe 'BEGIN{print"\033[;H"};s/\n/\033[K\n/g;END{print"\033[J"}' $@
}

export XENVIRONMENT=$HOME/.Xdefaults

# vi 'which file'
function viw {
    which=`which $1` && vi $which || echo $@ not found
}

export ANSIBLE_HOSTS=$HOME/hosts
export ANSIBLE_HOST_KEY_CHECKING=False


###
### time tracker cli - 'tt'
### tt start   = start day
### tt end     = end day
### tt list    = list projects
### tt hours   = list project hours over last week (or 'this' week?)
### tt TASK notes = implied start on TASK until next proj record is logged, new TASK gets added to list
###
export TT=$HOME/.tt
function _comp_tt {
    local   word="${COMP_WORDS[COMP_CWORD]}"    # word trying to complete
    if [[ $COMP_CWORD -eq 1 ]]; then
        if [ ! -f $TT.list ]; then
            COMPREPLY=( $(compgen -W "WARNING $TT.list does not exist" ) )
        else
            IFS=$'\n' read -d ' ' TASKLIST < $TT.list # so use this instead: http://stackoverflow.com/a/11394045/2135
            COMPREPLY=( $(compgen -W "$( echo ${TASKLIST[@]} )" -- "$word") )
        fi
    elif [[ $COMP_CWORD -eq 2 ]]; then
        COMPREPLY=( $(compgen -W "start end list" -- "$word") )
    else
        COMPREPLY=()
    fi
}
# need to decide if I'm doing 'tt action proj notes' vs 'tt proj action' vs 'tt proj foo' 'tt notes'
function tt () {
    # printf %(fmt)T is bash-4.2+ only, missing args presumes 'now' bash-4.3+
    STAMP=$(date '+%s %Y-%m-%d %H:%M:%S')
    TASK=$1
    shift
    if [[ -z "$TASK" ]]; then
        echo "usage: tt PROJECT comments"
    elif [[ "$TASK" = "list" ]]; then
        cat $TT.list | sort -i | cat -n
    else
        grep -q $TASK $TT.list || echo "$TASK" >> $TT.list
        echo $STAMP $@ | tee -a $TT.log
    fi
}
complete -F _comp_tt tt # should this be within 'tt' as a bootstrap?
