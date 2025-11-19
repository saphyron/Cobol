      identification division.
      program-id. kontoOplysning.

      environment division.
      input-output section.
      file-control.
     *> --- Input/Output filer: Bankdata, Transaktioner og samlet ---
     *> --- kontoudskrift ---
           select Bank-Data-in 
               assign to "text-files/Banker.txt"
               organization is line sequential.
           select Transaktion-Data-in 
               assign to "text-files/Transaktioner.txt"
               organization is line sequential.
           select Kontoudskrift-Out 
               assign to "text-files/KundeUdskrift.txt"
               organization is line sequential.

      data division.
      file section.
      FD Bank-Data-in.
      01 Bank-Information.
           copy "Opgave10/Copybooks/Banker.cpy".
      FD Transaktion-Data-in.
      01 Transaktion-Information.
           copy "Opgave10/Copybooks/Transaktioner.cpy".
      fd Kontoudskrift-Out.
      01 Udskriftslinje   pic x(300) value spaces.

      working-storage section.
     *> --- EOF Checks for hoved-transaktionsfil og bankfil ---
      01 EOF-check               pic x value "N".
           88 end-of-file        value "Y".
           88 more-to-read       value "N".
      01 EOF-check-bank          pic x value "N".
           88 end-of-file-bank   value "Y".
           88 more-to-read-bank  value "N".

     *> --- Transaktion ARRAYS ---
      copy "Opgave10/Copybooks/Transaktion.cpy".
     *> --- År Logik ---
      copy "Opgave10/Copybooks/Years.cpy".
     *> --- Bank-Information-Out ---
      copy "Opgave10/Copybooks/BankInfoOut.cpy".
     *> --- Pointer til STRING-ops og substring positioner ---
      01 pos                     pic 9(4)     value 0.
      01 Kunde-Info-Kontoudskrift.
           02 KUNDE-NAVN-OUT       pic x(300)     value spaces.
           02 KUNDE-ADRESSE-OUT    pic x(300)     value spaces.
      01 KontoUdskrift-ID-LINJE-OUT   pic x(300)  value spaces.
      01 KontoUdskrift-LINJE-OUT      pic x(300)  value spaces.
      01 nuvarende-konto-info.
           02 Konto-ID-NU          pic x(14)    value spaces.
           02 NASTE-KONTO-ID       pic x(14)    value spaces.
      01 dato-tid-info.
           02 Dato-NU               pic x(10)    value spaces.
           02 Tidspunkt-NU          pic x(8)     value spaces.
           02 DATO-RAW-NU           pic x(26)    value spaces.
      01 belob-formatering.
           02 Belob-DKK-NU          pic -ZZZZZZZZZZ9.99.
           02 Belob-Valuta-NU       pic -ZZZZZZZZZZ9.99.
           02 ValutaKode-NU         pic x(3)     value spaces.
     *> --- Valuta Konversioner (kurser og DKK-beløb i COMP-3) ---
      01 valuta-konvertering.
           copy "Opgave10/Copybooks/Valuta.cpy".
     *> --- Output-linjer til transaktioner pr. kunde/konto ---
      01 Kunde-Information-out.
           02 Konto-Linje-out          pic 9(4)    value 0.
           02 Konto-ID-Linje-out       pic x(14)   value spaces.
           02 Dato-Linje-out           pic x(10)   value spaces.
           02 Tidspunkt-Linje-out      pic x(8)    value spaces.
           02 Transaktion-Linje-out    pic x(20)   value spaces.
           02 Belob-DKK-Linje-out      pic x(16)   value spaces.
           02 Belob-Valuta-Linje-out   pic x(15)   value spaces.
           02 ValutaKode-Linje-out     pic x(4)    value spaces.
           02 Butik-Linje-out          pic x(20)   value spaces.
      01 felt-linje                    pic x(300)  value spaces.
      01 Saldo-Info-KontoUdskrift.
           02 Total-Saldo-DKK-IN       pic s9(13)v99 COMP-3 VALUE 0.
           02 Total-Saldo-DKK-OUT      pic s9(13)v99 COMP-3 VALUE 0.
           02 TOTAL-SUM-DKK            pic s9(13)v99 COMP-3 VALUE 0.
           02 Total-Saldo-DKK-IN-E     PIC -ZZZZZZZZZZ9.99. 
           02 Total-Saldo-DKK-OUT-E    PIC -ZZZZZZZZZZ9.99.
           02 TOTAL-SUM-DKK-E          PIC -ZZZZZZZZZZ9.99.
           02 WS-BELOB-NUM             pic s9(13)v99 COMP-3 VALUE 0.

      procedure division.
     *> --- Hovedforløb: loop igennem år, byg kontotabel og ---
     *> --- skriv kontoudskrifter ---
      Program-Execute.
           open output Kontoudskrift-Out

           perform varying CURRENT-AAR from start-aar by 1
               until CURRENT-AAR > SLUT-AAR

               move CURRENT-AAR to CURRENT-AAR-CHAR
               display "=== Starter Kontoudskrift for aar: " CURRENT-AAR
                   " ==="
               move 0 to ANTAL-KONTI
     *> --- Bygger konto-/transaktions-tabel i memory ---
     *> --- for det aktuelle år ---
               perform konto-tabel-opbygning-for-aar
               display "ANTAL-KONTI fundet: " ANTAL-KONTI
    
                   if ANTAL-KONTI > 0
                       perform læs-og-skriv-kontoudskrift
                   else
                       display "Ingen konto med transaktioner i aar."
                           CURRENT-AAR
                   end-if
           end-perform
           close Kontoudskrift-Out
             stop run.
     
     *> --- Læser hele transaktionsfilen og ---
     *> --- bygger kontotabel for et bestemt år ---
      konto-tabel-opbygning-for-aar.
       move "N" to EOF-check
       open input Transaktion-Data-in
           
           perform until end-of-file
               read Transaktion-Data-in
                   at end set end-of-file to TRUE
                   not at end
     *> --- Udtræk år fra dato-felt og filtrer kun transaktioner ---
     *> --- for CURRENT-AAR ---
                       move function TRIM(DATO 
                       of Transaktion-Information)
                           to DATO-RAW-NU
                       move DATO-RAW-NU(1:4) to AAR-FRA-DATO
                       if AAR-FRA-DATO = CURRENT-AAR
                           perform find-eller-opret-konto
                           perform tilføj-transaktion-til-konto
                       end-if
               end-read
           end-perform
           close Transaktion-Data-in
           exit.

     *> --- Her finder eller opretter vi konto i tabellen ---
      find-eller-opret-konto.
           set KONTO-IKKE-FUNDET to TRUE
           move 1 to I-KONTO
     *> --- Lineær søgning i kontotabellen efter matchende konto ---
           perform until KONTO-FUNDET or I-KONTO > ANTAL-KONTI
                if KONTO-ID of Transaktion-Information
                   = KT-KONTO-ID (I-KONTO)
                   and REG-NR of Transaktion-Information
                   = KT-REG-NR (I-KONTO)
                       set KONTO-FUNDET to TRUE
                else
                   add 1 to I-KONTO
                end-if
           end-perform
     *> --- Hvis konto ikke findes, opret ny konto-post og ---
     *> --- kopier stamdata ---
           if KONTO-IKKE-FUNDET
               if ANTAL-KONTI < MAX-KONTI
                   add 1 to ANTAL-KONTI
                   move ANTAL-KONTI to I-KONTO

                   move KONTO-ID of Transaktion-Information
                       to KT-KONTO-ID (I-KONTO)
                   move REG-NR of Transaktion-Information
                       to KT-REG-NR (I-KONTO)
                   move NAVN of Transaktion-Information
                       to KT-NAVN (I-KONTO)
                   move ADRESSE of Transaktion-Information
                       to KT-ADRESSE (I-KONTO)

                   move 0 to KT-ANTAL-TRANS (I-KONTO)
               else
     *> --- Beskyttelse mod overflow i kontotabel ---
                   display "Antal Konto har oversteget, maximum antal"
                    " konto tabellen understoetter"
                   stop run
               end-if
           end-if
           exit.

     *> --- Her tilføjes Transaktioner til Konti i kontotabellen ---
      tilføj-transaktion-til-konto.
           if KT-ANTAL-TRANS (I-KONTO) >= MAX-TRANS
               display "For mange transaktioner for konto-index=" 
                   I-KONTO
               display "  Konto-ID=" KT-KONTO-ID(I-KONTO)
               display "  Reg-Nr  =" KT-REG-NR(I-KONTO)
               display "  KT-ANTAL-TRANS=" KT-ANTAL-TRANS(I-KONTO)
               display "  MAX-TRANS     =" MAX-TRANS
               continue
           else
               add 1 to KT-ANTAL-TRANS (I-KONTO)
               move KT-ANTAL-TRANS (I-KONTO) to I-TRANS

               move BELOB of Transaktion-Information
                   to KT-BELOB (I-KONTO, I-TRANS)
               move VALUTA of Transaktion-Information
                   to KT-VALUTA (I-KONTO, I-TRANS)
               move TRANSAKTIONS-TYPE of Transaktion-Information
                   to KT-TYPE (I-KONTO, I-TRANS)
               move BUTIK of Transaktion-Information
                   to KT-BUTIK (I-KONTO, I-TRANS)
               move DATO of Transaktion-Information
                   to KT-DATO (I-KONTO, I-TRANS)
           end-if
           exit.
      
     *> --- Loop igennem alle konti og ---
     *> --- generer fuld kontoudskrift pr. konto ---
      læs-og-skriv-kontoudskrift.
           perform varying I-KONTO from 1 by 1 
               until I-KONTO > ANTAL-KONTI
     *> --- Nulstil saldoer per konto før vi summerer transaktioner ---
           move 0 to Total-Saldo-DKK-IN
                     Total-Saldo-DKK-OUT
                     TOTAL-SUM-DKK
     *> --- Hent bank- og kunde-info for nuværende konto ---
           perform bank-info-fra-konto
           perform kunde-info-fra-konto
     *> --- Skriv header (kunde, bank, kolonneoverskrifter) ---
           perform skriv-konto-header
     *> --- Skriv alle transaktioner for denne konto ---
           perform varying I-TRANS from 1 by 1
                   until I-TRANS > KT-ANTAL-TRANS(I-KONTO)
               perform udfyld-transaktionsfelter-fra-tabel
               perform byg-og-skriv-transaktions-linje-til-udskrift
           end-perform
     *> --- Afslut med totaler for kontoen ---
           perform skriv-konto-totals
           end-perform
           exit.


     *> --- Hent bankinfo ud fra reg-nr og fyld bank-outputfelter ---
      bank-info-fra-konto.
     *> --- Trimmer REG-NR og forkorter til 4 cifre ---
     *> --- til match mod bankfil ---
           move function TRIM(KT-REG-NR(I-KONTO))
                to REG-NR-KUNDE-TRIM-6
           if function LENGTH(REG-NR-KUNDE-TRIM-6) >= 4
               move REG-NR-KUNDE-TRIM-6(1:4) to REG-NR-KUNDE-TRIM-4
           else
               move REG-NR-KUNDE-TRIM-6 to REG-NR-KUNDE-TRIM-4
           end-if
     *> --- Sætter outputlinjer og rå bankfelter til spaces ---
           move spaces to REG-NR-OUT BANKNAVN-OUT BANKADDRESSE-OUT
           move spaces to TELEFON-OUT EMAIL-OUT
           move spaces to BANKNAVN-RAW BANKADDRESSE-RAW TELEFON-RAW 
           move spaces to EMAIL-RAW
     *> --- Håndtere bankens REG-NR ---
           move 151 to pos
           string 
               "Registreringsnummer: "              delimited by size
               function TRIM(REG-NR-KUNDE-TRIM-4)   delimited by size
                  into REG-NR-OUT
               with pointer pos
           end-string
     *> --- Hent bank information fra bank-data baseret på REG-NR  ---
       open input Bank-Data-in
           move "N" to EOF-check-bank
     *> --- Læs bankdata indtil matchende reg-nr er fundet eller EOF ---
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
     *> --- Byg tekstlinjer til banknavn, adresse, telefon og e-mail ---
                   move spaces to BANKNAVN-OUT
                   move 151 to pos
                   string
                       "Bank: "                  delimited by size
                       function TRIM(BANKNAVN-RAW)   
                                                 delimited by size
                          into BANKNAVN-OUT
                          with pointer pos
                   end-string

                   move spaces to BANKADDRESSE-OUT
                   move 151 to pos
                   string
                       "Bankadresse: "           delimited by size
                       function TRIM(BANKADDRESSE-RAW) 
                                                 delimited by size
                          into BANKADDRESSE-OUT
                          with pointer pos
                   end-string

                   move spaces to TELEFON-OUT
                   move 151 to pos
                   string
                       "Telefon: "              delimited by size
                       function TRIM(TELEFON-RAW)   
                                                 delimited by size
                          into TELEFON-OUT
                          with pointer pos
                   end-string

                   move spaces to EMAIL-OUT
                   move 151 to pos
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

     *> --- Henter kundeinfo (navn og adresse) fra kontotabellen ---
      kunde-info-fra-konto.
     *> --- Reset kunde-output og sætter outputlinje til spaces ---
           move space to KUNDE-NAVN-OUT KUNDE-ADRESSE-OUT
     *> --- Håndtere kundens navn ---
           move 1 to pos
           string
                "Kunde: "              delimited by size
                function TRIM(KT-NAVN (I-KONTO))
                                       delimited by size
                     into KUNDE-NAVN-OUT
                with pointer pos
           end-string
     *> --- Håndtere kundens adresse ---
           move 1 to pos
           string
                "Adresse: "             delimited by size
                function TRIM(KT-ADRESSE (I-KONTO))
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
     *> --- Skriv konto-ID og år som header-linje ---
           move spaces to felt-linje
           move 1 to pos
           string
                "Kontoudskrift for kontonr.: " delimited by size
                function TRIM(KT-KONTO-ID (I-KONTO)) delimited by size
                "                          "   delimited by size
                "Aar: "                        delimited by size
                CURRENT-AAR-CHAR               delimited by size                
                    into felt-linje
                    with pointer pos
           end-string
              write Udskriftslinje from felt-linje
     *> --- Skriv kolonne-overskrifter for transaktionslinjer ---
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
     
     *> --- Udfylder arbejdsfelter for en transaktion ---
     *> --- ud fra kontotabellen ---
       udfyld-transaktionsfelter-fra-tabel.
     *> --- Splitter timestamp til dato- og tidsdel ---
     *> --- (forventet format yyyy-mm-dd-hh.mm.ss...) ---
           move KT-DATO (I-KONTO, I-TRANS) to DATO-RAW-NU
           if DATO-RAW-NU(11:1) = "-"
               move DATO-RAW-NU(1:10) to Dato-NU
               move DATO-RAW-NU(12:8) to Tidspunkt-NU
           else
               move function TRIM(DATO-RAW-NU) to Dato-NU
               move spaces to Tidspunkt-NU
           end-if
           move Dato-NU to Dato-Linje-out
           move Tidspunkt-NU to Tidspunkt-Linje-out
     *> --- Valutakode, butik og transaktionstype kopieres og trimmes --
           move function TRIM(KT-VALUTA (I-KONTO, I-TRANS))
                to ValutaKode-Linje-out
           move function TRIM(KT-BUTIK (I-KONTO, I-TRANS))
                to Butik-Linje-out
           move function TRIM(KT-TYPE (I-KONTO, I-TRANS)) 
                to Transaktion-Linje-out
     *> --- Håndter beløb, valuta, butik ---
     *> --- Transactionstype i generet data, har ikke nogen
     *>     relevans til den egentlige transaktion. ---
           move function NUMVAL(KT-BELOB  (I-KONTO, I-TRANS)) 
               to WS-BELOB-NUM
     *> --- Konverter Valuta til DKK ---
           perform konverter-belob-til-dkk

     *> --- Opdater totals for indbetaling/udbetaling og ---
     *> --- samlet saldo i DKK ---
           if WS-BELOB-DKK-NUM < 0 add WS-BELOB-DKK-NUM 
               to Total-Saldo-DKK-OUT
           end-if
           if WS-BELOB-DKK-NUM > 0 add WS-BELOB-DKK-NUM 
               to Total-Saldo-DKK-IN
           end-if
           ADD WS-BELOB-DKK-NUM TO TOTAL-SUM-DKK
           exit.

     *> --- Valutakonvertering: USD/EUR -> DKK, ---
     *> --- andre koder behandles som DKK ---
      konverter-belob-til-dkk.
           evaluate function TRIM(ValutaKode-Linje-out)
               when "DKK"
                   move WS-BELOB-NUM to WS-BELOB-DKK-NUM
               when "EUR"
                   compute WS-BELOB-DKK-NUM rounded =
                       WS-BELOB-NUM * KURS-EUR-TIL-DKK
               when "USD"
                   compute WS-BELOB-DKK-NUM rounded =
                       WS-BELOB-NUM * KURS-USD-TIL-DKK
     *> --- Hvis det ikke er nogen af de faste værdier, bliver det ---
     *> --- anset som Dansk Valuta ---
               when other
                   move WS-BELOB-NUM to WS-BELOB-DKK-NUM
           end-evaluate
     *> --- Beløb gemmes både i DKK og original valuta til udskrift ---
           move WS-BELOB-DKK-NUM to Belob-DKK-NU
           move WS-BELOB-NUM to Belob-Valuta-NU
           exit.

     *> --- Bygger én formateret transaktionslinje til ---
     *> --- udskrift baseret på kolonne-layout ---
       byg-og-skriv-transaktions-linje-til-udskrift.
           MOVE SPACES TO felt-linje
           move spaces to Belob-DKK-Linje-out
           move spaces to Belob-Valuta-Linje-out
           move function TRIM(Belob-DKK-NU) 
               to Belob-DKK-Linje-out
           move function TRIM(Belob-Valuta-NU) 
               to Belob-Valuta-Linje-out

           *> Kolonne-layout:
           *> 1:10  Dato
           *> 12:8   Tidspunkt
           *> 21:20  Transaktionstype
           *> 42:16  Beløb (DKK)
           *> 59:15  Beløb (valuta)
           *> 75:3   Valutakode
           *> 80:20  Butik
            move Dato-Linje-out              to felt-linje(1:10)
            move " "                         to felt-linje(11:1)
            move Tidspunkt-Linje-out         to felt-linje(12:8)
            move " "                         to felt-linje(20:1)
            move Transaktion-Linje-out(1:20) to felt-linje(21:20)
            move Belob-DKK-Linje-out         to felt-linje(42:16)
            move Belob-Valuta-Linje-out      to felt-linje(59:15)
            move ValutaKode-Linje-out(1:4)   to felt-linje(75:3)
            move Butik-Linje-out(1:20)       to felt-linje(80:20)

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
           