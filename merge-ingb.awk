# merge-ingb.awk
#
# merges a INGB csv file:
# 1        2                     3          4               5      6        7              8              9              10                 11
# "Datum";"Naam / Omschrijving";"Rekening";"Tegenrekening";"Code";"Af Bij";"Bedrag (EUR)";"Mutatiesoort";"Mededelingen";"Saldo na mutatie";"Tag"
#
# to NHPO spreadsheet:
# Datum	Kas	Contributies	Concerten	Subsidies	Overige Inkomsten	Salarissen	Muziek	Zaalhuur	Betalingsverkeer	Secretariaat	Omschrijving

function analyse_field(match_text, field) {
  if (mededelingen ~ match_text ||
    (field == field_contributie && bedrag == "200,00") ||
    (field == field_subsidie && naam ~ "GEMEENTE") ||
    (field == field_salaris && naam ~ "P.H.C. Stam") ||
    (field == field_uitgaven && naam ~ "Evidos") ||
    (field == field_zaalhuur && naam ~ "Stichting DOCK") ||
    (field == field_secretariaat && naam ~ "J. van Meurs") ||
    (field == field_betv && naam ~ "Kosten Zakelijk"))
  {
    output_fields[field] = bedrag
    return 1
  }
  else
  {
    return 0
  }
}
  
BEGIN {
  FS = ";"
  field_max = 0
  line = 0
  required_fields = 11

  # init fields according to NHPO spreadsheet
  field_contributie = field_max++
  field_concert = field_max++
  field_subsidie = field_max++
  field_overige = field_max++
  field_uitgaven = field_max++
  field_salaris = field_max++
  field_muziek = field_max++
  field_zaalhuur = field_max++
  field_betv = field_max++
  field_secretariaat = field_max++
} 

{
  # be sure each record has correct fields
  if (NF != required_fields)
  {
    printf(">>> skip record %d: %d velden i.p.v. %d\n", NR, NF, required_fields)
  }
  else if (NR > 1)
  {
    # skip all " characters
    gsub("\"", "")

    # fields that are directly present in the csv input
    datum = $1 
    naam = $2 
    rekening = $3 
    af_bij = $6
    bedrag = $7
    mededelingen = $9
    saldo = $10
    
    for (i = 0; i < field_max; i++)
    {
      output_fields[i] = ""
    }
    
    # analyse the fields
    if (!analyse_field("[cC]ontributie|CONTBR", field_contributie) &&
        !analyse_field("concert", field_concert) &&
        !analyse_field("subsidie", field_subsidie) &&
        !analyse_field("overige", field_overige) &&
        !analyse_field("KAMER VAN|Federatie van", field_uitgaven) &&
        !analyse_field("salaris", field_salaris) &&
        !analyse_field("muziek", field_muziek) &&
        !analyse_field("zaalhuur", field_zaalhuur) &&
        !analyse_field("betv", field_betv) &&
        !analyse_field("secretariaat", field_secretariaat))
    {
      printf("\n>>> record: %d van '%s' bedrag %s met '%s'\n", NR, naam, bedrag, mededelingen)
      exit
    }
    
    # output to a csv file that can be imported into the NHPO spreadsheet
    # the order has to be reversed, so output to array
    text = sprintf("%s;%s;", datum, saldo)

    for (i = 0; i < field_max; i++)
    {
      text = sprintf("%s%s;", text, output_fields[i])
    }
    
    text = sprintf("%s%s", text, mededelingen)
    
    output[line++] = text
  }
}

END {
  for (i = line - 1; i >= 0; i--) 
  {
    printf("%s\n", output[i]);
  }
}
