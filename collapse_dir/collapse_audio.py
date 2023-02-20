#!/usr/bin/env python3
import sys
import subprocess

file = open(sys.argv[1])
lines = file.readlines()
length = len(lines)
audio = sys.argv[2]


i = 0
k = 0

while i<length-2:
    begining=lines[i].rstrip()
    ending=lines[i+1].rstrip()
    i+=2
    k+=1
    j="cut-output"+str(k)+".wav"
    # print(j)
    print("file '"+j+"'")
    cmd = ['ffmpeg', '-y', '-i', str(audio), '-ss', str(begining), '-to', str(ending), '-c:v', 'copy', '-c:a', 'copy', j]
    subprocess.call(cmd)
