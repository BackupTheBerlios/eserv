: ExtractUrl ( urla urlu -- usera useru filea fileu port hosta hostu prota protu)
  { a u \ filea fileu hosta hostu porta portu port usera useru prota protu }
  a u S" //" SEARCH NIP  a C@ [CHAR] / <> AND
  IF ( протокол задан )
     a - -> protu
     a -> prota
     u protu - 2- -> u
     a protu + 2+ -> a
  ELSE ( протокол не задан - неверный URL или это метод CONNECT)
     DROP S" connect:" -> protu -> prota
  THEN
  a u S" /" SEARCH NIP
  IF -> filea
     filea a - u SWAP - -> fileu
     filea a - -> hostu
  ELSE 
     DROP u -> hostu S" /" -> fileu -> filea
  THEN
  a -> hosta
  hosta hostu S" @" SEARCH NIP
  IF hosta -> usera
     DUP hosta - -> useru
     1+ -> hosta
     hostu useru 1+ - 0 MAX -> hostu
  ELSE DROP THEN
  hosta hostu S" :" SEARCH NIP
  IF -> porta
     porta hosta - hostu SWAP - -> portu
     porta hosta - -> hostu
     porta 1+ -> porta
     portu 1- 0 MAX -> portu
     porta portu >NUM
  ELSE DROP 
       prota protu S" http:" COMPARE-U 0= 
       IF 80 
       ELSE prota protu S" ftp:" COMPARE-U 0= 
            IF 21 ELSE 443 THEN
       THEN
  THEN -> port
  usera useru filea fileu port hosta hostu prota protu
;
: IncludeUrl ( urla urlu -- addr u ) { \ sl str filea fileu hosta hostu port usera useru prota protu }
  ExtractUrl -> protu -> prota -> hostu -> hosta -> port -> fileu -> filea -> useru -> usera
  prota protu S" http:" COMPARE-U 0<> IF S" incorrect protocol" EXIT THEN
  hosta hostu " {s}" port fsockopen -> sl
  useru IF usera useru base64 " Authorization: Basic {s}{CRLF}" STR@ 
        ELSE S" " THEN
  port 80 = IF S" " ELSE port " :{n}" STR@ THEN
  hosta hostu filea fileu
  " GET {s} HTTP/1.0{CRLF}Host: {s}{s}{CRLF}{s}User-Agent: {PROG-NAME}{CRLF}Referer: http://{Host: STR@}{URI}{CRLF}Connection: close{CRLF}{CRLF}"
  sl fputs
  BEGIN
    sl fgets STR@ NIP 0=
  UNTIL
  "" -> str
  BEGIN
    sl ['] fgets CATCH 0=
  WHILE
    str S+
    " {CRLF}" str S+
  REPEAT DROP
  str STR@
;
: IncludeLocalUri ( urla urlu -- addr u )
  User NIP IF " {User}:{Pass}@" STR@ ELSE S" " THEN
  " http://{s}{Host: STR@}{s}" STR@ IncludeUrl
;

: include: ( "url" -- addr u )
  ParseStr OVER C@ [CHAR] / =
  IF IncludeLocalUri ELSE IncludeUrl THEN
;
