WINAPI: OpenProcess      KERNEL32.DLL
WINAPI: TerminateProcess KERNEL32.DLL

: IsServiceStarted
  " ..\..\{PROGFILE}.pid" STR@ DELETE-FILE 4 >
;
: RunBat ( addr u -- ) { \ nul }
  WinNT?
  IF " cmd.exe /c {s}" ELSE " command.com /c {s}" THEN STR@
  S" NUL" R/W OPEN-FILE THROW -> nul
  nul nul 2SWAP ChildApp THROW
  1000 PAUSE
  ( -1 OVER WaitForSingleObject DROP) CLOSE-FILE THROW
  nul CLOSE-FILE THROW
;
: StartService
  WinNT?
  IF " ..\..\start_{PROGFILE}.bat" STR@ RunBat
  ELSE " ..\..\{PROGFILE}.exe" STR@ StartApp DROP 1000 PAUSE THEN
  IsServiceStarted
  IF " The {PROGNAME} service is started OK" 
  ELSE " The {PROGNAME} is FAILED to start" THEN STR@
;
: StopService
  WinNT?
  IF " ..\..\stop_{PROGFILE}.bat" STR@ RunBat
  ELSE " ..\..\{PROGFILE}.pid" STR@ INCLUDED
     0 0xFFF OpenProcess 1 SWAP TerminateProcess DROP
     1000 PAUSE
  THEN
  IsServiceStarted 0=
  IF " The {PROGNAME} service is stopped OK" 
  ELSE " The {PROGNAME} is FAILED to stop" THEN STR@
;
