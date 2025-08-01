# members-mail.awk

# 1) reads a mail csv file with semicolon as separator, with fields:
# 1    2             3
# Name;Contributions;Email

# 2) reads a mail template file

function expand_template()
{
  file_templ = ENVIRON["FILE_TEMPLATE"]
  n = split(FILENAME, account, "_")

  if (n < 1)
  {
    printf(">>> ERROR in: '%s' no account present before _\n",
      file_templ) > "/dev/stderr"
    exit
  }

  while (( getline line < file_templ) > 0)
  {
    sub("<ACCOUNT>", account[1], line)
    sub("<CONTRIB>", annual_contrib, line)
    sub("<EMAIL>", email, line)
    sub("<NAME>", name, line)
    sub("<SIGNATURE>", "Anton van Wezenbeek", line)
    sub("<YEAR>", "2025", line)

    print line > output
  }
  
  close(file_templ)
}

BEGIN {
  FS = ";"
  annual_contrib = 275
  line_no = 0
  required_fields = 3
}

{
  # be sure each record has correct fields
  if (NF != required_fields)
  {
    printf(">>> SKIP record %d: %d fields instead of %d\n",
      NR, NF, required_fields) > "/dev/stderr"
  }
  else
  {
    # skip all " characters
    gsub("\"", "")

    name = $1
    contrib = $2
    email = $3
    output = sprintf("template-%s.txt", name)
    
    expand_template()

    # Currently only msmtp is supported
    printf("cat %s | msmtp %s\n", output, email)
  }
}
