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

<head><title>Статистика почты</title></head>
<body>
<h1>Статистика почты</h1>

Период:
Год: <xsl:value-of select="MailStat/Period/YYYY"/>
Месяц: {PrevMonth} <xsl:value-of select="MailStat/Period/MM"/> {NextMonth}
<br/>Email: <xsl:value-of select="MailStat/Email"/>

<h2>Принятая почта</h2>

<table border="1">
<tr><th>N</th><th>Email отправителя</th><th>Сообщений</th><th>Размер</th></tr>

<xsl:for-each select="MailStat/RecvMail/Row">
  <tr>
    <td><xsl:value-of select="@N"/></td>
    <td><xsl:value-of select="Email"/></td>
    <td align="right"><xsl:value-of select="Msgs"/></td>
    <td align="right"><xsl:value-of select="Total"/></td>
  </tr>
</xsl:for-each>

</table>

<h2>Принятый, но отфильтрованный спам</h2>

<table border="1">
<tr><th>N</th><th>Email отправителя</th><th>Сообщений</th><th>Размер</th></tr>

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
