: HTTP-MAP: { \ proxy }
  BL SKIP
  [CHAR] : PARSE " {s}" ParseNum fsockopen -> proxy
  ParseStr 2DUP
  " CONNECT {s} HTTP/1.0{CRLF}Host: {s}{CRLF}{CRLF}"
  proxy fputs
  proxy fgets STYPE
  proxy fsock vClientSocket MAP-SOCKETS
;
