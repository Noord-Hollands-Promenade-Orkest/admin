#!/bin/bash

if [[ $1 == "-h" ]] || [[ $# -ne 1 ]]
then
  echo "use: merge-ingb.sh csv-file"
  exit 1
fi

input=$1

if [[ ! -f $1 ]]
then
  echo "file $1 does not exist"
  exit 1
fi

output=$1-nhpo.csv

awk -f admin/merge-ingb.awk $input > $output
