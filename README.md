# NHPO admin

This repo contains some scripts to facilitate admin tasks for the treasurer of
the orkest.

## usage

The `bank-transaction-read.sh` script can be used to
create a csv overview from the bank account that can
be imported into a spreadsheet for the annual meeting presentation or
municipal subsidy.

The `members-mail-contributions.sh` script can be used to
create an overview of annual contributions of members.

After changing the script files, run install to install them.

## example

```bash
bank-transaction-read.sh -c -m members.csv NL89INGB0003788111_01-01-2025_27-09-2025.csv
members-mail-contributions.sh -t members-mail-template.txt NL89INGB0003788111_01-01-2025_27-09-2025.csv-mail.csv
mail-them.sh
```
