: LogMonitor { mem h }
  BEGIN
    mem 100 h READ-FILE THROW ?DUP
    IF mem SWAP FPUT
    ELSE S" " FPUT THEN
    100 PAUSE
  AGAIN
;
: Monitoring { \ h mem }
  StdoutFile R/O OPEN-FILE-SHARED ?DUP 
  IF NIP " Unable to open a log-file {StdoutFile}. Error {n}" FPUTS EXIT THEN
  -> h
  h FILE-SIZE THROW
  h REPOSITION-FILE THROW
  100 ALLOCATE THROW -> mem
  mem h ['] LogMonitor CATCH IF 2DROP THEN
  mem FREE DROP h CLOSE-FILE DROP
;

: HtmlMonitoring
" HTTP/1.0 200 OK
Content-Type: text/plain
Connection: close

" FPUTS
  ['] Monitoring CATCH DROP
  StopProtocol
;
