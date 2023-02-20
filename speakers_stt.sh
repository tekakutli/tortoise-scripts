#!/usr/bin/env sh

# Transcribe what you're hearing, one keybinding away
# Put something like this in your sway/config:
# bindsym $mod+Shift+return exec alacritty -e bash /home/tekakutli/code/tortoise-scripts/speakers_stt_sway.sh

# use C-c on the spawned terminal to stop recording and then for whisper to transcribe it
# close the window to discard the recording, in my case Mod+Q

#THIS ASUMES YOU ALREADY HAVE WHISPER.CPP INSTALLED, SOMEWHERE
#https://github.com/ggerganov/whisper.cpp


##########################

CURRENTDIR=$(pwd)
mkdir -p $PATH_DESTINY
cd $PATH_DESTINY


METAFILE="./metadata.csv"
if [ ! -f $METAFILE ]
then
    touch $METAFILE
fi




STT_COUNTER=$(wc -l < metadata.csv)
echo $STT_COUNTER
STT_COUNTER=$(($STT_COUNTER+$CSV_OFFSET))


LIVE_RECORD="./recording.wav"
WAV_RECORD="./recording_whisper.wav"
pw-record $LIVE_RECORD
ffmpeg -y -i "$LIVE_RECORD" -ar 16000 -ac 1 -c:a pcm_s16le $WAV_RECORD



# TINY IS FAST AND ENOUGH
if [[ "$LANG_FROM" == "en" ]]; then
    $PATH_TO_WHISPER/main -m $PATH_TO_MODELS/$WHISPER_MODEL -l $LANG_FROM -f "$WAV_RECORD" -otxt
else
    $PATH_TO_WHISPER/main -m $PATH_TO_MODELS/$WHISPER_MODEL -l $LANG_FROM -tr -f "$WAV_RECORD" -otxt
fi

mkdir -p "./wavs"

TTT_COUNTER="STT-"$STT_COUNTER
# cp "$LIVE_RECORD" "./wavs/$TTT_COUNTER.wav"
cp "$LIVE_RECORD" "$TTT_COUNTER.wav"
echo "$TTT_COUNTER"".wav|"$(cat "$WAV_RECORD".txt) >> metadata.csv
sed -i "s/| /|/" metadata.csv

cd $CURRENTDIR
