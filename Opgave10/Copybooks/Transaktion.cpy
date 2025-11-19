       77  MAX-KONTI           PIC 9(5)     VALUE 7000.
       77  MAX-TRANS           PIC 9(5)     VALUE 20.

       77  I-KONTO             PIC 9(5)     VALUE 0.
       77  I-TRANS             PIC 9(5)     VALUE 0.

       77  KONTO-FOUND-FLAG    PIC X        VALUE "N".
           88 KONTO-FUNDET                 VALUE "Y".
           88 KONTO-IKKE-FUNDET            VALUE "N".

       01  KONTO-TABEL.
           05 ANTAL-KONTI                  PIC 9(5) VALUE 0.
           05 KONTO-POST OCCURS 7000 TIMES.
              10 KT-KONTO-ID              PIC X(14).
              10 KT-REG-NR                PIC X(6).
              10 KT-NAVN                  PIC X(30).
              10 KT-ADRESSE               PIC X(50).
              10 KT-ANTAL-TRANS           PIC 9(5)  VALUE 0.
              10 KT-TRANS OCCURS 20 TIMES.
                 15 KT-BELOB              PIC X(16).
                 15 KT-VALUTA             PIC X(4).
                 15 KT-TYPE               PIC X(20).
                 15 KT-BUTIK              PIC X(20).
                 15 KT-DATO               PIC X(26).
