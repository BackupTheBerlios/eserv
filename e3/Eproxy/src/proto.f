( wid -- xt )

( ������ proto.f ����������� "��������" ����������� ���������
  ��� �������� wordlist. ������������ ������ PROTOCOL:,
  ������� ������� �����-������� ������ ���������. ��� ����������
  ����� ���������� �������� ������, ������� ��������� �������.
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
\   IF CLOSE-FILE THROW          \ ok, ����� �������, ������� �������� �����
\   ELSE GetLastError 102 LOG 5000 PAUSE \ �� ���������� ��������� -
\   THEN                                 \ ������ ����� �������� ��������
\ ;                                      \ �������� � ����, ����� "����������" :)

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