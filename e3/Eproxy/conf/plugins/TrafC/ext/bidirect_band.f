\ 21.Dec.2002 Sat 11:05

: EVAL-STR ( ... s --  ... )
  DUP >R STR@ EVALUATE R> STRFREE
;
: Canal`
  NextWord 
  CanalsWordList SEARCH-WORDLIST
  ...
;

: BBand:
  NextWord 2DUP
  " Band: {s}_in ;Band" EVAL-STR
  " Band: {s}_ot ;Band" EVAL-STR
;

: +Canal`
  NextWord 2DUP
  " +CanalIn` {s}_in" EVAL-STR
  " +CanalOt` {s}_ot" EVAL-STR
;
