: /is
  ParseStr DUP 0=
  IF 2DROP ProgName @ COUNT THEN
  WinNT?
  IF CreateService IF 0 ELSE GetLastError THEN
  ELSE InstallService95 THEN
  ?DUP IF 241 ELSE 240 THEN LOG
  BYE
;
: /us
  ParseStr DUP 0=
  IF 2DROP ProgName @ COUNT THEN
  WinNT?
  IF DeleteService IF 0 ELSE GetLastError THEN
  ELSE UninstallService95 THEN
  ?DUP IF 243 ELSE 242 THEN LOG
  BYE
;

: RUN-SERVICE
  WinNT?
  IF ProgName @ COUNT StartService
     0= IF ( ��������� �� StartService ��� NT - ������ ������� ������� ) EXIT THEN
  THEN
  ( �� ���������� ��� ������, ��� Win9x, ������ �������� )
  -1 PAUSE ( ����, � ������� ����� �������� )
;
