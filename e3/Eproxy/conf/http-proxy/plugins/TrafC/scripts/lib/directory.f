
[UNDEFINED] GetCurrentDirectoryA [IF]
WINAPI: GetCurrentDirectoryA    KERNEL32.DLL [THEN]
: $cdir ( -- )
  HERE 260 GetCurrentDirectoryA
  260 MIN  HERE SWAP
;
