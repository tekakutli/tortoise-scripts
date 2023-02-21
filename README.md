# tortoise-scripts
extra stuff for efficiency
dependencies: linux, pipewire, ffmpeg, whisper  


SET YOUR VARIABLES  
the entry point is: tortoise_bash.sh  


while the objective of these scripts is to be ergonomic and to ease up tortoise usage, you still should study the functions, in particular to see what they are consuming  
ask me if something is not clear, and I'm open to write functions for useful cases that I have not yet contemplated  

remember output folder is: $TORTOISE_DIR/results  
you need to change the batch size <= number of wavs in the dataset, at $TORTRAIN_DIR/experiments/EXAMPLE_gpt.yml  

```
t_default                              # quick stt
rr                                     # quick reload tortoise_bash.sh if you change your variables
set_text <text to stt>


t_use_trained                          # uses the latest trained checkpoint to tts
t_new_train                            # new EXAMPLE_gpt.yml, but with your variables
t_train                                # train now
t_set_latest_state                     # to keep training your latest checkpoint
cp_to_voice <target-wav> <voice-name>  # copy this wav to a voice folder
install_whisper                        # fast whisper setup, set your own variables
stt_video "video-name.webm"            # split a video into segments, and transcribe them into a metadata.csv
clean_up_csv_of_audio_not_exist        # remove from the csv the audio files you deleted
collapse_audio                         # removes silence-clips from a clip
timestamp_words                        # timestamp every word in a wav
vtt_audio                              # vtt(give subtitles) to an audio
```


transcribe on the fly from your speakers by adding this to your sway/config, one keybinding away
```
bindsym $mod+Shift+return exec alacritty -e bash <fill-with-yours>/tortoise-scripts/speakers_stt_sway.sh 
```

what is tortoise? text to speech  
https://github.com/152334H/tortoise-tts-fast/  
https://github.com/152334H/dL-Art-School/  
