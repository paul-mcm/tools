#!/bin/ksh

SCHEMA_DIR=/etc/openldap/schema
DIR=/tmp/ldap
Trace=false

while getopts :hnt VAR 2> /dev/null
do
    case $VAR in
	h) continue
	   ;;
	t) Trace=true
	   PS4='$LINENO		'
	   set -x
	   ;;
	n) ldif_out=/dev/stdout
	   ;;
	?) echo "Bad arg"
	   exit
	   ;;
    esac
done

if [ $# -lt 1 ]
then
    echo 'Missing schema file'
    exit
fi

shift $(($OPTIND - 1))

[[ -d $DIR ]] && rm -Rf $DIR

mkdir -p ${DIR}/slapd.d
if [ $? -ne 0 ]
then
    echo "failed to created work dir $DIR"
    exit
fi

# Set vars related to schema naming conventions
schemafile=$1		# Full path
obj=${schemafile##*/}	# name of object, stp 1
obj=${obj%.schema}	# stp 2
typeset -l schema=$obj	# schema/lc

# unless we're running w/ the -n flag,
# set output to file in schema dir
ldif_out=${ldif_out:-"${SCHEMA_DIR}/${schema}.ldif"}

cp $schemafile $DIR/${schema}.schema

cat >&2 <<END >> ${DIR}/slapd.conf
include /etc/openldap/schema/core.schema
include /etc/openldap/schema/cosine.schema
include ${DIR}/${schema}.schema
END

slaptest -Qf ${DIR}/slapd.conf -F ${DIR}/slapd.d
if [[ $? -ne 0 ]]
then
    echo "slaptest error" && exit
fi

slapcat -n 0 -F ${DIR}/slapd.d -H "ldap:///???(cn={2}${schema})" | \
    grep -v -e ^structuralObjectClass: \
    -e ^entryUUID: \
    -e ^creatorsName: \
    -e ^createTimestamp: \
    -e ^entryCSN: \
    -e ^modifiersName: \
    -e ^modifyTimestamp: | \
    sed -e "s/{2}'"$obj"'/'"$obj"'/" > $ldif_out

exit

rm -Rf $DIR
