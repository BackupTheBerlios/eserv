\ API �����������, � ���������, ��������.
\ ���� Plugin ����� ��������, ���� ��������� �����������
\ �������������� ������ EXE. ���� ���, �� plugin �� ����������.

USER uInfectedMailFile		\ ��� �������� ����� ����� ������ � �������

\ �������� ������ �� ������
: ScanMailFile ( filea fileu -- true | false )
  AvScanFile
  IF VirusName S! TRUE
  ELSE VirusName 0! 2DROP FALSE THEN
;

\ ����������� ����������� ������ � �������� ����� ����� (~pig)
: MoveInfectedFileTo:
  ParseStr			\ ������� ��� �����
  2DUP uInfectedMailFile S!	\ ��������� ��� ���������
  MoveCurrentFileTo		\ ����������� ���� ������
;

\ ������� ����� ����� ����������� ������
: INFECTEDMAILFILE ( -- addr u )
  uInfectedMailFile @ STR@
;
