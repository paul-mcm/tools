#!/bin/ksh 
PROG='xls2csv.ksh'
FPATH='/home/paul/local/lib/ksh'
PATH='/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin'
OUTDIR='csv_files'

TestFlg=false
Trace=false
autoload

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
    if [[ $l = Day* ]]
    then
	continue
    fi

    day=${l%%,*}
    tmp=${l#*,}
    td=${tmp%,*,*}
    len=${td#*,}

    tmp=${td%,*}
    str_h=${tmp%:*}
    tmp=${td#*:}
    str_m=${tmp% *}

    if [[ $td = *PM* && $str_h -ne 12 ]]
    then
        ((str_h+=12))
    fi

    (( stp_t = (str_h * 60) + str_m + len))
    (( stp_m = stp_t % 60 )) 
    (( stp_h = $stp_t / 60 ))

    if [[ $stp_m -eq 0 ]]
    then
	stp_m='00'
    fi

    if [[ $day = Su ]]
    then
	day=1
    elif [[ $day = Mo ]]
    then
	day=2
    elif [[ $day = Tu ]]
    then
	day=3
    elif [[ $day = We ]]
    then
	day=4
    elif [[ $day == Th ]]
    then
	day=5
    elif [[ $day == Fr ]]
    then
	day=6
    elif [[ $day == Sa ]]
    then
	day=7
    fi

    echo "L: $l"
    output=$(echo $l | awk -F, -v OFS=, -v shr=$str_h -v smin=$str_m -v ehr=$stp_h \
	-v day=$day -v emin=$stp_m -v len=$len '{print day, $1, len, shr, smin, ehr, emin, $4, $5}')
    lessons="${lessons} $output"
done

IFS=$OFS

printf "%s\n" ${lessons[@]} | /usr/bin/sort -n -t , -k 1 -k 4 -k 5 -o $outfile




