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

<head><title>��������� ������</title></head>
<body>
<h1>������</h1>
����� �� ���������: <b>
<a>
<xsl:attribute name="href">domains.f?domain=<xsl:value-of select="Domains/DefaultDomain"/>&amp;action=edit</xsl:attribute>
<xsl:value-of select="Domains/DefaultDomain"/></a>
</b>
<p />
������ ����������� �� ���������: <b><xsl:value-of select="Domains/DefaultAuth"/></b>
<p />
�������� ����������� �� ���������: <b><xsl:value-of select="Domains/DefaultAuthSource"/></b>
<p />
<h2>��������� ������</h2>
<table border="1">
<tr><th>N</th><th>�����</th><th>�������� �����������</th><th>�������� �������</th>
<th>���</th><th>������������ ���</th><th>A</th>
</tr>

<xsl:for-each select="Domains/List/Row">
  <tr>
    <td><xsl:value-of select="@N"/></td>
    <td>
<a>
<xsl:attribute name="href">domains.f?domain=<xsl:value-of select="DOMAIN"/>&amp;action=edit</xsl:attribute>
<xsl:value-of select="DOMAIN"/></a>
    </td>
    <td><xsl:value-of select="AUTH"/> (<xsl:value-of select="AUTH_TYPE"/>)</td>
    <td><xsl:value-of select="DIRECTORY"/></td>
    <td><xsl:value-of select="ACCEPT_NEU"/></td>
    <td><xsl:value-of select="FORWARD_NEU"/></td>
    <td><a>
<xsl:attribute name="href">domains.f?domain=<xsl:value-of select="DOMAIN"/>&amp;action=delete</xsl:attribute>X</a>
    </td>
  </tr>
</xsl:for-each>

</table>

<xsl:value-of select="Domains/CurrentDomain"/>:
<xsl:value-of select="Domains/Action"/>
<p />

<xsl:for-each select="Domains/Domain/Row[@N=1]">
<form action="domains.f">
<table border="1">
<tr><td>�����</td><td><input name="domain" size="50"><xsl:attribute name="value"><xsl:value-of select="DOMAIN"/></xsl:attribute></input></td></tr>
<tr><td>�������� �����������</td><td><input name="auth" size="50"><xsl:attribute name="value"><xsl:value-of select="AUTH"/></xsl:attribute></input></td></tr>
<tr><td>�������� �������</td><td><input name="directory" size="50"><xsl:attribute name="value"><xsl:value-of select="DIRECTORY"/></xsl:attribute></input></td></tr>
<tr><td>��������� ���</td><td><input name="accept_neu" size="50"><xsl:attribute name="value"><xsl:value-of select="ACCEPT_NEU"/></xsl:attribute></input></td></tr>
<tr><td>������������ ���</td><td><input name="forward_neu" size="50"><xsl:attribute name="value"><xsl:value-of select="FORWARD_NEU"/></xsl:attribute></input></td></tr>
</table>
<input type="submit" value="���������"/>
</form>
</xsl:for-each>

<h2>�������� �������� (������� ����������)</h2>

<table border="1">
<tr><th>N</th><th>�����</th><th>�������� �������</th>
</tr>

<xsl:for-each select="Domains/ExtList/Row">
  <tr>
    <td><xsl:value-of select="@N"/></td>
    <td><xsl:value-of select="DOMAIN"/></td>
    <td><xsl:value-of select="DIRECTORY"/></td>
  </tr>
</xsl:for-each>

</table>

</body>
</html>

</xsl:template>
</xsl:stylesheet>
