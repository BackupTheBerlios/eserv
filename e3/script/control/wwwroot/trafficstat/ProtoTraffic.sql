select PROTOCOL, COUNT(PROTOCOL) AS CNT, SUM(CLIENT_READ) as RS, SUM(CLIENT_WRITE) as WS, SUM(OTHER_READ) as ORS, SUM(OTHER_WRITE) as OWS from [{y}{m}stat.txt] group by PROTOCOL order by SUM(CLIENT_WRITE) desc