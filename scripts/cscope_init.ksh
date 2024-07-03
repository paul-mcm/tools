#!/bin/ksh

# BUILD CSCOPE CROSS REFERENCE
# AND CTAGS FILE IN $PWD

FILES='cscope.files'
TAGS_FILE='ctags'
dir=$PWD

cd $dir
if [ $? -ne 0 ]
then
    echo "failed to cd to $dir"
    exit -1;
fi

if [[ ! -w $dir ]]
then
    echo "Can't write to $dir"
    exit 1
fi

find ./ -name "*.c" -o -name -o -name "*.h" > $FILES
if [ $? -ne 0 ]
then
    echo "find error"
    exit -1;
fi

# Call cscope
/usr/local/bin/cscope -qRb -i ./${FILES}

# Call ctags
cat $FILES | while read line
do
    /usr/bin/ctags -af $TAGS_FILE $line
    if [ $? -ne 0 ]
    then
	echo "ctags error: $?"
	exit -1
    fi
done
