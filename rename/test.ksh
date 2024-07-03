#!/usr/bin/

BIN="${HOME}/dev/tools/rename/rename"
IFS='
'

#set -A files '/home/paul/tmp/file one two three' 'file one two three' 'test/file one two three'
#set -A files '/home/paul/tmp/file one two three' './test/file one two three' './file one two three'  
set -A files './.test one two three'

function remove {
    for file in ${files[@]}
    do
	f=$(echo $file | sed 's/ /_/g')
	rm $f
    done
}

function remove_new {
    for f in ${files[@]}
    do	
	rm "$f"
    done
}

function create {
    for file in ${files[@]}
    do
	echo $file
	touch "${file}"
    done
}

function list {
    for file in ${files[@]}
    do
	ls -l "$file"
    done
}

function run_test {
    for file in ${files[@]}
    do
	$BIN $file
    done
}

#create
#list
#remove
#remove_new
#run_test
#list
