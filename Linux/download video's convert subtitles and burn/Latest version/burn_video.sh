#!/bin/bash

echo -------------------------------------------------------------------------- >> error.log

read -r FILENAME < filename.txt
echo "Filename: $FILENAME"
echo "Filename: $FILENAME" >> error.log
BASENAME="${FILENAME%.*}"
VAR=$(echo $BASENAME | sed 's/[][]/\\&/g' |  sed 's/ /\\ /g')

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
		COMMAND="~/ffmpeg-n4.4-latest-linux64-gpl-4.4/bin/ffmpeg -y -hide_banner -progress url -nostdin -i \"$FILENAME\" -map 0:v:0 -map 0:a:0 -strict -2 -filter_complex \"[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=black,subtitles=f='$line':force_style='Fontname=Simply Rounded Bold,FontSize=24,Outline=1'\" -c:s mov_text -c:v h264_nvenc -profile:v high -pix_fmt yuv420p -bf:v 3 -preset slow -rc-lookahead 32 -c:a copy \"out/$BASENAME.$LANGUAGE.PART.mp4\""
#		COMMAND="~/ffmpeg-n4.4-latest-linux64-gpl-4.4/bin/ffmpeg -y -hide_banner -progress url -nostdin -i \"$FILENAME\" -map 0:v:0 -map 0:a:0 -strict -2 -filter_complex \"[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=black,subtitles=f='$line':force_style='Fontname=Simply Rounded Bold.ttf,FontSize=24,Outline=1'\" -c:s mov_text -c:v h264_nvenc -profile:v high -pix_fmt yuv420p -bf:v 3 -preset slow -rc-lookahead 32 -c:a copy \"out/$BASENAME.$LANGUAGE.PART.mp4\""
#		COMMAND="~/ffmpeg-n4.4-latest-linux64-gpl-4.4/bin/ffmpeg -y -hide_banner -progress url -nostdin -i \"$FILENAME\" -map 0:v:0 -map 0:a:0 -strict -2 -filter_complex \"[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=black,subtitles=f='$line':force_style='Fontname=Simply Rounded Bold,FontSize=24,Outline=1'\" -c:s mov_text -c:v h264_nvenc -profile:v high -pix_fmt yuv420p -bf:v 3 -preset slow -rc-lookahead 32 -c:a copy \"out/$BASENAME.$LANGUAGE.PART.mp4\""
#		COMMAND="ffmpeg -y -hide_banner -progress url -nostdin -i \"$FILENAME\" -map 0:v:0 -map 0:a:0 -strict -2 -filter_complex \"[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=black,subtitles=f='$line':force_style='Fontname=Simply Rounded Bold,FontSize=24,Outline=1'\" -c:s mov_text -c:v h264_nvenc -profile:v high -pix_fmt yuv420p -bf:v 3 -preset slow -rc-lookahead 32 -c:a copy \"out/$BASENAME.$LANGUAGE.PART.mp4\""


#		COMMAND="ffmpeg -y -hide_banner -progress url -nostdin -i \"$FILENAME\" -map 0:v:0 -map 0:a:0 -strict -2 -filter_complex \"[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=black,subtitles=f='$line'\" -c:s mov_text -c:v h264_nvenc -profile:v high -pix_fmt yuv420p -bf:v 3 -preset slow -rc-lookahead 32 -c:a copy \"out/$BASENAME.$LANGUAGE.PART.mp4\""
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
done


