\ Plugin поддержки команды CALLBACK для Piafi MailKnocker
\ написан по просьбе Alexander Vedjakin [me@piafi.ru]

: PopStoreCallback { h -- }
  NextWord >NUM NextWord ROT
  PeerIP GetHostName THROW
  " Notify: {s}:{n} {s}{CRLF}" STR@ h WRITE-FILE THROW
;

IN-PROTOCOL: POP

: CALLBACK ( "port magic_word" -- ) \ for Piafi DialerP MailKnocker
  { \ h }
  GetCurrentMboxFilename 2DUP
  IsDirectory 0= IF 2DROP " -ERR unsupported storage type{CRLF}" POP. EXIT THEN
  " {s}\.callback" STR@ R/W CREATE-FILE
  ?DUP IF ErrorMessage " -ERR create file failed: {s}{CRLF}" POP. DROP EXIT THEN
  DUP -> h
  ['] PopStoreCallback CATCH 
  h CLOSE-FILE DROP
  ?DUP IF ErrorMessage " -ERR write error: {s}{CRLF}" POP. DROP EXIT THEN
  " +OK callback stored{CRLF}" POP.
;

PROTOCOL;