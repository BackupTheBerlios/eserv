MODULE: canals_stat-support

1 ( Минут)  60 *  1000 *  CONSTANT quotas_period

: (quota_stat) ( c-addr -- )
  DUP NAME> EXECUTE ( i )
  @ { cname oid  }

  oid :%Utilized      
  oid :Stat 1024 U/   DUP vNotEmpty OR TO vNotEmpty

  oid :ClearStat
  cname COUNT
  \ " {s} {n} {n} "  uStr @ S+  \ order: "name stat util"
  " {s} {n} {n} " uStr @  SWAP   DUP uStr !   S+  \ 'добавление' в начало строки
;

ALSO Quota_Support

: quotas_stat ( -- )
  RefreshStr
  FALSE TO vNotEmpty
  ['] (quota_stat) ForCanals
  vNotEmpty       IF  
  1322 LOG        THEN
;

PREVIOUS

EXPORT

: QuotasStatStr ( -- a u )
  uStr @ STR@
;

: start-quotas_stat ( -- )
  quotas_period ['] quotas_stat inPeriod
;
\ ..: AT-PROCESS-STARTING start-quotas_stat ;..

start-quotas_stat


;MODULE

\ ALSO stat1
