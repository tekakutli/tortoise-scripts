#!/usr/bin/env sh

# source this from your profile like so:
## source /home/$USER/code/tortoise-scripts/helper-bash.sh
# a single access point to bash stuff


# YOUR LOCATIONS
export TORTOISE_DIR="/home/$USER/code/tortoise-tts-fast/"
export TORTRAIN_DIR="/home/$USER/code/DL-Art-School/"
export SCRIPTS_DIR="/home/$USER/code/tortoise-scripts/"
# ONLY NEEDED IF collapse_audio
export VAD_DIR="/home/$USER/code/silero-vad/"







# EDIT ZONE
if [[ "$TTS_TEXT" == "" ]]; then
     export TTS_TEXT="use set underscore text to set the text"
fi


#speakers_stt.sh variables
export PATH_TO_WHISPER="/home/$USER/code/whisper.cpp"
export PATH_TO_MODELS="/home/$USER/files/models"
# export WHISPER_MODEL="ggml-tiny.bin"
export WHISPER_MODEL="ggml-tiny.en.bin"

export LANG_FROM="en"
export CSV_OFFSET=0 #quick fix, just set an offset big enough so new-names don't collide
#train variables, name of and directory where you are want your dataset
export T_NAME="silver"
export T_DIR="/home/tekakutli/files/models/"







export NAME_EXPERIMENT=$T_NAME
export NAME_DATASET="$T_NAME-dataset"
export PATH_DESTINY="$T_DIR""$T_NAME""-train/"
export PATH_TRAINING="$PATH_DESTINY""metadata.csv"
export NAME_VALIDATION="$T_NAME-validation"
export PATH_VALIDATION="$T_DIR""$T_NAME""-val/metadata.csv"

# alias tortoise="cd $TORTOISE_DIR'' && python tortoise/do_tts.py --kv_cache --half --preset very_fast"
alias tortoise="cd $TORTOISE_DIR'' && python tortoise/do_tts.py --kv_cache --half --sampler dpm++2m --steps 30"
t_default(){
     more_default="--voice emma --seed 45 --text"
     tortoise $more_default "$TTS_TEXT"
     echo "remember output folder is: $TORTOISE_DIR""results"
}

rr(){ #reload this file
     CURRENTDIR=$(pwd)
     cd $SCRIPTS_DIR
     source tortoise_bash.sh
     cd $CURRENTDIR
}
set_text(){
     export TTS_TEXT=$1
     rr
}

t_get_voice_pth_as(){
     #$1 = the voice folder name, $2 the new name
     cd $($TORTOISE_DIR)tortoise
     python get_conditioning_latents.py --voice $1
     cd $($TORTOISE_DIR)tortoise/voices/
     mkdir $2
     cd $2
     cp $($TORTOISE_DIR)results/conditioning_latents/$1.pth ./$2.pth
}

t_use_trained(){
     t_get_latest_train
     # tortoise --ar-checkpoint "$LATEST_GPT_TRAIN" --diff-checkpoint "$LATEST_DIFF_TRAIN" --text "$TTS_TEXT"
     tortoise --ar-checkpoint "$LATEST_GPT_TRAIN" --text "$TTS_TEXT" --voice silver
     # tortoise --ar-checkpoint "$(t_get_latest_train)" --text "$TTS_TEXT" --voice silver
     echo "remember output folder is: $TORTOISE_DIR""results"
}

t_new_train(){
     rr
     bash "$SCRIPTS_DIR""quick_experiment.sh"
     echo "now, edit further these files further, (like checkpoint_save_freq, batch_size, disable pretrain_model, etc... or gpt_path for diff)"
     echo $TORTRAIN_DIR"experiments/EXAMPLE_gpt.yml"
     echo $TORTRAIN_DIR"experiments/EXAMPLE_diff.yml"
}

t_train(){
     cd $TORTRAIN_DIR"codes"
     python3 train.py -opt ../experiments/EXAMPLE_gpt.yml
}
t_train_diff(){
     t_get_latest_train
     cd $TORTRAIN_DIR"codes"
     python3 train.py -opt ../experiments/EXAMPLE_diff.yml
}

t_get_latest_train(){
     gpt_place=$TORTRAIN_DIR"experiments/$NAME_EXPERIMENT-gpt/models/"
     diff_place=$TORTRAIN_DIR"experiments/$NAME_EXPERIMENT-diff/models/"
     mkdir -p $gpt_place
     mkdir -p $diff_place

     cd $gpt_place
     latest_model=$(ls | tail -1)
     export LATEST_GPT_TRAIN=$gpt_place$latest_model""

     cd $diff_place
     latest_model=$(ls | tail -1)
     export LATEST_DIFF_TRAIN=$diff_place$latest_model""
}

t_set_latest_state(){
     # GPT
     latest_state="  resume_state: "$LATEST_GPT_TRAIN
     latest_state=$(echo "$latest_state" | sed "s|models|training_state|" | sed "s|_gpt.pth|.state|")

     place=$TORTRAIN_DIR"/experiments/EXAMPLE_gpt.yml"
     to_replace=$(grep -m1 resume_state $place)
     sed -i "s|$to_replace|$latest_state|" $place
     sed -i "s| pretrain_model_gpt| #pretrain_model_gpt|" $place


     # DIFF
     latest_state="  resume_state: "$LATEST_DIFF_TRAIN
     latest_state=$(echo "$latest_state" | sed "s|models|training_state|" | sed "s|_ddpm.pth|.state|")

     place=$TORTRAIN_DIR"/experiments/EXAMPLE_diff.yml"
     to_replace=$(grep -m1 resume_state $place)
     sed -i "s|$to_replace|$latest_state|" $place
     sed -i "s| pretrain_model_gpt| #pretrain_model_gpt|" $place
}

cp_to_voice(){
     CURRENTDIR=$(pwd)
     cd $TORTOISE_DIR"tortoise/voices/"
     mkdir -p $2
     cp $CURRENTDIR/$1 ./$2/
     cd $CURRENTDIR
}

stt_video(){
     segment_time=4 #in seconds
     # Extract audio
     output_name="extracted_audio"
     ffmpeg -i "$1" -q:a 0 -map a "$output_name".wav
     output_name=$output_name".wav"

     # Original quality
     # ffmpeg -i "$output_name" -f segment -segment_time $segment_time -c copy "$output_name"-out%03d.wav
     ffmpeg -y -i "$output_name" -f segment -segment_time $segment_time -c copy -ar 16000 -ac 1 -c:a pcm_s16le "$output_name"-out%03d.wav


     ls | grep "$output_name"-out | while read -r line; do
          $PATH_TO_WHISPER/main -m $PATH_TO_MODELS/$WHISPER_MODEL -l en -f "$line" -otxt
          echo $line"|"$(cat "$line".txt | sed 's/\.$//' ) >> metadata.csv ; done

     rm "$output_name"-out*.txt
     clean_up_csv
}
stt_audios(){

     ls | grep ".wav" | while read -r line; do
          temporal_file="$line""-temp.wav"
          ffmpeg -y -i "$line" -ar 16000 -ac 1 -c:a pcm_s16le "$temporal_file"
          $PATH_TO_WHISPER/main -m $PATH_TO_MODELS/$WHISPER_MODEL -l en -f "$temporal_file" -otxt
          mv $temporal_file".txt" $line".txt"
          rm $temporal_file
          echo $line"|"$(cat "$line".txt | sed 's/\.$//' ) >> metadata.csv ; done

     rm *.txt
     clean_up_csv
}
vtt_audio(){
     temporal_file="$1""-temp.wav"
     ffmpeg -y -i "$1" -ar 16000 -ac 1 -c:a pcm_s16le "$temporal_file"
     $PATH_TO_WHISPER/main -m $PATH_TO_MODELS/$WHISPER_MODEL -l en -f "$temporal_file" -ovtt
     rm $temporal_file
}

clean_up_csv(){
     # CLEAN-UP
     # we remove dots at the end of the sentence, and lowercase everything
     sed -i "s/| /|/" metadata.csv
     tr '[:upper:]' '[:lower:]' < metadata.csv > metadata2.csv
     mv metadata2.csv metadata.csv
     # remove stuff by whisper that probably confusses gpt
     cat metadata.csv | grep -v "(" | grep -v "\[" | grep -v "*" > metadata2.csv
     mv metadata2.csv metadata.csv

}
clean_up_csv_of_audio_not_exist(){
     ls | while read -r line; do cat metadata.csv | grep -m1 $line >> metadata2.csv ; done
     mv metadata2.csv metadata.csv
}

#detects human voice, and then removes silence spaces that are way too big
collapse_audio(){
     # Extract audio
     output_name="extracted_audio"
     ffmpeg -i "$1" -q:a 0 -map a "$output_name".wav
     output_name=$output_name".wav"

     COLLAPSE_DIR=$SCRIPTS_DIR"collapse_dir/"
     vad=$COLLAPSE_DIR"vad.py"

     python $vad "$output_name" > audio_timecodes.txt
     # Proper format
     # cat audio_timecodes.txt | awk '{gsub(/[:\47]/,"");print $0}' | awk '{gsub(/.{end /,"");print $0}' | awk '{gsub(/ start /,"");print $0}' | awk '{gsub(/}./,"");print $0}' | awk -F',' '{ print $2 "," $1}' | awk '{gsub(/,/,"\n");print $0}' | while read -r line; do date -d@$line -u '+%T.%2N'; done | paste -d " "  - - | sed 's/ />/g' > audio_timestamps.txt
     cat audio_timecodes.txt | awk '{gsub(/[:\47]/,"");print $0}' | awk '{gsub(/.{end /,"");print $0}' | awk '{gsub(/ start /,"");print $0}' | awk '{gsub(/}./,"");print $0}' | awk -F',' '{ print $2 "," $1}' | awk '{gsub(/,/,"\n");print $0}' > list0.txt
     # Removal
     python $COLLAPSE_DIR"collapse_list_1.py" list0.txt > list1.txt
     python $COLLAPSE_DIR"collapse_list_2.py" list1.txt > list2.txt
     # Formats the time
     cat list2.txt | while read -r line; do date -d@$line -u '+%T.%2N'; done > list3.txt
     # Splits the audio
     python $COLLAPSE_DIR"collapse_audio.py" list3.txt $output_name > list4.txt
     # Merges the audios
     ffmpeg -f concat -i list4.txt -c copy collapsed_audio.wav
     # Clean-up
     rm cut-*
     rm audio_timecodes.txt
     rm list*.txt
}

#You set these variables
install_whisper(){
     cd $PATH_TO_MODELS
     # wget https://huggingface.co/datasets/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin
     wget https://huggingface.co/datasets/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin
     wget https://huggingface.co/Saideva/silero_vad/resolve/main/files/silero_vad.onnx


     cd $VAD_DIR".."
     git clone https://github.com/snakers4/silero-vad
     cd $PATH_TO_WHISPER".."
     git clone https://github.com/ggerganov/whisper.cpp
     cd whisper.cpp
     make
}

# Split audios per Word
# whisper_timestamped: git clone https://github.com/linto-ai/whisper-timestamped
timestamp_words(){
     whisper_timestamped "$1" --model_dir $PATH_TO_MODELS --model tiny.en --output_dir .
     name=$(echo $1.words | sed "s/.wav.words/.vtt/")
     cp $1".words.vtt" $name
     rm $1"".*
}

find_small_size(){
     ls -l --block-size=K | grep .wav | awk '{print $5" "$9}' | sed s"/K / /" | sort -rn
}

split_vtt(){
     # works both with sentences or words vtt
     name=$1
     python $SCRIPTS_DIR""collapse_dir/split_words.py $1 $2 > $name"_list.txt"
     # echo "mpv --playlist="$1"_list.txt"
}
