# 🖼️ **1. DATA DIVISION + PIC-felter (super god til COBOL’s styrker)**

**Slide:** *“Hvad jeg godt kan lide ved COBOL”*

### Hvorfor det er godt som billede:

* Viser COBOLs “data først”-filosofi
* Meget tydeligt visuelt (kolonner, PIC, struktur)
* Viser simplicity og rigid struktur

### Uddrag:

```cobol
01 Transaktion-Information.
   02 KONTO-ID           pic x(14).
   02 REG-NR             pic x(4).
   02 NAVN               pic x(50).
   02 ADRESSE            pic x(100).
   02 BELOB              pic x(16).
   02 VALUTA             pic x(3).
   02 DATO               pic x(26).
```

Dette billede er fantastisk til at forklare hvorfor COBOL er hurtigt, forståeligt og meget struktureret.

---

# 🖼️ **2. Konto-tabel arrayet (effektivitet + simplicity)**

**Slide:** *Performance & effektivitet*

Dette viser COBOL’s simple men hurtige array-baserede tilgang.

### Uddrag:

```cobol
copy "Opgave10/Copybooks/Transaktion.cpy".
```

Og inde i copybook’en (vis lille uddrag):

```cobol
01 Konto-Tabel.
   02 KT-KONTO-ID      pic x(14) occurs MAX-KONTI.
   02 KT-REG-NR        pic x(4)  occurs MAX-KONTI.
   02 KT-ANTAL-TRANS   pic 9(4)  occurs MAX-KONTI.
```

**Hvorfor det er et godt billede:**

* Nem at se, selv på afstand
* Forklarer hvorfor dit program æder 55k transaktioner på 15 sekunder
* Visualiserer COBOL's gamle men effektive data-layout

---

# 🖼️ **3. `PERFORM UNTIL` loop der behandler 55k transaktioner**

**Slide:** *Performance / hvad COBOL gør godt*

### Uddrag:

```cobol
perform until end-of-file
    read Transaktion-Data-in
        at end set end-of-file to true
        not at end
            if AAR-FRA-DATO = CURRENT-AAR
               perform find-eller-opret-konto
               perform tilføj-transaktion-til-konto
            end-if
    end-read
end-perform
```

**Hvorfor det er godt som billede:**

* Simpelt control-flow
* Let at forklare
* Viser hvordan COBOL arbejder batch-orienteret

---

# 🖼️ **4. STRING-kommando med pointer (perfekt til “COBOL er ufleksibel/oldschool”)**

**Slide:** *Hvad jeg IKKE kan lide ved COBOL*

Brug dette til at vise hvor tungt det er at formatere tekst i COBOL.

### Uddrag:

```cobol
move 1 to pos
string
    "Kontoudskrift for kontonr.: " delimited by size
    function TRIM(KT-KONTO-ID (I-KONTO)) delimited by size
    "  Aar: " delimited by size
    CURRENT-AAR-CHAR delimited by size
    into felt-linje
    with pointer pos
end-string
```

**Hvorfor billedet virker:**

* Viser tydeligt hvorfor COBOL føles rigid
* Mange ord for noget som er én linje i C#
* Perfekt eksempel til *"strengt, ufleksibelt, ingen moderne string-formattering"*

---

# 🖼️ **5. Valuta-konvertering (dine tekniske problemer)**

**Slide:** *Tekniske udfordringer*

### Uddrag:

```cobol
evaluate function TRIM(ValutaKode-Linje-out)
    when "DKK"
         move WS-BELOB-NUM to WS-BELOB-DKK-NUM
    when "EUR"
         compute WS-BELOB-DKK-NUM =
             WS-BELOB-NUM * KURS-EUR-TIL-DKK
    when "USD"
         compute WS-BELOB-DKK-NUM =
             WS-BELOB-NUM * KURS-USD-TIL-DKK
    when other
         move WS-BELOB-NUM to WS-BELOB-DKK-NUM
end-evaluate
```

**Hvorfor det fungerer visuelt:**

* Overskueligt og læseligt
* Viser en konkret funktion fra din løsning
* Understreger: *“Her fuckede det op, da beløb overlappede valutakoden”*

---

# 🖼️ **6. Buggen du løste — beløbsfeltet for kort**

**Slide:** *Problem → løsning*

Lav et slide hvor du viser *før/efter*:

### Før (bug):

```cobol
02 Belob-DKK-Linje-out pic x(15).
```

### Efter (fix):

```cobol
02 Belob-DKK-Linje-out pic x(16).
```

**Hvorfor det virker:**

* Ultra visuelt
* Alle kan se forskellen
* Perfekt til at forklare:
  “Ét tegn for kort gav fejl i valutakoden → data overlappede”
* Ideel til at vise COBOL’s sårbarhed

---

# 🖼️ **7. 80-tegns linjegrænse (et klassisk COBOL-billede)**

**Slide:** *Hvad jeg ikke kan lide*

Brug en af dine længere linjer der næsten når kolonne 80, fx:

```
00300      move function TRIM(KT-ADRESSE (I-KONTO)) to KUNDE-ADRESSE-OUT
```

Hvis du markerer:

* Kolonne 1
* Kolonne 6 (A-margin)
* Kolonne 72–80 (historisk linjeslut)

**Hvorfor dette er genialt visuelt:**

* Alle kan se “der er en usynlig mur her”
* Det harmonerer perfekt med din kritik i præsentationen

---

# 🖼️ **8. Års-loopet (`PERFORM VARYING CURRENT-AAR`)**

**Slide:** *Projektets flow / struktur*

### Uddrag:

```cobol
perform varying CURRENT-AAR from start-aar by 1
    until CURRENT-AAR > SLUT-AAR
    perform konto-tabel-opbygning-for-aar
    perform læs-og-skriv-kontoudskrift
end-perform
```

**Hvorfor det virker:**

* Enkel visuel struktur
* Perfekt til at vise “for hvert år → byg tabel → skriv rapport”
* Giver tilhørerne et godt overblik

---

# 📌 **Opsummering – De 8 bedste billeder**

| Slide | Billede                 | Hvorfor                              |
| ----- | ----------------------- | ------------------------------------ |
| 2     | DATA DIVISION + PIC     | Viser COBOL’s struktur og simpelhed |
| 3     | Konto-tabel array       | Understreger effektivitet            |
| 3     | PERFORM UNTIL loop      | Batch-flow, meget COBOL-agtigt       |
| 4     | STRING ... WITH POINTER | Viser rigiditet og tung syntaks      |
| 5     | Valuta Evaluate         | Reelt kodestykke + konkret fejl      |
| 5     | Beløb 16 tegn          | Let at forstå bugfix                |
| 6     | 80-tegns visuel linje   | Klassisk COBOL-begrænsning          |
| 7     | Års-loop               | Overblik over programflow            |
