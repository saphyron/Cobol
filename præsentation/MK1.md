
## Slide 1 – Titel & indhold

**Titel:**

> Erfaringer med COBOL – 2 ugers arbejde med kontoudskrifter

**Indhold:**

* Kort om opgaven og konteksten
* Hvad jeg godt kan lide ved COBOL
* Hvad jeg ikke kan lide
* Tekniske udfordringer i projektet
* Performance og effektivitet
* Hvad jeg har lært
* Afrunding og næste skridt

**Talenoter (ca. 1 min):**

* Sæt scenen: 2 ugers COBOL-arbejde, fokus på et bank/kontoudskrift-projekt.
* Forklar at du både vil tale om sproget generelt og meget konkrete ting fra koden, du lige har siddet med.

---

## Slide 2 – Projektet: hvad har jeg bygget?

**Titel:**

> Projektet: Kontoudskrifter i COBOL

**Indhold:**

* Input:

  * Bankdata (banker, adresser, kontaktinfo)
  * Transaktioner (~55.000 linjer, forskellige år, konti og valutaer)
* Behandling:

  * Bygger kontotabel i memory (arrays)
  * Sorterer transaktioner efter konto og år
  * Konverterer valuta til DKK
* Output:

  * Genererer kontoudskrifter pr. konto pr. år
  * Ca. 15 sekunder for alle 55.000 transaktioner

**Talenoter (1–1½ min):**

* Forklar dataflow: tekstfiler ind → arrays → gruppering → rapportfil.
* Understreg: alt er skrevet i “klassisk” COBOL-stil med `WORKING-STORAGE`, copybooks og faste felter.
* Nævn konkret: den kører alle 55k transaktioner på ~15 sek, inkl. gruppering og udskrift.

---

## Slide 3 – Hvad jeg godt kan lide ved COBOL

**Titel:**

> Styrker: Hvad jeg faktisk kan lide ved COBOL

**Indhold:**

* Data-first tilgang:

  * `DATA DIVISION` og `PIC`-felter gør datastrukturen ekstremt tydelig
* Arrays/tabeller:

  * Kontotabel + transaktionstabel i memory
  * Lineær søgning, men stadig hurtig på 55k records
* Simpel kontrolflow:

  * `PERFORM ... UNTIL` er meget ligetil
  * Få “magiske” ting – det der står, er det der sker
* Lav overhead:

  * Ingen ORM, ingen runtime magic
  * Bare filer, felter og beregninger

**Talenoter (1–1½ min):**

* Giv eksemplet med kontotabellen: én datastruktur der indeholder alt for hver konto.
* Fremhæv, at du kan se præcis hvordan data ligger i hukommelsen – ingen skjulte lag.
* Sig at det giver en god forståelse af dataflow og performance.

---

## Slide 4 – Hvad jeg *ikke* kan lide

**Titel:**

> Svagheder: Hvad der irriterer mig ved COBOL

**Indhold:**

* Streng og ufleksibel syntaks:

  * Alt skal passe 100 % i `PIC`-felter
  * Små fejl i længder giver mærkelige bugs
* Karakter-/felt-opsætning:

  * Et enkelt tegn for meget i beløbsfeltet → ødelægger valuta
  * Skulle ændre `PIC X(15)` → `PIC X(16)` for at få korrekt konvertering
* 80-tegns-grænsen:

  * Historisk for mainframes – men føles kunstig i dag
  * Gør lange `STRING`-linjer og kommentarer mere bøvlede
* Manglende fleksibilitet:

  * Ingen dynamiske arrays, ingen “nem” refaktorering
  * Meget manuelt arbejde ved strukturelle ændringer

**Talenoter (1–1½ min):**

* Fortæl historien om valuta-buggen: “7” der sneg sig med ind i valutakoden → fejlagtig konvertering.
* Brug det som eksempel på, hvor “skørt” følsomt COBOL er på feltlængder.
* Nævn at 80-tegns-reglen måske giver mening historisk, men spænder ben for læsbarhed i dag.

---

## Slide 5 – Konkrete tekniske problemer i projektet

**Titel:**

> Tekniske udfordringer i kontoudskrift-projektet

**Indhold:**

* Valuta-håndtering:

  * Input: beløb + valuta (DKK, EUR, USD)
  * Løsning: `NUMVAL` + konvertering til DKK i et separat modul
* Feltlængder:

  * Beløb: måtte øges fra 15 til 16 tegn
  * Ellers blev valutakode “forurenet” og konvertering fejlede
* Dato og tid:

  * Forskellige formater (`yyyy-mm-dd-hh.mm.ss...`)
  * Måtte splitte dato/tid manuelt via substrings
* Sikkerhedschecks:

  * Max antal konti (`MAX-KONTI`) og transaktioner (`MAX-TRANS`) per konto
  * Beskyttelse mod overflow i arrays

**Talenoter (1–1½ min):**

* Gennemgå kort valuta-modulet: læser valutakode, vælger kurs, gemmer både DKK-beløb og original valuta.
* Forklar, hvordan du opdagede beløbsfelt-problemet via output (7’eren foran EUR).
* Nævn at meget tid gik på debugging af *dataformater* frem for algoritmer.

---

## Slide 6 – Performance og effektivitet

**Titel:**

> Performance: Hvor effektivt er det faktisk?

**Indhold:**

* Processing:

  * Ca. 55.000 transaktioner
  * Alle grupperet på konto og år
  * Alle kontoudskrifter genereret
* Tidsforbrug:

  * Ca. 15 sekunder for hele kørslen
  * Inkluderer file I/O, opbygning af tabeller og skrivning af output
* Algoritmer:

  * Simpel lineær søgning i kontotabel
  * Ingen avancerede datastrukturer, men stadig hurtig nok
* Læring:

  * COBOL kan være ekstremt effektivt på sekventielle jobs
  * Flaskehalse er ofte I/O og ikke selve beregningerne

**Talenoter (1–1½ min):**

* Fremhæv, at selv med ret “naiv” algoritme er performance god nok til denne type batch-job.
* Brug det som positiv pointe: COBOL + sekventielle filer + arrays passer godt til store batch-kørsler.
* Du kan kort nævne, at man *kunne* optimere yderligere (bedre søgning), men det var ikke nødvendigt.

---

## Slide 7 – Hvad har været interessant ved COBOL?

**Titel:**

> Hvad har været mest interessant for mig?

**Indhold:**

* At tænke “data først”:

  * Designe copybooks (strukturer) var næsten vigtigere end selve koden
* Respekt for gamle systemer:

  * Forstår bedre, hvorfor COBOL stadig bruges i banker
  * Stabilitet > fleksibilitet
* Fejltyper:

  * Små PIC-fejl kan give store, men stille, dataproblemer
  * Tvinger én til at være ekstremt præcis
* Sammenligning med moderne sprog:

  * Mindre fleksibelt, men mere transparent
  * Intet “framework-støj” mellem dig og data

**Talenoter (1–1½ min):**

* Fortæl om, hvordan du nærmest var tvunget til at lave ordentlig datastruktur fra starten.
* Nævn, at COBOL føles kedeligt på overfladen, men meget “ærlig” i, hvad den gør.
* Du kan koble det til dit normale arbejde: i C#/SQL gemmer frameworks ofte detaljerne – her ser du alt.

---

## Slide 8 – Afrunding & min konklusion

**Titel:**

> Afrunding: Min konklusion om COBOL

**Indhold:**

* Hvad jeg kan lide:

  * Klar datastruktur, forudsigelighed, god performance til batch
* Hvad jeg ikke kan lide:

  * Manglende fleksibilitet, streng syntaks, 80-tegn og PIC-helvede
* Opgaven:

  * Fik et fuldt kontoudskrift-system til at virke
  * Håndtering af 55k transaktioner, valuta, bank- og kundeinfo
* Næste skridt:

  * Kunne forbedre modulopdeling (flere copybooks)
  * Mere genbrugelige rutiner til datoer, valuta og udskrift
* Overordnet:

  * God læring i “old school” databehandling
  * Giver bedre forståelse for moderne systemer og legacy-integration

**Talenoter (1–1½ min):**

* Saml trådene: COBOL er ikke “mit nye yndlingssprog”, men det har nogle klare styrker.
* Slut med en personlig vinkel: hvad du tager med dig videre til fremtidige projekter (fx mere fokus på datamodellering og tydelige formater).
