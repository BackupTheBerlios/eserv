VARIABLE PLUGINS-STR
VARIABLE $ROOT-DIR
" ..\..\.." $ROOT-DIR !
VARIABLE $PLUGIN-PATH
VARIABLE $PLUGIN-NAME
VARIABLE $MENU
VARIABLE $PROG

: ROOT-DIR
  $ROOT-DIR @ STR@
;
: PluginName
  $PLUGIN-NAME @ STR@ 2DUP \>_
;
: PROG
  $PROG @ STR@
;
: PluginTitle
  " {ROOT-DIR}\{PluginPath}\{LANG}\title.txt" STR@ EVAL-FILE
  DUP 0= IF 2DROP PluginName THEN
  " {PROG} - {s}" STR@
;
: PluginDescr
  " {ROOT-DIR}\{PluginPath}\{LANG}\description.txt" STR@ EVAL-FILE
;
: PluginPath
  $PLUGIN-PATH @ STR@
;
: MENU-PRE
  SOURCE NIP 3 < IF EXIT THEN
  [CHAR] ; PARSE S@ [CHAR] ; PARSE S@ 2SWAP
  2DUP S" ://" SEARCH NIP NIP \ указан полный URL с протоколом
  IF
    " <li><a class={''}item{''} HREF={''}{s}{''}>{s}</a>{CRLF}"
  ELSE
    OVER C@ [CHAR] / =
    IF
    " <li><a class={''}item{''} HREF={''}{s}{''}>{s}</a>{CRLF}"
    ELSE
    " <li><a class={''}item{''} HREF={''}/main/{PluginPath}/{LANG}/{s}{''}>{s}</a>{CRLF}"
    THEN
  THEN
  $MENU @ S+
;
: MENU-FILE ( addr u -- addr2 u2 )
  "" $MENU !
  ['] MENU-PRE TO <PRE>
  ['] INCLUDED CATCH IF 2DROP THEN
  ['] NOOP TO <PRE>
  $MENU @ STR@
;
: PluginMenu
  " {ROOT-DIR}\{PluginPath}\{LANG}\menu.txt" STR@ MENU-FILE
;
: ParsePluginPath { \ fl }
  "" $PLUGIN-NAME !
  "" $PLUGIN-PATH !
  "" $PROG !
  BEGIN
    [CHAR] / PARSE DUP
  WHILE
    2DUP S" .." COMPARE 0<>
    IF 2DUP S" activate.f" COMPARE 0<>
       IF fl 0= IF 2DUP $PROG S! fl 1+ -> fl THEN
          2DUP
          $PLUGIN-NAME @ STR+ S" _" $PLUGIN-NAME @ STR+
          $PLUGIN-PATH @ STR+ S" /" $PLUGIN-PATH @ STR+
       ELSE 2DROP THEN
    ELSE 2DROP THEN
  REPEAT 2DROP
  PluginName 1- 0 MAX $PLUGIN-NAME S!
  PluginPath 1- 0 MAX $PLUGIN-PATH S!
;
: PluginHtml ( addr u -- addr 2 u2 )
  2DUP \>/
  ['] ParsePluginPath EVALUATE-WITH
  S" lib\list-plugins.pat" EVAL-FILE
;
: LIST-PLUGIN 
  NIP 
  IF 2DROP
  ELSE 
     2DUP S" *activate.f*" WildCMP-U 0=
     IF PluginHtml PLUGINS-STR @ STR+
     ELSE 2DROP THEN
  THEN 
;
: LIST-PLUGINS
  "" PLUGINS-STR !
  " {ROOT-DIR}\Eproxy" STR@ ['] LIST-PLUGIN FIND-FILES-R
  " {ROOT-DIR}\acWEB"  STR@ ['] LIST-PLUGIN FIND-FILES-R
  " {ROOT-DIR}\acFTP"  STR@ ['] LIST-PLUGIN FIND-FILES-R
  " {ROOT-DIR}\acSMTP" STR@ ['] LIST-PLUGIN FIND-FILES-R
  " {ROOT-DIR}\acIMAP" STR@ ['] LIST-PLUGIN FIND-FILES-R
  " {ROOT-DIR}\CommonPlugins" STR@ ['] LIST-PLUGIN FIND-FILES-R
  PLUGINS-STR @ STR@
;
