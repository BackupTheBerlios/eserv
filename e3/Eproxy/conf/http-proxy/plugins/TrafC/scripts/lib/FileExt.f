\ 15.Jan.2002 Tue 03:17

\ REQUIRE [IF]     lib\include\tools.f
\ REQUIRE WintNT?  ~ac\lib\win\winver.f

WINAPI: MoveFileExA KERNEL32.DLL
WINAPI: MoveFileA   KERNEL32.DLL

: RENAME-FILE   ( c-addr1 u1  c-addr2 u2 -- ior )
\ FILE EXT
\ Rename the file named by the character string c-addr1 u1 to the name
\ in the character string c-addr2 u2. ior is the implementation-defined
\ I/O result code. )
  DROP NIP  SWAP  MoveFileA  ERR
;

\ such method, as below - for scripts only ... 

WinNT? [IF]

: MOVE-FILE   ( c-addr1 u1  c-addr2 u2 -- ior )
\ if file named by the character string c-addr2 u2 already exist,
\ it be replace by a source file
  DROP NIP SWAP
  1 ROT ROT
  MoveFileExA 1 <> IF GetLastError ELSE 0 THEN
  ( not support by win95 )
;

       [ELSE]

: MOVE-FILE   ( c-addr1 u1  c-addr2 u2 -- ior )
\ if file named by the character string c-addr2 u2 already exist,
\ it be replace by a source file
  2DUP DELETE-FILE DROP
  RENAME-FILE
;
       [THEN]

