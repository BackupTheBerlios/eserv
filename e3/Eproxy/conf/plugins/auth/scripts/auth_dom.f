WARNING 0!

WINAPI: MoveFileExA KERNEL32.DLL

USER Srcs
USER Dom
USER NEW-FILE


: ShowSrcs { \ h -- addr u }
  "" Srcs !
  INCLUDED
  Srcs @ STR@
;
: AuthSource:
  ParseStr 2>R NextWord BL SKIP 1 PARSE 2SWAP 2R> 2DUP
  " <option value={''}{s}{''}>{s} ({s} {s})</option>{CRLF}"
  Srcs @ S+
;

: ModFile ( xt -- )
  S" ..\AuthDomains.rules.txt.new" R/W CREATE-FILE THROW NEW-FILE !
  ALSO EXECUTE
  S" ..\AuthDomains.rules.txt" INCLUDED
  PREVIOUS
  S" action" EVALUATE S" add" COMPARE 0=
  IF " Domain: {domain} {''}{source}{''}{CRLF}"
     STR@ NEW-FILE @ WRITE-FILE THROW
  THEN
  NEW-FILE @ CLOSE-FILE THROW NEW-FILE 0!
  1 S" ..\AuthDomains.rules.txt" DROP S" ..\AuthDomains.rules.txt.new" DROP 
  MoveFileExA 1 <> THROW
;

InVoc{ DELETE-ACTION
: Domain:
  ParseStr IsSet 0= POSTPONE \
  IF SOURCE " {s}{CRLF}"
     STR@ NEW-FILE @ WRITE-FILE THROW
  THEN
;
}PrevVoc

InVoc{ ADD-ACTION
: Domain:
  SOURCE " {s}{CRLF}" POSTPONE \
  STR@ NEW-FILE @ WRITE-FILE THROW
;
}PrevVoc

InVoc{ ACTIONS
: delete
  ['] DELETE-ACTION ModFile
  " Delete OK" STR@
;
: add
  ['] ADD-ACTION ModFile
  " Add OK" STR@
;
}PrevVoc

: Domain:
  ParseStr ParseStr 2SWAP 2DUP
  " <tr><td><input type=checkbox name={''}{s}{''}></td><td>{s}</td><td>{s}</td></tr>{CRLF}"
  Dom @ S+
;
: ShowDomains { \ h -- addr u }
  "" Dom !
  INCLUDED
  Dom @ STR@
;
