<?xml version="1.0" encoding="windows-1251"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
<html>
<head><title>Статистика по трафику</title></head>
<body>
<h1>Статистика по трафику</h1>

Период:
Год: <xsl:value-of select="TrafficStat/Period/YYYY"/>
Месяц: {PrevMonth} <xsl:value-of select="TrafficStat/Period/MM"/> {NextMonth}

<h2>Общий трафик по клиентским IP</h2>

Может включать IP не из локальной сети, если работают
общедоступные сервисы (SMTP, HTTP, etc) или предпринимались
попытки неавторизованного доступа.

<table border="1">
<tr><th>N</th><th>IP клиента</th><th># Подключений</th>
<th>Передано клиенту</th><th>Прочитано от клиента</th>
<th>Внешний тр. передано</th><th>Внешний тр. принято</th></tr>

<xsl:for-each select="TrafficStat/Traffic/Row">
  <tr>
    <td><xsl:value-of select="@N"/></td>
    <td><xsl:value-of select="IP"/></td>
    <td align="right"><xsl:value-of select="CNT"/></td>
    <td align="right"><xsl:value-of select="WS"/></td>
    <td align="right"><xsl:value-of select="RS"/></td>
    <td align="right"><xsl:value-of select="OWS"/></td>
    <td align="right"><xsl:value-of select="ORS"/></td>
  </tr>
</xsl:for-each>

</table>

<h2>Трафик по протоколам</h2>

<table border="1">
<tr><th>N</th><th>Протокол</th><th># Подключений</th>
<th>Передано клиенту</th><th>Прочитано от клиента</th>
<th>Внешний тр. передано</th><th>Внешний тр. принято</th></tr>

<xsl:for-each select="TrafficStat/ProtoTraffic/Row">
  <tr>
    <td><xsl:value-of select="@N"/></td>
    <td><xsl:value-of select="PROTOCOL"/></td>
    <td align="right"><xsl:value-of select="CNT"/></td>
    <td align="right"><xsl:value-of select="WS"/></td>
    <td align="right"><xsl:value-of select="RS"/></td>
    <td align="right"><xsl:value-of select="OWS"/></td>
    <td align="right"><xsl:value-of select="ORS"/></td>
  </tr>
</xsl:for-each>

</table>

</body>
</html>
</xsl:template>
</xsl:stylesheet>
