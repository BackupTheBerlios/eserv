( wid -- xt )

( ћакрос proto.f компилирует "оболочку" обработчика протокола
  над заданным wordlist. »спользуетс€ словом PROTOCOL:,
  которое создает слово-словарь команд протокола. ѕри выполнении
  слова происходит создание потока, который выполн€ет команды.
)
( wid )

:NONAME
  [ SWAP ] LITERAL EvalCommands
;
( xt1 )

:NONAME ( socket -- ret_code )
  ThreadInit
  [ SWAP ] LITERAL CATCH
  ThreadExit
; TASK

( task-xt )

\ :NONAME
\   vClientSocket [ SWAP ] LITERAL START ?DUP
\   IF CLOSE-FILE THROW          \ ok, поток запущен, закрыли ненужный хэндл
\   ELSE GetLastError 102 LOG 5000 PAUSE \ не получилось запустить -
\   THEN                                 \ скорее всего нехватка ресурсов
\ ;                                      \ ругаемс€ и ждем, может "рассосетс€" :)

:NONAME
  [ SWAP ]
  BEGIN
    vClientSocket [ ROT ] LITERAL START DUP 0=
  WHILE
    DROP
    GetLastError 102 LOG
    5000 PAUSE
  REPEAT
  CLOSE-FILE THROW
;
( xt )