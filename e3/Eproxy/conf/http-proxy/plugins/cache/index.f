\ : TT SOURCE TYPE CR ; ' TT TO <PRE>
USER uCURRENT-CACHE-FILE     \ ����� �����, ���� ������������ �����������
USER $CURRENT-CACHE-FILENAME \ ��� ����� ����� (����)
USER uCACHED-FILE            \ ����� ����� � ����, ��������� �� ������
USER uCACHED-FILE-AGE        \ ������� � ���� ����� ����� (����)
USER-VALUE vNO-CACHE         \ �� ������ �� ����
USER-VALUE vNO-WCACHE        \ �� ���������� � ���

USER uAV-CHECKED             \ �������� �����������
VECT vAvScanFile :NONAME 2DROP S" " 0 ; TO vAvScanFile

: AvScanFile2
  ['] vAvScanFile CATCH 
  ?DUP IF ( ." ERR:" .) 439 LOG 2DROP S" " 0 THEN
;
VARIABLE uCACHE-DIR

: CACHE-DIR uCACHE-DIR @ STR@ ;
: CURRENT-CACHE-FILENAME 
  $CURRENT-CACHE-FILENAME @ 
  ?DUP IF STR@ ELSE S" " THEN
;
: SetCacheDir uCACHE-DIR S! ;

: FileIsOlderThan: ( -- flag )
  ParseNum uCACHED-FILE-AGE @ <
;

: URL>PATH { a u -- a u }
  a u + 1- C@ [CHAR] / = IF S" __" a u + SWAP MOVE u 2+ -> u THEN
  a 2+ u 2- 0 MAX S" .." SEARCH NIP
  IF S" __" ROT SWAP MOVE ELSE DROP THEN
  a u S" :" SEARCH NIP OVER a 1+ <> AND
  IF [CHAR] _ SWAP C! ELSE DROP THEN
  0 a u + C!
  a u
;
: TPORT
  TARGET-PORT 80 = IF S" " EXIT THEN
  TARGET-PORT
;
: CachedFileName ( -- addr u )
  TARGET-HOST DROP 4 S" www." COMPARE-U 0=
  IF " {CACHE-DIR}\{TARGET-HOST DROP 4 + 1}\{TARGET-HOST DROP 5 + 1}\{TARGET-HOST}{TPORT}{TARGET-URI}"
  ELSE " {CACHE-DIR}\{TARGET-HOST DROP 1}\{TARGET-HOST DROP 1 + 1}\{TARGET-HOST}{TPORT}{TARGET-URI}"
  THEN
  STR@ URL>PATH
;
: CreateCachedFile
  uAV-CHECKED 0!
  vHttpReplyCode 200 <> IF EXIT THEN
  METHOD S" GET" COMPARE 0<> IF EXIT THEN
  vNO-WCACHE IF EXIT THEN
  TARGET-PROT S" http:" COMPARE 0<> IF EXIT THEN

  CachedFileName 2DUP />\
  2DUP $CURRENT-CACHE-FILENAME S!
  R/W CREATE-FILE-PATH
  IF DROP uCURRENT-CACHE-FILE 0! 
     $CURRENT-CACHE-FILENAME 0!
  ELSE uCURRENT-CACHE-FILE ! THEN
;
: DeleteCachedFile
  $CURRENT-CACHE-FILENAME @ STR@ DELETE-FILE DROP
  TRUE uAV-CHECKED ! \ ����� ������������� ���� �� ������� ����������
;
: CloseFileInCache
  uCACHED-FILE @ ?DUP 
  IF CLOSE-FILE DROP
     uCACHED-FILE 0!
  THEN
;
: CloseCachedFile
  uCURRENT-CACHE-FILE @ ?DUP 
  IF CLOSE-FILE DROP 
     uREADBODY-ERROR @ 
     CONTENT-LENGTH uLENGTH @ <> CONTENT-LENGTH MAX-INT <> AND
     OR \ true, ���� ����� ������� ���������� ����

     uAV-CHECKED @ 0=
     uLAST-CHUNK @ 0= AND \ ���� LAST-CHANK=true, �� ���� ���������� �����
     IF
        uScan? @
        IF
          CURRENT-CACHE-FILENAME AvScanFile2
          TRUE uAV-CHECKED !
          IF ( virusname) S" Yes" 2SWAP 434 LOG
             TRUE
          ELSE
             2DROP 440 LOG \ ��� ������
             FALSE 
          THEN
          OR
        THEN
     THEN

     IF DeleteCachedFile THEN
     uCURRENT-CACHE-FILE 0!
  THEN
  CloseFileInCache
;
: OnBodyStart1
  CreateCachedFile
  " {REPLY-LINE}{CRLF}{REPLY-HEADERS}{CRLF}" STR@
  uCURRENT-CACHE-FILE @
  ?DUP IF WRITE-FILE THROW ELSE 2DROP THEN
;
: OnBodyEnd1
  CloseCachedFile
;
: OnBodyEndError1
  CloseCachedFile
;
: IsCachedFile ( -- flag )
  METHOD S" GET" COMPARE 0<> IF FALSE EXIT THEN
  vNO-CACHE vNO-WCACHE OR IF FALSE EXIT THEN
  TARGET-PROT S" http:" COMPARE 0<> IF FALSE EXIT THEN

  CachedFileName R/O OPEN-FILE-SHARED
  IF DROP uCACHED-FILE 0! 
     MAX-INT uCACHED-FILE-AGE !
     FALSE
  ELSE
     DUP uCACHED-FILE !
     DAYS-OLD uCACHED-FILE-AGE ! 
     TRUE
  THEN
;
: Header-IfModified
  uCACHED-FILE @ ?DUP
  IF >R 0 0 <# R> FileDateTime#GMT #>
     " If-Modified-Since: {s}" 
  ELSE "" THEN STR@
;
: ReadCachedReplyHeader { mem \ str i -- str }
  MAX-INT SetContentLength
  "" -> str
  0 -> i
  BEGIN
    mem 1000 uCACHED-FILE @ READ-LINE THROW
    OVER 0<> AND
  WHILE
    i 0= IF mem OVER SetReplyLine
            mem 9 + 3 >NUM TO vHttpReplyCode
         ELSE mem OVER " {s}" InterpretReplyLine THEN
    mem SWAP str STR+ CRLF str STR+
    i 1+ -> i
  REPEAT DROP
  str
;
: ReadCachedHeader ( mem -- )
  ReadCachedReplyHeader
  CONTENT-LENGTH MAX-INT =
  IF ( ����� ����������, keep-alive ���������� )
    StopProtocol
  THEN
  vStopProtocol 
  IF vHttpReplyCode IF " Proxy-Connection: close{CRLF}" OVER S+ THEN
  ELSE " Proxy-Connection: Keep-Alive{CRLF}" OVER S+ THEN
  DUP CRLF ROT STR+
  FPUTS
;


: TCP_HIT { \ mem }
  1000 ALLOCATE THROW -> mem
  mem ['] ReadCachedHeader CATCH IF DROP THEN \ 15.05.2003: ������ ��� �����������
  mem uCACHED-FILE @ ['] PutFile CATCH DUP IF NIP NIP THEN
  mem FREE THROW
  CloseFileInCache
  THROW
;
: RefreshCacheObject { \ header }
  SendRequestHttp
  ['] ReadHeaderHttp CATCH
  IF ( ReadHeadersError)
     S" TCP_REFRESH_FAIL_HIT" SetAction
     DisconnectTarget TCP_HIT EXIT \ ���� �� ������ ��������, ������ �� ����
  THEN
  -> header
  vHttpReplyCode 304 = \ 304 Not modified
  IF uCACHED-FILE @ \ � ���� ��������� ������, � �� ���������
     IF
       DisconnectTarget S" TCP_REFRESH_HIT" SetAction
       TCP_HIT EXIT \ �� ���������, ������ �� ����
     ELSE
       DisconnectTarget S" TCP_REFRESH_BHIT" SetAction
       header FPUTS
       EXIT
     THEN
  THEN
  \ ���� ����� ������, ��������� ���:
  S" TCP_REFRESH_MISS" SetAction
  CloseFileInCache
  header FPUTS
  ReadBodyHttp \ �� �������� OnBodyStart, OnBodyEnd
;
: TCP_REFRESH
  Header-IfModified +OptionalHeaders
  ['] ConnectTarget CATCH
  IF ( ConnectError)
     S" TCP_REFRESH_FAIL_HIT" SetAction
     DisconnectTarget TCP_HIT EXIT \ ���� �� ������ �����������, ������ �� ����
  THEN
  ['] RefreshCacheObject CATCH
  DisconnectTarget THROW
;
: SendFromCache
  S" TCP_HIT" SetAction
;
: RefreshCache
  S" TCP_REFRESH" SetAction
;
: TCP_CLIENT_REFRESH TCP_MISS ;

: FPUT-cache
  uCURRENT-CACHE-FILE @
  ?DUP IF >R 2DUP R> WRITE-FILE THROW
          uScan? @ uAV-CHECKED @ 0= AND
          IF uLAST-CHUNK @
             IF 
                CloseCachedFile \ ����� ��������� �� ����� �������
                uAV-CHECKED @ 0=
                IF
                  CURRENT-CACHE-FILENAME AvScanFile2
                  TRUE uAV-CHECKED !
                  IF 2DUP ( virusname) S" No" 2SWAP 434 LOG
                     FPUT 2DROP 
                     DeleteCachedFile
                     -4900 THROW
                  ELSE 2DROP 440 LOG THEN
                THEN
             THEN
          THEN
       THEN
  FPUT
;
\ ==================================== �������������� ��������� �������� ===
IN-PROTOCOL: HTTP-PROXY

: PRAGMA:
  NextWord S" no-cache" COMPARE-U 0=    \ �� ����� �� ����, ���� � ������� ����
  IF TRUE TO vNO-CACHE                  \ ������ Pragma: no-cache
     S" TCP_CLIENT_REFRESH" SetAction
  THEN             
  +Headers
;
: CACHE-CONTROL:
  NextWord S" no-cache" COMPARE-U 0=    \ �� ����� �� ����, ���� � ������� ����
  IF TRUE TO vNO-CACHE                  \ ������ Cache-Control: no-cache
     S" TCP_CLIENT_REFRESH" SetAction
  THEN
  +Headers
;
: AUTHORIZATION:                        \ �� ����������, ���� ��������������
  TRUE TO vNO-WCACHE                    \ ����������� � �������
  +Headers
;
\ : COOKIE:                               \ �� ����������, ���� ����
\   TRUE TO vNO-WCACHE                    \ Cookie � ������� (����� ����� ����������� ��� ������ �������������
\   +Headers                              \ � � Cookie ����� ���� �����������)
\ ;
\ ����� ��� ����� ���������� Cookie :(

PROTOCOL;

\ ==================================== �������������� ��������� ������� ===
GET-CURRENT HTTP-REPLY-HEADERS SET-CURRENT

: SET-COOKIE:                           \ �� ����������, ���� � ������ ����
  TRUE TO vNO-WCACHE                    \ ������ Set-Cookie: ...
;
: CACHE-CONTROL:                        \ �� ����������, ���� � ������ ����
  SOURCE S" max-age=0" SEARCH NIP NIP   \ ������ Cache-Control: ...
  IF TRUE TO vNO-WCACHE EXIT THEN
  SOURCE S" no-" SEARCH NIP NIP
  IF TRUE TO vNO-WCACHE EXIT THEN
  SOURCE S" private" SEARCH NIP NIP
  IF TRUE TO vNO-WCACHE EXIT THEN
;

SET-CURRENT

