: ##n
  0 <# # # #>
;
: ####n
  0 <# # # # # #>
;
: MMDD
  " {schMH @ ##n}{schDD @ ##n}" STR@
;
: YYYYMMDD
  " {schYYYY @ ####n}{schMH @ ##n}{schDD @ ##n}" STR@
;
: YYYY-MM-DD
  " {schYYYY @ ####n}-{schMH @ ##n}-{schDD @ ##n}" STR@
;
: DD.MM.YYYY
  " {schDD @ ##n}.{schMH @ ##n}.{schYYYY @ ####n}" STR@
;
: YYYYMM
  " {schYYYY @ ####n}{schMH @ ##n}" STR@
;
: hh:mm:ss
  " {schHH @ ##n}:{schMM @ ##n}:{schSS @ ##n}" STR@
;
: bps
  WSTAT
  1000 vReqElapsed 1 MAX */
;
: rbps
  RSTAT
  1000 vReqElapsed 1 MAX */
;
: MLOG-FILE-DOES
  DOES> @ ?DUP IF ROT ROT " {s}{CRLF}" STR@ ROT WRITE-FILE THROW 
               ELSE 2DROP THEN
;
: CREATE-MLOG-FILE ( addr u -- h )
  2DUP + 0 SWAP C!
  2DUP " CREATE {s}" STR@ EVALUATE MLOG-FILE-DOES
  ['] Open/CreateLogFile CATCH ?DUP
  IF NIP NIP 0 , 0 SWAP ELSE DUP , 0 THEN
;
: FileLog { a u fa fu -- }
  fa fu SFIND IF a u ROT EXECUTE EXIT THEN
  CREATE-MLOG-FILE
  IF DROP ELSE a u " {s}{CRLF}" STR@ ROT
               ?DUP IF WRITE-FILE THROW ELSE 2DROP THEN
          THEN
;

: MLOG { a u \ l s -- }
  a C@ [CHAR] * = 
  IF a 1+ u 1- S" *" SEARCH
     IF -> l -> s
        s 1+ l 1-
        a 1+ u l - 1-
        FileLog EXIT
     ELSE 2DROP THEN
  THEN
  a u " {s}{CRLF}" STYPE
; 
