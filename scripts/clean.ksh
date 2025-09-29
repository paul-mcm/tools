#!/bin/ksh

PROG='clean.ksh'
FPATH="/home/paul/local/lib/ksh"
Trace=false
TestFlg=false
autoload

function help {
    cat >&2 <<ENDUSAGE

$PROG - remove pesky emacs backup files (e.g, *~ and .*~x)
	    from working directory or directory  

Usage: clean.ksh [ -htx ] [ dir ]

Options:
    -d <dir>	-	remove backup files in <dir>
    -h		-       display this 'help' section
    -t		-	Debug; show but don't exec commands
			that make modifications/changes
    -x		-       turn on xtrace

ENDUSAGE
     exit
}

while getopts :d:htx OPT 2> /dev/null
do
    case $OPT in
        d) dir=$OPTARG
	   ;;
        h) help
           exit
           ;;
        t) TestFlg=true
           ;;
        x) Trace=true
           echo "Tracing $prog"
           PS4='$LINENO:        '
           set -x
           ;;
        ?) echo "error"
           exit
           ;;
    esac
done
shift $(($OPTIND - 1))

if [[ -n "$dir" ]]
then
    d=${dir%/}
    [[ -d "$d" ]] || die "invalid directory" 
    cd "$d"
    [[ $PWD != "$d" ]] && die "failed to cd to $d"
fi

runcmd rm ./.*~ > /dev/null 2>&1
runcmd rm ./*~ > /dev/null 2>&1

