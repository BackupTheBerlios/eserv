<?xml version="1.0" encoding="windows-1251"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
            indent="yes"
            encoding="windows-1251"
            />
<xsl:template match="/">
<html xmlns="http://www.w3.org/1999/xhtml">

<head><title>���������� �����</title></head>
<body>
<h1>���������� �����</h1>

������:
���: <xsl:value-of select="MailStat/Period/YYYY"/>
�����: {PrevMonth} <xsl:value-of select="MailStat/Period/MM"/> {NextMonth}
<br/>Email: <xsl:value-of select="MailStat/Email"/>

<h2>�������� �����</h2>

<table border="1">
<tr><th>N</th><th>Email �����������</th><th>���������</th><th>������</th></tr>

<xsl:for-each select="MailStat/RecvMail/Row">
  <tr>
    <td><xsl:value-of select="@N"/></td>
    <td><xsl:value-of select="Email"/></td>
    <td align="right"><xsl:value-of select="Msgs"/></td>
    <td align="right"><xsl:value-of select="Total"/></td>
  </tr>
</xsl:for-each>

</table>

<h2>��������, �� ��������������� ����</h2>

<table border="1">
<tr><th>N</th><th>Email �����������</th><th>���������</th><th>������</th></tr>

<xsl:for-each select="MailStat/RecvSpam/Row">
  <tr>
    <td><xsl:value-of select="@N"/></td>
    <td><xsl:value-of select="Email"/></td>
    <td align="right"><xsl:value-of select="Msgs"/></td>
    <td align="right"><xsl:value-of select="Total"/></td>
  </tr>
</xsl:for-each>

</table>

</body>
</html>

</xsl:template>
</xsl:stylesheet>
