#!/usr/bin/env python3
import sys

file = open(sys.argv[1])
lines = file.readlines()
length = len(lines)


i = 0
threshold = 3


print(lines[0].rstrip())

while i<length-2:
    ending=float(lines[i+1].rstrip())+threshold
    next_begining=float(lines[i+2].rstrip())
    i+=2
    if ending<next_begining:
        print(ending-threshold)
        if i<length:
            print(lines[i].rstrip())

print(lines[length-1].rstrip())
