0 VALUE  H-ACTIVITY
VARIABLE ACTIVITY-FILE
HERE S" activity.log" S", 0 C, ACTIVITY-FILE !

: OpenLogFile { a u -- h }
  a u R/W OPEN-FILE-SHARED
  IF DROP
     a u 
     R/W CREATE-FILE-SHARED THROW
  ELSE DUP DUP FILE-SIZE THROW
       ROT REPOSITION-FILE THROW
  THEN
;

: StartActivityLog ( -- )
  ACTIVITY-FILE @ COUNT  OpenLogFile  TO H-ACTIVITY
;

: ActivityLOG ( -- )
  H-ACTIVITY 0= IF EXIT THEN
  vElapsed 0= IF EXIT THEN
  uClientReadStat  @ 1000 vElapsed */  \ то, что читается от клиента. обычно исходящий трафик.
  uClientWriteStat @ 1000 vElapsed */  \ то, что пишется клиенту. обычно входящий (снаружи) трафик.
  vElapsed
  \ " {UNIXDATE} {CLIENT} {n} {n} {n} {CRLF}"
  \ " {<<# CurrentDateTime#Z-ap #>} {CLIENT} {n} {n} {n} {CRLF}"
  " {<<# CurrentDateTime#Z #>} {CLIENT} {n} {n} {n} {CRLF}"

  DUP   STR@ H-ACTIVITY WRITE-FILE THROW
  STRFREE
;

: LogActivity { mem h }
  BEGIN
    mem 100 h READ-FILE THROW ?DUP
    IF mem SWAP FPUT
    ELSE S" " FPUT THEN
    100 PAUSE
  AGAIN
;

: Activity { \ h mem }
  ACTIVITY-FILE @ COUNT R/O OPEN-FILE-SHARED ?DUP 
  IF NIP " Unable to open a activity-file {ACTIVITY-FILE @ COUNT}. Error {n}" FPUTS EXIT THEN
  -> h
  h FILE-SIZE THROW
  h REPOSITION-FILE THROW
  500 ALLOCATE THROW -> mem
  mem h ['] LogActivity CATCH IF 2DROP THEN
  mem FREE DROP h CLOSE-FILE DROP
;

: HtmlActivity ( -- )
  " <PRE>{CRLF}" FPUTS
  ['] Activity CATCH DROP
  StopProtocol
;
