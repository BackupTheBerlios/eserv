VARIABLE UDPMAPPINGS
VARIABLE UDPCLIENTS

REQUIRE ServerUdp  conf/plugins/udpmap/server_udp.f
REQUIRE ListenUdp: conf/plugins/udpmap/listen_udp.f

0
4 -- umLink
4 -- umPort
4 -- umToPort
4 -- umToIP
0 -- umToAddr
CONSTANT /um

: UDPMAP: { \ mem }
  Port: BL PARSE0 Port: 
  OVER /um + CHAR+ ALLOCATE THROW -> mem
  mem umToPort !
  mem umToAddr SWAP CHAR+ MOVE
  mem umPort !
  mem umToIP 0!
  UDPMAPPINGS @ mem umLink !
  mem UDPMAPPINGS !
;
: IsUdpMappedPort { port -- um true |  false }
  UDPMAPPINGS @
  BEGIN
    DUP
  WHILE
    DUP umPort @ port = IF TRUE EXIT THEN
    umLink @
  REPEAT
;
0
4 -- ucLink
4 -- ucPeerIP
4 -- ucPeerPort
4 -- ucSocket
4 -- ucReplySocket
CONSTANT /uc

: GetUdpMapSocket ( -- socket )
  { \ uc }
\ Найти сокет, через который переправляются пакеты,
\ полученные от ip:port текущего клиента.
\ (каждой паре клиентских ip:port соответствует сокет на сервере).
\ Если не найдено, то это новая пара - создать ей сокет.
  UDPCLIENTS @
  BEGIN
    DUP
  WHILE
    DUP ucPeerPort @ OVER ucPeerIP @  UdpPeerPort UdpPeerIP D=
        IF ucSocket @ EXIT THEN
    umLink @
  REPEAT DROP
  /uc ALLOCATE THROW -> uc
  UdpPeerIP uc ucPeerIP !
  UdpPeerPort uc ucPeerPort !
  vServerSocket uc ucReplySocket !
  CreateUdpSocket THROW DUP uc ucSocket !
  UDPCLIENTS @ uc ucLink !
  uc UDPCLIENTS !
  0 OVER 0 AddUdpServer
;
: ForwardPacket { um -- }
  um umToIP @ DUP 0= 
  IF DROP um umToAddr ASCIIZ> GetHostIP DROP DUP um umToIP ! THEN
  um umToPort @
  RecvAddr RecvSize
  GetUdpMapSocket ['] WriteTo CATCH IF 2DROP 2DROP DROP THEN
;
: ForwardReplyPacket { \ uc -- }
  UDPCLIENTS @
  BEGIN
    DUP
  WHILE
    DUP ucSocket @ vServerSocket =
        IF -> uc
           uc ucPeerIP @ uc ucPeerPort @
           RecvAddr RecvSize
           uc ucReplySocket @ ['] WriteTo CATCH IF 2DROP 2DROP DROP THEN
           EXIT
        THEN
    ucLink @
  REPEAT DROP
;
: DumpUdpLists
  ." Udp mappings:" CR
  UDPMAPPINGS @
  BEGIN
    DUP
  WHILE
    DUP umPort @ . ." -> "
    DUP umToAddr ASCIIZ> TYPE
    DUP umToIP @ ?DUP IF ." (" NtoA TYPE ." )" THEN
    ." :"
    DUP umToPort @ . CR
    umLink @
  REPEAT DROP CR
  ." Udp clients:" CR
  UDPCLIENTS @
  BEGIN
    DUP
  WHILE
    DUP ucPeerIP @ NtoA TYPE ." :"
    DUP ucPeerPort @ . 
    DUP ucSocket @ ." s=" . CR
    ucLink @
  REPEAT DROP CR
  ." Udp sockets:" CR
  vUdpFdSet DUP CELL+ SWAP @ CELLS OVER + SWAP
  ?DO
    I @ DUP . sockIP&Port NIP ." p=" . CR
  4 +LOOP CR
;