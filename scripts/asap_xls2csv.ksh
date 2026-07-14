#!/bin/ksh

PROG='xls2csv.ksh'
FPATH='/home/paul/local/lib/ksh'
PATH='/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin'
OUTDIR='csv_files'
set -A DAYS Su Mo Tu We Th Fr Sa
TestFlg=false
Trace=false
autoload

function make_csv_file {
    typeset infile=$1
    typeset outfile
    typeset output
    typeset lessons
    typeset tmp
 
    tmp=$(basename $infile)
    ${TestFlg:-false} && outfile='/dev/stdout' || \
	outfile="${OUTDIR}/${tmp%.xls}.csv"

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
    runcmd 'echo Day,Wday,Length,Start Hr,Start Min,Stop Hr,Stop Min,Last,First' >> $outfile
    runcmd "printf "%s\n" ${lessons[@]} | /usr/bin/sort -n -t , -k 1 -k 4 -k 5" >> $outfile
}

while getopts :d:f:tx OPT 2> /dev/null
do
    case $OPT in
        f) infile=$OPTARG
           ;;
	d) indir=$OPTARG
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

[[ ! -f /usr/local/bin/html2text ]] && die "html2text not found"


if [[ -f $infile ]]
then
    make_csv_file $infile    
elif [[ -d $indir ]]
then
    for file in $(ls ${indir}/*)
    do
        echo $file
	make_csv_file $file
    done
fi
