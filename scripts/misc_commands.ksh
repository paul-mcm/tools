#!/bin/ksh 

MPLY='/usr/local/bin/mpalyer'
Prog=${0##*/}

function pkg_search {
    typeset p=$1
    typeset RunDir='/usr/ports'

    cd $RunDir
    if [[ "$PWD" != $RunDir ]]
    then
	echo "Unable to CD to $rundir"
	exit
    fi
    make search key="$p"
    exit
}

function addup {
    total=0

    while read number
    do
	((total = total + number))
    done 

    echo $total
    exit
}

function battery_chk {
     SYSCTL='/sbin/sysctl'
     STAT='hw.sensors.acpiac0.indicator0'
     BAT0='hw.sensors.acpibat0.watthour3'
     BAT1='hw.sensors.acpibat1.watthour3'

     $SYSCTL $BAT0 $BAT1 $STAT | sed \
	-e 's/hw.sensors.acpibat[0,1].watthour3=\([0-9.]\{1,\}\).*/\1/' \
	-e 's/hw.sensors.acpiac0.indicator0=\([A-Za-z]\{1,\}\) .*/Power: \1/'
     exit
}

function remove_backup_files {
    if [[ $# = 1 ]]
    then
	cd $1
	`rm .*~ >/dev/null 2>&1`
	`rm *~ >/dev/null 2>&1`
    else
	`rm .*~ >/dev/null 2>&1`
	`rm *~ >/dev/null 2>&1`
    fi
    exit
}

function mplay_deutschlandfunk {
    $MPLY 'https://st01.sslstream.dlf.de/dlf/01/128/mp3/stream.mp3'
    exit
}

function mplay_radiotre {
    $MPLY http://icestreaming.rai.it/3.mp3
    exit
}

function mplay_radiouno {
    $MPLY http://icestreaming.rai.it/1.mp3
    exit
}

function lib_lookup {
    typeset q=$1
    RunDir="${HOME}/unix_admin" 

    cd $RunDir
    if [[ "$PWD" != $RunDir ]]
    then
	echo "Unable to CD to $rundir"
	exit
    fi

    echo "Q: $q"

    opts="options/${q}_options"          
    refs="refs/${q}_ref"    
    notes="notes/${q}_notes"             

    [ -f $opts ] && file=$opts
    [ -f $refs ] && file=$refs
    [ -f $notes ] && file=$notes
  
    if [[ -z $file ]]
    then
	echo "nothing found"
	exit
    fi

    lines=$(wc -l $file) 
    lines=${lines% *}  

    if (( lines < 50 ))
    then
	/bin/cat $file
    else
	/usr/bin/less $file
    fi                                                
    exit
}

case $Prog in
    pkgs) pkg_search $1
	  exit
	  ;;
    addnum) addup
	  exit
	  ;;
    bat) battery_chk
	  exit
	  ;;
    clean) remove_backup_files
	  exit
	  ;;
    radiouno) mplay_radiouno
	    exit
	    ;;
    radiotre) mplay_radiotre
	    exit
	    ;;
    dfunk) mplay_deutschlandfunk
	    exit
	    ;;
    libl) lib_lookup $1
	 exit
	 ;;
esac

exit

