USER Ipa

: Mask: ( "mask" -- mask )
  0 0 NextWord >NUMBER
  1- 0 MAX >R 1+ >R D>S 
  0 0 R> R> >NUMBER 1- 0 MAX >R 1+ >R D>S 8 LSHIFT +
  0 0 R> R> >NUMBER 1- 0 MAX >R 1+ >R D>S 16 LSHIFT +
  0 0 R> R> >NUMBER 1- 0 MAX 2DROP D>S 24 LSHIFT +
;
: IP-Auth:
  ParseStr ParseStr 2SWAP " {s} {s}" STR@ 
  ParseStr 2SWAP 2DUP
  " <tr><td><input type=checkbox name={''}{s}{''}></td><td>{s}</td><td>{s}</td></tr>{CRLF}"
  Ipa @ S+
;
: IpAuths
  "" Ipa !
  INCLUDED
  Ipa @ STR@
;

WINAPI: MoveFileExA KERNEL32.DLL

USER NEW-FILE

: ModFile ( xt -- )
  S" ..\IpAuth.rules.txt.new" R/W CREATE-FILE THROW NEW-FILE !
  ALSO EXECUTE
  S" ..\IpAuth.rules.txt" INCLUDED
  PREVIOUS
  S" action" EVALUATE S" add" COMPARE 0=
  IF " IP-Auth: {ip} {username}{CRLF}"
     STR@ NEW-FILE @ WRITE-FILE THROW
  THEN
  NEW-FILE @ CLOSE-FILE THROW NEW-FILE 0!
  1 S" ..\IpAuth.rules.txt" DROP S" ..\IpAuth.rules.txt.new" DROP 
  MoveFileExA 1 <> THROW
;
: ValidateSubnet { \ a u a2 u2 }
  ParseStr GetHostIP THROW NtoA " {s}" STR@ -> u -> a
  Mask: NtoA -> u2 -> a2
  a2 u2 S" 0.0.0.0" COMPARE 0=
  IF S" 255.255.255.255" -> u2 -> a2 THEN
  a2 u2 a u " {s} {s}" STR@ S" ip" SetParam
;

InVoc{ DELETE-ACTION
: IP-Auth:
  ParseStr ParseStr 2SWAP " {s}+{s}" STR@ IsSet 0= POSTPONE \
  IF SOURCE " {s}{CRLF}"
     STR@ NEW-FILE @ WRITE-FILE THROW
  THEN
;
}PrevVoc

InVoc{ ADD-ACTION
: IP-Auth:
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
  S" ip" EVALUATE ['] ValidateSubnet EVALUATE-WITH
  ['] ADD-ACTION ModFile
  " Add OK" STR@
;
}PrevVoc
