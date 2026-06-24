#!/bin/ksh 
PROG='xls2csv.ksh'
FPATH='/home/paul/local/lib/ksh'
PATH='/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin'
OUTDIR='csv_files'

TestFlg=false
Trace=false
autoload

set -A DAYS Su Mo Tu We Th Fr Sa

while getopts :f:tx OPT 2> /dev/null
do
    case $OPT in
        f) infile=$OPTARG
	   tmp=$(basename $infile)
	   outfile="${OUTDIR}/${tmp%.xls}.csv"
           ;;
        t) TestFlg=true 
           ;;
        x) TestFlg=true
           Trace=true
           echo "Tracing $Prog"
           PS4='$LINENO:       '
           set -x
           ;;
        ?) echo "try again..." && exit
           ;;
    esac
done

OFS=$IFS
IFS="
"
for l in $(/usr/local/bin/html2text -width 150 $infile | \
	sed -e 's/^[^a-zA-Z]\{1,\}//' -e 's/[ ]\{2,\}/,/g' | \
	awk -v OFS=, -F, '{print $5, $6, $7, $2, $1 }' )
do
    [[ $l = Day* ]] && continue
    IFS=,
    set -- $l 
    wday=$1; start_t=$2; len=$3; first_last="$4,$5"

    # set start hour/min
    str_h=${start_t%:*}; 
    tmp=${start_t#*:}
    str_m=${tmp% *}

    # set stop hour/min 
    [[ $start_t = *PM* && $str_h -lt 12 ]] && \
	(( str_h+=12 ))
    (( stp_t = (str_h * 60) + str_m + len))
    (( stp_m = stp_t % 60 )) 
    (( stp_h = $stp_t / 60 ))

    [[ $first_last = [A-Za-z]*\ [A-Za-z]* ]] && \
	first_last=$(echo "$first_last" | sed 's/ /-/g')

    if [[ $stp_m -eq 0 ]]
    then
	stp_m='00'
    fi

    if [[ $wday = 'Su' ]]
    then
	day=0
    elif [[ $wday = 'Mo' ]]
    then
	day=1
    elif [[ $wday = 'Tu' ]]
    then
	day=2
    elif [[ $wday = 'We' ]]
    then
	day=3
    elif [[ $wday == 'Th' ]]
    then
	day=4
    elif [[ $wday == 'Fr' ]]
    then
	day=5
    elif [[ $wday == 'Sa' ]]
    then
	day=6
    fi

    output="${day},${DAYS[$day]},${len},${str_h},${str_m},${stp_h},${stp_m},${first_last}"

    lessons="${lessons} $output"
done

IFS=$OFS

echo "Day,Wday,Length,Start Hr, Start Min, Stop Hr, Stop Min, Last, First" >> $outfile

printf "%s\n" ${lessons[@]} | /usr/bin/sort -n -t , -k 1 -k 4 -k 5 #>> $outfile
