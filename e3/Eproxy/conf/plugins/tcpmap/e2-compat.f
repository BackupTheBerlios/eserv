: TCPMAP: { \ proxy }
  BL SKIP
  [CHAR] : PARSE " {s}" ParseNum fsockopen -> proxy
  ParseStr 2DUP
  " CONNECT {s} HTTP/1.0{CRLF}Host: {s}{CRLF}{CRLF}"
  proxy fputs
  proxy fgets STYPE
  proxy fsock vClientSocket MAP-SOCKETS
;
VARIABLE TCPMAPPINGS

0
4 -- tmLink
4 -- tmPort
4 -- tmToPort
4 -- tmToIP
0 -- tmToAddr
CONSTANT /tm

: TCPMAP: { \ mem }
  Port: BL PARSE0 Port: 
  OVER /tm + CHAR+ ALLOCATE THROW -> mem
  mem tmToPort !
  mem tmToAddr SWAP CHAR+ MOVE
  mem tmPort !
  mem tmToIP 0!
  TCPMAPPINGS @ mem tmLink !
  mem TCPMAPPINGS !
;
: IsTcpMappedPort { port -- tm true |  false }
  TCPMAPPINGS @
  BEGIN
    DUP
  WHILE
    DUP tmPort @ port = IF TRUE EXIT THEN
    tmLink @
  REPEAT
;
