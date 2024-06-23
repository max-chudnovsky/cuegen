#!/bin/bash

# Init
INPUT=./input.txt
MP3FILE=$1
TRACK=1

if [ "$MP3FILE" = "" ]; then
	echo "$(basename $0): error.  missing audio filename parameter"
	echo "Usage: $(basename $0) <audio filename>"
	exit 1
fi
if [ ! -r ./input ]; then
	echo "$(basename $0): error.  missing input information file: ./input"
	echo "File needs to be in this format:"
	echo "artist:album:year:genre"
	echo "TRACK_START_TIME ARTIST - TRACKTITLE"
	echo "  TIME FORMAT: H:M:S"
	exit 1
fi

fixindex(){
	if [ "$(echo "$1" | awk -F: '{print NF}')" = "2" ]; then
		echo "$1:00"
	else
		H=$(echo $1 | awk -F: '{print $1}' | sed 's/^0//g')
		M=$(echo $1 | awk -F: '{print $2}' | sed 's/^0//g')
		HM=$((H*60))
		S=$(echo $1 | awk -F: '{print $3}')
		echo "$((HM+M)):$S:00"
	fi
}

# strip pretty characters
sed -i 's/◉ //g;s/♫ //g' $INPUT

# lets get artist/title/year/genre for album from first line of input file.  it has to be in format:  artist:album:year:genre
ARTIST=$(awk -F: 'NR==1{print $1}' $INPUT)
ALBUM=$(awk -F: 'NR==1{print $2}' $INPUT)
YEAR=$(awk -F: 'NR==1{print $3}' $INPUT)
GENRE=$(awk -F: 'NR==1{print $4}' $INPUT)

echo "TITLE $ALBUM
PERFORMER $ARTIST
REM Year  : $YEAR
REM Genre : Ambient
FILE \"$MP3FILE\" MP3" > "${MP3FILE%.*}".cue

while IFS= read -r line; do
  TIME=$(fixindex ${line%% *})
  echo "  TRACK $(printf '%02d\n' "$TRACK") AUDIO
    TITLE \"${line#* }\"
    PERFORMER \"$ARTIST\"
    INDEX 01 $TIME"
  ((TRACK++))
done < <(awk 'NR>1{print}' $INPUT) >> "${MP3FILE%.*}".cue
