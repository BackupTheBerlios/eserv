<?xml version="1.0" encoding="windows-1251"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
<html>
<head><title>���������� �� �������</title></head>
<body>
<h1>���������� �� �������</h1>

������:
���: <xsl:value-of select="TrafficStat/Period/YYYY"/>
�����: {PrevMonth} <xsl:value-of select="TrafficStat/Period/MM"/> {NextMonth}

<h2>����� ������ �� ���������� IP</h2>

����� �������� IP �� �� ��������� ����, ���� ��������
������������� ������� (SMTP, HTTP, etc) ��� ���������������
������� ����������������� �������.

<table border="1">
<tr><th>N</th><th>IP �������</th><th># �����������</th>
<th>�������� �������</th><th>��������� �� �������</th>
<th>������� ��. ��������</th><th>������� ��. �������</th></tr>

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

<h2>������ �� ����������</h2>

<table border="1">
<tr><th>N</th><th>��������</th><th># �����������</th>
<th>�������� �������</th><th>��������� �� �������</th>
<th>������� ��. ��������</th><th>������� ��. �������</th></tr>

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
