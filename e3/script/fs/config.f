: PROGNAME S" Eproxy/3.x" ;
: PROGFILE S" Eproxy" ;
: HOMEPAGE S" http://eproxy.etype.net/" ;
: DOCS S" http://sourceforge.net/docman/?group_id=21876" ;

: LEFT_BGCOLOR ( S" #D0DCE0") S" #B1DACF" ;
: MAIN_BGCOLOR ( S" #F5F5F5" S" #C8E3FF" S" #D0E0F0") S" #CFCFFF" ;
: MAIN_BACKGROUND ( S" images/bkg.gif") S" " ;
: INDEX_BGCOLOR S" #000000" ;

: LANG? { a u -- a u true | false }
  S" HTTP_ACCEPT_LANGUAGE" ENVIRONMENT? 
  IF a u SEARCH NIP NIP
     IF a u TRUE EXIT THEN
  THEN FALSE
;
: LANG
  S" ru" LANG? IF EXIT THEN
  S" de" LANG? IF EXIT THEN
  S" es" LANG? IF EXIT THEN
  S" it" LANG? IF EXIT THEN
  S" en"
;
: IsServiceStarted
  " {ModuleDirName}..\..\{PROGFILE}\{PROGFILE}.pid" STR@ DELETE-FILE 4 >
;
: IsServiceStarted:
  NextWord 2DUP
  " {ModuleDirName}..\..\{s}\{s}.pid" STR@ DELETE-FILE 4 >
;
: MainMenuFile
  " {ModuleDirName}..\..\{PROGFILE}\conf\{LANG}\menu.html" STR@
;
: quote_char? ( c -- flag )
  DUP [CHAR] \ = IF DROP TRUE EXIT THEN
  DUP [CHAR] - = IF DROP TRUE EXIT THEN
  DROP FALSE
;
: \>_ ( addr u -- )
\  0 ?DO DUP I + C@ [CHAR] \ = IF [CHAR] _ OVER I + C! THEN LOOP DROP
  0 ?DO DUP I + C@ quote_char? IF [CHAR] _ OVER I + C! THEN LOOP DROP
;

VARIABLE OutText
VARIABLE uPluginName
VARIABLE uPluginPath
: PluginName uPluginName @ ?DUP IF STR@ 2DUP \>_ ELSE S" unknown" THEN ;
: PluginPath uPluginPath @ ?DUP IF STR@ 2DUP \>/ ELSE S" unknown" THEN ;
: Plugin: NextWord 2DUP uPluginName S! 2DUP uPluginPath S!
" {ModuleDirName}..\..\{PROGFILE}\conf\{s}\{LANG}\menu.html" STR@
  EVAL-FILE OutText @ STR+
;
: PluginsMenu
  "" OutText !
\  " ..\..\..\{PROGFILE}\conf\OnStartupPlugins.rules.txt" STR@ 
  " ..\..\{PROGFILE}\conf\OnStartupPlugins.rules.txt" STR@
  ['] INCLUDED CATCH
  IF 2DROP THEN
  OutText @ STR@
;

WARNING 0!
USER uAuthServer

: AuthServer uAuthServer @ ?DUP IF EXECUTE ELSE S" ." THEN ;

: LoginUserNT 2DROP 2DROP 0 ;
