( текущий каталог процесса 
    conf\http-proxy\plugins\TrafC\%lang%\menu\
  - в котором находитс€ html )

\ REQUIRE $cdir     ..\..\scripts\lib\directory.f

Require SPARSE      lib\parse.f
Require MOVE-FILE   lib\FileExt.f
Include             lib\core-spf.f
Require Include     requ.f

VECT $cfgfile
:NONAME S" " ; TO $cfgfile

WARNING 0!

USER uStr "" uStr !
USER uNum
USER NEW-FILE \ h

: RefreshStr ( -- )
  uStr @ ?DUP IF STRFREE uStr 0! THEN "" uStr !
;

: ReadFile { xt -- }
  C/L >R  0x10000 TO C/L
\  $cfgfile R/O OPEN-FILE-SHARED THROW xt INCLUDE-FILE-WITH
  $cfgfile R/O OPEN-FILE-SHARED IF DROP ELSE xt INCLUDE-FILE-WITH THEN
  R> TO C/L
;

: ModFile ( xt -- ) \ xt is translator of config-file
  " { $cfgfile}.new" { xt cfg2 }
  cfg2 STR@ R/W CREATE-FILE THROW NEW-FILE !

  $cfgfile R/O OPEN-FILE THROW xt INCLUDE-FILE-WITH

  NEW-FILE @ CLOSE-FILE THROW NEW-FILE 0!

  cfg2 STR@ $cfgfile MOVE-FILE THROW
  cfg2 STRFREE
;

: DeleteSelected  ( -- )
  { \ s1 }
  BEGIN REFILL WHILE
  CURSTR @ " n{n}" -> s1 
  s1 STR@ IsSet 0= IF  SOURCE LTL @ + NEW-FILE @ WRITE-FILE THROW THEN
  s1 STRFREE   REPEAT
;

 : >NUM 0 0 2SWAP >NUMBER 2DROP D>S ;

: (>num) ( a u -- x )
  DEPTH >R
  EVALUATE
  DEPTH R> - -1 <> IF ABORT THEN
;
: >num ( a u -- x true | false )
  ['] (>num) CATCH IF 2DROP FALSE EXIT THEN
  TRUE
;
: dec-num? ( a u -- flag )
  BASE @ >R DECIMAL
  >num DUP IF NIP THEN
  R> BASE !
;
: AsNum ( a u -- num )
  >num 0= IF 0 THEN
;

InVoc{ ACTIONS

0 VALUE cfgfile

: open-cfg ( -- )
  $cfgfile R/W OPEN-FILE THROW TO cfgfile
;
: addto-cfg ( a u -- )
  cfgfile FILE-SIZE THROW cfgfile REPOSITION-FILE THROW
  cfgfile WRITE-FILE THROW
;
: close-cfg ( -- )
  cfgfile CLOSE-FILE THROW
;
: delete ( -- a u )
  ['] DeleteSelected ModFile
  S" Deleted OK"
;
}PrevVoc

: DoAction ( -- a u )
  S" action" EVALUATE        ALSO ACTIONS
  ['] EVALUATE  CATCH
  ?DUP                IF NIP NIP
  DUP 0< IF ABS S" -" ELSE 0 0 THEN
  " Error: #{s}{n}" STR@ THEN   PREVIOUS
;
