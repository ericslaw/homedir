#!/bin/bash
# install script to setup homedir based on cloned github repo

# location of this script
HERE=`perl -MFile::Basename -MCwd=abs_path -MList::Util=first -le 'print first { -e $_ } map { -e $_ ? abs_path $_ : undef } map { -f $_ ? dirname $_ : $_ } @ARGV' -- "$0" ${BASH_SOURCE[0]:-$0}`

# TODO: add -verbose and -neuter flags
# note: if doit does not eval then panic will likely trigger
function doit {
    echo "$@"
    eval "$@"
}
function panic {
    echo $@
    exit 1
}
# create link at dst to src, optionally backup to sav
function linkcreate { # src dst [sav]
    local src="$1"
    local dst="$2"
    local sav="$3"
    test -e "$src"   ||   panic "src $src missing"
    test -n "$dst"   ||   panic "dst $dst missing"

    # save if defined + src exists, dst exists but is not a link, and save not exist already
    if [ -n $sav -a -e $src -a -e $dst -a ! -L $dst -a ! -e $sav ]; then
        doit mv -v $dst $sav
    fi

    # link if does not already exist -- will exist as link if previously installed, will exist as file if something went wrong (readonly filesystem)
    if [ ! -e $dst ]; then
        doit ln -s $src $dst
    fi

    if [ ! -L $dst ]; then
        panic "$dst is not a link"
    fi
}
function linkrestore { # dst sav
    local dst="$2"
    local sav="$3"
    if [ -e $sav -a -L $dst ]; then
        doit rm $dst
        doit mv $sav $dst
    fi
}


src=$HERE
dst=$HOME

test -d "$src"   ||   panic "src repo not found"
test -d "$dst"   ||   panic "dst home not found"

# what to do? ln, cp, mv, rm? generally ln to src

# link dirs and files here
for obj in .git .hammerspoon .bashrc .profile .vimrc .jq; do
    linkcreate $src/$obj $dst/$obj $dst/$obj.save
done

# populate one-time skel files here
for obj in .promptrc; do
    if [ -e $src/$obj.skel -a ! -e $dst/$obj ]; then
        doit cp -v $src/$obj.skel $dst/$obj
    fi
done

# make empty dirs here
for obj in .backup logs tmp; do
    if [ ! -d $dst/$obj ]; then
        doit mkdir -p $dst/$obj
    fi
done
