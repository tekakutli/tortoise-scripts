#!/usr/bi/env python3
import torch
import sys
import os
torch.set_num_threads(1)
from IPython.display import Audio
from pprint import pprint

# git clone https://github.com/snakers4/silero-vad
sys.path.append(os.environ['VAD_DIR'])
from utils_vad import read_audio, get_speech_timestamps, OnnxWrapper

# wget https://huggingface.co/Saideva/silero_vad/resolve/main/files/silero_vad.onnx
model_dir=os.environ['PATH_TO_MODELS']
model = OnnxWrapper(os.path.join(model_dir, 'silero_vad.onnx'))


sampling_rate = 16000 # also accepts 8000
wav = read_audio(sys.argv[1], sampling_rate=sampling_rate)
# get speech timestamps from audio file
speech_timestamps = get_speech_timestamps(wav, model, sampling_rate=sampling_rate, return_seconds=True)
pprint(speech_timestamps)
