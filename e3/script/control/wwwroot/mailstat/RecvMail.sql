select LCASE(EMAIL_TO) as Email, COUNT(EMAIL_TO) as Msgs, SUM(MSG_SIZE) as Total from [{y}{m}mail.txt] where EMAIL_TO<>'' group by LCASE(EMAIL_TO) order by SUM(MSG_SIZE) desc
