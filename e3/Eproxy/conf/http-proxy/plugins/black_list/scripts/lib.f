VARIABLE AuthParams
VARIABLE AuthSource
VARIABLE AuthType

: AUTH-PARAMS AuthParams @ STR@ ;
: AUTH-SOURCE AuthSource @ STR@ ;
: AUTH-TYPE   AuthType   @ STR@ ;

: AuthSource:
  ParseStr AuthSource S! NextWord 2DUP AuthType S!
  1 PARSE AuthParams S!
  " ..\..\..\..\..\conf\plugins\auth\{s}\lib.f" STR@ INCLUDED
;
S" ..\..\..\..\..\conf\plugins\auth\AuthSources.rules.txt" INCLUDED

USER Dom

: Domain:
  ParseStr ParseStr 2SWAP 2DUP
  " <option value={''}{s}{''}>{s} ({s}){CRLF}"
  Dom @ S+
;
: ListDomains { \ h -- addr u }
  "" Dom !
  S" ..\..\..\..\..\..\Eproxy\conf\plugins\auth\AuthDomains.rules.txt" INCLUDED
  Dom @ STR@
;
