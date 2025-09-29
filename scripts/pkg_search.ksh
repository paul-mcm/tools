#!/bin/ksh
     
PROG='pkg_search.ksh'
FPATH="/home/paul/local/lib/ksh"
RUNDIR='/usr/ports'
Trace=false
TestFlg=false
autoload

pkg="$1"
[[ -z "$pkg" ]] && die "Usage: $PROG <pkg name>"

cd $RUNDIR
[[ $PWD != $RUNDIR ]] && die "Unable to CD to $RUNDIR"

/usr/bin/make search key="$pkg"
OA
exit

