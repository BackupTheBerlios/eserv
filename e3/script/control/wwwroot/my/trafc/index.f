<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Proxy control</title>
<link rel="stylesheet" href="/my/style.css">
</head>


<body topmargin="0" leftmargin="10" marginheight="0" marginwidth="0"
bgcolor="#E0F0F0" text="#000000" link="#000099" alink="#0000ff"
vlink="#000099" >


{ 
  " ..\..\Eproxy\conf\http-proxy\plugins\TrafC\scripts\" 
  STR@ +ModuleDirName SOURCE-NAME!

  S" stat_quotas.f"   Included
  S" stat_quotas_u.f" Included
  S" "
}

<h2>Статистика Quota-каналов</h2>
<h3>Пользователь: {UserName}</h3>

<font color=red>
{S" action" IsSet [IF] DoAction [ELSE] S" " [THEN] }</font>
<hr>


<form action=stat_quotas_table.f>
<input type=hidden name=action value=show>
<input type=hidden name=noskin value=on>

<table border=0 cellspacing=10>

<tr> <td>

<table border=0 cellspacing=20>
<tr> <td VALIGN=top>   


<h3> <input type=radio name=ShowAll value=FALSE> Фильтр </h3>

<font face="Courier New">
<table border=1>
<tr><th>on/off</th><th>Канал</th></tr>
{GetNames}
</table>
</font>

</td> 

<td VALIGN=top> 

<h3> <input type=radio name=ShowAll value=TRUE checked> Все каналы  </h3> 

<input type=submit value="Показать">

</td>
</tr>

</table>
</td>
</tr>

<tr>
<td>

<h3 align=center> Журнал </h3>
<SELECT SINGLE NAME=logfile_selected SIZE=5>
{GetFileList}
</SELECT>
<br>
<p> По умолчанию выбирается текущий (последний) журнал 
<input type=submit value="Ok">             </p>

</td>
</tr>

</table>

</form>


</body>
