( 
  Error codes:
  -5001 wrong welcome string
  -5002 wrong user
  -5003 wrong pass
  -5004 wrong 'quit' reply
  -5005 wrong 'stat' reply
  -5006 wrong 'list' reply
  -5007 wrong 'top'  reply
  -5008 wrong 'retr' reply
  -5009 wrong 'dele' reply
  -6008 wrong smtp reply
  -6009 wrong 'helo' reply
)
REQUIRE inList conf/plugins/pop2smtp/list.f
REQUIRE PopSetCurrentMsgid conf/plugins/pop2smtp/msgid.f

USER uRECIPIENTS
USER uSENDERS
VARIABLE vPop2SmtpDebug SMTP[Pop2SmtpDebug] >FLAG vPop2SmtpDebug !

\ ===========
\ USER $HEADER-NAME
\ USER $HEADER-STR
\ : SetHeader ( addr u -- ) $HEADER-STR S! ;
\ : HEADER-STR  $HEADER-STR  @ STR@ ;
\ : HEADER-NAME $HEADER-NAME @ STR@ ;
\ : HSKIP ( addr u -- addr2 u2 )
\ отрезать название заголовка
\   S" : " SEARCH
\   IF 2- 0 MAX SWAP 2+ SWAP THEN
\ ;
\ ===========

: PopLine ( sl -- str )
  fgets
  vPop2SmtpDebug @ IF DUP STR@ TYPE CR THEN
;
: SmtpLine ( s -- str )
  fgets
  vPop2SmtpDebug @ IF DUP STR@ TYPE CR THEN
;
: PopReply ( -- str n flag )
  NextWord S" +OK" COMPARE-U \ flag = true, if code<>"+OK"
  ParseNum 1 PARSE " {s}"
  SWAP ROT
;
: SmtpReply ( -- n flag )
  SOURCE NIP 4 < IF -6008 THROW THEN
  TIB 3 + C@ IsDelimiter \ flag = true for the last line in a multiline reply
  BL TIB 3 + C!
  ParseNum DUP 100 600 WITHIN 0= IF -6008 THROW THEN
  POSTPONE \
  SWAP
;
: SmtpReplyCode { s \ str -- str n }
  "" -> str
  BEGIN
    s SmtpLine STR@ 2DUP " {$str}{s}{CRLF}" -> str
    " {s}" STR@ ['] SmtpReply EVALUATE-WITH
    DUP 0= IF NIP THEN
  UNTIL
  str SWAP
;
: PopLineErr ( sl -- flag )
  PopLine STR@ ['] PopReply EVALUATE-WITH
  NIP NIP
;
: PopCommand { str sl -- }
  vPop2SmtpDebug @ IF str STR@ TYPE THEN
  str sl fputs
;
: SmtpCommand { str s -- }
  vPop2SmtpDebug @ IF str STR@ TYPE THEN
  str s fputs
;
: PopCommandReply { str sl -- str n flag }
  str sl PopCommand
  sl PopLine STR@ ['] PopReply EVALUATE-WITH
;
: SmtpCommandReply { str s -- str n }
  str s SmtpCommand
  s SmtpReplyCode
;
: PopCommandErr ( str sl -- flag )
  PopCommandReply NIP NIP
;
: PopConnect ( server port -- sl )
  fsockopen
  DUP fsock 600000 SWAP SetSocketTimeout THROW
  DUP PopLineErr IF -5001 THROW THEN
;
: SmtpConnect ( server port -- s )
  fsockopen
  DUP fsock 600000 SWAP SetSocketTimeout THROW
  DUP SmtpReplyCode 200 300 WITHIN 0= IF -6001 THROW THEN DROP
\  " HELO localhost{CRLF}" OVER SmtpCommandReply
  " HELO pop2smtp{CRLF}" OVER SmtpCommandReply
  200 300 WITHIN 0= IF -6009 THROW THEN DROP
;
: PopDisconnect ( sl -- )
  fclose
;
: SmtpDisconnect ( sl -- )
  fclose
;
: PopLogin { pop3user pop3pass sl -- }
  " USER {$pop3user}{CRLF}" sl PopCommandErr IF -5002 THROW THEN
  " PASS {$pop3pass}{CRLF}" sl PopCommandErr IF -5003 THROW THEN
;
: SmtpLogin { smtpuser smtppass s -- }
;
: PopLogout { sl -- }
  " QUIT{CRLF}" sl PopCommandErr IF -5004 THROW THEN
;
: SmtpLogout { sl -- }
  " QUIT{CRLF}" sl SmtpCommandReply 200 300 WITHIN 0= IF -6004 THROW THEN DROP
;
: PopListItem { lst \ mem -- flag lst }
  SOURCE S" ." COMPARE 0= IF 0 FALSE EXIT THEN
  ParseNum ParseNum
  3 CELLS ALLOCATE THROW -> mem
  mem CELL+ CELL+ !
  mem CELL+ !
  lst mem ! mem -> lst
  lst TRUE
;
: PopReadList { sl \ lst -- lst }
  " LIST{CRLF}" sl PopCommandErr IF -5006 THROW THEN
  BEGIN
    lst sl PopLine STR@ ['] PopListItem EVALUATE-WITH
  WHILE
    -> lst
  REPEAT
  DROP lst
;
: PopList { sl -- lst }
  " STAT{CRLF}" sl PopCommandReply IF -5005 THROW THEN
  NIP 0<>
  IF sl PopReadList
  ELSE 0 THEN
;
: PopGetHdrX ( -- hdr hdrt )
  [CHAR] : PARSE " {s}" SOURCE " {s}"
;
: PopGetHdr ( addr u -- hdr hdrt )
  ['] PopGetHdrX EVALUATE-WITH
;
: PopEvalHdrRules ( hdr hdrt -- )
  SWAP STR@ $HEADER-NAME S!
  STR@ SetHeader
  S" plugins\pop2smtp\headers\HEADER" EvalRules
;
: PopHeaderString { hdr hdrt str -- hdr hdrt addr2 u2 }
  str STR@
  DUP 0= IF 2DROP
            hdr IF hdr hdrt PopEvalHdrRules
                   hdr STRFREE hdrt STRFREE
                   HEADER-STR DUP IF " {s}{CRLF}{CRLF}" STR@ THEN
                ELSE CRLF THEN
            S" plugins\pop2smtp\headers\HEADER-END" EvalRules
\            TRUE -> body
            0 0 2SWAP
         ELSE
            OVER C@ IsDelimiter 
                      IF hdrt ?DUP 
                         IF STR@ " {s}{CRLF}{s}" ELSE " {s}" THEN
                         -> hdrt 0 0
                      ELSE hdr IF hdr hdrt PopEvalHdrRules
                                  hdr STRFREE hdrt STRFREE
                                  HEADER-STR DUP IF " {s}{CRLF}" STR@ THEN
                               ELSE 0 0 THEN
                           2SWAP PopGetHdr -> hdrt -> hdr
                      THEN
            hdr hdrt 2SWAP
         THEN
;
: PopRecvMsg { n sl \ top hdr hdrt -- top }
  n " TOP {n} 0{CRLF}" sl PopCommandErr IF -5007 THROW THEN
  uRECIPIENTS FreeList
  uSENDERS FreeList
  "" -> top
  hdr hdrt
  BEGIN
    sl PopLine DUP STR@ S" ." COMPARE 0<>
  WHILE
    PopHeaderString
    top STR+
  REPEAT
  DROP 2DROP
  top
;
: PopDelMsg { n sl -- }
  n " DELE {n}{CRLF}" sl PopCommandErr IF -5009 THROW THEN
;
: SmtpRcpt ( s addr u -- s flag )
  " RCPT TO:<{s}>{CRLF}" OVER SmtpCommandReply NIP
  200 300 WITHIN
;
: SmtpRcpt+ ( vrcpt s node -- vrcpt s )
  NodeValue XCOUNT SmtpRcpt
  IF SWAP 1+ SWAP THEN
;
: SmtpSendMsgBody { n top sl s -- flag }
  " DATA{CRLF}" s SmtpCommandReply 300 400 WITHIN NIP 0= IF FALSE EXIT THEN
  n " RETR {n}{CRLF}" sl PopCommandErr IF -5008 THROW THEN
  top s SmtpCommand
  BEGIN
    sl PopLine STR@ NIP 0=
  UNTIL
  BEGIN
    sl PopLine STR@ 2DUP
    " {s}{CRLF}" s SmtpCommand
    S" ." COMPARE 0=
  UNTIL
  s SmtpReplyCode NIP 200 300 WITHIN
;
: SmtpSaveMsg1 { n sl f -- }
  n " RETR {n}{CRLF}" sl PopCommandErr IF -5008 THROW THEN
  BEGIN
    sl PopLine STR@ 2DUP
    f WRITE-FILE THROW CRLF f WRITE-FILE THROW
    S" ." COMPARE 0=
  UNTIL
;
: SmtpSaveMsg { n sl \ f -- }
  S" Pop2Smtp[FileName]" EVALUATE R/W CREATE-FILE-PATH THROW
  -> f
  n sl f ['] SmtpSaveMsg1 CATCH IF 2DROP DROP THEN
  f CLOSE-FILE THROW 
;
: SmtpSendMsg { n top eml sl s \ vrcpt -- flag }
  uSENDERS @ 
  ?DUP IF NodeValue XCOUNT " MAIL FROM:<{s}>{CRLF}" 
       ELSE " MAIL FROM:<>{CRLF}" THEN
  s SmtpCommandReply
  200 300 WITHIN NIP 0= IF FALSE EXIT THEN
  vrcpt s ['] SmtpRcpt+ uRECIPIENTS DoList
  DROP -> vrcpt
  vrcpt 0=
  IF s eml STR@ ?DUP
     IF SmtpRcpt NIP IF vrcpt 1+ -> vrcpt THEN 
     ELSE 2DROP THEN
  THEN
  vrcpt 0 > \ smtp server accepted one or more recipients
  IF n top sl s SmtpSendMsgBody ( flag )
  ELSE FALSE THEN
  \ flag=false, if smtp server rejected the message
  DUP 0= IF S" Pop2Smtp[SaveRejected]" EVALUATE >NUM
            IF DROP n sl SmtpSaveMsg TRUE THEN
         THEN
;
: PopRecvSend { lst eml del sl s \ top -- }
  lst
  BEGIN
    DUP
  WHILE
    DUP CELL+ @ sl PopRecvMsg -> top
    top STR@ NIP 0 >
    IF
      DUP CELL+ @ top eml sl s SmtpSendMsg 
      vPop2SmtpDebug @ IF ." ACCEPTED=" DUP . CR THEN
      del AND IF DUP CELL+ @ sl PopDelMsg THEN
    THEN
    DUP @ SWAP FREE THROW
  REPEAT DROP
;
: (Strip2<)
  [CHAR] < PARSE 2DROP [CHAR] > PARSE
;
: Strip2<
  Strip<
  2DUP S" <" SEARCH NIP NIP
  IF ['] (Strip2<) EVALUATE-WITH THEN
;
: ParseRcpt1 { rcptlist -- }
  SOURCE TIB,>BL
  NextWord 2DROP
  BEGIN
    NextWord DUP
  WHILE
    2DUP S" @" SEARCH NIP NIP
    IF Strip2<
       2DUP rcptlist inList
       IF 2DROP
       ELSE COPYBUFC rcptlist AddNode THEN
    ELSE 2DROP THEN
  REPEAT 2DROP
;
: ParseRcptFor1 { rcptlist -- }
  SOURCE TIB,>BL
  NextWord 2DROP
  BEGIN
    NextWord DUP
  WHILE
    S" for" COMPARE 0=
    IF 
       NextWord
       2DUP S" @" SEARCH NIP NIP
       IF Strip2<
          2DUP rcptlist inList
          IF 2DROP
          ELSE COPYBUFC rcptlist AddNode THEN
       ELSE 2DROP THEN
    THEN
  REPEAT 2DROP
;
: ParseRcpt ( rcptlist -- )
  HEADER-STR " {s}" STR@
  ['] ParseRcpt1 EVALUATE-WITH
;
: ParseRcptFor ( rcptlist -- )
  HEADER-STR " {s}" STR@
  ['] ParseRcptFor1 EVALUATE-WITH
;
: DumpRcpt ( rcpt_node -- )
  NodeValue XCOUNT TYPE CR
;
: DumpRcpts
  ['] DumpRcpt uRECIPIENTS DoList CR
;
: Pop2SmtpSmtp { smtpuser smtppass eml del sl s -- }
  smtpuser smtppass s SmtpLogin
  ( list) eml del sl s PopRecvSend
  s SmtpLogout
;
: Pop2SmtpPop { pop3user pop3pass smtpserver smtpport smtpuser smtppass eml del sl \ s -- }
  pop3user pop3pass sl PopLogin
  sl PopList ?DUP 
  IF smtpserver smtpport SmtpConnect -> s
     smtpuser smtppass eml del sl s ['] Pop2SmtpSmtp CATCH
     s SmtpDisconnect
     THROW
  THEN
  sl PopLogout
;
: Pop2Smtp { pop3server pop3port pop3user pop3pass smtpserver smtpport smtpuser smtppass eml del \ sl -- }
  pop3server pop3port  PopConnect -> sl
  pop3user pop3pass smtpserver smtpport smtpuser smtppass eml del sl ['] Pop2SmtpPop CATCH
  sl PopDisconnect
  THROW
;
: Pop2SmtpDb1
  FIELD1 " {s}"
  FIELD2 >NUM
  FIELD3 " {s}"
  FIELD4 " {s}"
  FIELD5 " {s}"
  FIELD6 >NUM
  FIELD7 " {s}"
  FIELD8 " {s}"
  FIELD9 " {s}"
  FIELD10 >NUM
  Pop2Smtp
;
: Pop2SmtpDb
  ['] Pop2SmtpDb1 CATCH CR . CR
;
( ѕример:
" www.eserv.ru" 110 " myname" " mypassw"
" rainbow.koenig.ru" 25 "" "" " webmaster@rainbow.koenig.ru" FALSE
Pop2Smtp
)