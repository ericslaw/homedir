#!/bin/bash
# this script helps setup the environment to run command in this tool package
# generally it means adding to the PATH
#test $_ = $0 && echo "ERROR this script is meant to be sourced not run" && exit 1
thisdir=`perl -MFile::Basename -MCwd=abs_path -le 'print dirname(abs_path($ARGV[0]||"."))' $BASH_SOURCE`
export PATH=$thisdir/bin:$PATH
