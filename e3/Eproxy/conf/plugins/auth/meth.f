( but see \ REQUIRE Unauthorized conf\http-proxy\plugins\black_list\index.f )

USER $REALM         \ str - область авторизации
: REALM        $REALM        @ STR@ ;

: UNAUTHORIZED
" HTTP/1.0 401 Unauthorized
Proxy-Connection: close
WWW-Authenticate: Basic realm={''}{REALM}{''}
Content-Type: text/html
Connection: close

<html><body>
<h2>Unauthorized, {REALM}</h2>
</body></html>
"
  FPUTS StopProtocol

;
: Unauthorized ( -- )
  S" UNAUTHORIZED" $ACTION S!
  ParseStr $REALM S!
;
