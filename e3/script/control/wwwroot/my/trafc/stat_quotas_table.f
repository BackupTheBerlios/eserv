<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Proxy control</title>
<link rel="stylesheet" href="/my/style.css">
</head>


<body topmargin="0" leftmargin="10" marginheight="0" marginwidth="0"
bgcolor="#E0F0F0" text="#000000" link="#000099" alink="#0000ff"
vlink="#000099" >


<a name="TOP"></a>

{ 
  " ..\..\Eproxy\conf\http-proxy\plugins\TrafC\scripts\" 
  STR@ +ModuleDirName SOURCE-NAME!

  S" stat_quotas.f" Included
  S" stat_quotas_u.f" Included
  S" "
}

<H2> C��������� </H2>
<h3>������������: {UserName}</h3>

<p>
� ������� ��������� ���������� ������������� quota-�������:
���������� ����� �� ��������
� ����� ���������� ���� ����� ����� ������/�������� - � ��������� ������������.
</p>

<table border=1 cellpadding=1 cellspacing=1 width={TableWidth}>
<CAPTION>
������ <small> {LogName} </small> </CAPTION>
{GetHeader}
{GetStat}
{GetHeader}
</table>

<body>
</html>
