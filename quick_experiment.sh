#!/bin/bash

# quick access to $TORTRAIN_DIR/experiments/EXAMPLE_gpt.yml most important settings

# NAME_EXPERIMENT="your_experiment_name"
# NAME_DATASET="training_dataset_name"
# PATH_TRAINING="path_to_training_dataset"
# NAME_VALIDATION="validation_dataset_name"
# PATH_VALIDATION="path_to_validation_dataset"



# YOU SHOULD DIRECTLY PLAY WITH THIS FILE THO
EXAMPLE="$TORTRAIN_DIR/experiments/EXAMPLE_gpt.yml"
EXAMPLE_RAW="$TORTRAIN_DIR/experiments/EXAMPLE_gpt_raw.yml"


#Executes only once
#this script will fail if you edited it directly already
if [ ! -f $EXAMPLE_RAW ]
then
    cp $EXAMPLE $EXAMPLE_RAW
fi



cp "$EXAMPLE_RAW" "$EXAMPLE"

sed -i "s|CHANGEME_your_experiment_name|$NAME_EXPERIMENT|" $EXAMPLE
sed -i "s|CHANGEME_training_dataset_name|$NAME_DATASET|" $EXAMPLE
sed -i "s|CHANGEME_path_to_training_dataset|$PATH_TRAINING|" $EXAMPLE
sed -i "s|CHANGEME_validation_dataset_name|$NAME_VALIDATION|" $EXAMPLE
sed -i "s|CHANGEME_path_to_validation_dataset|$PATH_VALIDATION|" $EXAMPLE
