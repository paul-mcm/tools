#!/bin/ksh
# BUILD CSCOPE CROSS REFERENCE AND CTAGS FILE IN $PWD
FPATH='/usr/local/lib/ksh'
FILES='cscope.files'
TAGS_FILE='ctags'
Trace=false
autoload

[[ ! -w $PWD ]] && die "Can't write to $dir"

find ./ -name "*.c" -o -name "*.h" > $FILES || die echo "find error"

# Call cscope
/usr/local/bin/cscope -b -i ./${FILES}

# Call ctags
cat $FILES | while read line
do
    /usr/bin/ctags -af $TAGS_FILE $line
    [[ $? -ne 0 ]] && die "ctags error: $?"
done
