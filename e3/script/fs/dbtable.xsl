<?xml version="1.0" encoding="windows-1251"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
            indent="yes"
            encoding="windows-1251"
            />
<!-- =================================================== -->
<xsl:template match="/">
<xsl:apply-templates />
<xsl:variable name="r" select="/Table/@CurrentRow"/>
<xsl:if test="$r &gt; 0">
<xsl:apply-templates mode="form" />
</xsl:if>
</xsl:template>

<!-- =================================================== -->
<xsl:template match="Table">
<h1><xsl:call-template name="translateName" /></h1>
<form action="{Table/@Name}">
<table border="1" class="small">
<xsl:apply-templates select="Row[1]" mode="header"/>
<xsl:variable name="sortby" select="@SortBy"/>
<xsl:apply-templates>
  <xsl:sort select="./*[position()=$sortby]"/>
</xsl:apply-templates>
</table>
<xsl:call-template name="tableActions" />
</form>
</xsl:template>

<!-- =================================================== -->
<xsl:template match="*" mode="field">
<tr><td><b><xsl:call-template name="translate" /></b></td>
<td><input size="50">
<xsl:attribute name="name">f_<xsl:value-of select="name()"/></xsl:attribute>
<xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
</input>
</td>
</tr>
</xsl:template>

<!-- =================================================== -->
<xsl:template match="Table" mode="form">

<form action="{@Name}">
<table border="1" class="small">
<xsl:variable name="r" select="@CurrentRow"/>
<xsl:apply-templates select="Row[@N=$r]/*" mode="field"/>
</table>
<xsl:call-template name="rowActions" />
</form>

</xsl:template>

<!-- =================================================== -->
<xsl:template match="Row">
<tr>

<xsl:if test="position() mod 2 = 0">
<xsl:attribute name="class">row2</xsl:attribute>
</xsl:if>

<td>
<input type="checkbox">
<xsl:attribute name="name"><xsl:value-of select="./*[1]"/></xsl:attribute>
</input>

<a title="Изменить" href="{/Table/@Name}?r={@N}">
<xsl:value-of select="position()"/></a>
</td>

<xsl:apply-templates />
</tr>
</xsl:template>

<!-- =================================================== -->
<xsl:template match="Row" mode="header">
<tr><th>N</th>
<xsl:apply-templates mode="header"/>
</tr>
</xsl:template>

<!-- =================================================== -->
<xsl:template match="*">
<td><xsl:value-of select="."/></td>
</xsl:template>

<!-- =================================================== -->
<xsl:template match="*" mode="header">
<th><a href="{/Table/@Name}?sortby={position()}"
title="Сортировать по {name()}">
<xsl:call-template name="translate" /></a>
</th>
</xsl:template>

<!-- ======= перевод ИМЕНИ текущего узла =============== -->

<xsl:template name="translate">
<xsl:variable name="field" select="name()"/>
<xsl:variable name="trans" select="document('dbtrans.xml')/Trans/*[name()=$field]"/>
<xsl:value-of select="$trans"/>
<xsl:if test="not($trans)"><xsl:value-of select="$field"/></xsl:if>
</xsl:template>

<!-- ======= перевод атрибута @Name текущего узла ====== -->

<xsl:template name="translateName">
<xsl:variable name="field" select="@Name"/>
<xsl:variable name="trans" select="document('dbtrans.xml')/Trans/*[name()=$field]"/>
<xsl:value-of select="$trans"/>
<xsl:if test="not($trans)"><xsl:value-of select="$field"/></xsl:if>
</xsl:template>

<!-- =================================================== -->
<xsl:template name="tableActions">
<select name="runsql">
<option value="delete_{/Table/@Name}">Удалить</option>
</select>
<input type="hidden" name="key" value="{name(/Table/Row[1]/*[1])}" />
<input type="submit" value="Выполнить"/>
</xsl:template>

<!-- =================================================== -->
<xsl:template name="rowActions">
<select name="runsql">
<option value="insert_{/Table/@Name}">Добавить</option>
</select>
<input type="submit" value="Выполнить"/>
</xsl:template>

<!-- =================================================== -->
</xsl:stylesheet>
