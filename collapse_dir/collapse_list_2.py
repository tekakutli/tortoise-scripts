#!/usr/bin/env python3
import sys

file = open(sys.argv[1])
lines = file.readlines()
length = len(lines)


i = 0
threshold = 3


while i<length-2:
    begining=float(lines[i].rstrip())+threshold
    ending=float(lines[i+1].rstrip())
    i+=2
    if ending>begining:
        print(begining-threshold)
        print(ending)
