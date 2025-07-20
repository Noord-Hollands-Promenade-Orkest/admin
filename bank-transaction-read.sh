#!/bin/bash

usage()
{
  echo "Usage: bank-transaction-read.sh [-ch] [-m info] csv-file"
  echo "-c       generates contributions overview"
  echo "-h       displays usage information and exits"
  echo "-m       generates mail addresses using specified info file"
  echo ""
  echo "reads a csv bank transaction file and generates an excel csv file"
}

while getopts ":mch" opt; do
  case $opt in
    c)
      export CREATE_CONTRIB=1
      shift
    ;;

    h)
      usage
      exit 1
    ;;

    m)
      export CREATE_MAILING=1
      export FILE_INFO=${OPTARG}

      if [[ ! -f $FILE_INFO ]]
      then
        echo "file $FILE_INFO does not exist"
        exit 1
      fi

      shift
    ;;

    :)
      echo "option -${OPTARG} requires an argument"
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

output=$1-columns.csv
export FILE_CONTRIB=$1-contributions.csv
export FILE_MAIL=$1-mail.csv

awk -f ${scriptdir}/bank-transaction-read.awk $input > $output
