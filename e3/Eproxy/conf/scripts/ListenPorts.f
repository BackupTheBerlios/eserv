WARNING 0!

WINAPI: MoveFileExA KERNEL32.DLL

: Listen: { \ s -- addr u }
  "" -> s
  BEGIN
    REFILL SOURCE NIP 0 > AND
  WHILE
    NextWord \ port
    NextWord DUP 0= IF 2DROP S" All" THEN \ interface
    2SWAP SOURCE
    " <tr><td><input type=checkbox name={''}{s}{''}></td><td>{s}</td><td>{s}</td></tr>{CRLF}" s S+
  REPEAT
  s STR@ POSTPONE \
;

USER uInterfaces

: ListInterface
  NtoA 2DUP " <option value={s}>{s}{CRLF}" uInterfaces @ S+
;
: ListInterfaces ( -- addr u )
  S" <select name=interface>" uInterfaces S!
  ['] ListInterface ForEachIP DROP
  S" </select>" uInterfaces @ STR+
  uInterfaces @ STR@
;

USER NEW-FILE

InVoc{ ADD-ACTION

: Listen: { \ s -- addr u }
  " Listen:{CRLF}" -> s
  BEGIN
    REFILL SOURCE NIP 0 > AND
  WHILE
    SOURCE s STR+
    CRLF s STR+
  REPEAT
  " {port} {interface}{CRLF}{CRLF}" s S+
  s STR@ NEW-FILE @ WRITE-FILE THROW
  POSTPONE \
;

}PrevVoc

InVoc{ DEL-ACTION

: Listen: { \ s -- addr u }
  " Listen:{CRLF}" -> s
  BEGIN
    REFILL SOURCE NIP 0 > AND
  WHILE
    SOURCE BL [CHAR] + CONVERT 
    SOURCE IsSet 0=
    SOURCE [CHAR] + BL CONVERT 
    IF SOURCE s STR+ CRLF s STR+ THEN
  REPEAT
  CRLF s STR+
  s STR@ NEW-FILE @ WRITE-FILE THROW
  POSTPONE \
;

}PrevVoc

: ModFile ( xt -- )
  S" ..\ListenPorts.rules.txt.new" R/W CREATE-FILE THROW NEW-FILE !
  ALSO EXECUTE
  S" ..\ListenPorts.rules.txt" INCLUDED
  PREVIOUS
  NEW-FILE @ CLOSE-FILE THROW NEW-FILE 0!
  1 S" ..\ListenPorts.rules.txt" DROP S" ..\ListenPorts.rules.txt.new" DROP 
  MoveFileExA 1 <> THROW
;
InVoc{ ACTIONS
: add
  ['] ADD-ACTION ModFile
  " Add OK" STR@
;
: delete
  ['] DEL-ACTION ModFile
  S" Delete OK"
;
}PrevVoc

: NOTFOUND \ обработка незнакомых директив
  NEW-FILE @ 
  IF 2DROP SOURCE NEW-FILE @ WRITE-FILE THROW 
     CRLF NEW-FILE @ WRITE-FILE THROW 
  ELSE 2DROP POSTPONE \ THEN
;