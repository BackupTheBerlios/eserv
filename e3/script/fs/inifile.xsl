<?xml version="1.0" encoding="windows-1251"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
            indent="yes"
            encoding="windows-1251"
            />
<!-- =================================================== -->
<xsl:template match="/Ini">
<xsl:apply-templates mode="sect"/>
</xsl:template>

<!-- =================================================== -->
<xsl:template match="*" mode="keys">
<tr><td><xsl:value-of select="name()"/></td>
<td>
<xsl:if test="@file='user'">
<xsl:apply-templates select="." mode="user-value"/>
</xsl:if>
<xsl:if test="not(@file='user')">
<xsl:apply-templates select="." mode="def-value"/>
</xsl:if>
</td></tr>
</xsl:template>

<!-- =================================================== -->
<xsl:template match="*" mode="sect">

<a onClick="expand('{name()}_ini')">
<img src="/images/plus.gif" border="0" alt="+" width="9" height="9" id="img{name()}_ini"/>
<b><xsl:value-of select="name()"/></b>
</a>

<div ID="{name()}_ini" class="Hidden">
<blockquote>
<form action="{Table/@Name}" method="POST">
<table border="1">
<xsl:apply-templates mode="keys"/>
</table>
<input type="hidden" name="SectionName" value="{name()}"/>
<input type="submit" value="Применить"/>
</form>
</blockquote>
</div><br/>
</xsl:template>

<!-- =================================================== -->
<xsl:template match="*" mode="def-value">
<input name="{name()}" value="{.}" class="def-option" size="50" />
</xsl:template>

<!-- =================================================== -->
<xsl:template match="*" mode="user-value">
<input name="{name()}" value="{.}" class="user-option" size="50" />
</xsl:template>

<!-- =================================================== -->
</xsl:stylesheet>
