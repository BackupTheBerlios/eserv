MODULE: canals_stat-support

1 ( Минут)  60 *  1000 *  CONSTANT bands_period

: (band_stat) ( c-addr -- )
  DUP NAME> EXECUTE ( i )
  @ { cname oid  }
  oid :%Utilized   DUP vNotEmpty OR TO vNotEmpty
  oid :ClearStat
  cname COUNT
\  " {s} {n} "  uStr @ S+
  " {s} {n} " uStr @  SWAP   DUP uStr !   S+  \ 'добавление' в начало строки
;

ALSO Band_Support

: bands_stat ( -- )
  RefreshStr
  FALSE TO vNotEmpty
  ['] (band_stat) ForCanals
  vNotEmpty       IF
  1321 LOG        THEN
;

PREVIOUS

EXPORT

: BandsStatStr ( -- a u )
  uStr @ STR@
;

: start-bands_stat
  bands_period ['] bands_stat inPeriod
;
\ ..: AT-PROCESS-STARTING start-bands_stat ;..

start-bands_stat


;MODULE

\ ALSO stat1
