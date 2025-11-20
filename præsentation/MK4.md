## 1️⃣ System / opsætning (filer ↔ COBOL-program)

**Formål:** Bruges tidligt i præsentationen til at vise “hvad består systemet af?”.

```mermaid
flowchart LR
    subgraph Files ["Input- og outputfiler (tekstfiler)"]
        A["Banker.txt<br/>(Bank-Data-in)"]
        B["Transaktioner.txt<br/>(Transaktion-Data-in)"]
        C["KundeUdskrift.txt<br/>(Kontoudskrift-Out)"]
    end

    subgraph Copybooks ["Copybooks (struktur og konstanter)"]
        CB1["Banker.cpy<br/>Bank-Information"]
        CB2["Transaktioner.cpy<br/>Transaktion-Information"]
        CB3["Transaktion.cpy<br/>KONTO-TABEL / arrays"]
        CB4["Years.cpy<br/>start-aar / slut-aar"]
        CB5["Valuta.cpy<br/>Valutakurser"]
        CB6["BankInfoOut.cpy<br/>Bank-info til udskrift"]
    end

    subgraph Program["COBOL-program<br/>kontoOplysning"]
        P1["DATA DIVISION<br/>FD / WORKING-STORAGE"]
        P2["Program-Execute<br/>PERFORM CURRENT-AAR"]
        P3["konto-tabel-opbygning-for-aar"]
        P4["læs-og-skriv-kontoudskrift"]
    end

    A -->|læses af| P3
    B -->|læses af| P3
    P4 -->|write| C

    CB1 --> P1
    CB2 --> P1
    CB3 --> P1
    CB4 --> P1
    CB5 --> P1
    CB6 --> P1
```

---

## 2️⃣ Dataflow – fra filer til kontoudskrift

**Formål:** Vise hvordan data flytter sig igennem programmet.

```mermaid
flowchart LR
    T["Transaktioner.txt"] --> R1["READ Transaktion-Data-in"]
    R1 --> F1["konto-tabel-opbygning-for-aar"]

    F1 -->|AAR-FRA-DATO = CURRENT-AAR| F2["find-eller-opret-konto"]
    F2 --> F3["tilføj-transaktion-til-konto"]
    F3 --> KT["KONTO-TABEL<br/>(arrays i WORKING-STORAGE)"]

    KT --> G1["læs-og-skriv-kontoudskrift"]

    B["Banker.txt"] --> BI["bank-info-fra-konto"]
    BI --> H1["Bank-info-ud (REG-NR, BANKNAVN, osv.)"]

    G1 --> H1
    G1 --> H2["kunde-info-fra-konto"]
    G1 --> H3["udfyld-transaktionsfelter-fra-tabel"]
    H3 --> V["konverter-belob-til-dkk"]
    V --> L["byg-og-skriv-transaktions-linje-til-udskrift"]
    L --> O["KundeUdskrift.txt"]
```

---

## 3️⃣ Processflow pr. år (øverst i Program-Execute)

**Formål:** Vise “hvad sker der, når programmet kører?” – godt overblik-slide.

```mermaid
flowchart TD
    S["START Program-Execute"]
    S --> O1["OPEN Kontoudskrift-Out"]

    O1 --> L1["PERFORM VARYING CURRENT-AAR<br/>FROM start-aar BY 1<br/>UNTIL CURRENT-AAR > slut-aar"]

    L1 --> S1["Set ANTAL-KONTI = 0"]
    S1 --> B1["konto-tabel-opbygning-for-aar"]
    B1 --> C1["ANTAL-KONTI > 0 ?"]

    C1 -->|Ja| G1["læs-og-skriv-kontoudskrift"]
    C1 -->|Nej| N1["DISPLAY 'Ingen konto med transaktioner i aar.'"]

    G1 --> L2["Næste CURRENT-AAR (loop)"]
    N1 --> L2
    L2 -->|Til sidst| E1["CLOSE Kontoudskrift-Out"]
    E1 --> END["STOP RUN"]
```

---

## 4️⃣ Detaljeret konto/transactions-flow

**Formål:** Slide der zoomer ind i “hvad sker der for én konto?”, kan kobles til din performance-snak og valuta-håndtering.

```mermaid
flowchart TD
    A["For hver konto I-KONTO"] --> R0["Nulstil totals<br/>Total-Saldo-DKK-IN/OUT/TOTAL-SUM-DKK"]
    R0 --> B["bank-info-fra-konto<br/>(REG-NR trim, opslag i Banker.txt)"]
    B --> C["kunde-info-fra-konto<br/>(navn + adresse)"]
    C --> D["skriv-konto-header"]

    D --> TLOOP["PERFORM VARYING I-TRANS<br/>1 TO KT-ANTAL-TRANS(I-KONTO)"]

    TLOOP --> T1["udfyld-transaktionsfelter-fra-tabel<br/>(Dato, tid, valuta, butik, type)"]
    T1 --> T2["konverter-belob-til-dkk<br/>(EUR/USD → DKK)"]
    T2 --> T3["Opdatér totaler<br/>IN / OUT / TOTAL-SUM-DKK"]
    T3 --> T4["byg-og-skriv-transaktions-linje-til-udskrift"]

    T4 --> TLOOP

    TLOOP -->|færdig| F["skriv-konto-totals<br/>+ afslutningshilsen"]
```

---

## 5️⃣ Valuta-konverterings-flow (fremhæver både logik og fejlmulighed)

**Formål:** Bruges i delen hvor du taler om problemer med felter/char-opsætning og hvor én kolonne for lidt gav fejl.

```mermaid
flowchart TD
    S["WS-BELOB-NUM<br/>(NUMVAL af KT-BELOB)"]
      --> V1["TRIM(ValutaKode-Linje-out)"]

    V1 --> C{"Valutakode?"}

    C -->|DKK| D1["WS-BELOB-DKK-NUM = WS-BELOB-NUM"]
    C -->|EUR| D2["WS-BELOB-DKK-NUM = WS-BELOB-NUM * KURS-EUR-TIL-DKK"]
    C -->|USD| D3["WS-BELOB-DKK-NUM = WS-BELOB-NUM * KURS-USD-TIL-DKK"]
    C -->|Other| D4["WS-BELOB-DKK-NUM = WS-BELOB-NUM"]

    D1 --> O["Belob-DKK-NU = WS-BELOB-DKK-NUM<br/>Belob-Valuta-NU = WS-BELOB-NUM"]
    D2 --> O
    D3 --> O
    D4 --> O

    O --> T["Bruges til:<br/>- Kolonner (Beløb DKK / valuta)<br/>- Total-Saldo-DKK-IN/OUT<br/>- TOTAL-SUM-DKK"]
```

---

## 6️⃣ Simpelt diagram over konto-tabel (arrays)

**Formål:** Understreger din pointe om “effektive arrays, lidt overhead, simpelt layout”.

```mermaid
graph TD
  subgraph Memory ["WORKING-STORAGE (memory)"]
    K["KONTO-TABEL (konto[1..N])"]
    T["KT-TRANS (N x MAX-TRANS)"]
    Krow["Et konto-element: ID, regnr, navn, antal trans"]
    Trow["Transaktioner for samme konto: beløb, valuta, butik, dato, type"]
  end

  K --> Krow
  T --> Trow
  Krow --> Trow

```
