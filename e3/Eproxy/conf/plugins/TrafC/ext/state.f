\ 22.Jul.2002

: StateCanal { a u -- }
    a u ResolveCanal?           IF  ( oid )
    a u TYPE ."  {{ " CR
    :TellState  
    ." }}" CR                   ELSE
    ." ( " a u TYPE 
    ."  - canal not found)" CR  THEN 
;
: (StateCanals) ( -- )
  { \ a u }
  BEGIN   NextWord DUP
  WHILE   StateCanal
  REPEAT  2DROP
;
: StateCanals ( a u -- )
  ['] (StateCanals) EVALUATE-WITH
;
: StateAllCanals ( -- )
  ['] StateCanal ForCanalNames
;
