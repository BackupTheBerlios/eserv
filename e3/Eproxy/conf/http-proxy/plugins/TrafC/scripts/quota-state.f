\ 03.Aug.2003 Sun 03:48

Require UD$RS lib\print.f
Require SecondsToTimeDate  lib\ftime.f \  lib\seconds.f 


CREATE StartSpot 2 CELLS ALLOT
0 VALUE vLimitBytes
0 VALUE vCountBytes
0 VALUE vPeriodSec

VOCABULARY QuotaStateLex
GET-CURRENT ALSO QuotaStateLex DEFINITIONS

: LimitBytes= \ 51200 
  INTERPRET TO vLimitBytes
;
: CountBytes= \ 0 
  INTERPRET TO vCountBytes
;
: PeriodSec=  \ 600 
  INTERPRET TO vPeriodSec
;
: StartSpot=  \ 29579593 322864472 \ 2003 8 2 22 54 48 
  INTERPRET SWAP   StartSpot 2!
;

PREVIOUS SET-CURRENT


: FetchCanal ( name-a name-u -- )
  S" .." SEARCH IF 2DROP EXIT THEN
  " ..\..\DATA\trafc\canals\save\quotas\{s}" STR@ +ModuleDirName
  2DUP FILE-EXIST 0= IF 2DROP EXIT THEN

  ALSO QuotaStateLex
    INCLUDED
  PREVIOUS
;

: CanalId ( -- a u )
  S" q" IsSet           IF 
  S" q" EVALUATE
  2DUP FetchCanal       ELSE
  S" не задан"          THEN
;

: nstr ( n -- a u ) 
  0 0 UD$RS
;
: period ( -- a u )
  vPeriodSec 
  \ 1000 M* \ 10 M*
  \  DateAsString

  SecondsToTimeDate ( sec -- sec min hr day mt year )
  DROP 30 * +  
  " {n}, {n}:{n}:{n}" STR@
;
: term ( -- a u )
  StartSpot 2@ vPeriodSec addsec
  UTC>
  FTimeToTimeDate
  " {n}.{n}.{n} {n}:{n}:{n}" STR@
;

\ ===
: UserName ( -- a u )
  S" REMOTE_USER" ENVIRONMENT? 0= IF S" -" THEN
;
\ ===
