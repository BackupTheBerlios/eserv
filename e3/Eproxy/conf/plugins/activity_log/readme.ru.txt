Plugin activity_log

������ ������� �������� ������� ������� ��������
(�� ����� �� �������� �� ����������� � ������-�������)
� ���-���� activity.log.
������: UNIXDATE IP timeperiod_ms cps-in cps-out


��������� � ������������.

1. ����������� ����� ������� � �������� conf\plugins\activity_log\

2. ��� �������� ������� � conf\OnStartupPlugins.rules.txt �������� ������
    Plugin: plugins\activity_log

3. ��� ������� ���� � conf\OnDisconnect.rules.txt  �������� ������
    ActivityLOG

4. ��� ����������� �������������� ���������� ���� �������� � conf\http-proxy\wwwroot\
    ���� activity.html

5. ������������� Eproxy

6. ��� ���������� ������� http://eproxy:3130/activity.html
   ��������� ��������, �������� Opera 5.0, �� ���������� ������ �����
   ����� ���������.  ����� ���������� ���������� ������������
   ��� ������������� ����� ����� �����������.
   ������� Internet Explorer ������������ �������� ;)

_________________________________________________________

09.Oct.2001 Tue 19:28  Ruvim Pinka  <ruvim@forth.org.ru>