REQUIRE [UNDEFINED]     lib\include\tools.f

[UNDEFINED] IT      [IF]
: IT LATEST NAME> ; [THEN]

[UNDEFINED] IS      [IF]
: IS POSTPONE TO ; 
IMMEDIATE           [THEN]


[UNDEFINED] INCLUDE-FILE-WITH [IF]

VERSION 100000 U/ 3 = [IF] 

: INCLUDE-FILE-WITH ( i*x fileid xt -- j*x )
  TIB >R >IN @ >R #TIB @ >R SOURCE-ID >R BLK @ >R CURSTR @ >R
  ( xt ) >R
  C/L 2 + ALLOCATE THROW TO TIB  BLK 0!
  TO SOURCE-ID
  CURSTR 0!

  R> EXECUTE
( не предполагает исключений в xt. при исключении 
  оставит источник -как есть )

  TIB FREE THROW
  SOURCE-ID CLOSE-FILE THROW ( ошибка закрытия файла )
  R> CURSTR ! R> BLK ! R> TO SOURCE-ID R> #TIB ! R> >IN ! R> TO TIB
;
[ELSE]
\ .( spf version not compatibly, cant't define INCLUDE-FILE-WITH ) CR
: INCLUDE-FILE-WITH ( i*x fileid xt -- j*x )
  OVER >R
  ['] READ-LINE SWAP RECEIVE-WITH-XT
  R> CLOSE-FILE SWAP THROW THROW
;
[THEN]                        [THEN]
