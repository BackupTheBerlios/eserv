\ �������� ������������� ����� �� ����� (������������ � rvm)
: MyFileExists ( addr u -- flag )
  { fa fu \ fdat fnam }
  /WIN32_FIND_DATA ALLOCATE THROW -> fdat	\ �������� ������ ��� ���������
  256 ALLOCATE THROW -> fnam			\ �������� ������ ��� ��� �����
  0 fnam fu + C!				\ ����� ��������� ������������
  fa fnam fu CMOVE				\ ����������� ��� �����
  fdat fnam FindFirstFileA			\ ��������� ����� �����
  DUP -1 <>					\ ����������� ���������� � ��������� �� ������������
  IF
    TRUE					\ ��� ������ ��������
    BEGIN
      fdat dwFileAttributes @ FILE_ATTRIBUTE_DIRECTORY AND AND	\ ���� ��� �������, ���� ������ ������ �� �������
    WHILE
      fdat OVER FindNextFileA 0<> 		\ ������ ��������� ����
    REPEAT
    FindClose DROP				\ ������� �����
    fdat dwFileAttributes @ FILE_ATTRIBUTE_DIRECTORY AND 0=	\ ������ �� ���� ���� ����?
  ELSE
    DROP FALSE					\ ��� ����� ������
  THEN
  fnam FREE THROW fdat FREE THROW		\ ���������� ������
;

\ ��������� ����� ������ ������ ��������� �����
: (MyCheckEmailForward) ( -- )
  " {SMTP[Out]}\{FIELD2}\{FIELD3}\*.*" STR@ MyFileExists	\ ���� �� ����� �� ��������?
  IF
     S" smtp\delivery\RunSendMailAppForward" EvalRules	\ ��, ������������ ��������
  THEN
;
