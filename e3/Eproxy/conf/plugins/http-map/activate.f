\ " ac" 3128 fsockopen " CONNECT ac:25 HTTP/1.0{CRLF}Host: ac:25{CRLF}{CRLF}" OVER fputs
\ DUP fgets STYPE
\ fsock vClientSocket MAP-SOCKETS
