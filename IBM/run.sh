#!/bin/bash
gcc -m64 -no-pie -std=c17 -c driver.c
as -o $1.o $1.asm &&
gcc -m64 -no-pie -std=c17 -o $1 driver.c $1.o &&
./$1
