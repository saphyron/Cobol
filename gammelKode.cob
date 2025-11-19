 procedure division.
      Program-Execute.
           open input Transaktion-Data-in
                output Kontoudskrift-Out

           perform until end-of-file
               read Transaktion-Data-in
                   at end set end-of-file to TRUE
               not at end
               move Konto-ID of Transaktion-Information(1:14)
                   to NASTE-KONTO-ID
               if function TRIM(Konto-ID-NU) not = spaces
                   and NASTE-KONTO-ID not = function TRIM(
                       KONTO-ID-NU) perform skriv-konto-totals
               end-if
               if NASTE-KONTO-ID not = function TRIM(Konto-ID-NU)
                   move NASTE-KONTO-ID to Konto-ID-NU
                   move 0 to Total-Saldo-DKK-IN
                   move 0 to Total-Saldo-DKK-OUT
                   move 0 to TOTAL-SUM-DKK
     *> --- Hent bank og kunde info fra transaktion ---
                   perform bank-info-fra-transaktion
                   perform kunde-info-fra-transaktion
                   perform skriv-konto-header
               end-if
     
     *> --- Udfyld transaktions felter fra transaktion ---
                   perform udfyld-transaktionsfelter-fra-transaktion
                   perform byg-og-skriv-transaktions-linje-til-udskrift
               end-read
           end-perform
     *> --- Skriv sidste konto totals ---
           if function TRIM(Konto-ID-NU) not = spaces
               perform skriv-konto-totals
           end-if
           close Transaktion-Data-in Kontoudskrift-Out
       stop run.


     *> --- Her hentes bank information fra transaktionen ---
      bank-info-fra-transaktion.
           move function TRIM(REG-NR of Transaktion-Information)
                to REG-NR-KUNDE-TRIM-6
           if function LENGTH(REG-NR-KUNDE-TRIM-6) >= 4
               move REG-NR-KUNDE-TRIM-6(1:4) to REG-NR-KUNDE-TRIM-4
           else
               move REG-NR-KUNDE-TRIM-6 to REG-NR-KUNDE-TRIM-4
           end-if
     *> --- Sætter outputlinje til spaces ---
           move spaces to REG-NR-OUT BANKNAVN-OUT BANKADDRESSE-OUT
           move spaces to TELEFON-OUT EMAIL-OUT
           move spaces to BANKNAVN-RAW BANKADDRESSE-RAW TELEFON-RAW 
           move spaces to EMAIL-RAW
     *> --- Håndtere bankens REG-NR ---
           move 201 to pos
           string 
               "Registreringsnummer: "              delimited by size
               function TRIM(REG-NR-KUNDE-TRIM-4)   delimited by size
                  into REG-NR-OUT
               with pointer pos
           end-string
     *> --- Hent bank information fra bank data fil ---
       open input Bank-Data-in
           set more-to-read-bank to TRUE
           move "N" to EOF-check-bank
     *> --- Læs bank data fil indtil matchende reg-nr er fundet ---
           perform until end-of-file-bank
           read Bank-Data-in
               at end move "Y" to EOF-check-bank
               not at end
                   move function TRIM(REG-NR of Bank-Information)
                       to REG-NR-BANK-TRIM
               if REG-NR-KUNDE-TRIM-4 = REG-NR-BANK-TRIM
                   move BANKNAVN of Bank-Information to BANKNAVN-RAW
                   move BANKADDRESSE of Bank-Information 
                       to BANKADDRESSE-RAW
                   move TELEFON of Bank-Information to TELEFON-RAW
                   move EMAIL of Bank-Information to EMAIL-RAW
     *> --- Håndtere bank information ---
                   move spaces to BANKNAVN-OUT
                   move 201 to pos
                   string
                       "Bank: "                  delimited by size
                       function TRIM(BANKNAVN-RAW)   
                                                 delimited by size
                          into BANKNAVN-OUT
                          with pointer pos
                   end-string

                   move spaces to BANKADDRESSE-OUT
                   move 201 to pos
                   string
                       "Bankadresse: "           delimited by size
                       function TRIM(BANKADDRESSE-RAW) 
                                                 delimited by size
                          into BANKADDRESSE-OUT
                          with pointer pos
                   end-string

                   move spaces to TELEFON-OUT
                   move 201 to pos
                   string
                       "Telefon: "              delimited by size
                       function TRIM(TELEFON-RAW)   
                                                 delimited by size
                          into TELEFON-OUT
                          with pointer pos
                   end-string

                   move spaces to EMAIL-OUT
                   move 201 to pos
                   string
                       "E-mail: "                delimited by size
                       function TRIM(EMAIL-RAW)     
                                                 delimited by size
                          into EMAIL-OUT
                          with pointer pos
                   end-string
                   move "Y" to EOF-check-bank
               end-if
           end-read
           end-perform
           close Bank-Data-in
           exit.  

     *> --- Her Hentes kunde info fra transaktionen ---
      kunde-info-fra-transaktion.
     *> --- Sætter outputlinje til spaces ---
           move space to KUNDE-NAVN-OUT KUNDE-ADRESSE-OUT
     *> --- Håndtere kundens navn ---
           move 1 to pos
           string
                "Kunde: "              delimited by size
                function TRIM(NAVN of Transaktion-Information)
                                       delimited by size
                     into KUNDE-NAVN-OUT
                with pointer pos
           end-string
     *> --- Håndtere kundens adresse ---
           move 1 to pos
           string
                "Adresse: "             delimited by size
                function TRIM(ADRESSE of Transaktion-Information)
                                        delimited by size
                        into KUNDE-ADRESSE-OUT
                with pointer pos
           end-string
           exit.

     *> --- Konto-header skrives til udskrift ---
      skriv-konto-header.
     *> --- Skriv kunde info til udskrift ---
           write Udskriftslinje from "-------------------------------"
           write Udskriftslinje from KUNDE-NAVN-OUT
           write Udskriftslinje from KUNDE-ADRESSE-OUT
           write Udskriftslinje from spaces
           write Udskriftslinje from spaces
     *> --- Skriv bank info til udskrift ---
           write Udskriftslinje from REG-NR-OUT
           write Udskriftslinje from BANKNAVN-OUT
           write Udskriftslinje from BANKADDRESSE-OUT
           write Udskriftslinje from TELEFON-OUT
           write Udskriftslinje from EMAIL-OUT
           write Udskriftslinje from spaces
           write Udskriftslinje from spaces
           write Udskriftslinje from spaces
     *> --- Skriv konto ID header til udskrift ---
           move spaces to felt-linje
           move 1 to pos
           string
                "Kontoudskrift for kontonr.: " delimited by size
                function TRIM(KONTO-ID of Transaktion-Information)
                                            delimited by size
                    into felt-linje
                    with pointer pos
           end-string
              write Udskriftslinje from felt-linje
     *> --- Skriv kolonne header til udskrift ---
           MOVE SPACES TO KontoUdskrift-LINJE-OUT
           MOVE 1 TO pos
           STRING
               "Dato "                 DELIMITED BY SIZE
               "Tidspunkt "            DELIMITED BY SIZE
               "Transaktionstype  "    DELIMITED BY SIZE
               "Beløb (DKK)  "         DELIMITED BY SIZE
               "Beløb (valuta)  "      DELIMITED BY SIZE
               "Valutakode   "         DELIMITED BY SIZE
               "Butik"                 DELIMITED BY SIZE
               INTO KontoUdskrift-LINJE-OUT
               WITH POINTER pos
           END-STRING
           WRITE Udskriftslinje FROM KontoUdskrift-LINJE-OUT
           exit.
     
     *> --- Her udfyldes transaktions felter fra transaktion
       udfyld-transaktionsfelter-fra-transaktion.
           move DATO of Transaktion-Information to DATO-RAW-NU
           if DATO-RAW-NU(11:1) = "-"
               move DATO-RAW-NU(1:10) to Dato-NU
               move DATO-RAW-NU(12:8) to Tidspunkt-NU
           else
               move function TRIM(DATO-RAW-NU) to Dato-NU
               move spaces to Tidspunkt-NU
           end-if
           move Dato-NU to Dato-Linje-out
           move Tidspunkt-NU to Tidspunkt-Linje-out
           *> --- Håndter valutakode og butik samt transaktionstype ---
           move function TRIM(VALUTA of Transaktion-Information)
                to ValutaKode-Linje-out
           move function TRIM(BUTIK of Transaktion-Information)
                to Butik-Linje-out
           move function TRIM(TRANSAKTIONS-TYPE 
                of Transaktion-Information) to Transaktion-Linje-out
     *> --- Håndter beløb, valuta, butik ---
           move function NUMVAL(BELOB of Transaktion-Information) 
               to WS-BELOB-NUM
           move WS-BELOB-NUM to Belob-DKK-NU
           move WS-BELOB-NUM to Belob-Valuta-NU

           if WS-BELOB-NUM < 0 add WS-BELOB-NUM 
               to Total-Saldo-DKK-OUT
           end-if
           if WS-BELOB-NUM > 0 add WS-BELOB-NUM 
               to Total-Saldo-DKK-IN
           end-if
           ADD WS-BELOB-NUM TO TOTAL-SUM-DKK
           exit.

     *> --- Byg og skriv transaktions linje til udskrift ---
       byg-og-skriv-transaktions-linje-til-udskrift.
           MOVE SPACES TO felt-linje
           move spaces to Belob-DKK-Linje-out
           move spaces to Belob-Valuta-Linje-out
           move function TRIM(Belob-DKK-NU) 
               to Belob-DKK-Linje-out
           move function TRIM(Belob-Valuta-NU) 
               to Belob-Valuta-Linje-out

           *> Kolonne-layout (1-baseret):
           *>  1:10  Dato
           *> 12:8   Tidspunkt
           *> 21:20  Transaktionstype
           *> 42:15  Beløb (DKK)
           *> 58:15  Beløb (valuta)
           *> 74:4   Valutakode
           *> 79:20  Butik
            move Dato-Linje-out              to felt-linje(1:10)
            move " "                         to felt-linje(11:1)
            move Tidspunkt-Linje-out         to felt-linje(12:8)
            move " "                         to felt-linje(20:1)
            move Transaktion-Linje-out(1:20) to felt-linje(21:20)
            move Belob-DKK-Linje-out         to felt-linje(42:15)
            move Belob-Valuta-Linje-out      to felt-linje(58:15)
            move ValutaKode-Linje-out(1:4)   to felt-linje(74:4)
            move Butik-Linje-out(1:20)       to felt-linje(79:20)

            write Udskriftslinje from felt-linje
           EXIT.

     

     *> --- Her laver vi addition for total sum ---
      skriv-konto-totals.
           write Udskriftslinje from spaces
     *> --- Skriv total indbetalt til udskrift ---
           move spaces to felt-linje
           move Total-Saldo-DKK-IN to Total-Saldo-DKK-IN-E
           move Total-Saldo-DKK-OUT to Total-Saldo-DKK-OUT-E
           move TOTAL-SUM-DKK to TOTAL-SUM-DKK-E
           move 1 to pos
           string
                "Total indbetalt (DKK): "        delimited by size
                function TRIM(Total-Saldo-DKK-IN-E) delimited by size
                   into felt-linje
                   with pointer pos
           end-string
           write Udskriftslinje from felt-linje
     *> --- Skriv total udbetalt til udskrift ---
           move spaces to felt-linje
           move 1 to pos
           string
                "Total udbetalt (DKK): "         delimited by size
                function TRIM(Total-Saldo-DKK-OUT-E) delimited by size
                   into felt-linje
                   with pointer pos
           end-string
           write Udskriftslinje from felt-linje
     *> --- Skriv samlet saldo til udskrift ---
           move spaces to felt-linje
           move 1 to pos
           string
                "Saldo (DKK): "          delimited by size
                function TRIM(TOTAL-SUM-DKK-E)     delimited by size
                   into felt-linje
                   with pointer pos
           end-string
           write Udskriftslinje from felt-linje
           write Udskriftslinje from spaces
           write Udskriftslinje from spaces
     *> --- Skriv afslutningshilsen til udskrift ---
           move spaces to felt-linje
           move 1 to pos
           string
               "Med venlig hilsen,"            delimited by size
                  into felt-linje
           end-string
           write Udskriftslinje from felt-linje
           move spaces to felt-linje
           move 1 to pos
           string
                function TRIM(BANKNAVN-RAW)   delimited by size
                    into felt-linje
                    with pointer pos
           end-string
           write Udskriftslinje from felt-linje
           exit.
           