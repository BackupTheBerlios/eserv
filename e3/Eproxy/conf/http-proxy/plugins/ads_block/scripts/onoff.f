: TurnOn
  S" ..\activate.f" R/W CREATE-FILE THROW DUP
  " TRUE uAdsBlock !{CRLF}" STR@ ROT WRITE-FILE THROW
  CLOSE-FILE THROW
  S" AdsBlock is now turned ON"
;
: TurnOff
  S" ..\activate.f" R/W CREATE-FILE THROW DUP
  " FALSE uAdsBlock !{CRLF}" STR@ ROT WRITE-FILE THROW
  CLOSE-FILE THROW
  S" AdsBlock is now turned OFF"
;
