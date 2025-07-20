#!/bin/bash

usage()
{
  echo "Usage: bank-transaction-read.sh [-hm] csv-file"
  echo "-h       displays usage information and exits"
  echo "-m       generates mail addresses to be sent"
  echo ""
  echo "reads a csv bank transaction file and creates a excel vcs file"
}

while getopts "hm" opt; do
  case $opt in
    m)
      option_asan="-DwexENABLE_ASAN=ON"
      shift
    ;;

    h)
      usage
      exit 1
    ;;

    \?)
      echo "illegal option -$OPTARG"
      exit 1
    ;;
  esac
done

if [[ $# -ne 1 ]]
then
  usage
  exit 1
fi

input=$1

if [[ ! -f $1 ]]
then
  echo "file $1 does not exist"
  exit 1
fi

scriptdir="$(dirname -- "$BASH_SOURCE";)"

output=$1-nhpo.csv

awk -f ${scriptdir}/bank-transaction-read.awk $input > $output
