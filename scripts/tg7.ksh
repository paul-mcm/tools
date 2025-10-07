#!/bin/ksh

URL='https://www.la7.it/tgla7/podcast'
TMPFILE=$(/usr/bin/mktemp) || exit 1
curl -s $URL >> $TMPFILE

while read line
do
    ln=$(echo $line | \
        grep 'https://limone.iltrovatore.it/audio.mp3?source_r=la7&fn=podcast-tgla7-')
    [[ $? -eq 0 ]] && break
done < /tmp/tmp.Ac5Ngnq9AS

url=$(echo $ln | \
    sed 's/.*\(https:\/\/limone.iltrovatore.it\/audio.mp3\?source_r=la7&fn=podcast-tgla7-[0-9]\{1,\}.mp3\).*/\1/')

rm $TMPFILE

/usr/local/bin/mplayer $url


