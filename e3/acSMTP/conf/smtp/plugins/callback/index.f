\ Plugin ��������� ������� CALLBACK ��� Piafi MailKnocker
\ ������� �� ������� Alexander Vedjakin [me@piafi.ru]

: (Notify:) ( "host:port word" -- )
  { \ conn }
  BL SKIP [CHAR] : PARSE " {s}"
  NextWord >NUM ['] fsockopen CATCH
  0= IF
    -> conn
    NextWord " {s}{CRLF}" conn ['] fputs CATCH IF DROP THEN
    conn fclose
  ELSE NextWord 2DROP THEN
;
: Notify: ( "host:port word" -- )
  ['] (Notify:) CATCH DROP \ ���������� ������ �����, 
                           \ �.�. ������ ����� ���� ����������
;
