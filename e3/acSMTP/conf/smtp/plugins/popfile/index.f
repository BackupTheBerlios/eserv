VARIABLE vPopFileDebug

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
: GetContentLength1
  NextWord 2DROP ParseNum
;
: GetContentLength ( addr u -- n )
  ['] GetContentLength1 EVALUATE-WITH
;
USER PopFileSocket

: IncludeUrlPost ( posta postu urla urlu -- addr u ) 
  { \ sl str filea fileu hosta hostu port usera useru prota protu cl mem pl }
  PopFileSocket @ ?DUP IF CloseSocket DROP PopFileSocket 0! THEN
  ExtractUrl -> protu -> prota -> hostu -> hosta -> port -> fileu -> filea -> useru -> usera
  prota protu S" http:" COMPARE-U 0<> IF S" incorrect protocol" EXIT THEN
  hosta hostu " {s}" port fsockopen -> sl
  sl fsock PopFileSocket !
  600000 sl fsock SetSocketTimeout THROW
  ( posta postu) DUP
  useru IF usera useru base64 " Authorization: Basic {s}{CRLF}" STR@ 
        ELSE S" " THEN
  port 80 = IF S" " ELSE port " :{n}" STR@ THEN
  hosta hostu filea fileu
  " POST {s} HTTP/1.0
Host: {s}{s}
{s}User-Agent: {PROG-NAME}
Content-Type: text/xml
Content-length: {n}
Connection: close{CRLF}{CRLF}{s}"
  sl fputs
  BEGIN
    sl fgets STR@
    2DUP S" Content-Length: " SEARCH NIP NIP
    IF 2DUP GetContentLength -> cl THEN
    NIP 0=
  UNTIL

  cl sl SocketReadFromPending -> pl ( addr )
  cl ALLOCATE THROW -> mem
  ( addr ) mem pl MOVE

  cl pl - 0 MAX -> cl

  mem pl + cl sl fsock read
  sl fclose
  PopFileSocket 0!
  mem pl cl +
;
: PopFileConvertResult ( addr u -- addr2 u2 )
  2DUP 8 MIN S" <string>" COMPARE 0= IF 17 - SWAP 8 + SWAP EXIT THEN
  2DUP 4 MIN S" <i4>" COMPARE 0= IF 9 - SWAP 4 + SWAP EXIT THEN
  2DUP 8 MIN S" <base64>" COMPARE 0= IF 17 - SWAP 8 + SWAP debase64 EXIT THEN
;
VARIABLE POPFILE-MUT

: PopFileCall ( addr u -- addr u ) { a1 u1 \ a u l err }

  POPFILE-MUT @ 0= 
  IF " ESERV-POPFILE-MUT" STR@ FALSE CREATE-MUTEX THROW POPFILE-MUT !
    WinNT? 
    IF
      CreateEveryoneACL ?DUP
      IF NIP " ACL: {n}" TYPE CR
      ELSE
         POPFILE-MUT @ SetObjectACL DROP
      THEN
    THEN
  THEN

  -1 POPFILE-MUT @ WAIT THROW DROP

  a1 u1 S" http://localhost:8081/RPC2" ['] IncludeUrlPost CATCH
  IF 2DROP 2DROP 500 PAUSE
     a1 u1 S" http://localhost:8081/RPC2" ['] IncludeUrlPost CATCH -> err
     err IF 2DROP 2DROP err " <Error {n}>" STR@ THEN
  THEN

  vPopFileDebug @ IF CR 2DUP TYPE CR THEN
  PopFileSocket @ ?DUP IF CloseSocket DROP PopFileSocket 0! THEN

  S" <param><value>" DUP -> l SEARCH
  IF l - 0 MAX SWAP l + SWAP 2DUP -> u -> a
     S" </value></param>" SEARCH
     IF NIP u SWAP - a SWAP
        PopFileConvertResult
     THEN
  THEN

  POPFILE-MUT @ RELEASE-MUTEX DROP
;
: PopFileClassify ( filea fileu -- addr u )
vPopFileDebug @ IF 2DUP TYPE CR THEN
" <?xml version={''}1.0{''}?>
<methodCall>
   <methodName>Classifier/Bayes.classify</methodName>
   <params>
      <param>
         <value><string>{s}</string></value>
         </param>
      </params>
   </methodCall>
" STR@
  PopFileCall
;
: PopFileClassificationMatch { filea fileu addr u -- flag }
  filea fileu PopFileClassify
  addr u COMPARE-U 0=
;
\ S" spam.txt" S" spam" PopFileClassificationMatch .

: PopFileHistoryFilename ( -- addr u )
" <?xml version={''}1.0{''}?>
<methodCall>
   <methodName>Classifier/Bayes.history_filename</methodName>
   <params>
      <param>
         <value><i4>{CurrentThreadNumber}</i4></value>
      </param>
      <param>
         <value><i4>{uMCNT @}</i4></value>
      </param>
      <param>
         <value><string>.msg</string></value>
      </param>
      <param>
         <value><i4>1</i4></value>
      </param>
   </params>
</methodCall>
" STR@
  PopFileCall
;
\ PopFileHistoryFilename TYPE
: PopFileAddToBucket ( filea fileu addr u -- addr u )
\  2SWAP 1.162&r2=1.173 - расскомментировать, если bayes.pm версии ниже 1.173
" <?xml version={''}1.0{''}?>
<methodCall>
   <methodName>Classifier/Bayes.add_message_to_bucket</methodName>
   <params>
      <param>
         <value><string>{s}</string></value>
      </param>
      <param>
         <value><string>{s}</string></value>
      </param>
   </params>
</methodCall>
" STR@
  PopFileCall
;
\ S" spam.txt" S" spam" PopFileAddToBucket TYPE
: PopFileDelFromBucket ( filea fileu addr u -- addr u )
\  2SWAP 1.162&r2=1.173 - расскомментировать, если bayes.pm версии ниже 1.173
" <?xml version={''}1.0{''}?>
<methodCall>
   <methodName>Classifier/Bayes.remove_message_from_bucket</methodName>
   <params>
      <param>
         <value><string>{s}</string></value>
      </param>
      <param>
         <value><string>{s}</string></value>
      </param>
   </params>
</methodCall>
" STR@
  PopFileCall
;
: PopFileColorMessage ( filea fileu -- addr u )
" <?xml version={''}1.0{''}?>
<methodCall>
   <methodName>Classifier/Bayes.get_html_colored_message</methodName>
   <params>
      <param>
         <value><string>{s}</string></value>
      </param>
   </params>
</methodCall>
" STR@
  PopFileCall
;
\ S" spam2.txt" PopFileColorMessage TYPE
\ S" spam.txt" S" clear" PopFileAddToBucket .( ==>) TYPE .( <==)
