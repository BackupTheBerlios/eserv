\ 11.Aug.2003

\ {Dirs[Lists]}\trafc\bands.txt 
\ {Dirs[Lists]}\trafc\quotas.txt

: _LoadBand ( -- )
  FIELD1 NIP 0= IF EXIT THEN
  " Band: {FIELD1} {FIELD2} =CPS ;Band"
  DUP STR@ EVALUATE STRFREE
;
: _LoadQuota ( -- )
  FIELD1 NIP 0= IF EXIT THEN
  " Quota: {FIELD1} {FIELD2} =Limit {FIELD3} =Period ;Quota"
  DUP STR@ EVALUATE STRFREE
;

: LoadBandsList-db ( -- )
  " {Dirs[Lists]}\trafc\bands.txt"  DUP STR@
  ['] _LoadBand ForEachFileRecord   STRFREE
;
: LoadQuotasList-db ( -- )
  " {Dirs[Lists]}\trafc\quotas.txt" DUP STR@
  ['] _LoadQuota ForEachFileRecord  STRFREE
;
