: HTTP-REDIRECT
  " HTTP/1.0 302 Moved
Server: {PROG-NAME}
Location: {REDIRECT-TO}
Content-Type: text/html
Pragma: no-cache
Connection: close

<html><body><a href={REDIRECT-TO}>Moved here</a></body></html>
" FPUTS StopProtocol
  302 TO vHttpReplyCode
;

: UrlRedirect
  URL ParseStr WildCMP-U 0=
  IF S" HTTP-REDIRECT" SetAction
     ParseStr $REDIRECT-TO S!
  ELSE POSTPONE \ THEN
;
