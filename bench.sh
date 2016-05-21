#!/bin/bash

if [ $# -lt 2 ]; then
  echo "Usage: $(basename $0) <size> <file>"
  exit
fi

SIZE=$1
FILE=$2

stack build

> $FILE;

for i in -N1 -N4 -N8; do
  (echo;echo;echo "------ With $i----- ";time \
    stack exec gc-test -- $SIZE +RTS $i -s) 2>&1 | tee -a $FILE
done
