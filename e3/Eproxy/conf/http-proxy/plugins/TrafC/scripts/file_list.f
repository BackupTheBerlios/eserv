\ текущий: conf\http-proxy\plugins\TrafC\{LANG}\menu\

\ REQUIRE TIME&DATE lib\include\facil.f 
Require TIME&DATE lib\include\facil.f 

: MMDD- ( a u -- a1 u1 )
  TIME&DATE
  DROP >R >R 2DROP DROP \ 2R> ( dd mm )
  <# HOLDS  R> 0 # # 2DROP R> 0 # # #>
;

VECT filemask ( -- a u )

: filemask1 S" canal*" ; ' filemask1 TO filemask

: dir ( -- a u )
\   S" ..\..\..\..\..\Plugins\trafc\log\"
\   S" ..\..\..\..\..\..\..\DATA\log\trafc\"
\   S" ..\..\DATA\log\trafc\" +ModuleDirName
   " ..\{Dirs[Logs]}\trafc\" STR@ +ModuleDirName \ 23.Aug.2003
;

USER uCurrFile
: CurrFile uCurrFile @ ?DUP IF STR@ ELSE 0. THEN ;

USER uFLStr

: (GetFile) ( a u -- )
  2DUP
    uCurrFile @ ?DUP 0= IF "" DUP uCurrFile ! THEN
  STR!

  2DUP " <OPTION value={''}{s}{''}> {s}{CRLF}" 
  uFLStr @ S+
; 
: GetFileList ( -- a u )
  "" uFLStr !
  " {dir}{filemask}" STR@ ['] (GetFile) FIND-FILES
  uFLStr @ STR@
;
