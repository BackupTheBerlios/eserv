WARNING 0!
WINAPI: MoveFileExA KERNEL32.DLL

USER uStr "" uStr !
USER uNum

: DenyUrl:
  uNum 1+!
  NextWord uNum @
  " <tr><td><input type=checkbox name={''}n{n}{''}></td><td>deny url</td><td>{s}</td></tr>{CRLF}" uStr @ S+
  POSTPONE \
;
: AllowUrl:
  uNum 1+!
  NextWord uNum @
  " <tr><td><input type=checkbox name={''}n{n}{''}></td><td>allow url</td><td>{s}</td></tr>{CRLF}" uStr @ S+
  POSTPONE \
;
: DenyHost:
  uNum 1+!
  NextWord uNum @
  " <tr><td><input type=checkbox name={''}n{n}{''}></td><td>deny site</td><td>{s}</td></tr>{CRLF}" uStr @ S+
  POSTPONE \
;
: AllowHost:
  uNum 1+!
  NextWord uNum @
  " <tr><td><input type=checkbox name={''}n{n}{''}></td><td>allow site</td><td>{s}</td></tr>{CRLF}" uStr @ S+
  POSTPONE \
;
USER NEW-FILE

: ModFile ( xt -- )
  S" ..\OnRequest.rules.txt.new" R/W CREATE-FILE THROW NEW-FILE !
  ALSO EXECUTE
  S" ..\OnRequest.rules.txt" INCLUDED uNum 0!
  PREVIOUS
  NEW-FILE @ CLOSE-FILE THROW NEW-FILE 0!
  1 S" ..\OnRequest.rules.txt" DROP S" ..\OnRequest.rules.txt.new" DROP 
  MoveFileExA 1 <> THROW
;
: DeleteRule?
  uNum 1+!
  POSTPONE \
  uNum @ " n{n}" STR@ IsSet IF EXIT THEN
  SOURCE " {s}{CRLF}" STR@ NEW-FILE @ WRITE-FILE THROW
;
InVoc{ DEL-ACTION

: DenyUrl:  DeleteRule? ;
: DenyHost: DeleteRule? ;
: AllowUrl:  DeleteRule? ;
: AllowHost: DeleteRule? ;

: NOTFOUND \ обработка незнакомых директив
  NEW-FILE @ 
  IF 2DROP SOURCE NEW-FILE @ WRITE-FILE THROW 
     CRLF NEW-FILE @ WRITE-FILE THROW
  ELSE 2DROP THEN
  POSTPONE \ 
;

}PrevVoc

InVoc{ ACTIONS
: add_site { \ h }
  S" ..\OnRequest.rules.txt" R/W OPEN-FILE THROW -> h
  h FILE-SIZE THROW h REPOSITION-FILE THROW
  S" deny" IsSet
  IF " DenyHost: {site}{CRLF}"
  ELSE " AllowHost: {site}{CRLF}" THEN
  STR@ h WRITE-FILE THROW
  h CLOSE-FILE THROW
  " Add OK" STR@
;
: add_url { \ h }
  S" ..\OnRequest.rules.txt" R/W OPEN-FILE THROW -> h
  h FILE-SIZE THROW h REPOSITION-FILE THROW
  S" deny" IsSet
  IF " DenyUrl: {url}{CRLF}"
  ELSE " AllowUrl: {url}{CRLF}" THEN
  STR@ h WRITE-FILE THROW
  h CLOSE-FILE THROW
  " Add OK" STR@
;
: delete
  ['] DEL-ACTION ModFile
  S" Delete OK"
;
}PrevVoc

: NOTFOUND \ обработка незнакомых директив
  NEW-FILE @ 
  IF 2DROP SOURCE NEW-FILE @ WRITE-FILE THROW 
     CRLF NEW-FILE @ WRITE-FILE THROW
  ELSE 2DROP THEN
  POSTPONE \ 
;
