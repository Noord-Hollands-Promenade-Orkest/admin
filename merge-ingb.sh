#!/bin/bash

file=overzicht-2022.csv

if [[ $# -eq 1 ]] 
  then
    file=$1
fi

awk -f admin/merge-ingb.awk $file
