1500 VALUE PACK_SIZE
   0 VALUE vUdpFdSet
   0 VALUE vUdpFdSetCopy
1000 VALUE vUdpSockets
   0 VALUE UdpPeerIP
   0 VALUE UdpPeerPort
   0 VALUE RecvSize
   0 VALUE RecvAddr

: UdpCLIENT ( -- addr u )
  UdpPeerIP NtoA
;
: ReadUdp { mem ss \ port ip size -- }
  ss TO vServerSocket
  ss TO vClientSocket \ это для лога
  mem PACK_SIZE vServerSocket ['] ReadFrom CATCH
  IF 2DROP DROP
  ELSE
    TO UdpPeerPort TO UdpPeerIP TO RecvSize
    mem TO RecvAddr
    S" OnUdpRecv" ['] EvalRules CATCH  IF 2DROP THEN
  THEN
;
: ServerUdp { fdset \ mem -- }
  NextThread
  PACK_SIZE ALLOCATE THROW -> mem
  BEGIN
    S0 @ SP!
    fdset vUdpFdSetCopy vUdpSockets 2+ CELLS MOVE
    0 0 0 vUdpFdSetCopy 0 select SOCKET_ERROR <>
  WHILE
    GetTime
    mem
    vUdpFdSetCopy DUP CELL+ SWAP @ CELLS OVER + SWAP
    ?DO
      DUP I @ ReadUdp
    4 +LOOP DROP
  REPEAT DROP
;
' ServerUdp TASK: ServerUdpThread
