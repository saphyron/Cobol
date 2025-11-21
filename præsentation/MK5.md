# **📄 Slide 1 — Titel + Indholdsfortegnelse**

### **Titel:**

**COBOL – Erfaringer, udfordringer og resultater fra 2 ugers arbejde**

### **Navn:**

John Høeg

### **Indhold (bullet points):**

* Kort intro til projektet
* Hvad jeg kan lide ved COBOL
* Hvad der giver problemer
* Dataflow i mit projekt
* Tekniske begrænsninger
* Performance-resultater
* Konklusion

*(Ingen diagram her – rent intro.)*

---

# **📄 Slide 2 — Projektets kontekst**

### **Formål med projektet**

* Parse 55.000+ transaktioner
* Sortere dem efter bankkonto og år
* Generere kontoudskrifter
* Håndtere valuta, bankdata og filinput

### **Diagram (system overview)**

Indsæt dette diagram som billede:

**System / opsætnings-diagram**

```mermaid
flowchart LR
    subgraph Files ["Input- og outputfiler (tekstfiler)"]
        A["Banker.txt"]
        B["Transaktioner.txt"]
        C["KundeUdskrift.txt"]
    end

    subgraph Copybooks ["Copybooks"]
        CB1["Banker.cpy"]
        CB2["Transaktioner.cpy"]
        CB3["Transaktion.cpy"]
        CB4["Years.cpy"]
        CB5["Valuta.cpy"]
        CB6["BankInfoOut.cpy"]
    end

    subgraph Program["COBOL-program"]
        P1["DATA DIVISION"]
        P2["Program-Execute"]
        P3["konto-tabel-opbygning-for-aar"]
        P4["læs-og-skriv-kontoudskrift"]
    end

    A --> P3
    B --> P3
    P4 --> C
    CB1 --> P1
    CB2 --> P1
    CB3 --> P1
    CB4 --> P1
    CB5 --> P1
    CB6 --> P1
```

---

# **📄 Slide 3 — Hvad jeg kan lide ved COBOL**

### **Positive ting**

* **Utrolig effektivt** med store datamængder (55k records på ~15 sekunder)
* **Arrays i WORKING-STORAGE er ekstremt hurtige**
* **Ingen kompleks syntaks** → let at læse
* Næsten **intet runtime-overhead**
* Meget deterministisk: “maskine-opførsel” i stedet for magi

### **Diagram: Konto-array struktur**

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

*(Viser hvor simpelt og effektivt data ligger i memory.)*

---

# **📄 Slide 4 — Hvad jeg ikke kan lide**

### **Ulemper og frustrationspunkter**

* **Alt er fixed-width** → fejl, hvis 1 tegn er forkert
* Ingen dynamiske arrays
* Copybooks bliver hurtigt uoverskuelige
* Der er **80-tegns linjegrænse** i klassisk COBOL
* String-håndtering er smertefuld
* Debugging kræver meget print debugging

### Eksempel på konkret problem:

* Ét enkelt tal for lidt i **Beløb-feltet** ødelagde valutaomregningen totalt.

*(Her kan du vise et før/efter screenshot.)*

---

# **📄 Slide 5 — Dataflow i projektet**

### **Viser hele pipeline fra filer til output**

```mermaid
flowchart LR
    T["Transaktioner.txt"] --> R1["READ Transaktion-Data-in"]
    R1 --> F1["konto-tabel-opbygning-for-aar"]

    F1 --> F2["find-eller-opret-konto"]
    F2 --> F3["tilføj-transaktion-til-konto"]
    F3 --> KT["KONTO-TABEL"]

    KT --> G1["læs-og-skriv-kontoudskrift"]

    B["Banker.txt"] --> BI["bank-info-fra-konto"]
    BI --> L["byg-og-skriv-transaktions-linje"]

    L --> OUT["KundeUdskrift.txt"]
```

---

# **📄 Slide 6 — Processflow pr. år**

### **Sådan arbejder programmet internt**

```mermaid
flowchart TD
    S["START"] --> O1["OPEN output"]
    O1 --> LOOP["For hver år (start-aar → slut-aar)"]

    LOOP --> BT["Byg konto-tabel for året"]
    BT --> CHK{"ANTAL-KONTI > 0?"}

    CHK -->|Ja| GEN["Generér kontoudskrifter"]
    CHK -->|Nej| SKIP["Ingen transaktioner for året"]

    GEN --> LOOP
    SKIP --> LOOP

    LOOP --> END["STOP RUN"]
```

```mermaid
flowchart LR
    S["START"]
    O1["OPEN output"]
    LOOP["For hvert år (start-aar → slut-aar)"]
    BT["Byg konto-tabel for året"]
    CHK{"ANTAL-KONTI > 0?"}
    GEN["Generér kontoudskrifter"]
    SKIP["Ingen transaktioner for året"]
    END["STOP RUN"]

    S --> O1 --> LOOP --> BT --> CHK
    CHK -->|Ja| GEN --> LOOP
    CHK -->|Nej| SKIP --> LOOP
    LOOP -->|Når sidste år er behandlet| END

```

---

# **📄 Slide 7 — Valuta-konvertering (teknisk udfordring)**

### Hvorfor dette var svært:

* Fixed width felter → *valuta sad nogle gange off-by-one*
* NUMVAL fejlede hvis beløbet var off alignment
* Konvertering misviste totals, hvis DKK og EUR ikke linede op

### Diagram:

```mermaid
flowchart TD
    S["NUMVAL(KT-BELOB)"] --> V["Valuta-kode"]
    V --> CH{"DKK / EUR / USD?"}

    CH -->|DKK| D1["= BELØB"]
    CH -->|EUR| D2["BELØB * kursEUR"]
    CH -->|USD| D3["BELØB * kursUSD"]
    CH -->|Other| D4["= BELØB"]

    D1 --> OUT["DKK-beløb"]
    D2 --> OUT
    D3 --> OUT
    D4 --> OUT
```

---

# **📄 Slide 8 — Konklusion**

### Det vigtigste jeg har lært:

* COBOL er **simpelt men stærkt**, lige så hurtigt som C når alt ligger i memory
* Fixed-width + ingen dynamik = mange fejlmuligheder
* Men meget deterministisk og stabilt
* Copybooks giver struktur, men gør projektet tungt
* God oplevelse at prøve et sprog hvor *intet er magi*, alt er synligt

### Afslutning

* Projektet håndterede **55.000 transaktioner på ~15 sekunder**
* Fik bygget et fuldt kontoudskriftssystem med valuta, bankdata og årsfiltrering
