      identification division.
      program-id. Hello.

      data division.
      working-storage section.
      01 VAR-TEXT      pic x(30) value "Hello, en variabel".

      procedure division.
     *> Jeg skal lave et display, der faar cobol til at skrive
     *> til konsollen. Og bruger en variabel denne gang.
      display VAR-TEXT.
      stop run.
      