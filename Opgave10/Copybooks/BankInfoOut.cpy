     *> --- Trimmet reg-numre, for kunde og bank ---
      01 REG-NR-BANK-TRIM          pic x(4)     value spaces.
      01 REG-NR-KUNDE-TRIM-6       pic x(6)     value spaces.
      01 REG-NR-KUNDE-TRIM-4       pic x(4)     value spaces.
     *> --- Output-linjer --- (300 tegn hver)
      01 Bank-Info-KontoUdskrift.
           02 REG-NR-OUT        pic x(300)     value spaces.
           02 BANKNAVN-OUT      pic x(300)    value spaces.
           02 BANKADDRESSE-OUT  pic x(300)    value spaces.
           02 TELEFON-OUT       pic x(300)    value spaces.
           02 EMAIL-OUT         pic x(300)    value spaces.
     *> --- Bank Data ---      
      01 BANK-RAW.
           02 BANKNAVN-RAW          pic x(30)    value spaces.
           02 BANKADDRESSE-RAW      pic x(50)    value spaces.
           02 TELEFON-RAW           pic x(15)    value spaces.
           02 EMAIL-RAW             pic x(30)    value spaces.