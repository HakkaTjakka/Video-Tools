#!/bin/bash

echo -------------------------------------------------------------------------- >> error.log

echo Getting filename from URL: $*
echo Getting filename from URL: $* >> error.log

		## yt-dlp -i --restrict-filenames --skip-unavailable-fragments --geo-bypass --get-filename "ytsearch:$*" > filename.txt

yt-dlp -i --restrict-filenames --skip-unavailable-fragments --geo-bypass --get-filename "$*" > filename.txt

read -r FILENAME < filename.txt
echo "Filename: $FILENAME"

echo "Filename: $FILENAME" >> error.log

BASENAME="${FILENAME%.*}"

echo "Basename: $BASENAME"

		## yt-dlp --restrict-filenames --abort-on-error --no-mtime --sub-lang "nl,en" --write-subs --convert-subs srt --write-auto-subs --download-archive ARCHIVE.TXT --skip-unavailable-fragments --write-thumbnail --geo-bypass "ytsearch:$*"

#--default-search "ytsearch"

COMMAND="yt-dlp  --restrict-filenames --abort-on-error --no-mtime --sub-lang "nl" --write-subs --convert-subs srt --write-auto-subs --download-archive ARCHIVE.TXT --skip-unavailable-fragments --write-thumbnail --geo-bypass "$*""

echo "$COMMAND" >> COMMANDS.SH
echo "$COMMAND" > command.sh
chmod +x command.sh
./command.sh


#while IFS= read -r line; do
#	echo "yt-dlp: $line"
#	echo "yt-dlp: $line" >> error.log
#done <<< $($COMMAND)



# yt-dlp --restrict-filenames --abort-on-error --no-mtime --sub-lang "nl,en" --write-subs --convert-subs srt --write-auto-subs --download-archive ARCHIVE.TXT --skip-unavailable-fragments --write-thumbnail --geo-bypass "$*"

# `ls -1 $value*`


VAR=$(echo $BASENAME | sed 's/[][]/\\&/g')

while IFS= read -r line; do
	echo "Subtitle file: $line"
	echo "Subtitle file: $line" >> error.log
	sof/sof $line
done <<< $(ls -1 $VAR.*.srt)

while IFS= read -r line; do
	echo "Subtitle fixed: $line"
	echo "Subtitle fixed: $line" >> error.log
	
	LANGUAGE="${line%.*}"
	LANGUAGE="${LANGUAGE%.*}"
	LANGUAGE="${LANGUAGE##*.}"
	echo "Language: $LANGUAGE"

	COMMAND="ffmpeg -y -hide_banner -progress url -nostdin -i \"$FILENAME\" -map 0:v:0 -map 0:a:0 -strict -2 -filter_complex \"[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=black,subtitles=f='$line':force_style='Fontname=Simply Rounded Bold,FontSize=24,Outline=1'\" -c:s mov_text -c:v h264_nvenc -profile:v high -pix_fmt yuv420p -bf:v 3 -preset slow -rc-lookahead 32 -c:a copy \"out/$BASENAME.$LANGUAGE.PART.mp4\""
	echo "$COMMAND" >> COMMANDS.SH
	echo "$COMMAND" > command.sh
	chmod +x command.sh
	./command.sh

	COMMAND="mv \"out/$BASENAME.$LANGUAGE.PART.mp4\" \"out/$BASENAME.$LANGUAGE.mp4\""
	echo "$COMMAND" >> COMMANDS.SH
	echo "$COMMAND" > command.sh
	chmod +x command.sh
	./command.sh



done <<< $(ls -1 $VAR.*.srt.double)


