USER uPopMsgidList
USER $PopCurrentMsgid

: PopMsgidFile S" conf\plugins\pop2smtp\pop3msgids.txt" ;

: PopSetCurrentMsgid ( addr u -- )
  $PopCurrentMsgid S!
;

: PopReadMsgidList { \ h }
  PopMsgidFile R/O OPEN-FILE
  IF DROP EXIT THEN
  -> h
  BEGIN
    TIB C/L h READ-LINE THROW
  WHILE
    #TIB ! >IN 0!
    1 PARSE DUP CELL+ CHAR+ ALLOCATE THROW >R
    DUP R@ CELL+ C!
    R@ CELL+ CHAR+ SWAP MOVE
    uPopMsgidList @ R@ !
    R> uPopMsgidList !
  REPEAT DROP
  h CLOSE-FILE THROW
;
: PopIsOldMsgid { addr u -- flag }
  uPopMsgidList @
  BEGIN
    DUP
  WHILE
    DUP CELL+ COUNT addr u COMPARE 0=
        IF ( ."  already exists" CR) EXIT THEN
    @
  REPEAT
;
: PopSaveReceivedMsgid
  $PopCurrentMsgid @ 0= IF EXIT THEN
  PopMsgidFile Open/CreateLogFile
  >R
  R@ FILE-SIZE THROW R@ REPOSITION-FILE THROW
  $PopCurrentMsgid @ STR@ R@ WRITE-FILE THROW
  CRLF R@ WRITE-FILE THROW
  R> CLOSE-FILE THROW
;
