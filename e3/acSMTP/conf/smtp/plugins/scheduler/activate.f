:NONAME
 S" SMTP[SynchronousSend]" EVALUATE >FLAG 0=	\ �� ���������� �� �������?
 IF
   " {SMTP[Out]}\*.*" STR@ MyFileExists		\ ���� �� ����� �� ��������?
   IF
     S" smtp\delivery\RunSendMailApp" EvalRules	\ ��, ������������ ��������
   THEN
   S" SMTP[EmailSmtpForward]" EVALUATE ['] (MyCheckEmailForward) ForEachFileRecord	\ ��������� �� �� ����� � ����������
 THEN
; TASK: MYSMC-

:NONAME
 BEGIN
   0 MYSMC- START CLOSE-FILE THROW		\ ��������� ����� ��������
   60000 PAUSE					\ �������� ����� 
 AGAIN
; TASK: MYSM-

0 MYSM- START CLOSE-FILE THROW
