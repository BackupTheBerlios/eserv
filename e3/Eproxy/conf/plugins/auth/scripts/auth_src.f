WARNING 0!

WINAPI: MoveFileExA KERNEL32.DLL

USER Srcs
USER NEW-FILE


: ShowSrcs { \ h -- addr u }
  "" Srcs !
  INCLUDED
  Srcs @ STR@
;
: AuthSource:
  ParseStr 2>R NextWord BL SKIP 1 PARSE 2SWAP 2R> 2DUP
  " <tr><td><input type=checkbox name={''}{s}{''} checked></td><td>{s}</td><td>{s}</td><td>{s}</td></tr>{CRLF}"
  Srcs @ S+
;

: ModFile ( xt -- )
  S" ..\AuthSources.rules.txt.new" R/W CREATE-FILE THROW NEW-FILE !
  ALSO EXECUTE
  S" ..\AuthSources.rules.txt" INCLUDED
  PREVIOUS
  NEW-FILE @ CLOSE-FILE THROW NEW-FILE 0!
  1 S" ..\AuthSources.rules.txt" DROP S" ..\AuthSources.rules.txt.new" DROP 
  MoveFileExA 1 <> THROW
;

InVoc{ UPDATE-ACTION
: AuthSource:
  ParseStr 2DUP " {s}" STR@ 2DUP BL [CHAR] + CONVERT IsSet BL SKIP 1 PARSE ROT
  IF 2SWAP " AuthSource: {''}{s}{''} {s}{CRLF}"
  ELSE 2SWAP " \ AuthSource: {''}{s}{''} {s}{CRLF}" THEN
  STR@ NEW-FILE @ WRITE-FILE THROW
;
: \
  NextWord S" AuthSource:" COMPARE 0<> 
  IF SOURCE NEW-FILE @ WRITE-FILE THROW
     CRLF 2 NEW-FILE @ WRITE-FILE THROW
     POSTPONE \
     EXIT 
  THEN
  ParseStr 2DUP " {s}" STR@ 2DUP BL [CHAR] + CONVERT IsSet BL SKIP 1 PARSE ROT
  IF 2SWAP " AuthSource: {''}{s}{''} {s}{CRLF}"
  ELSE 2SWAP " \ AuthSource: {''}{s}{''} {s}{CRLF}" THEN
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
  NextWord S" AuthSource:" COMPARE 0<> IF POSTPONE \ EXIT THEN
  ParseStr 2>R NextWord BL SKIP 1 PARSE 2SWAP 2R> 2DUP
  " <tr><td><input type=checkbox name={''}{s}{''}></td><td>{s}</td><td>{s}</td><td>{s}</td></tr>{CRLF}"
  Srcs @ S+
;
