
[UNDEFINED] PARSE-AREA [IF]
: PARSE-AREA ( -- a u )
  SOURCE SWAP >IN @ + SWAP >IN @ -
;                      [THEN]

: SPARSE ( sa su -- a1 u1 true | false )
\ ��������� �� ����������� sa su, ����������� ����������.
\ ��� �������� >IN �� ��������.
  PARSE-AREA { sa su a u }
  a u sa su SEARCH  IF 
  DROP a -  DUP su + >IN +!
  a SWAP TRUE  EXIT THEN
  2DROP FALSE
;
: SPARSETO ( sa su -- a1 u1 true | false )
\ ��������� �� ����������� sa su, ����������� �� ����������.
\ ��� �������� >IN �� ��������.
  PARSE-AREA { sa su a u }
  a u sa su SEARCH  IF 
  DROP a -  DUP >IN +!
  a SWAP TRUE  EXIT THEN
  2DROP FALSE
;

