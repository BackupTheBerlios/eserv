[UNDEFINED] init-trafc [IF] \EOF [THEN]
init-trafc \ initialization

\ ClientTrafC \ ���������� ������ TrafC ������������� �� �������  acTCP <--> client
 ServerTrafC \ ���������� ������ TrafC ������������� �� �������  inet <--> acTCP
                ( � ��������, ��������� ��� ������-��������. )
\ StopTrafC   \ ������������� ������ TrafC

Include ext\index.f
\ Include DefBands.rules.txt
\ Include DefQuotas.rules.txt
