#!/bin/bash

input=overzicht-2022.csv
output=overzicht-2022.ods

if [[ $# -eq 1 ]] 
  then
    input=$1
    output=$1.ods
fi

awk -f admin/merge-ingb.awk $input > $output
