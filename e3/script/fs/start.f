WINAPI: OpenProcess      KERNEL32.DLL
WINAPI: TerminateProcess KERNEL32.DLL
WINAPI: SetCurrentDirectoryA         KERNEL32.DLL
WINAPI: GetCurrentDirectoryA         KERNEL32.DLL
WINAPI: CreatePipe            KERNEL32.DLL
WINAPI: DuplicateHandle       KERNEL32.DLL
WINAPI: GetCurrentProcess     KERNEL32.DLL

00000002 CONSTANT DUPLICATE_SAME_ACCESS

: DUP-HANDLE-INHERITED ( h1 -- h2 ior )
  0 >R
  >R DUPLICATE_SAME_ACCESS TRUE 0 RP@ CELL+
  GetCurrentProcess R> GetCurrentProcess DuplicateHandle
  R> SWAP ERR
;

: InitPROGNAME
  S" service" IsSet 
  IF S" service" EVALUATE 2DUP 
     S" PROGNAME" SetParam
     S" PROGFILE" SetParam
  THEN
;
InitPROGNAME

: RunBat ( addr u -- ) { \ nul }
  WinNT?
  IF " cmd.exe /c {''}{s}{''}" ELSE " command.com /c {''}{s}{''}" THEN STR@
  S" NUL" R/W OPEN-FILE THROW -> nul
  nul DUP-HANDLE-INHERITED THROW -> nul
  H-STDIN nul 2SWAP ChildApp THROW
  1000 PAUSE
  ( -1 OVER WaitForSingleObject DROP) CLOSE-FILE THROW
  nul CLOSE-FILE THROW
;
: StartService
  WinNT?
  IF " {ModuleDirName}..\..\{PROGFILE}\start_service.bat"
     STR@ RunBat
  ELSE " {ModuleDirName}..\..\{PROGFILE}\{PROGFILE}.exe" 
       STR@ StartApp DROP 3000 PAUSE
  THEN
  IsServiceStarted 0= WinNT? AND \ сервис не установлен, запустим exe
  IF
    " {ModuleDirName}..\..\{PROGFILE}\{PROGFILE}.exe" 
    STR@ StartApp DROP 3000 PAUSE
  THEN
  IsServiceStarted
  IF " The {PROGNAME} service is started OK" 
  ELSE " The {PROGNAME} is FAILED to start" THEN STR@
;
: StopService
  WinNT?
  IF " {ModuleDirName}..\..\{PROGFILE}\stop_service.bat" STR@ RunBat
  ELSE " {ModuleDirName}..\..\{PROGFILE}\{PROGFILE}.pid" STR@ INCLUDED
     0 0xFFF OpenProcess 1 SWAP TerminateProcess DROP
     1000 PAUSE
  THEN
  IsServiceStarted WinNT? AND \ сервис не установлен, убьем exe
  IF 3000 PAUSE
     " {ModuleDirName}..\..\{PROGFILE}\{PROGFILE}.pid" STR@ INCLUDED
     0 0xFFF OpenProcess 1 SWAP TerminateProcess DROP
     1000 PAUSE
  THEN
  IsServiceStarted 0=
  IF " The {PROGNAME} service is stopped OK" 
  ELSE " The {PROGNAME} is FAILED to stop" THEN STR@
;
: InstallService
  ModuleDirName " {s}\..\.." STR@ DROP SetCurrentDirectoryA DROP ( это не коды ошибок :)
  PAD 5000 GetCurrentDirectoryA PAD SWAP
  " cmd.exe /c {''}{s}\utils\install_service.bat{''} {service}" STR@ StartAppWait DROP
  S" OK"
;
: UninstallService
  ModuleDirName " {s}\..\.." STR@ DROP SetCurrentDirectoryA DROP ( это не коды ошибок :)
  PAD 5000 GetCurrentDirectoryA PAD SWAP
  " cmd.exe /c {''}{s}\utils\uninstall_service.bat{''} {service}" STR@ StartAppWait DROP
  S" OK"
;