\ 11.Aug.2003   new mechanism, use mlog

MODULE: canals_stat-support

USER-VALUE vNotEmpty

USER uStr

: RefreshStr ( -- )
  uStr @ ?DUP IF STRFREE uStr 0! THEN
  "" uStr !
  GetTime \ обновление штампа времени ( для лога)
;

;MODULE
