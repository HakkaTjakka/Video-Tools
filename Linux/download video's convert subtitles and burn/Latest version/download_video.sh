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
VAR=$(echo $BASENAME | sed 's/[][]/\\&/g')
#echo "Basename: $BASENAME"

#yt-dlp --restrict-filenames --abort-on-error --no-mtime --sub-lang "nl,en,de" --write-subs --convert-subs srt --write-auto-subs --download-archive ARCHIVE.TXT --skip-unavailable-fragments --write-thumbnail --geo-bypass "ytsearch:$*"
#--default-search "ytsearch"
COMMAND="yt-dlp --restrict-filenames --default-search "ytsearch" --abort-on-error --no-mtime --sub-lang "nl,en" --write-subs --write-auto-subs --download-archive ARCHIVE.TXT --skip-unavailable-fragments --write-thumbnail --geo-bypass "$*""

#COMMAND="yt-dlp  --restrict-filenames --abort-on-error --no-mtime --sub-langs all --write-subs --write-auto-subs --embed-subs --download-archive ARCHIVE.TXT --skip-unavailable-fragments --write-thumbnail --geo-bypass "$*""

echo "$COMMAND" >> COMMANDS.SH
echo "$COMMAND" > command.sh
chmod +x command.sh
./command.sh

if [ ! -d "subs" ]; then
	mkdir "subs"
fi	
# convert .vtt to .srt. Can also be done by yt-dlp with --convert-subs srt but only after/when downloading. So when interrupted can be continued.
for line in $VAR.*.vtt
do
	LANGUAGE="${line%.*}"
	LANGUAGE="${LANGUAGE##*.}"
	echo "Converting subtitle file to .srt and fixing: $line"
	echo "Converting subtitle file to .srt and fixing: $line" >> error.log
	ffmpeg -n -hide_banner -i $BASENAME.$LANGUAGE.vtt $BASENAME.$LANGUAGE.srt
#	rm -f $BASENAME.$LANGUAGE.vtt
	sof/sof $BASENAME.$LANGUAGE.srt
#	echo "Moving $BASENAME.$LANGUAGE.srt* to dir: subs/$LANGUAGE"
	if [ ! -d "subs/$BASENAME" ]; then
		mkdir "subs/$BASENAME"
	fi	

	if [ ! -d "subs/$BASENAME/$LANGUAGE" ]; then
		mkdir "subs/$BASENAME/$LANGUAGE"
	fi	
#	mv "$BASENAME.$LANGUAGE.vtt" "subs/$BASENAME/$LANGUAGE"
#	mv "$BASENAME.$LANGUAGE.srt" "subs/$BASENAME/$LANGUAGE"
#	mv "$BASENAME.$LANGUAGE.srt.single" "subs/$BASENAME/$LANGUAGE"
#	mv "$BASENAME.$LANGUAGE.srt.double" "subs/$BASENAME/$LANGUAGE"
done

# select wanted languages
LANG="nl"; 		mv "subs/$BASENAME/$LANG/$BASENAME.$LANG.srt.double" .	# Dutch	nl
#LANG="en"; 		mv "subs/$BASENAME/$LANG/$BASENAME.$LANG.srt.double" .	# English	en
#LANG="de"; 		mv "subs/$BASENAME/$LANG/$BASENAME.$LANG.srt.double" .	# German	de
#LANG="fr"; 		mv "subs/$BASENAME/$LANG/$BASENAME.$LANG.srt.double" .	# French	fr
#LANG="tr"; 		mv "subs/$BASENAME/$LANG/$BASENAME.$LANG.srt.double" .	# Turkish	tr
#LANG="ar"; 		mv "subs/$BASENAME/$LANG/$BASENAME.$LANG.srt.double" .	# Arabic	ar
#LANG="zh-Hans"; 	mv "subs/$BASENAME/$LANG/$BASENAME.$LANG.srt.double" .	# Chinese	zh-Hans

if [ ! -d "out" ]; then
	mkdir "out"
fi	
for line in $VAR.*.srt.double
do
	echo "Subtitle fixed: $line"
	echo "Subtitle fixed: $line" >> error.log
	
	LANGUAGE="${line%.*}"
	LANGUAGE="${LANGUAGE%.*}"
	LANGUAGE="${LANGUAGE##*.}"
	echo "Language: $LANGUAGE"

	if test -f "out/$BASENAME.$LANGUAGE.mp4"; then
		echo "out/$BASENAME.$LANGUAGE.mp4 exists."
	else

		COMMAND="ffmpeg -y -hide_banner -progress url -nostdin -i \"$FILENAME\" -i \"$line\" -map 0:v:0 -map 0:a:0 -map 1:s:0 -strict -2 -filter_complex \"[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=black\" -c:s mov_text -c:v h264_nvenc -profile:v high -pix_fmt yuv420p -bf:v 3 -preset slow -c:a copy \"out/$BASENAME.$LANGUAGE.PART.mp4\""

#		COMMAND="ffmpeg -y -hide_banner -progress url -nostdin -i \"$FILENAME\" -map 0:v:0 -map 0:a:0 -strict -2 -filter_complex \"[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=black,subtitles=f='$line':force_style='Fontname=Simply Rounded Bold,FontSize=24,Outline=1'\" -c:s mov_text -c:v h264_nvenc -profile:v high -pix_fmt yuv420p -bf:v 3 -preset slow -c:a copy \"out/$BASENAME.$LANGUAGE.PART.mp4\""

#		~/nvidia/ffmpeg/ffmpeg -y -hide_banner -progress url -nostdin -i "$FILENAME" -strict -2 -filter_complex "[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=black" -c:s mov_text -c:v h264_nvenc -profile:v high -pix_fmt yuv420p -preset slow -c:a copy "out/$BASENAME.$LANGUAGE.PART.mp4"
		
#		COMMAND="ffmpeg -y -hide_banner -progress url -nostdin -i \"$FILENAME\" -map 0:v:0 -map 0:a:0 -strict -2 -filter_complex \"[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=black,subtitles=f='$line':force_style='Fontname=Simply Rounded Bold,FontSize=24,Outline=1'\" -c:s mov_text -c:v h264_nvenc -profile:v high -pix_fmt yuv420p -bf:v 3 -preset slow -c:a copy \"out/$BASENAME.$LANGUAGE.PART.mp4\""
#		COMMAND="ffmpeg -y -hide_banner -progress url -nostdin -i \"$FILENAME\" -map 0:v:0 -map 0:a:0 -strict -2 -filter_complex \"[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=black,subtitles=f='$line':force_style='Fontname=Simply Rounded Bold,FontSize=24,Outline=1'\" -c:s mov_text -c:v h264_nvenc -profile:v high -pix_fmt yuv420p -bf:v 3 -preset slow -rc-lookahead 32 -c:a copy \"out/$BASENAME.$LANGUAGE.PART.mp4\""
		echo "$COMMAND" >> COMMANDS.SH
		echo "$COMMAND" > command.sh
		chmod +x command.sh
		./command.sh

		COMMAND="mv \"out/$BASENAME.$LANGUAGE.PART.mp4\" \"out/$BASENAME.$LANGUAGE.mp4\""
		echo "$COMMAND" >> COMMANDS.SH
		echo "$COMMAND" > command.sh
		chmod +x command.sh
		# burn *(&'r burn
		./command.sh
	fi
#	mv "$BASENAME.$LANGUAGE.srt.double" "subs/$BASENAME/$LANGUAGE"
done


