: SkipConfig { e2 }
  BEGIN
    TIB C/L e2 READ-LINE THROW
  WHILE
    TIB SWAP S" Users:" COMPARE 0= IF EXIT THEN
  REPEAT DROP
;
: SourceFile
  S" AUTH[Eserv2Userlist]" EVALUATE
;
: TargetFile
  S" AUTH[Userlist]" EVALUATE " {ModuleDirName}..\{s}.new" STR@
;
: ConvertTo
  BL SKIP [CHAR] : PARSE
  NextWord DUP 
  IF debase64 MD5 2SWAP " {s};{s};1;;;;" STR@ 
  ELSE 2DROP 2DROP S" " THEN
;
: UserConvert { \ e2 e3 magic }
  SourceFile R/O OPEN-FILE ?DUP
  IF NIP DUP ErrorMessage 2- " Unable to open the file '{SourceFile}', error: {s} ({n})" STR@ EXIT
  ELSE -> e2 THEN
  TargetFile R/W CREATE-FILE ?DUP
  IF NIP DUP ErrorMessage 2- " Unable to create the file '{TargetFile}', error: {s} ({n})" STR@ EXIT
  ELSE -> e3 THEN
  ^ magic 4 e2 READ-FILE THROW DROP
  ^ magic 4 S" \ th" COMPARE 0=
  IF e2 SkipConfig ELSE 0 0 e2 REPOSITION-FILE THROW THEN
  S" USER;PASS;ACTIVE;FNAME;LNAME;EMAIL;HOMEPAGE" e3 WRITE-LINE THROW
  BEGIN
    TIB C/L e2 READ-LINE THROW OVER 0<> AND
  WHILE
    TIB SWAP ['] ConvertTo EVALUATE-WITH ?DUP IF e3 WRITE-LINE THROW ELSE DROP THEN
  REPEAT DROP
  e2 CLOSE-FILE THROW
  e3 CLOSE-FILE THROW
  " OK, пользователи с непустыми паролями из {SourceFile}<br> скопированы в {TargetFile}" STR@
;
UserConvert
