\ 26.Nov.2002 Tue 04:26



    \ FPUTS

\  FGET ( a u -- u1 )
\  FPUT ( a u -- )
\  FPUTS ( str -- ) \ str not freed
\  FGETS ( -- str )

: ctrl ." control forth.. " CR ;

: ttt1

\  TARGET-FILE URI-DECODE

  TARGET-FILE [CHAR] / BL CONVERT

  TARGET-FILE EVALUATE

  ( TARGET-URI содержит еще "?ccc" )
;

( можно stdout перенаправить в сокет на время EVALUATE )

( на клиенте:
 S" SOURCE TYPE CR 2 3 + . CR CR" base64 
 " GET /ctrl?cmdl={s} HTTP/1.0" FPUTS
 
 \ это смысл. а снаружи так:
 RPC" ccc"

 S" ccc" RPC

)

\ результат удаленного вызова - ТЕКСТ. только текст.
\ который и передается клиенту.

\ Если cgi-процесс будет сам соединение устанавливать,
\ можно и post делать, и файл передавать на трансляцию.



\EOF

: TTT1
  BEGIN
    FGETS STYPE CR
  AGAIN
;

\EOF

\ (") ( addr u -- s )
\ FILE ( fname-addr fname-u -- addr1 u1 )


: server1
  TARGET-FILE  \ 2DUP />\
  S" *server1" WildCMP-U 0= IF

    METHOD S" POST" COMPARE 0= IF

    EVAL-FILE ( a u -- a1 u1 )


    FGETS ( -- str )

    POST-LENGTH

    vClientSocket ( -- socket )
    vConnection   ( -- socketline )

;


LocalWeb.rules.txt

 если запрос через IncludeUrl  
   (стандартный GET ) - то только кодировать команду в строке URL
   ?cmdl="qqqqqqqqqqqqqwwww"



---

TARGET-FILE S" ctrl" COMPARE 0= |

\ URI-DECODE ( a u -- a u1 )
\ %xx -> c

" HTTP/1.0 200 OK
Content-Type: text/html
Connection: close

" FPUTS

CR DumpParams CR

" URL               {URL}{CRLF}" FPUTS
" METHOD            {METHOD}{CRLF}" FPUTS
" TARGET-HOST       {TARGET-HOST}{CRLF}" FPUTS
" TARGET-FILE       {TARGET-FILE}{CRLF}" FPUTS
" TARGET-URI        {TARGET-URI }{CRLF}" FPUTS
" HTTP-COMMANDLINE  {HTTP-COMMANDLINE}{CRLF}" FPUTS
" REPLY-LINE        {REPLY-LINE}{CRLF}" FPUTS
" CONNECT-METHOD    {CONNECT-METHOD}{CRLF}" FPUTS
" URI-PREFIX        {URI-PREFIX}{CRLF}" FPUTS
" REPLY-HEADERS     {REPLY-HEADERS}{CRLF}" FPUTS
" HTTPVER           {HTTPVER}{CRLF}" FPUTS

\ URL               /sss/dd?cmdl=sssss=sss=ss
( \ TARGET-URI        /sss/dd?cmdlssssssssss )
\ why???

TRUE TO vStopProtocol
\EOF

" conf\http-proxy\wwwroot{TARGET-FILE 2DUP />\}" STR@
EVAL-FILE FPUT TRUE TO vStopProtocol

\ i.e.

URL               /poll2.html?zzz=qqq
METHOD            GET
TARGET-HOST       
TARGET-FILE       /poll2.html
TARGET-URI        /poll2.html?zzzqqq
HTTP-COMMANDLINE  GET /poll2.html?zzz=qqq HTTP/1.1
REPLY-LINE        
CONNECT-METHOD    DIRECT-CONNECTION
URI-PREFIX        
REPLY-HEADERS     
HTTPVER           HTTP/1.1
