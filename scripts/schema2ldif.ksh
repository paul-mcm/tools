#!/bin/ksh

SCHEMA_DIR=/etc/openldap/schema
DIR=/tmp/ldap
Trace=false
Write=false
Out=/dev/stdout # -w flag will ouput to ldif file

while getopts :htw VAR 2> /dev/null
do
    case $VAR in
	h) continue
	   ;;
	t) Trace=true
	   PS4='$LINENO		'
	   set -x
	   ;;
	w) Write=true
	   ;;
	?) echo "Bad arg"
	   exit
	   ;;
    esac
done

shift $(($OPTIND - 1))

[[ -d $DIR ]] && rm -Rf $DIR

mkdir -p ${DIR}/slapd.d
if [ $? -ne 0 ]
then
    echo "failed to created work dir $DIR"
    exit
fi

schemafile=$1		# Full path
obj=${schemafile##*/}	# name of object, stp 1
obj=${obj%.schema}	# stp 2
typeset -l schema=$obj	# schema/lc
$Write && Out="${SCHEMA_DIR}/${schema}.ldif"

cp $schemafile $DIR/${schema}.schema

echo "include /etc/openldap/schema/core.schema" > ${DIR}/slapd.conf
echo "include /etc/openldap/schema/cosine.schema" >> ${DIR}/slapd.conf
echo "include ${DIR}/${schema}.schema" >> ${DIR}/slapd.conf

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
    sed -e "s/{2}'"$obj"'/'"$obj"'/" > $Out

exit

rm -Rf $DIR
