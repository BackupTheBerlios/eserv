<?xml version="1.0" encoding="windows-1251"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
            indent="yes"
            encoding="windows-1251"
            />

<!-- =================================================== -->
<xsl:template match="menu">
<p/><xsl:value-of select="@label"/><br/>
<xsl:apply-templates mode="submenu"/>
</xsl:template>

<!-- =================================================== -->
<xsl:template match="menu" mode="submenu">
<div id="{@id}_d" class="menu_div">
<a onClick="expand('{@id}')">
<img src="/images/plus.gif" border="0" alt="+" width="9" height="9" id="img{@id}"/></a>

<a href="{@value}"> <xsl:value-of select="@label"/> </a>

<ul id="{@id}" class="Hidden">
<xsl:apply-templates/>
</ul>
</div>
</xsl:template>

<!-- =================================================== -->
<xsl:template match="menuitem">
<li><a class="item" href="{@value}"> <xsl:value-of select="@label"/> </a></li>
<xsl:apply-templates/>
</xsl:template>
<!-- =================================================== -->
</xsl:stylesheet>
