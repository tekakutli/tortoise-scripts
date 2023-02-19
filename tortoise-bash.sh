#!/usr/bin/env sh

# source this from your profile like so:
## source /home/$USER/code/tortoise-scripts/helper-bash.sh
# a single access point to bash stuff

TORTOISE_DIR="/home/$USER/code/tortoise-tts-fast/"
TORTRAIN_DIR="/home/$USER/code/DL-Art-School/"
TTS_TEXT="traditional machine learning or should I be doing deep learning"


NAME_EXPERIMENT="dud"
NAME_DATASET="dud-dataset"
PATH_TRAINING="/tmp/train/metadata.csv"
NAME_VALIDATION="dud-validation"
PATH_VALIDATION="/tmp/val/metadata.csv"


PATH_TO_WHISPER="/home/$USER/code/whisper.cpp"
PATH_TO_MODELS="/home/$USER/files/models"


t_get_voice_pth_as(){
     #$1 = the voice folder name, $2 the new name
     cd $($TORTOISE_DIR)tortoise
     python get_conditioning_latents.py --voice $1
     cd $($TORTOISE_DIR)tortoise/voices/
     mkdir $2
     cd $2
     cp $($TORTOISE_DIR)results/conditioning_latents/$1.pth ./$2.pth
}

alias t_default="--voice emma --seed 42 --text '$TTS_TEXT'"
alias tortoise="cd $TORTOISE_DIR'' && python tortoise/do_tts.py --kv_cache --half --preset very_fast"

t_use_trained(){
     alias tortoise_use="tortoise --text '$TTS_TEXT' --ar-checkpoint"
     tortoise_use $(tortoise_get_latest_train) $1
}

t_train(){
     cd $TORTRAIN_DIR"codes"
     python3 train.py -opt ../experiments/EXAMPLE_gpt.yml
}

t_quick_experiment(){
     bash $TORTRAIN_DIR"quick-experiment.sh"
}

t_get_latest_train(){
     models_place=$TORTRAIN_DIR"experiments/$NAME_EXPERIMENT/models/"
     cd $models_place
     latest_model=$(ls | tail -1)
     echo $models_place$latest_model
}

#You set these variables
install_whisper(){
     cd $PATH_TO_MODELS
     # wget https://huggingface.co/datasets/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin
     wget https://huggingface.co/datasets/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin
     cd $PATH_TO_WHISPER
     git clone https://github.com/ggerganov/whisper.cpp
     cd whisper.cpp
     make
}
