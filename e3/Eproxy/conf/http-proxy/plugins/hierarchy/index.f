USER $CASCADE-HOST
USER uCASCADE-PORT
USER $CASCADE-USER
USER $CASCADE-PASS
USER uDirectConnectionAllowed

: DirectConnectionAllowed
  TRUE uDirectConnectionAllowed !
;
: SetCascadeHost
  $CASCADE-HOST S!
;
: SetCascadePort
  uCASCADE-PORT !
;
: SetCascadeUser
  $CASCADE-USER S!
;
: SetCascadePass
  $CASCADE-PASS S!
;
: ConnectParent
  $CASCADE-HOST @ uCASCADE-PORT @ fsockopen
  SetTargetConn
;
: CASCADE
  ['] ConnectParent CATCH ?DUP
  IF uDirectConnectionAllowed @
     IF DROP S" DIRECT" SetHierarchy DIRECT EXIT ELSE ConnectError THEN
  THEN
  TARGET-PROT S" connect:" COMPARE 0=
  IF
    SendRequestHttp
    TARGET-CONN fsock vClientSocket ['] MAP-SOCKETS CATCH
  ELSE
    ['] ConnectParent CATCH ConnectError
    ['] TalkTarget CATCH
  THEN
  DisconnectTarget
\ ...  vHttpReplyCode 503 = uDirectConnectionAllowed @ AND \ ...
  THROW
;
: CascadeVia:
  ParseStr SetCascadeHost ParseNum SetCascadePort
  ParseStr SetCascadeUser ParseStr SetCascadePass
  $CASCADE-USER @ STR@
  ?DUP IF $CASCADE-PASS @ STR@ 2SWAP " {s}:{s}" STR@ base64
          " Proxy-Authorization: Basic {s}" STR@ +OptionalHeaders
       ELSE DROP THEN
  S" CASCADE" SetHierarchy
;
