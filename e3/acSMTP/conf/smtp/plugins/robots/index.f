( ~pig)
\ �������������� ���������� ������

USER $RobotFileName				\ ��� �������� ����� ����� ����� ������

\ ������ � ������ �������������� ����� ������
: RobotFileName ( -- str ) $RobotFileName @ ;
: ROBOTFILENAME ( -- addr u ) RobotFileName STR@ ;
: CreateRobotFile ( addr u -- )
  2DUP FixFilename				\ ��������� ��� ����� �� ������������ ��������
  2DUP " {ModuleDirName}{s}" STR@ $RobotFileName S!	\ ������������� ������ ���� � �����
  CopyCurrentFileTo				\ ������� ����� �����
;
: CreateRobotFile: ( "file" -- )
  ParseStr					\ ������� ��� �����
  CreateRobotFile				\ ������� ��������� ����� ��� ������
;
