      identification division.
      program-id. varAndmove.
      data division.
      working-storage section.
     *> Deklaration af variabler
      01 Kunde-Information.
           02 Kunde-Id          pic x(10)    value spaces.
           02 Person-Navn.
               03 Fuld-Navn     pic x(40)    value spaces.
               03 Fornavn       pic x(20)    value spaces.
               03 Efternavn     pic x(20)    value spaces.
           02 Konto-Information.   
               03 Kontonummer   pic x(20)    value spaces.
               03 Balance       pic 9(7)v99  value zeros.
               03 Valutakode    pic x(3)     value spaces.
      01 Fuld-Navn-Renser       pic x(40)    value spaces.
      01 Kode-logik.
           02 IX01              pic 9(2)     value 1.
           02 IX02              pic 9(2)     value 1.
           02 Curr-Char         pic x        value space.
           02 Prev-Char         pic x        value space.
      procedure division.
     *> Jeg skal lave et program, der bruger move til at tildele
     *> værdier til variabler og derefter display dem.
           move "C123456789"      to Kunde-Id
           move "Lars"            to Fornavn
           move "Jensen"          to Efternavn
           move "1234567890"      to Kontonummer
           move 1000.33           to Balance
           move "DKK"             to Valutakode
           string Fornavn delimited by size " "
           delimited by size Efternavn
           delimited by size
           into Fuld-Navn-Renser
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
     *> Display værdierne til konsollen
           display "-------------------------------"
           display "Kunde Information:"
           display "Kunde Id: "      Kunde-Id of Kunde-Information
           display "Fuld Navn: "     Fuld-Navn of Person-Navn
           display "Kontonummer: "   Kontonummer of Konto-Information
           display "Balance: "       Balance of Konto-Information 
               " " Valutakode of Konto-Information
           display "-------------------------------"
           display Kunde-Information
           display "-------------------------------"
           stop run.
