\ 10.2002
\ ���� ����� Logon ( ~ac\lib\win\access\NT_LOGON.F ) ��� NT4
\   ���� LOGON32_LOGON_NETWORK ������ LOGON32_LOGON_NETWORK_CLEARTEXT

WinNT? [IF] HERE 1 CELLS + @ 4 = [IF]

[UNDEFINED] JMP [IF]
: JMP   ( xt1 xt2 -- )   \  Name-new-ver Name-old-ver JMP
  0x0E9 OVER C!     \ jmp-code
  1+  DUP >R
  CELL+ - R> !
;               [THEN]

: NewLogon ( S"user" S"password" S"domain" -- token ior )
  DROP >R DROP >R DROP >R
  TOKEN LOGON32_PROVIDER_DEFAULT LOGON32_LOGON_NETWORK
  R> R> SWAP R> SWAP LogonUserA
  IF TOKEN @ FALSE ELSE 0 GetLastError THEN
;

' NewLogon ' Logon JMP

[THEN] [THEN]