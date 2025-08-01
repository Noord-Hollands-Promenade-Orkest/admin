#!/bin/bash

usage()
{
  echo "Usage: bank-transaction-read.sh [-ch] [-m info-file] csv-file"
  echo "-c     generates contributions overview"
  echo "-h     displays usage information and exits"
  echo "-m     generates mail addresses using specified info-file"
  echo ""
  echo "reads a csv bank transaction file and outputs an excel csv file"
}

while getopts ":m:ch" opt; do
  case $opt in
    c)
      export CREATE_CONTRIB=1
    ;;

    h)
      usage
      exit 1
    ;;

    m)
      export CREATE_MAILING=1
      export FILE_INFO="${OPTARG}"

      if [[ ! -f $FILE_INFO ]]
      then
        echo "info file $FILE_INFO does not exist"
        exit 1
      fi
    ;;

    :)
      echo "option -${OPTARG} requires an argument"
      exit 1
    ;;

    ?)
      echo -e "option -$OPTARG not supported"
      exit 1
    ;;
  esac
done

shift "$(($OPTIND -1))"

if [[ $# -ne 1 ]]
then
  usage
  exit 1
fi

input=$1

if [[ ! -f $1 ]]
then
  echo "input file $1 does not exist"
  exit 1
fi

scriptdir="$(dirname -- "$BASH_SOURCE";)"

output=$1-columns.csv
export FILE_CONTRIB=$1-contributions.csv
export FILE_MAIL=$1-mail.csv

awk -f ${scriptdir}/bank-transaction-read.awk $input > $output
