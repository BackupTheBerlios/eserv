select LCASE(EMAIL_FROM) as Email, COUNT(EMAIL_FROM) as Msgs, SUM(MSG_SIZE) as Total from [{y}{m}mail.txt] where LCASE(EMAIL_TO)='{email}' group by LCASE(EMAIL_FROM) order by COUNT(EMAIL_FROM) desc
