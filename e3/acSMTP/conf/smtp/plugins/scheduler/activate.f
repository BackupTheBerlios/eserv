:NONAME
 S" SMTP[SynchronousSend]" EVALUATE >FLAG 0=	\ не блокирован ли автомат?
 IF
   " {SMTP[Out]}\*.*" STR@ MyFileExists		\ есть ли файлы на отправку?
   IF
     S" smtp\delivery\RunSendMailApp" EvalRules	\ да, инициировать отправку
   THEN
   S" SMTP[EmailSmtpForward]" EVALUATE ['] (MyCheckEmailForward) ForEachFileRecord	\ проделать то же самое с пересылкой
 THEN
; TASK: MYSMC-

:NONAME
 BEGIN
   0 MYSMC- START CLOSE-FILE THROW		\ запустить поток проверки
   60000 PAUSE					\ минутная пазуа 
 AGAIN
; TASK: MYSM-

0 MYSM- START CLOSE-FILE THROW
