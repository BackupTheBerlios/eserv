MODULE: Quota_Support

: path2 S" ..\DATA\trafc\canals\save\quotas\" ;

' path2 TO path

;MODULE


1 ( Минут) 60 * 1000 * ' SaveQuotas inPeriod

\ .( quotas autosave started ) CR
