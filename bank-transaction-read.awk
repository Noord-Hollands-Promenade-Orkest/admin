# bank-transaction.awk

# merges a bank transaction csv file with semicolon as separator, with fields:
#  1      2                    3         4              5      6
# "Date";"Name / Description";"Account";"Counterparty";"Code";"Debit/credit";
#  7              8                  9               10                 11
# "Amount (EUR)";"Transaction type";"Notifications";"Resulting balance";"Tag"

# to NHPO csv file with fields as returned by add_header

function add_header()
{
  printf(\
"Datum;Saldo;Naam;Contributies;Concerten;Subsidies;Overige Inkomsten;\
Uitgaven;Salarissen;Muziek;Zaalhuur;Betalingsverkeer;Secretariaat;\
Omschrijving\n");
}

function analyse_field(match_text, field)
{
  if ((notifications ~ match_text && debit_credit == "Credit") ||
    (field == field_contributie && amount == "275,00") ||
    (field == field_concert && debit_credit == "Credit" &&
       (notifications ~ "Openbaar optreden" ||
        notifications ~ "NhPO" ||
        notifications ~ "Concert" ||
        notifications ~ "Factuur" ||
        notifications ~ "kaart")) ||
    (field == field_subsidie && name ~ "GEMEENTE") ||
    (field == field_muziek && name ~ "P.H.C. Stam" &&
      (notifications ~ "Onkosten")) ||
    (field == field_salaris && name ~ "P.H.C. Stam") ||
    (field == field_secretariaat && name ~ "Mw HF van Garrel" && debit_credit == "Debit") ||
    (field == field_zaalhuur && (name ~ "Stichting DOCK" || name ~ "Coop.* Buurts U.A.")) ||
    (field == field_uitgaven && debit_credit == "Debit" &&
       (name ~ "Evidos" ||
        name ~ "Your Hosting" ||
        name ~ "Groenmarktkerk" ||
        name ~ "Kennemer" ||
        name ~ "Kemp" ||
       (notifications ~ "Factuur" && name != "P.H.C. Stam") ||
        notifications ~ "declaratie" || notifications ~ "Teruggave")) ||
    (field == field_betv && name ~ "Kosten Zakelijk") ||
    (field == field_overige_inkomsten && debit_credit == "Credit") ||
    (field == field_uitgaven && debit_credit == "Debit"))
  {
    # to debug
    # printf("---------> %s %s %s found\n", name, match_text, field)
    output_fields[field] = amount
    return 1
  }
  else
  {
    return 0
  }
}

BEGIN {
  FS = ";"
  error = 0
  field_max = 0
  line_no = 0
  required_fields = 11

  # init and setup fields according to the NHPO spreadsheet
  # (these are in Dutch)
  field_datum = field_max++
  field_saldo = field_max++
  field_naam =  field_max++
  field_contributie = field_max++
  field_concert = field_max++
  field_subsidie = field_max++
  field_overige_inkomsten = field_max++
  field_uitgaven = field_max++
  field_salaris = field_max++
  field_muziek = field_max++
  field_zaalhuur = field_max++
  field_betv = field_max++
  field_secretariaat = field_max++
  field_omschrijving = field_max++
}

{
  # be sure each record has correct fields
  if (NF != required_fields)
  {
    printf(">>> SKIP record %d: %d velden i.p.v. %d\n",
      NR, NF, required_fields) > "/dev/stderr"
  }
  else if (NR > 1)
  {
    # skip all " characters
    gsub("\"", "")

    # fields that are directly present in the INGB csv input
    date = $1
    name = $2
    debit_credit = $6
    amount = $7
    notifications = $9
    resulting_balance = $10

    for (i = 0; i < field_max; i++)
    {
      output_fields[i] = ""
    }

    output_fields[field_datum] = date;
    output_fields[field_saldo] = resulting_balance;
    output_fields[field_naam] = name;
    output_fields[field_omschrijving] = notifications;
    
    # analyse the fields
    if (!analyse_field("[cC]ontri?b|CONTBR|CONTR|speelj|bijbetaling", field_contributie) &&
        !analyse_field("betv", field_betv) &&
        !analyse_field("muziek", field_muziek) &&
        !analyse_field("concert|optreden", field_concert) &&
        !analyse_field("subsidie", field_subsidie) &&
        !analyse_field("salaris", field_salaris) &&
        !analyse_field("secretariaat", field_secretariaat) &&
        !analyse_field("zaalhuur", field_zaalhuur) &&
        !analyse_field("eclaratie", field_uitgaven) &&
        !analyse_field("KAMER VAN|Federatie van", field_uitgaven) &&
        !analyse_field("overige", field_overige_inkomsten))
    {
      printf(">>> ERROR no match record: %d van '%s' amount: %s deb/cre: %s notifications: '%s'\n",
                NR, name, amount, debit_credit, notifications) > "/dev/stderr"
      error = 1
      exit
    }

    # output to a csv file that can be used as the NHPO spreadsheet
    # the order has to be reversed, so output to array
    line = ""

    for (i = 0; i < field_max; i++)
    {
      line = sprintf("%s%s;", line, output_fields[i])
    }

    output[line_no++] = line
  }
}

END {
  if (!error)
  {
    add_header();

    for (i = line_no - 1; i >= 0; i--)
    {
      printf("%s\n", output[i]);
    }
  }
}
