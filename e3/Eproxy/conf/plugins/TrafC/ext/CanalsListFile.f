\ 04.Mar.2003 Tue 17:05  в отдельное расширение


\ Band: C1  500 =Band_CPS ;Band
\ name cps


ALSO band_canal :ConfLexicon
: (LoadBandsList) ( -- )
  BEGIN REFILL WHILE
    SOURCE NIP IF
      \ Band: 0 PARSE EVALUATE ( cps ) =CPS ;Band
      0 PARSE " Band: {s} =CPS ;Band" DUP >R STR@ EVALUATE
      R> STRFREE
    THEN
  REPEAT
;
PREVIOUS

: LoadBandsList ( filename-a filename-u -- )
  \ +PathTrafC 2DUP FILE-EXIST 0= IF 2DROP EXIT THEN
  +SourcePath 2DUP FILE-EXIST 0= IF ." not found: " TYPE CR EXIT THEN
  ['] (LoadBandsList) INCLUDE-SFILE-WITH
;

\ ---

\ Quita: Q1  10 Min =Period  20 Mb =Limit  ;Quota

ALSO quota_canal :ConfLexicon
: (LoadQuotasList) ( -- )
  BEGIN REFILL WHILE
    SOURCE NIP IF
      \ Quota: 0 PARSE EVALUATE ( bytes seconds ) =Period =Limit ;Quota
      0 PARSE " Quota: {s} =Period =Limit ;Quota" DUP >R STR@ EVALUATE
      R> STRFREE
    THEN
  REPEAT
;
PREVIOUS

: LoadQuotasList ( filename-a filename-u -- )
\  +PathTrafC R/O OPEN-FILE IF DROP EXIT THEN
\  ['] (LoadQuotasList) INCLUDE-FILE-WITH

\  +PathTrafC 2DUP FILE-EXIST 0= IF 2DROP EXIT THEN

  +SourcePath 2DUP FILE-EXIST 0= IF ." not found: " TYPE CR EXIT THEN

  ['] (LoadQuotasList) INCLUDE-SFILE-WITH
;
