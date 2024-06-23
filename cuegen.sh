#!/bin/bash
# written by Max Chudnovsky

# Init
INPUT=./input
MP3FILE=$1
TRACK=1

usage(){
	echo "$(basename $0) $1"
	echo "Usage: $(basename $0) <audio filename>"
	echo -e "\nScript expects to find $INPUT file with data about track layout and other info"
	echo "File needs to be in this format:"
        echo "artist:album:year:genre"
        echo "TRACK_START_TIME ARTIST - TRACKTITLE"
        echo "  TIME FORMAT: H:M:S"
}

if [ "$MP3FILE" = "" ]; then
	usage "error.  missing audio filename parameter"
	exit 1
fi

if [ ! -r ./input ]; then
	usage "error.  missing input information file: ./input"
	exit 1
fi
if [ $(awk -F: 'NR==1{print NF}' $INPUT) != "4" ]; then
	usage "error: looks like you do not have 4 fields in the header of $INPUT file."
	exit 1
fi
	

# Function that will correct time index from H:M:S to M:S format we need for cue file
fixindex(){
	if [ "$(echo "$1" | awk -F: '{print NF}')" = "2" ]; then
		echo "$1:00"
	else
		H=$(echo "$1" | awk -F: '{print $1}' | sed 's/^0//g')
		M=$(echo "$1"| awk -F: '{print $2}' | sed 's/^0//g')
		HM=$((H*60))
		S=$(echo "$1" | awk -F: '{print $3}')
		echo "$((HM+M)):$S:00"
	fi
}

# strip any leading non alpha numeric characters (sometimes used for decoration in youtube)
sed -i 's/^[^[:alnum:]]*//' $INPUT

# get artist/title/year/genre for album from the header of input file.  it has to be in format:  artist:album:year:genre
ARTIST=$(awk -F: 'NR==1{print $1}' $INPUT)
ALBUM=$(awk -F: 'NR==1{print $2}' $INPUT)
YEAR=$(awk -F: 'NR==1{print $3}' $INPUT)
GENRE=$(awk -F: 'NR==1{print $4}' $INPUT)

# build a header for cue
echo "TITLE $ALBUM
PERFORMER $ARTIST
REM Year  : $YEAR
REM Genre : $GENRE
FILE \"$MP3FILE\" MP3" > "${MP3FILE%.*}".cue

# go through input file and generate info for tracks
while IFS= read -r line; do
  echo "  TRACK $(printf '%02d\n' "$TRACK") AUDIO
    TITLE \"${line#* }\"
    PERFORMER \"$ARTIST\"
    INDEX 01 $(fixindex ${line%% *})"
  ((TRACK++))
done < <(awk 'NR>1{print}' $INPUT) >> "${MP3FILE%.*}".cue
