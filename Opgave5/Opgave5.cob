      identification division.
      program-id. kontoOplysning.
      data division.
      working-storage section.
     *> Deklaration af variabler
      01 Kunde-Information.
           copy "KUNDER.cpy".
      01 Fuld-Navn-Renser       pic x(40)    value spaces.
      01 Addresse-Fixer         pic x(100)   value spaces.
      01 Addresse               pic x(100)   value spaces.
      01 Kode-logik.
           02 IX01              pic 9(2)     value 1.
           02 IX02              pic 9(2)     value 1.
           02 Curr-Char         pic x        value space.
           02 Prev-Char         pic x        value space.
           02 IX001              pic 9(3)     value 1.
           02 IX002              pic 9(3)     value 1.
           02 Currr-Char         pic x        value space.
           02 Prevv-Char         pic x        value space.
      procedure division.
     *> Jeg skal lave et program, der bruger move til at tildele
     *> værdier til variabler og derefter display dem.
           move "C123456789"      to Kunde-Id
           move "Lars"            to Fornavn
           move "Jensen"          to Efternavn
           move "1234567890"      to Kontonummer
           move 1000.33           to Balance
           move "DKK"             to Valutakode
           move "Hjejlevej"       to Vejnavn
           move "6, 1TV"          to Husnummer
           move "8600"            to Postnummer
           move "Silkeborg"       to By-navn
           move "86888888"        to Telefon
           move "Saphyron@hotmail.com" to Email
           string Fornavn delimited by size " "
           delimited by size Efternavn
           delimited by size
           into Fuld-Navn-Renser
           end-string
           string Vejnavn delimited by size " "
           delimited by size Husnummer
           delimited by size
           into Addresse-Fixer
           end-string
     *> Rensning af dobbelte mellemrum i Fuld-Navn
           move spaces to Fuld-Navn
           move 1 to IX01
           move 0 to IX02
           move space to Prev-Char
           perform varying IX01 from 1 by 1 
           until IX01 > length of Fuld-Navn-Renser
               move Fuld-Navn-Renser(IX01:1) to Curr-Char
               if Curr-Char not = space or Prev-Char not = space
                   add 1 to IX02
                   move Curr-Char to Fuld-Navn(IX02:1)
               end-if
               move Curr-Char to Prev-Char
           end-perform
     *> Rensning af dobbelte mellemrum i Addresse-Oplysninger
           move spaces to Addresse
           move 1 to IX001
           move 0 to IX002
           move space to Prevv-Char
           perform varying IX001 from 1 by 1 
           until IX001 > length of Addresse-Fixer
               move Addresse-Fixer(IX001:1) to Currr-Char
               if Currr-Char not = space or Prevv-Char not = space
                   add 1 to IX002
                   move Currr-Char to Addresse(IX002:1)
               end-if
               move Currr-Char to Prevv-Char
           end-perform
     *> Display værdierne til konsollen
           display "-------------------------------"
           display "Kunde Information:"
           display "Kunde Id: "      Kunde-Id of Kunde-Information
           display "Fuld Navn: "     Fuld-Navn of Person-Navn
           display "Kontonummer: "   Kontonummer of Konto-Information
           display "Balance: "       Balance of Konto-Information 
               " " Valutakode of Konto-Information
           display "Addresse Oplysninger:"
           display "Addresse: " Addresse
           display "Postnummer: " Postnummer of Addresse-Oplysninger 
               " By: " By-navn of Addresse-Oplysninger
           display "Kontakt Oplysninger:"
           display "Telefon: " Telefon of Kontakt-Oplysninger  
               " Email: " Email of Kontakt-Oplysninger 
           display "-------------------------------"
           display Kunde-Information
           display "-------------------------------"
           stop run.
