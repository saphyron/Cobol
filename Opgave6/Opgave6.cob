      identification division.
      program-id. kontoOplysning.

      environment division.
      input-output section.
      file-control.
           select Kunde-File assign to "Kundeoplysninger.txt"
               organization is line sequential.

      data division.
      file section.
      FD Kunde-File.
      01 Kunde-Information.
           copy "KUNDER.cpy".

      working-storage section.
      01 EOF-check               pic x value "N".
           88 end-of-file        value "Y".
           88 more-to-read       value "N".
      01 Rens-Fuld-Navn          pic x(40)    value spaces.
      01 Addresse                pic x(90)    value spaces.
      01 Rens-Addresse           pic x(90)    value spaces.

      procedure division.
      Program-Execute.
           open input Kunde-File

           perform until end-of-file
               read Kunde-File
                   at end set end-of-file to TRUE
               not at end
                   string function TRIM(Fornavn) delimited by size 
                   " "                           delimited by size 
                   function TRIM(Efternavn)      delimited by size
                      into Fuld-Navn
                   end-string
                   string function TRIM(Vejnavn) delimited by size 
                   " "                           delimited by size 
                   function TRIM(Husnummer)      delimited by size
                      into Addresse
                   end-string

                   display "-------------------------------"
                   display "Kunde Oplysninger:"
                   display "Fuld Navn: " Fuld-Navn
                   display "Kontonummer: " Kontonummer
                   display "Balance: " Balance " " Valutakode
                   display "Adresse: " Addresse
                   display "Postnummer: " Postnummer
                   display "By: " By-navn
                   display "Telefon: " Telefon
                   display "Email: " Email
                   display "-------------------------------"
               end-read
           end-perform
           close Kunde-File

           stop run.
