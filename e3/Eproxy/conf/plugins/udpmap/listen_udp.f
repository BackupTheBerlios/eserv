
: AddUdpServer { port s thread -- }
  vUdpFdSet @ vUdpSockets > IF 610 LOG -610 THROW THEN
\  port s thread AddServer
  s
  vUdpFdSet @ CELLS CELL+ vUdpFdSet + !
  vUdpFdSet 1+!
;
: ListenPortUdp ( port -- )
  { port \ s  -- }
  CreateUdpSocket THROW -> s
  port s BindSocket THROW
\  s ServerUdpThread START
  0
  port s ROT AddUdpServer
;
: ListenInterfaceUdp ( port IP -- )
  { port ip \ s }
  CreateUdpSocket THROW -> s
  port ip s BindSocketInterface THROW
\  s ServerUdpThread START
  0
  port s ROT AddUdpServer
;
: StartUdpServer
  uListeners @ IF
   vUdpFdSet ServerUdpThread START DROP
  THEN
;
: ListenUdp: { \ sp err }
  UDPMAPPINGS 0!
  vUdpSockets 2+ CELLS ALLOCATE THROW TO vUdpFdSet
  vUdpSockets 2+ CELLS ALLOCATE THROW TO vUdpFdSetCopy
  vUdpFdSet 0!
  BEGIN
    REFILL
  WHILE
    SP@ -> sp
    ParseNum DUP 0= IF DROP StartUdpServer EXIT THEN
    BL PARSE0 ?DUP
    IF GetHostIP DROP ['] ListenInterfaceUdp
    ELSE DROP ['] ListenPortUdp THEN

    CATCH ?DUP 
    IF -> err sp SP! SOURCE err DUP ErrorMessage ROT
       510 GetLogStr MessageY/N
       0= IF BYE THEN
    THEN
    uListeners 1+!
  REPEAT
  StartUdpServer
;
