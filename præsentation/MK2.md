## Slide 1 – Titel & indhold

### Korte bullets (på selve sliden)

**Titel:**

> Erfaringer med COBOL – kontoudskrifter på mainframe-måden

**Indhold:**

* 2 ugers COBOL-forløb
* Kontoudskrift-projekt
* Hvad jeg kan lide ved COBOL
* Hvad jeg ikke kan lide
* Tekniske problemer og performance
* Hvad jeg har lært

### Taletekst (ca. 1 min)

> Jeg hedder [navn], og jeg vil fortælle om de sidste to uger, hvor jeg har arbejdet med COBOL.
>
> Fokus har været et kontoudskrift-projekt, der minder om noget, man kunne finde i et banksystem: vi læser bankdata og transaktioner, sorterer dem, og genererer kontoudskrifter per konto og per år.
>
> I præsentationen vil jeg først kort forklare, hvad systemet gør.
> Så vil jeg snakke om, hvad jeg faktisk godt kan lide ved COBOL, og hvad jeg ikke er så fan af – især omkring streng syntaks, feltlængder og 80-tegns-grænsen.
>
> Derefter kommer jeg ind på nogle konkrete tekniske problemer fra projektet, blandt andet valuta-konvertering og felt-bugs.
> Jeg runder af med performance-tallene og hvad jeg har lært af at arbejde med et meget “old school” sprog.

---

## Slide 2 – Projektet: hvad har jeg bygget?

### Korte bullets

**Titel:**

> Projektet: Kontoudskrifter i COBOL

**Indhold:**

* Input: banker + ~55.000 transaktioner
* Gruppér efter konto og år
* Valuta → konvertering til DKK
* Output: kontoudskrift per konto/per år
* Kørselstid ~15 sekunder

### Taletekst (ca. 1–1½ min)

> Projektet går i korte træk ud på at simulere et banksystem, der genererer kontoudskrifter.
>
> Jeg har to primære inputfiler:
> *En bankfil* med oplysninger om banker – registreringsnummer, navn, adresse, telefon og e-mail.
> Og *en transaktionsfil* med omkring 55.000 transaktioner. Hver linje indeholder CPR, navn, adresse, kontonummer, reg.nr, beløb, valutakode, transaktionstype, butik og dato/tid.
>
> COBOL-programmet læser alle transaktioner, bygger en intern kontotabel i memory, og grupperer dem både per konto og per år.
> For hver konto og hvert år bliver der derefter genereret en kontoudskrift med bankinfo, kundeinfo, alle transaktioner og en samlet saldo.
>
> Hele kørslen – inklusiv læsning af alle 55.000 linjer, gruppering og skrivning af rapporter – tager cirka 15 sekunder, hvilket er ret effektivt, når man tænker på, at det hele er ren tekst-I/O og arrays.

---

## Slide 3 – Hvad jeg godt kan lide ved COBOL

### Korte bullets

**Titel:**

> Styrker ved COBOL

**Indhold:**

* Klare datastrukturer (`DATA DIVISION`, `PIC`)
* Arrays/tabeller er simple og effektive
* Kontrolflow er meget tydeligt
* Meget lidt “magic” / framework-støj
* Godt til batch-arbejde som dette

### Taletekst (ca. 1–1½ min)

> Noget af det, jeg faktisk synes er ret fedt ved COBOL, er hvor data-orienteret sproget er.
>
> I `DATA DIVISION` definerer man meget præcist sine felter med `PIC`. Man kan se helt ned på tegnniveau, hvordan data ligger i filen og i hukommelsen. Det gør strukturen ekstremt tydelig.
>
> Arrays – eller tabeller – er også simple at arbejde med. I mit projekt har jeg en kontotabel med op til 7.000 konti, og for hver konto op til 20 transaktioner. Det er bare en fast datastruktur i memory, og så laver jeg lineær søgning.
>
> Kontrolflowet er også ret nemt at læse: `PERFORM ... UNTIL` og sekventielle reads. Det, der står i koden, er stort set det, der sker – ingen ORM, ingen dependency injection, ingen skjulte lag.
>
> Til batch-jobs som denne opgave – læs filer, processér, skriv output – passer COBOL overraskende godt.

---

## Slide 4 – Hvad jeg *ikke* kan lide

### Korte bullets

**Titel:**

> Svagheder ved COBOL

**Indhold:**

* Meget ufleksibel syntaks
* PIC-felter: små fejl → store problemer
* Feltlængde-helvede (beløb og tekst)
* 80-tegns-grænse pr. linje
* Refaktorering er tung og manuel

### Taletekst (ca. 1–1½ min)

> På den anden side er der også nogle ting, der irriterer mig ved COBOL.
>
> Sproget er ekstremt ufleksibelt. Alt skal matche `PIC`-definitionerne 100 %. Hvis et felt er defineret med for få tegn, eller hvis man forskubber noget, så begynder data at overlappe – uden at compileren nødvendigvis klager.
>
> Et konkret eksempel fra mit projekt er beløbsfeltet: Da det var `PIC X(15)`, endte et ekstra tegn nogle gange inde i valutakoden. Det gav ting som “7EUR”, og så fejlede valuta-konverteringen. Løsningen var at gøre beløb længere, til `X(16)`, og justere layoutet.
>
> 80-tegns-grænsen per linje er også et historisk krav, som i dag mest føles som en begrænsning – især når man har lange `STRING`-udtryk eller gerne vil skrive meningsfulde kommentarer.
>
> Samlet set gør det sproget svært at refaktorere. Små strukturelle ændringer kræver, at man tjekker mange steder manuelt.

---

## Slide 5 – Konkrete tekniske problemer

### Korte bullets

**Titel:**

> Tekniske udfordringer i projektet

**Indhold:**

* Valuta: DKK, EUR, USD → altid DKK internt
* `NUMVAL` til at læse beløb som tal
* Beløbslængde: skulle ændres fra 15 til 16 tegn
* Dato/tid: parsing via substrings
* Grænser: `MAX-KONTI` og `MAX-TRANS` for sikkerhed

### Taletekst (ca. 1–1½ min)

> Hvis vi kigger på nogle konkrete tekniske problemer fra projektet, er valuta-delen et godt eksempel.
>
> I inputfilen står beløbet som tekst, efterfulgt af en valutakode – fx `95570.67EUR`. Først bruger jeg `NUMVAL` til at få beløbet oversat til et numerisk felt, og så har jeg et separat valuta-modul med kurser til DKK for EUR og USD.
>
> Problemet opstod, fordi beløbsfeltet ikke var langt nok. Når beløbet fyldte hele feltet, “spildte” et ekstra tegn over i valutakoden. Resultatet var noget i stil med “7EUR”, og det ødelagde både visning og konvertering. Ved at øge feltlængden og justere kolonnerne blev det løst.
>
> Dato og tid krævede også lidt håndarbejde: formatet var `yyyy-mm-dd-hh.mm.ss.ffffff`, så jeg måtte splitte dato og tidspunkt manuelt via substring.
>
> Til sidst har jeg lagt sikkerhed ind med `MAX-KONTI` og `MAX-TRANS`, så programmet stopper pænt, hvis der kommer flere poster, end tabellerne understøtter.

---

## Slide 6 – Performance og effektivitet

### Korte bullets

**Titel:**

> Performance og effektivitet

**Indhold:**

* ~55.000 transaktioner
* Bygger kontotabel + grupperer per år
* Genererer kontoudskrift for alle konti
* Kørselstid ~15 sekunder
* Simple algoritmer, men hurtige nok

### Taletekst (ca. 1–1½ min)

> En af de mest positive ting ved opgaven er, hvor effektivt programmet rent faktisk kører.
>
> Vi har omkring 55.000 transaktioner, der læses sekventielt ind. For hver transaktion finder programmet den tilhørende konto i tabellen – med en simpel lineær søgning – og tilføjer den til kontoens interne transaktionsliste.
>
> Når tabellen er bygget for et år, genererer programmet kontoudskrifter for alle konti, inklusive valuta-konverterede beløb og totalsaldi.
>
> Det hele tager cirka 15 sekunder fra start til slut: læsning af filer, opbygning af tabeller, beregning af saldi og skrivning af den samlede rapportfil.
>
> Det viser, at selv med “naive” algoritmer og uden avancerede datastrukturer kan COBOL være meget effektiv til sekventielt batch-arbejde, hvor flaskehalsen primært er disk-I/O.

---

## Slide 7 – Hvad har været interessant?

### Korte bullets

**Titel:**

> Hvad har været mest interessant?

**Indhold:**

* At tænke “data først” gennem copybooks
* Forståelse for legacy bank-systemer
* Fokus på datakvalitet og felter
* Anderledes fejltyper end i moderne sprog
* Sammenligning med C#/SQL og frameworks

### Taletekst (ca. 1–1½ min)

> Noget af det mest interessante har været at blive tvunget til at tænke “data først”.
>
> I COBOL starter alt med copybooks og `PIC`-felter. Man designer strukturen for banker, kunder og transaktioner, før man overhovedet tænker på kontrolflowet. Det minder mig om, hvor vigtig datamodellering er – også i moderne systemer.
>
> Jeg har også fået mere respekt for, hvorfor gamle banksystemer stadig kører på COBOL: Når først strukturen er rigtig, er koden ekstremt stabil. Der er ikke så meget “magisk” lag ovenpå, der kan gå i stykker.
>
> Fejltyperne er også anderledes. I C# får man typisk exceptions og compilerfejl. I COBOL kan man have en stille datafejl, fordi et felt er én karakter for kort. Det lærer én at være meget præcis.
>
> Samtidig er det interessant at sammenligne med C#/SQL, hvor frameworks skjuler meget af dette. Her ser man alt – på godt og ondt.

---

## Slide 8 – Konklusion og næste skridt

### Korte bullets

**Titel:**

> Konklusion: Min oplevelse med COBOL

**Indhold:**

* Styrker:

  * Klar datastruktur
  * God til batch og tekstfiler
* Svagheder:

  * Uflekstibelt, meget manuelt
  * PIC- og længde-problemer
* Projektresultat:

  * Fungerende kontoudskriftssystem
  * 55k transaktioner på ~15 sek
* Læring:

  * Mere respekt for legacy
  * Bedre fokus på dataformat og validering

### Taletekst (ca. 1–1½ min)

> Hvis jeg skal samle det hele, så vil jeg sige, at COBOL både har nogle klare styrker og nogle tydelige svagheder.
>
> Styrkerne er især datastrukturen og forudsigeligheden. `DATA DIVISION` gør det krystalklart, hvilke felter der findes, og programmet er godt til sekventielle batch-jobs som denne kontoudskrift.
>
> Svaghederne er manglende fleksibilitet og den hårde afhængighed af `PIC`-felter og feltlængder. Små fejl i længder kan give meget mærkelige resultater, og refaktorering er tung.
>
> Projektet endte med et fuldt fungerende kontoudskriftssystem, der gennemgår omkring 55.000 transaktioner på cirka 15 sekunder, grupperer dem efter konto og år, konverterer valuta til DKK og producerer læsbare udskrifter.
>
> Det vigtigste, jeg tager med, er en bedre forståelse af, hvorfor COBOL-systemer stadig lever, og samtidig en skarpere opmærksomhed på datadefinitioner og formater – noget der også er meget relevant i moderne C#/SQL-projekter.
