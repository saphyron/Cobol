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
      procedure division.
     *> Jeg skal lave et program, der bruger move til at tildele
     *> værdier til variabler og derefter display dem.
           move "C123456789"      to Kunde-Id
           move "Lars"            to Fornavn
           move "Jensen"          to Efternavn
           move "1234567890"      to Kontonummer
           move 1000.33           to Balance
           move "DKK"             to Valutakode
     *> Display værdierne til konsollen
           display "Kunde Id: "      Kunde-Id
           display "Fornavn: "       Fornavn
           display "Efternavn: "     Efternavn
           display "Kontonummer: "   Kontonummer
           display "Balance: "       Balance
           display "Valutakode: "    Valutakode
           stop run.
