WARNING 0!
WINAPI: MoveFileExA KERNEL32.DLL

USER uStr "" uStr !
USER uNum
: NextWord?
  NextWord DUP 0= IF 2DROP S" &nbsp;" THEN
  1 PARSE DUP 0= IF 2DROP S" &nbsp;" THEN
  2SWAP
;
: BlockUrl:
  uNum 1+!
  NextWord 2>R NextWord? 2R> uNum @
  " <tr><td><input type=checkbox name={''}n{n}{''}></td><td>block url</td><td>{s}</td><td>{s}</td><td>{s}</td></tr>{CRLF}" uStr @ S+
  POSTPONE \
;
: NotBlockUrl:
  uNum 1+!
  NextWord 2>R NextWord? 2R> uNum @
  " <tr><td><input type=checkbox name={''}n{n}{''}></td><td>allow url</td><td>{s}</td><td>{s}</td><td>{s}</td></tr>{CRLF}" uStr @ S+
  POSTPONE \
;
: BlockHost:
  uNum 1+!
  NextWord 2>R NextWord? 2R> uNum @
  " <tr><td><input type=checkbox name={''}n{n}{''}></td><td>block site</td><td>{s}</td><td>{s}</td><td>{s}</td></tr>{CRLF}" uStr @ S+
  POSTPONE \
;
: NotBlockHost:
  uNum 1+!
  NextWord 2>R NextWord? 2R> uNum @
  " <tr><td><input type=checkbox name={''}n{n}{''}></td><td>allow site</td><td>{s}</td><td>{s}</td><td>{s}</td></tr>{CRLF}" uStr @ S+
  POSTPONE \
;
: UrlAuthGroup: \ {url} {groupname} {domain} {rules}
  uNum 1+!
  NextWord 2>R ParseStr NextWord 2SWAP " {s}@{s}" STR@ 1 PARSE 2SWAP 2R> uNum @
  " <tr><td><input type=checkbox name={''}n{n}{''}></td><td>allow url for group</td><td>{s}</td><td>{s}</td><td>{s}&nbsp;</td></tr>{CRLF}" uStr @ S+
  POSTPONE \
;
: UrlAuthUser: \ {url} {username} {domain} {rules}{CRLF}
  uNum 1+!
  NextWord 2>R NextWord NextWord 2SWAP " {s}@{s}" STR@ 1 PARSE 2SWAP 2R> uNum @
  " <tr><td><input type=checkbox name={''}n{n}{''}></td><td>allow url for user</td><td>{s}</td><td>{s}</td><td>{s}&nbsp;</td></tr>{CRLF}" uStr @ S+
  POSTPONE \
;
: DenyUrlAuthGroup: \ {url} {groupname} {domain} {rules}
  uNum 1+!
  NextWord 2>R ParseStr NextWord 2SWAP " {s}@{s}" STR@ 1 PARSE 2SWAP 2R> uNum @
  " <tr><td><input type=checkbox name={''}n{n}{''}></td><td>deny url for group</td><td>{s}</td><td>{s}</td><td>{s}&nbsp;</td></tr>{CRLF}" uStr @ S+
  POSTPONE \
;
: DenyUrlAuthUser: \ {url} {username} {domain} {rules}{CRLF}
  uNum 1+!
  NextWord 2>R NextWord NextWord 2SWAP " {s}@{s}" STR@ 1 PARSE 2SWAP 2R> uNum @
  " <tr><td><input type=checkbox name={''}n{n}{''}></td><td>deny url for user</td><td>{s}</td><td>{s}</td><td>{s}&nbsp;</td></tr>{CRLF}" uStr @ S+
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

: BlockUrl:     DeleteRule? ;
: BlockHost:    DeleteRule? ;
: NotBlockUrl:  DeleteRule? ;
: NotBlockHost: DeleteRule? ;
: UrlAuthGroup: DeleteRule? ;
: UrlAuthUser:  DeleteRule? ;
: DenyUrlAuthGroup: DeleteRule? ;
: DenyUrlAuthUser:  DeleteRule? ;

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
  IF " BlockHost: {site} {users} {rules}{CRLF}"
  ELSE " NotBlockHost: {site} {users} {rules}{CRLF}" THEN
  STR@ h WRITE-FILE THROW
  h CLOSE-FILE THROW
  " Add OK" STR@
;
: add_url { \ h }
  S" ..\OnRequest.rules.txt" R/W OPEN-FILE THROW -> h
  h FILE-SIZE THROW h REPOSITION-FILE THROW
  S" deny" IsSet
  IF " BlockUrl: {url} {users} {rules}{CRLF}"
  ELSE " NotBlockUrl: {url} {users} {rules}{CRLF}" THEN
  STR@ h WRITE-FILE THROW
  h CLOSE-FILE THROW
  " Add OK" STR@
;
: add_auth { \ h }
  S" ..\OnRequest.rules.txt" R/W OPEN-FILE THROW -> h
  h FILE-SIZE THROW h REPOSITION-FILE THROW
  S" atype" EVALUATE S" allow" COMPARE 0=
  IF
    S" for" EVALUATE S" group" COMPARE 0=
    IF " UrlAuthGroup: {url} {''}{groupname}{''} {domain} {rules}{CRLF}"
    ELSE " UrlAuthUser: {url} {username} {domain} {rules}{CRLF}" THEN
  ELSE
    S" for" EVALUATE S" group" COMPARE 0=
    IF " DenyUrlAuthGroup: {url} {''}{groupname}{''} {domain} {rules}{CRLF}"
    ELSE " DenyUrlAuthUser: {url} {username} {domain} {rules}{CRLF}" THEN
  THEN
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
