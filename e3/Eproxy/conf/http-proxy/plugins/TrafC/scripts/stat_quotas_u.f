
: FilePermits ( -- a u )
  S" ..\..\Eproxy\conf\http-proxy\plugins\TrafC\users_quota_permits.list.txt"
  +ModuleDirName
;

0 VALUE cnl-a 
0 VALUE cnl-u

: SetItCanal ( a u -- )
  TO cnl-u TO cnl-a
;
: ItCanal ( -- a u )
  cnl-a cnl-u
;
: UserName ( -- a u )
  S" REMOTE_USER" ENVIRONMENT? 0= IF S" -" THEN
;

0 VALUE vFoundUser

GET-CURRENT
VOCABULARY CanalPermits_voc ALSO CanalPermits_voc DEFINITIONS

\ User as_admin     Can Q1 Q2 Qtest1

: User ( "user" -- flag )
  NextWord UserName COMPARE
  DUP 0= IF TRUE TO vFoundUser THEN
;
: Can ( f1 flag "ccc" -- f2 )
  IF POSTPONE \ EXIT THEN
  BEGIN NextWord DUP WHILE
    ItCanal COMPARE 0= OR
  REPEAT 2DROP
;
PREVIOUS SET-CURRENT

: PermitCanal ( a u -- flag )
  SetItCanal
  ALSO CanalPermits_voc
  0 FilePermits INCLUDED
  PREVIOUS
  vFoundUser 0= OR
;

: Accepted2? ( canal_name-a canal_name-u -- flag )
  FALSE TO vFoundUser

  2DUP PermitCanal 0= IF 2DROP FALSE EXIT THEN

  S" ShowAll" EVALUATE EVALUATE IF 2DROP TRUE EXIT THEN
  " accept_{s}" STR@ IsSet
;  ' Accepted2? TO Accepted?


\ ---

VOCABULARY CanalPermits_voc2
GET-CURRENT ALSO CanalPermits_voc2 DEFINITIONS
: User ( "user" -- flag )
  NextWord UserName COMPARE
;
: Can ( flag "ccc" -- )
  IF POSTPONE \ EXIT THEN
  BEGIN NextWord DUP WHILE
    2DUP
    " <tr><td> <input type=checkbox name=accept_{s}></td><td>{s}</td</tr>" uStr @ S+
  REPEAT 2DROP
;
PREVIOUS SET-CURRENT

: GetNames ( -- a u ) \ ->  <tr><th>on/off</th><th>Канал</th></tr>
  RefreshStr
  ALSO CanalPermits_voc2
  \ FilePermits uStr @ STR+ \ - for test
  FilePermits ['] INCLUDED CATCH IF 2DROP THEN
  PREVIOUS
  uStr @ STR@
;
