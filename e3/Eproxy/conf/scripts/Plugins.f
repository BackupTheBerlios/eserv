WARNING 0!

WINAPI: MoveFileExA KERNEL32.DLL

USER Plugins
USER NEW-FILE


: ShowPlugins { \ h -- addr u }
  "" Plugins !
  INCLUDED
  Plugins @ STR@
;
: Plugin:
  NextWord
  2DUP " ..\..\conf\{s}\{LANG}\description.txt" STR@ FILE
  DUP 0= IF 2DROP 2DUP " ..\..\conf\{s}\en\description.txt" STR@ FILE THEN
  2SWAP 2DUP " {s}" STR@ 2DUP [CHAR] \ [CHAR] _ CONVERT
  " <tr><td><input type=checkbox name={''}{s}{''} checked></td><td>{s}</td><td>{s}</td></tr>{CRLF}"
  Plugins @ S+
;

: ModFile ( xt -- )
  S" ..\OnStartupPlugins.rules.txt.new" R/W CREATE-FILE THROW NEW-FILE !
  ALSO EXECUTE
  S" ..\OnStartupPlugins.rules.txt" INCLUDED
  PREVIOUS
  NEW-FILE @ CLOSE-FILE THROW NEW-FILE 0!
  1 S" ..\OnStartupPlugins.rules.txt" DROP S" ..\OnStartupPlugins.rules.txt.new" DROP 
  MoveFileExA 1 <> THROW
;

InVoc{ UPDATE-ACTION
: Plugin:
  NextWord 2DUP " {s}" STR@ 2DUP [CHAR] \ [CHAR] _ CONVERT IsSet
  IF " Plugin: {s}{CRLF}"
  ELSE " \ Plugin: {s}{CRLF}" THEN
  STR@ NEW-FILE @ WRITE-FILE THROW
;
: \
  NextWord S" Plugin:" COMPARE 0<> 
  IF SOURCE NEW-FILE @ WRITE-FILE THROW
     CRLF 2 NEW-FILE @ WRITE-FILE THROW
     POSTPONE \
     EXIT 
  THEN
  NextWord 2DUP " {s}" STR@ 2DUP [CHAR] \ [CHAR] _ CONVERT IsSet
  IF " Plugin: {s}{CRLF}"
  ELSE " \ Plugin: {s}{CRLF}" THEN
  STR@ NEW-FILE @ WRITE-FILE THROW
;
}PrevVoc

InVoc{ ACTIONS
: update
  ['] UPDATE-ACTION ModFile
  " Update OK" STR@
;
}PrevVoc

: \
  NextWord S" Plugin:" COMPARE 0<> IF POSTPONE \ EXIT THEN
  NextWord
  2DUP " ..\..\conf\{s}\{LANG}\description.txt" STR@ FILE
  2SWAP 2DUP " {s}" STR@ 2DUP [CHAR] \ [CHAR] _ CONVERT
  " <tr><td><input type=checkbox name={''}{s}{''}></td><td>{s}</td><td>{s}</td></tr>{CRLF}"
  Plugins @ S+
;
