cuegen
----------------------------
a small script that converts track lists from YouTube videos into cue files that can be used with mp3tag

artist is intentionally populated the same for all tracks to simplify searching in iTunes from the header line of the input file.  actual "artist - track" is added to the title of the track so it is visible when it's playing.

Input file example (./input):
----------------------------

```
<HEADER LINE>: ARTIST:NAME_OF_ALBUM:YEAR

example:
Ethnic Music:Best Deep House Mix Vol.54:2024

DATA:  STARTTIME ARTIST - TRACKNAME

example:
00:00 RILTIM - Exciting
04:54 Ahmed Abdurahimli - Love In Summer
07:59 KASIMOFF - Alone
12:46 Gurban Abbasli - Amour Sonata
