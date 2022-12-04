# merge-ingb.awk
#
# merges a INGB csv file with fields:
# 1        2                     3          4               5      6        7              8              9              10                 11
# "Datum";"Naam / Omschrijving";"Rekening";"Tegenrekening";"Code";"Af Bij";"Bedrag (EUR)";"Mutatiesoort";"Mededelingen";"Saldo na mutatie";"Tag"
#
# to NHPO spreadsheet with fields:
# Datum	Kas	Contributies	Concerten	Subsidies	Overige Inkomsten	Salarissen	Muziek	Zaalhuur	Betalingsverkeer	Secretariaat	Omschrijving

function analyse_field(match_text, field) {
  if (mededelingen ~ match_text ||
    (field == field_contributie && bedrag == "200,00") ||
    (field == field_concert && 
       (mededelingen ~ "Openbaar optreden" || mededelingen ~ "NhPO" || mededelingen ~ "Concert" ||
        mededelingen ~ "kaart")) ||
    (field == field_subsidie && naam ~ "GEMEENTE") ||
    (field == field_salaris && naam ~ "P.H.C. Stam") ||
    (field == field_uitgaven &&
       (naam ~ "Evidos" || naam ~ "Your Hosting" || naam ~ "Groenmarktkerk" || naam ~ "Kennemer" ||
        mededelingen ~ "Factuur" || mededelingen ~ "declaratie" || mededelingen ~ "Teruggave")) ||
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
  error = 0
  field_max = 0
  line_no = 0
  required_fields = 11

  # init fields according to the NHPO spreadsheet
  field_datum = field_max++
  field_saldo = field_max++
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
  field_omschrijving = field_max++
} 

{
  # be sure each record has correct fields
  if (NF != required_fields)
  {
    printf(">>> SKIP record %d: %d velden i.p.v. %d\n", NR, NF, required_fields)
  }
  else if (NR > 1)
  {
    # skip all " characters
    gsub("\"", "")

    # fields that are directly present in the INGB csv input
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
    
    output_fields[field_datum] = datum;
    output_fields[field_saldo] = saldo;
    output_fields[field_omschrijving] = mededelingen;
    
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
      printf(">>> ERROR no match record: %d van '%s' bedrag: %s mededelingen: '%s'\n", NR, naam, bedrag, mededelingen)
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
    printf("Datum;Kas;Contributies;Concerten;Subsidies;Overige Inkomsten;Salarissen;Muziek;Zaalhuur;Betalingsverkeer;Secretariaat;Omschrijving");
  
    for (i = line_no - 1; i >= 0; i--) 
    {
      printf("%s\n", output[i]);
    }
  }
}
