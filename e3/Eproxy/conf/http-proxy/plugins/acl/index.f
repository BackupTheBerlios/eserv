\ "*" в поле FIELD2 (user/group/domain) означает 
\ "любой авторизованный пользователь любой группы", как AllUsers в Eserv/2
\ пустое поле FIELD2 означает "все", как All в Eserv/2

USER $AUTH-DATA
USER $REALM
: REALM $REALM @ STR@ ;

: PcrUser? ( -- flag )
  FIELD2 NIP 0= IF TRUE EXIT THEN
  FIELD2 S" *" COMPARE 0= IF UID @ 0<> EXIT THEN
  User FIELD2 WildCMP-U 0= IF TRUE EXIT THEN
  UserEmail FIELD2 WildCMP-U 0= IF TRUE EXIT THEN
\  User FIELD2 IsMemberOf IF TRUE EXIT THEN
  FIELD3 " {s}" >R FIELD4 " {s}" >R
  FIELD2 " {s}" STR@ S" IsGroupMember" EvalRules 
  R> STR@ SetField4 R> STR@ SetField3
  IF TRUE EXIT THEN
  FALSE
;
: PcrTime? ( -- flag )
  FIELD3 NIP 0= IF TRUE EXIT THEN
  FIELD3 S" -" SEARCH NIP NIP
  IF " TimeInterval: {FIELD3}" ELSE " Time: {FIELD3}" THEN
  STR@ EVALUATE
;
: PcrRule? ( -- flag )
  FIELD4 NIP 0= IF TRUE EXIT THEN
  FIELD4 EVALUATE
;
: ProxyCheckRules
\ На входе в процедуру:
\ {FIELD2}=GROUP, {FIELD3}=TIME, {FIELD4}=RULE
\ если поля пустые, то соответствующее условие не проверяется
  PcrUser?
  IF \ пользователь совпал или пустое поле или группа совпала
     PcrTime?
     IF PcrRule?
     ELSE 0 THEN
  ELSE 0 THEN
;
: TCP_DENIED
  " HTTP/1.0 407 Unauthorized
Server: {PROG-NAME}
Content-Type: text/html
Proxy-Authenticate: Basic realm={REALM}
Proxy-Connection: close

Unauthorized ({REALM})
" FPUTS TRUE TO vStopProtocol
  407 TO vHttpReplyCode
;
: ADV_BLOCK
  200 TO vHttpReplyCode
  " HTTP/1.0 200 OK
Content-Type: image/gif
Content-Length: 45
Connection: Keep-Alive

" FPUTS S" conf\http-proxy\plugins\acl\blank.gif" FILE FPUT
;
: Unauthorized ( -- )
  S" TCP_DENIED" SetAction
  ParseStr $REALM S!
;
: ACL_DISABLED
  404 TO vHttpReplyCode
  " HTTP/1.0 404 Disabed by admin
Content-Type: text/html
Connection: close

" FPUTS S" conf\http-proxy\plugins\acl\NotFound.html" EVAL-FILE FPUT
CloseConnection
;
: AclDisabled
  S" ACL_DISABLED" SetAction
;
: NF AclDisabled TRUE ;
: AU
  S" TCP_DENIED" SetAction
  S" PROXY" $REALM S!
  TRUE
;
: ProxyAccessDenied
  ActionChanged 0=
\ если никакие другие действия не заданы (словами NF, AU в FIELD4/RULES),
\ то по умолчанию принимаем блокировку рекламы, выдаем прозрачный gif
  IF
    S" ADV_BLOCK" SetAction
  THEN
;

: Authorization { \ in }
  >IN @ -> in
  BL SKIP BL PARSE S" Basic" COMPARE 0=
  IF
    BL SKIP BL PARSE BasicAuthorization
    User Pass SetUser UID 0!
  ELSE in >IN ! 1 PARSE $AUTH-DATA S!
  THEN
;
: IsGroupMember:
  ParseStr S" IsGroupMember" EvalRules
;

IN-PROTOCOL: HTTP-PROXY

: PROXY-AUTHORIZATION:
  Authorization
;

PROTOCOL;
