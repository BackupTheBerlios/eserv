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

<!-- автоперевод названия таблицы по trans.xml -->
<xsl:variable name="tabl" select="Table/@Name"/>
  <xsl:variable name="tabltran" select="document('trans.xml')/Trans/*[name()=$tabl]"/>
  <xsl:variable name="table">
  <xsl:choose>
     <xsl:when test="string-length($tabltran)=0">
       <xsl:value-of select="$tabl"/>
     </xsl:when>
     <xsl:otherwise>
       <xsl:value-of select="$tabltran"/>
     </xsl:otherwise>
  </xsl:choose>
  </xsl:variable>

<xsl:variable name="r" select="Table/@CurrentRow"/>

<head><title><xsl:value-of select="$table"/></title>
<link rel="stylesheet" href="/fs/table_style.css"/>
</head>
<body>
<h1><xsl:value-of select="$table"/></h1>
<h2><xsl:value-of select="Table/@RunSql"/>
<font color="red"><xsl:value-of select="Table/@Error"/></font></h2>

<form action="table.f">
<table border="1">
<tr><th>N</th>
<!-- автоперевод заголовков таблицы по trans.xml -->
<xsl:for-each select="Table/Row[1]/*">
<th>
  <xsl:variable name="nam" select="name()"/>
  <xsl:variable name="tran" select="document('trans.xml')/Trans/*[name()=$nam]"/>
  <xsl:choose>
     <xsl:when test="string-length($tran)=0">
       <xsl:value-of select="name()"/>
     </xsl:when>
     <xsl:otherwise>
       <xsl:value-of select="$tran"/>
     </xsl:otherwise>
  </xsl:choose>
</th>
</xsl:for-each>
</tr>
<xsl:apply-templates select='Table/Row'/>
</table>
<select name="runsql">
<option>
<xsl:attribute name="value">delete_<xsl:value-of select='Table/@Name'/></xsl:attribute>
Удалить</option>
</select>
<input type="hidden" name="table">
<xsl:attribute name="value"><xsl:value-of select='Table/@Name'/></xsl:attribute>
</input>
<input type="hidden" name="key">
<xsl:attribute name="value"><xsl:value-of select="name(Table/Row[1]/*[1])"/></xsl:attribute>
</input>
<input type="submit" value="Выполнить"/>
</form>

<xsl:if test="$r &gt; 0">

<form action="table.f">
<table border="1">
<xsl:for-each select="Table/Row[@N=$r]/*">
<tr><td><b>
  <xsl:variable name="nam" select="name()"/>
  <xsl:variable name="tran" select="document('trans.xml')/Trans/*[name()=$nam]"/>
  <xsl:choose>
     <xsl:when test="string-length($tran)=0">
       <xsl:value-of select="name()"/>
     </xsl:when>
     <xsl:otherwise>
       <xsl:value-of select="$tran"/>
     </xsl:otherwise>
  </xsl:choose>
</b></td>
<td><input size="50">
<xsl:attribute name="name"><xsl:value-of select="name()"/></xsl:attribute>
<xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
</input>
</td>
</tr>
</xsl:for-each>
</table>

<select name="runsql">
<option>
<xsl:attribute name="value">insert_<xsl:value-of select='Table/@Name'/></xsl:attribute>
Добавить</option>
<!--<option>
<xsl:attribute name="value">update_<xsl:value-of select='Table/@Name'/></xsl:attribute>
Применить</option>-->
</select>
<input type="hidden" name="table">
<xsl:attribute name="value"><xsl:value-of select='Table/@Name'/></xsl:attribute>
</input>
<input type="submit" value="Выполнить"/>
</form>
</xsl:if>


</body>
</html>

</xsl:template>

<!-- Строки основной таблицы -->
<xsl:template match="Row">
<tr>
<xsl:if test="position() mod 2 = 0">
<xsl:attribute name="class">row2</xsl:attribute>
</xsl:if>
<td><input type="checkbox">
<xsl:attribute name="name"><xsl:value-of select="./*[1]"/></xsl:attribute>
</input>
<a title="Изменить"><xsl:attribute name="href">table.f?table=<xsl:value-of select="/Table/@Name"/>&amp;r=<xsl:value-of select="position()"/>
</xsl:attribute>
<xsl:value-of select="position()"/></a>
</td>
<xsl:apply-templates select='./*'/>
</tr>
</xsl:template>

<xsl:template match="DOMAIN">
<td>
<a>
<xsl:attribute name="href">domains.f?domain=<xsl:value-of select="."/>&amp;action=edit</xsl:attribute>
<xsl:value-of select="."/>
</a>
</td>
</xsl:template>

<xsl:template match="*">
<td><xsl:value-of select="."/></td>
</xsl:template>

</xsl:stylesheet>
