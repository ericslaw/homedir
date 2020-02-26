#!/usr/bin/perl -l
# idiomatic word pair script
# offer list of word groupings for use in coding/organizing
# items are _generally_ opposites/antonyms, but synonyms (and sequences?) are relevant too
# rank items by some attributes
# include notes on usage/warnings
# include naming checklist items from code complete
# TODO: denote when similar(=+) or opposite(|/); sim vs opp? is there another like sequence?

use strict;
use List::Util qw(min max);
my $target = shift @ARGV;
my @list = 

    # rank by similar length
    sort {$a+0 <=> $b+0}
    map { my @wordlen = map {length} split/\W+/,$_; my$span= max(@wordlen) - min(@wordlen);"$span $_" }

    # filter by input regex
    grep { $_ =~ $target }
    map { join"|", sort split/\W+/ }

    # filter out comments and blank lines
    grep /./,
    map { chomp; s/#.*//; $_ }
    <DATA>;

# show me matches
print join"\n",@list;

# TODO:
# show me the other words that have other combos  (how many levels deep?)
# rank by preference shorter
# consider white/black list
# consider some rank modification as a note/comment
# rank by uniqueness of word usage/frequency

__DATA__
# Commented out sets are more similar than different:
# ::: similar :::
# span/spread
# apply/invoke
# call/apply
# do/redo
# drop/dip
# finish/complete
# flag/mark
# format/clear
# need/want
# open/load
# set/put
# state/status
# step/skip
# this/that
# ::: Sequences :::
# red green blue

stop/go
red/green
above/below
active/passive
add/del
add/sub
add/sub/remove/del
alloc/free
allow/deny
append/prepend
approve/deny
backup/restore
before/after
begin/end
big/small
big/sml
buffer/stream
build/destroy
busy/idle
client/server
compress/uncompress
confirm/deny
cook/thaw
create/destroy
do/undo
edit/save
enable/disable
encode/decode
enter/exit
escape/unescape
expand/contract
fire/reset
first/last
focus/blur
fore/back
fork/reap
fresh/stale
from/into
get/set/put
give/take
global/local
grant/block
grant/revoke
group/ungroup
have/need/want
head/tail
import/export
in/out
include/exclude
incr/decr
initialize/destroy
input/output
insert/delete
install/uninstall
join/split
kill/reap
last/next
load/save
lock/unlock
master/slave
min/max
move/remove
move/size
old/new
on/off
open/close
open/save
pack/unpack
parent/child
pass/fail
ping/pong
pop/push
prev/next
pub/sub
public/private
raw/cook
read/write
req/opt
request/response
required/optional
rise/fall
same/diff
select/clear
self/other
send/recv
set/clr
set/reset
shift/unshift
show/hide
shrink/enlarge
signal/clear
size/resize
sleep/wake
source/target
spike/dip
src/dst
start/end
start/stop
startup/shutdown
store/fetch
store/load
store/retrieve
suspend/resume
unconnect/disconnect
up/dn
up/down
was/now
