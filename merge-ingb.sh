#!/bin/bash

if [[ $1 == "-h" ]]
  then
    echo "use merge-ingb.sh -h [csv-file]"
    exit 1
fi

input=overzicht-2022.csv
output=overzicht-2022.ods

if [[ $# -eq 1 ]]
  then
    input=$1
    output=$1-nhpo.csv
fi

awk -f admin/merge-ingb.awk $input > $output
