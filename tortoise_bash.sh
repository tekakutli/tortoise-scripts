#!/usr/bin/env sh

# source this from your profile like so:
## source /home/$USER/code/tortoise-scripts/helper-bash.sh
# a single access point to bash stuff


# YOUR LOCATIONS
export TORTOISE_DIR="/home/$USER/code/tortoise-tts-fast/"
export TORTRAIN_DIR="/home/$USER/code/DL-Art-School/"
export SCRIPTS_DIR="/home/$USER/code/tortoise-scripts/"






# EDIT ZONE
if [[ "$TTS_TEXT" == "" ]]; then
     export TTS_TEXT="use set undescore text to set text"
fi


#speakers_stt.sh variables
export PATH_TO_WHISPER="/home/$USER/code/whisper.cpp"
export PATH_TO_MODELS="/home/$USER/files/models"
export WHISPER_MODEL="ggml-tiny.bin"

export LANG_FROM="en"
export CSV_OFFSET=0 #quick fix, just set an offset big enough so new-names don't collide
#train variables, name of and directory where you are want your dataset
export T_NAME="sreeni"
export T_DIR="/home/tekakutli/files/models/"







export NAME_EXPERIMENT=$T_NAME
export NAME_DATASET="$T_NAME-dataset"
export PATH_DESTINY="$T_DIR""$T_NAME""-train/"
export PATH_TRAINING="$PATH_DESTINY""metadata.csv"
export NAME_VALIDATION="$T_NAME-validation"
export PATH_VALIDATION="$T_DIR""$T_NAME""-val/metadata.csv"


alias tortoise="cd $TORTOISE_DIR'' && python tortoise/do_tts.py --kv_cache --half --preset very_fast"
t_default(){
     more_default="--voice emma --seed 42 --text"
     tortoise $more_default "$TTS_TEXT"
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
     tortoise --text '$TTS_TEXT' --ar-checkpoint "$(t_get_latest_train)" --text "$TTS_TEXT"
     # tortoise --text '$TTS_TEXT' --ar-checkpoint "$(t_get_latest_train)" --text "$TTS_TEXT" --voice silverdale
}

t_new_train(){
     bash "$SCRIPTS_DIR/quick_experiment.sh"
     echo "now, edit further this file, (like checkpoint_save_freq, batch_size, disable pretrain_model, etc)"
     echo $TORTRAIN_DIR"/experiments/EXAMPLE_gpt.yml"
}
t_train(){
     cd $TORTRAIN_DIR"codes"
     python3 train.py -opt ../experiments/EXAMPLE_gpt.yml
}

t_get_latest_train(){
     models_place=$TORTRAIN_DIR"experiments/$NAME_EXPERIMENT/models/"
     cd $models_place
     latest_model=$(ls | tail -1)
     echo $models_place$latest_model
}
t_set_latest_state(){
     latest_state="  resume_state: "$(t_get_latest_train)
     latest_state=$(echo "$latest_state" | sed "s|models|training_state|" | sed "s|_gpt.pth|.state|")

     place=$TORTRAIN_DIR"/experiments/EXAMPLE_gpt.yml"
     to_replace=$(grep -m1 resume_state $place)
     sed -i "s|$to_replace|$latest_state|" $place
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
     output_name="extracted_audio"
     ffmpeg -i "$1" -q:a 0 -map a "$output_name".wav


     output_name=$output_name".wav"
     # Original quality
     # ffmpeg -i "$output_name" -f segment -segment_time $segment_time -c copy "$output_name"-out%03d.wav
     ffmpeg -y -i "$output_name" -f segment -segment_time $segment_time -c copy -ar 16000 -ac 1 -c:a pcm_s16le "$output_name"-out%03d.wav


     ls | grep "$output_name"-out | while read -r line; do
          $PATH_TO_WHISPER/main -m $PATH_TO_MODELS/$WHISPER_MODEL -l en -f "$line" -otxt
          echo $line"|"$(cat "$line".txt) >> metadata.csv ; done


     rm "$output_name"-out*.txt
     sed -i "s/| /|/" metadata.csv
}

#You set these variables
install_whisper(){
     cd $PATH_TO_MODELS
     wget https://huggingface.co/datasets/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin
     # wget https://huggingface.co/datasets/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin
     cd $PATH_TO_WHISPER
     git clone https://github.com/ggerganov/whisper.cpp
     cd whisper.cpp
     make
}


