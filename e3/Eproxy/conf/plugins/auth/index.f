VARIABLE AuthParams
: AUTH-PARAMS AuthParams @ STR@ ;

: VOC-ALIAS ( a1 u1 a2 u2 -- ) \ S" Proxy NT" S" auth_nt"
  SFIND 0= THROW
  , \ cfa
  0 C, \ flags
  FORTH-WORDLIST +SWORD ALIGN
;
: AuthSource:
  ParseStr
  NextWord 2DUP 2DUP " VOCABULARY {s} ALSO {s} DEFINITIONS" STR@ EVALUATE
  2SWAP 2OVER VOC-ALIAS
  1 PARSE AuthParams S!
  " conf\plugins\auth\{s}\index.f" STR@ IncludeWithError
  PREVIOUS DEFINITIONS
;
: IP-Auth:
  User NIP IF POSTPONE \ EXIT THEN \ не перебивать установленное имя
  ParseStr GetHostIP THROW
  Mask: PeerIP AND =
  IF NextWord S" " SetUser -1 UID ! ELSE POSTPONE \ THEN
;
USER CurrentDomain
USER CurrentDomainXT

: Domain:
  NextWord CurrentDomain @ STR@ COMPARE 0=
  IF ParseStr SFIND 0= IF -2018 THROW THEN
     CurrentDomainXT ! \EOF
  ELSE POSTPONE \ THEN
;
: ExecuteInDomain ( ... worda wordu doma domu -- ... )
  CurrentDomain S! CurrentDomainXT 0!
  S" plugins\auth\AuthDomains" EvalRules
  CurrentDomainXT @ DUP 0= IF -2019 THROW THEN
  ALSO EXECUTE SFIND PREVIOUS 0= IF -2020 THROW THEN
  EXECUTE
;
: AuthorizeInDomain ( usera useru passa passu doma domu -- uid )
  S" LoginDomainUser" 2SWAP ExecuteInDomain
;
: IsMemberOfGroupInDomain: ( usera useru "group" "domain" -- flag )
  ParseStr S" IsMemberOf" ParseStr ExecuteInDomain
;
