\ High perfomance SSI processor for Eserv 3.0
\ (c) Dmitry Yakimov 2002

\ SSI can be multi-lined

\ Supported instructions:
\ #printenv
\ #echo
\ #include
\ #fsize
\ #flastmod


WORDLIST CONSTANT SSI-COMMANDS
USER $OUT-STR

: SSI-FPUT
   $OUT-STR @ STR+
;

WINAPI: CharLowerBuffA USER32.DLL
\ WINAPI: GetFileTime KERNEL32.DLL
WINAPI: FileTimeToLocalFileTime KERNEL32.DLL
\ WINAPI: FileTimeToSystemTime KERNEL32.DLL


USER-CREATE lpLWT
8 USER-ALLOT

USER-CREATE lpLocalTime
8 USER-ALLOT

USER-CREATE SYSTIME
/SYSTEMTIME USER-ALLOT

: GetFileDate ( addr u -- str )
  { \ f }
  R/O OPEN-FILE-SHARED
  IF DROP ""
  ELSE -> f
     lpLWT 0 0
     f GetFileTime DROP
     f CLOSE-FILE THROW
     lpLocalTime lpLWT FileTimeToLocalFileTime DROP
     SYSTIME lpLocalTime FileTimeToSystemTime DROP
     SYSTIME 12 + W@ 
     SYSTIME 10 + W@ 
     SYSTIME 8 + W@ 
     SYSTIME 6 + W@ 
     SYSTIME 2 + W@ 
     SYSTIME W@ 
     <# DateTime# 0. #> "" DUP >R STR+ R>
  THEN
;

: LowerCase ( addr u -- addr u )
   2DUP SWAP CharLowerBuffA DROP
;
  
: SKIPN ( addr u n -- addr1 u1 )
   2DUP 1+ <
   IF DROP DUP THEN
   >R R@ -
   SWAP R> + SWAP
;

: ParseTag ( addr1 u1 addr2 u2 -- addr3 u3 -1 | 0 )
\ addr1 u1 - stream string
\ addr2 u2 - a tag to be found
\ addr3 u3 - a tag value without quotes
   DUP >R
   SEARCH DUP
   IF
     DROP
     R@ SKIPN
     OVER C@ [CHAR] = = IF 1 SKIPN THEN
     OVER C@ [CHAR] " = IF 1 SKIPN THEN
     2DUP [CHAR] " >R RP@ 1 SEARCH RDROP
     IF DROP NIP
        OVER - TRUE
     ELSE 2DROP FALSE
     THEN
   THEN RDROP
;

: REPLACE ( c-addr u c1 c2 -- c-addr u )
\ c1 -> c2
  2SWAP
  OVER + SWAP
  DO
    OVER I C@ =
    IF DUP I C! THEN
  LOOP 2DROP
;

: WebFilePath ( addr u -- str_filename )
  { \ str }
  "" -> str
  ROOT_DIR str STR+
  OVER C@ [CHAR] \ <> IF S" \" str STR+ THEN
  str STR+ str
;

: GetDir ( addr u -- addr1 u1 )
  2DUP
  BEGIN
    S" \" SEARCH DUP
    IF
      >R 1- SWAP 1+ SWAP R>
    THEN
    0=
  UNTIL
  NIP -
;

: ExecSSICommand { xt }
   S" virtual" ParseTag
   IF
     S" .." SEARCH IF 2DROP EXIT THEN
     WebFilePath STR@ 
     xt EXECUTE
     SSI-FPUT EXIT
   THEN
   S" file" ParseTag
   IF
     S" .." SEARCH IF 2DROP EXIT THEN
     FILENAME GetDir 
     "" DUP >R
     STR+ R@ STR+
     R> STR@ xt EXECUTE SSI-FPUT
   THEN
;

: INCLUDE_SSI ( addr u -- addr1 u1 )
   FILE
;

: FSIZE_SSI ( addr u -- addr1 u1 )
  { \ f  }
  R/O OPEN-FILE-SHARED
  IF DROP S" "
  ELSE -> f
     f FILE-SIZE THROW D>S
     f CLOSE-FILE THROW
  THEN 0 <# #S #>
;

: FLASTMOD_SSI ( addr u -- addr1 u1 )
   GetFileDate STR@
;

\ SSI commands

GET-CURRENT
SSI-COMMANDS SET-CURRENT 

: printenv ( addr u -- )
   2DROP CgiEnvir 2DUP 0 0x0A REPLACE SSI-FPUT
;

: echo
   S" var" ParseTag
   IF
     DUP 1+ >R
     CgiEnvir 2SWAP SEARCH
     IF
       DROP R@ + ASCIIZ> SSI-FPUT
     ELSE 2DROP
     THEN RDROP
   THEN
;

: include
  ['] INCLUDE_SSI ExecSSICommand
;

: flastmod ( addr u )
  ['] FLASTMOD_SSI ExecSSICommand
;

: fsize
  ['] FSIZE_SSI ExecSSICommand
;

SET-CURRENT

: ExecSSI ( addr1 u1 addr2 u2 - addr1 u1 0 | -1  )
   SWAP OVER PAD SWAP CMOVE
   PAD SWAP LowerCase SSI-COMMANDS SEARCH-WORDLIST
   IF EXECUTE TRUE 
   ELSE FALSE
   THEN
;

: SelectCommand ( addr u -- addr1 u1 addr2 u2 )
  { \ c-a c-u }
\ until space or eof
  OVER -> c-a
  BEGIN
    OVER C@ BL =
    IF
      c-a c-u -1
    ELSE ^ c-u 1+!
      1 SKIPN DUP 0=
    THEN
  UNTIL
;

: ProcessSSI1 { addr u }
   addr u                         
   BEGIN
     S" <!--#" SEARCH
     IF
       2DUP S" -->" SEARCH
       IF
         3 SKIPN
         2SWAP
         OVER addr -
         addr SWAP SSI-FPUT

         5 SKIPN
         SelectCommand 
         
         \ Only ssi body
         2>R DROP
         >R OVER R@ - R> SWAP 2R>
          
         ExecSSI 0=
         IF
           DROP 8 -
           >R OVER R>
           SWAP OVER - SSI-FPUT
         THEN
       ELSE
         2DROP 5 SKIPN
         OVER addr -
         addr SWAP SSI-FPUT
       THEN OVER -> addr
       FALSE 
     ELSE 
       SSI-FPUT TRUE 
     THEN
   UNTIL
;

: ProcessSSI
   "" $OUT-STR !
   ProcessSSI1
   $OUT-STR @ STR@
;

: SEND_SSI_FILE_HEADER { size \ out }
  200 PostResponse
  nHTTP_VERSION @ 10 >
  IF  " HTTP/1.1 200 OK{CRLF}" ELSE " HTTP/1.0 200 OK{CRLF}" THEN -> out
  " Content-Length: {#size}{CRLF}Connection: " out S+
  vStopProtocol
  IF " close" ELSE " Keep-Alive" THEN out S+
  " {CRLF}Content-Type: {CONTENT-TYPE}{CRLF}Server: Eserv/3.x{CRLF}{CRLF}" out S+
  out ['] FPUTS CATCH IF DROP THEN
;

: FPUT-DATA { addr u }
   u 1000 /
   0 ?DO addr I 1000 * + 1000 FPUT LOOP
   u 1000 MOD
   addr u + OVER - SWAP FPUT
;

: SEND_SSI_ANSWER { \ mem h len -- }
  FILESIZE -> len
  len ALLOCATE THROW -> mem
  FILENAME R/O OPEN-FILE-SHARED THROW -> h
  mem len h READ-FILE THROW DROP
  h CLOSE-FILE THROW
  mem len ProcessSSI 

  $OUT-STR @ STR@ NIP SEND_SSI_FILE_HEADER

  ['] FPUT-DATA CATCH DUP
  IF NIP NIP THEN
  mem FREE THROW
  $OUT-STR @ STRFREE
  THROW
;

: PROCESS_SSI
  FilenameExists
  IF SEND_SSI_ANSWER
  ELSE SendFile
  THEN
;

: SSI
   S" PROCESS_SSI" $ACTION S!
;
            