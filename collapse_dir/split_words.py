#!/usr/bin/env python3
import sys
import subprocess
from datetime import datetime, timedelta

name = sys.argv[1]
file = open(name)
lines = file.readlines()
length = len(lines)
audio = sys.argv[2]

i = 0
k = 0

while i<length-2:
    time=lines[i+2].rstrip()
    text=lines[i+3].rstrip()
    i+=3
    k+=1
    # j=name+"-cut"+str(k)+"-"+text+".wav"
    j=name+"-cut"+str(k)+".wav"

    if (len(time) < 28):
        left, right = time[:10].rstrip(), time[14:].rstrip()
        timestemp_i_time = datetime.strptime(left, "%M:%S.%f") - timedelta(milliseconds=1000)
        timestemp_f_time = datetime.strptime(right, "%M:%S.%f") + timedelta(milliseconds=1000)
    else:
        left, right = time[:13].rstrip(), time[17:].rstrip()
        timestemp_i_time = datetime.strptime(left, "%H:%M:%S.%f") - timedelta(milliseconds=1000)
        timestemp_f_time = datetime.strptime(right, "%H:%M:%S.%f") + timedelta(milliseconds=1000)

    timestemp_zero_time = datetime.strptime("00:00:00.000", "%H:%M:%S.%f")
    if timestemp_i_time<timestemp_zero_time:
        timestemp_i_time=timestemp_zero_time

    i_time=str(timestemp_i_time.time())
    f_time=str(timestemp_f_time.time())

    if (len(i_time) > 8):
        i_time = i_time[:-4]
    if (len(f_time) > 8):
        f_time = f_time[:-4]

    cmd = ['ffmpeg', '-y', '-i', str(audio), '-ss', i_time, '-to', f_time, '-c:v', 'copy', '-c:a', 'copy', j]
    subprocess.call(cmd)

    # choose one
    print(j+"|"+str(text))
    # print("file '"+j+"'")
    # print(j)
