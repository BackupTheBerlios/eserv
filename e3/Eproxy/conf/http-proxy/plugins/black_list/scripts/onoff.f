: TurnOn
  S" ..\activate.f" R/W CREATE-FILE THROW DUP
  " TRUE uBlackList !{CRLF}" STR@ ROT WRITE-FILE THROW
  CLOSE-FILE THROW
  S" Black list is now turned ON"
;
: TurnOff
  S" ..\activate.f" R/W CREATE-FILE THROW DUP
  " FALSE uBlackList !{CRLF}" STR@ ROT WRITE-FILE THROW
  CLOSE-FILE THROW
  S" Black list is now turned OFF"
;
