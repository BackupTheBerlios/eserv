USER $Pop3proxyUser
USER $Pop3proxyHost

PROTOCOL: POP3PROXY
: USER
  SOURCE S" :" SEARCH NIP NIP
  IF
    [CHAR] : PARSE $Pop3proxyHost S!
    NextWord $Pop3proxyUser S!
  ELSE
    SOURCE S" @" SEARCH NIP NIP
    IF [CHAR] @ PARSE $Pop3proxyUser S!
       NextWord $Pop3proxyHost S!
    ELSE " -ERR Please use user@host or host:user syntax{CRLF}" FPUTS EXIT
    THEN
  THEN
  $Pop3proxyHost @ 110 ['] fsockopen CATCH
  ?DUP IF DUP ErrorMessage 2-
          $Pop3proxyHost @ STR@
          " -ERR Unable to connect to {s}, error={s} ({n}){CRLF}" FPUTS EXIT
       ELSE SetTargetConn THEN
  TARGET-CONN ['] fgets CATCH
  ?DUP IF DUP ErrorMessage 2-
          $Pop3proxyHost @ STR@
          " -ERR Error while reading from {s}, error={s} ({n}){CRLF}" FPUTS EXIT
       THEN
  DUP STR@ 3 MIN S" +OK" COMPARE-U 0<>
  IF STR@ $Pop3proxyHost @ STR@ " -ERR Unexpected string from {s}: {s}{CRLF}" FPUTS EXIT THEN
  DROP
  $Pop3proxyUser @ STR@ " USER {s}{CRLF}" ['] TPUTS CATCH
  ?DUP IF DUP ErrorMessage 2-
          $Pop3proxyHost @ STR@
          " -ERR Error while writing to {s}, error={s} ({n}){CRLF}" FPUTS EXIT
       THEN
  TARGET-CONN fsock vClientSocket ['] MAP-SOCKETS CATCH
  TARGET-CONN ['] fclose CATCH DROP
  CloseConnection
;
: QUIT
  " +OK disconnecting...{CRLF}" FPUTS
  CloseConnection
;
: NOTFOUND
  " -ERR Unknown command{CRLF}" FPUTS
;
: UseThreadConnect ;
PROTOCOL;
