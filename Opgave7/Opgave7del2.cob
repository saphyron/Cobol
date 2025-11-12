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
           02 felt-linje pic x(300) value spaces.

      working-storage section.
      01 EOF-check               pic x value "N".
           88 end-of-file        value "Y".
           88 more-to-read       value "N".
      01 Addresse                pic x(70)    value spaces.
      01 Konto-Linje             pic x(60)    value spaces.
      01 Kontakt-Linje           pic x(80)    value spaces.
      01 By-Linje                pic x(60)    value spaces.
      01 Rens-Fuld-Navn          pic x(60)    value spaces.
      01 pos                     pic 9(3)     value 1.

      procedure division.
      Program-Execute.
           open input Kunde-Fil-in output Kunde-Fil-out

           perform until end-of-file
               read Kunde-Fil-in
                   at end set end-of-file to TRUE
               not at end
                   perform behandler-paragraffer
                   
               end-read
           end-perform
           close Kunde-Fil-in Kunde-Fil-out
           display "Færdig med at behandle kundeoplysninger."
       stop run.


     *> Her bliver der behandlet paragrafferne
           behandler-paragraffer.
               perform formater-navne
               perform formater-konto
               perform formater-adresse
               perform formater-by-og-post
               perform formater-kontakt

               move spaces to felt-linje
               string Rens-Fuld-Navn
                      delimited by size Konto-Linje
                      delimited by size Addresse
                      delimited by size By-Linje
                      delimited by size Kontakt-Linje
                      into felt-linje
               end-string
               write Kunde-Information-out from felt-linje
               exit.

           formater-navne.
               move spaces to Rens-Fuld-Navn
               move 1 to pos
               string "Person-Navn: "        delimited by size
               function TRIM(Fornavn)        delimited by size 
               " "                           delimited by size 
               function TRIM(Efternavn)      delimited by size
                  into Rens-Fuld-Navn
               with pointer pos
               on overflow
                   continue
               end-string
               exit.
           formater-konto.
               move spaces to Konto-Linje
               string "Konto-Information: "      delimited by size
               function TRIM(Kontonummer)        delimited by size 
               " "                               delimited by size
               function TRIM(Balance)            delimited by size
               " "                               delimited by size
               function TRIM(Valutakode)         delimited by size
                  into Konto-Linje
               end-string
               exit.
           formater-adresse.
               move spaces to Addresse
               string "Addresse-Oplysninger: "   delimited by size
               function TRIM(Vejnavn)            delimited by size 
               " "                               delimited by size
               function TRIM(Husnummer)          delimited by size
                  into Addresse
               end-string
               exit.
           formater-by-og-post.
               move spaces to By-Linje
               string "By-Oplysninger: "         delimited by size
               function TRIM(By-navn)            delimited by size
               " "                               delimited by size
               function TRIM(Postnummer)         delimited by size
                  into By-Linje
               end-string
               exit.
           formater-kontakt.
               move spaces to Kontakt-Linje
               string "Kontakt-Oplysninger: "    delimited by size
               function TRIM(Telefon)            delimited by size
               " "                               delimited by size
               function TRIM(Email)              delimited by size
                  into Kontakt-Linje
               end-string
               exit.

               

