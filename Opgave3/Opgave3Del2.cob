      identification division.
      program-id. varAndmove.
      data division.
      working-storage section.
     *> Deklaration af variabler
      01 Kunde-Id      pic x(10)    value spaces.
      01 Fornavn       pic x(20)    value spaces.
      01 Efternavn     pic x(20)    value spaces.
      01 Kontonummer   pic x(20)    value spaces.
      01 Balance       pic 9(7)v99  value zeros.
      01 Valutakode    pic x(3)     value spaces.
     *> Nye Variabler
      01 Fuld-Navn         pic x(40)    value spaces.
      01 Index01           pic 9(2)     value 1.
      01 Index02           pic 9(2)     value 1.
      01 Current-Char      pic x        value space.
      01 Previous-Char     pic x        value space.
      01 Fuld-Navn-Renser  pic x(40)    value spaces.
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
           into Fuld-Navn
           end-string
     *> Rensning af dobbelte mellemrum i Fuld-Navn
           move spaces to Fuld-Navn-Renser
           move 1 to Index01
           move 0 to Index02
           move space to Previous-Char
           perform varying Index01 from 1 by 1 
           until Index01 > length of Fuld-Navn
               move Fuld-Navn(Index01:1) to Current-Char
               if Current-Char not = space or Previous-Char not = space
                   add 1 to Index02
                   move Current-Char to Fuld-Navn-Renser(Index02:1)
               end-if
               move Current-Char to Previous-Char
           end-perform
     *> Display værdierne til konsollen
           display "-------------------------------"
           display "Kunde Id: "      Kunde-Id
           display "Fuld Navn: "     Fuld-Navn-Renser
           display "Kontonummer: "   Kontonummer
           display "Balance: "       Balance " " Valutakode
           display "-------------------------------"
           display "---------Old Values------------"
           display "Fornavn: "       Fornavn
           display "Efternavn: "     Efternavn
           display "Fuld Navn: "     Fuld-Navn
           display "Kontonummer: "   Kontonummer
           display "Balance: "       Balance
           display "Valutakode: "    Valutakode
           display "-------------------------------"
           stop run.
