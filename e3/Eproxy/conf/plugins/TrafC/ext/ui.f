\ for user interface

: TillUnblock ( -- a u )
  TillUnblockCanalKit
  60 /MOD \ sec
  60 /MOD \ min
  24 /MOD \ hour
  \ days
  " {n} ���� {n} ����� {n} ����� {n} ������ " STR@
;

: IsQuota ( a u -- oid true | false )
  ResolveCanal?               IF ( oid )
  DUP @ quota_canal = IF \ is quota_cl
  TRUE                ELSE
  DROP 0              THEN    ELSE
  0                           THEN
;
: (QuotasKitCounted) ( s -- )   
  { s \ a u }
  BEGIN NextWord -> u -> a u WHILE
    a u IsQuota IF :BytesExhausted a u " Counted_{s}={n}&" s S+ THEN
  REPEAT
;
: QuotasKitCounted ( a1 u1 -- a u ) \ �� ���� - ������ ���� �������
  "" DUP >R ROT ROT ['] (QuotasKitCounted) EVALUATE-WITH
  R> STR@
;
