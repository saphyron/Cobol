      identification division.
      program-id. kontoOplysning.

      environment division.
      input-output section.
      file-control.
           select Kunde-Fil-in assign to "Kundeoplysninger.txt"
               organization is line sequential.
           select Kunde-Fil-out assign to "OutKundeoplysninger.txt"
               organization is line sequential.

      data division.
      file section.
      FD Kunde-Fil-in.
      01 Kunde-Information.
           copy "KUNDER.cpy".
      fd Kunde-Fil-out.
      01 Kunde-Information-out.
           02 felt-linje pic x(237) value spaces.

      working-storage section.
      01 EOF-check               pic x value "N".
           88 end-of-file        value "Y".
           88 more-to-read       value "N".
      01 Rens-Fuld-Navn          pic x(40)    value spaces.
      01 Addresse                pic x(90)    value spaces.
      01 Rens-Addresse           pic x(90)    value spaces.

      procedure division.
      Program-Execute.
           open input Kunde-Fil-in output Kunde-Fil-out

           perform until end-of-file
               read Kunde-Fil-in
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

                   move spaces to felt-linje
                   string Kunde-Id 
                      delimited by size Fuld-Navn
                      delimited by size Fornavn
                      delimited by size Efternavn
                      delimited by size Kontonummer
                      delimited by size Balance
                      delimited by size Valutakode
                      delimited by size Vejnavn
                      delimited by size Husnummer
                      delimited by size Postnummer
                      delimited by size By-navn
                      delimited by size Telefon
                      delimited by size Email
                      into felt-linje
                   end-string
                   write Kunde-Information-out from felt-linje
               end-read
           end-perform
           close Kunde-Fil-in Kunde-Fil-out

           stop run.
