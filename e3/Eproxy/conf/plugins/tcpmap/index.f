: DoTcpmap1 ( to-socket -- )
  S" plugins\tcpmap\OnRequest" EvalRules
  vClientSocket MAP-SOCKETS
  S" plugins\tcpmap\OnRequestComplete" EvalRules
;

: GetTcpmapParams
  BL PARSE0 ParseNum
;
:NONAME ( mem -- ret_code ) { mem \ a u port s }
  mem @
  ThreadInit
  mem CELL+ CELL+ mem CELL+ @  -> u -> a
  a u ['] GetTcpmapParams EVALUATE-WITH
  -> port
  GetHostIP ?DUP
  IF NIP DUP a u 615 LOG \ can't get IP ior
  ELSE
     port
     CreateSocket DROP DUP -> s
     ConnectSocket ?DUP
     IF DUP a u 620 LOG \ can't connect ior
     ELSE s ['] DoTcpmap1 CATCH >R
          SP@ S0 ! R> \ ior
     THEN
      s CloseSocket DROP
  THEN
  ( ior )
  mem 0 GetProcessHeap HeapFree DROP
  ThreadExit
; TASK: DoTcpmap

: MAPTO: { \ mem }
  CharAddr NextWord 2DROP NextWord 2DROP CharAddr OVER -
  DUP CELL+ CELL+ 0 GetProcessHeap HeapAlloc DUP 0= THROW -> mem
  vClientSocket mem !
  DUP mem CELL+ !
  mem CELL+ CELL+ SWAP MOVE
  mem DoTcpmap START ?DUP
  IF CLOSE-FILE THROW
  ELSE GetLastError 102 LOG 5000 PAUSE
  THEN
;
WARNING 0!
: PROTOCOL ( -- addr u )
  vWid IF PROTOCOL ELSE S" TCPMAP" THEN
;

: StartTcpMapping { \ err }
  FIELD1 >NUM ['] ListenPort
    CATCH ?DUP 
    IF -> err
       >IN 0! ParseNum ParseStr ROT " {n} {s}" STR@
       err DUP ErrorMessage ROT
       err 10049 =
       IF \ "требуемый адрес для своего контекста неверен"
          \ эта ошибка возникает, если сказано слушать несуществующий
          \ сетевой интерфейс, а он может стать несуществующим, если
          \ просто отключен кабель. Ругаемся в лог вместо сообщения.
          511 LOG
       ELSE
         510 GetLogStr
         MessageY/N
         0= IF BYE THEN
       THEN
    THEN
    uListeners 1+!
;
: StartTcpMappings
  S" PROXY[TcpMap]" EVALUATE
  ['] StartTcpMapping ForEachFileRecord ( S" текстовый файл" xt -- )
;