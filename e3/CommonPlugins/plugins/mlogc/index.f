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
VARIABLE LOG-MUT

: FileLog1 { a u fa fu -- }
  fa fu + 0 SWAP C!
  fa fu ['] Open/CreateLogFile CATCH ?DUP
  IF NIP NIP 0 SWAP ELSE 0 THEN
  IF DROP ELSE a u " {s}{CRLF}" STR@ ROT
               ?DUP IF DUP >R WRITE-FILE THROW
                       R> CLOSE-FILE THROW
                    ELSE 2DROP THEN
          THEN
;
: FileLog
  -1 LOG-MUT @ WAIT THROW DROP
  ['] FileLog1 CATCH
  LOG-MUT @ RELEASE-MUTEX DROP
  THROW
;

: LOG-MUTEX
  LOG-MUT @ 0= 
  IF " ESERV-LOG-MUT" STR@ FALSE CREATE-MUTEX THROW LOG-MUT !
    WinNT? 
    IF
      CreateEveryoneACL ?DUP
      IF NIP " ACL: {n}" TYPE CR
      ELSE
         LOG-MUT @ SetObjectACL DROP
      THEN
    THEN
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
