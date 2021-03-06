<?xml version="1.0" encoding="UTF-8" ?>

<!-- Génération du fichier d'en-tête -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >
<xsl:output method="text" />

<xsl:template match="/">

<xsl:for-each select="class" >

/**
	<xsl:value-of select="description" />
**/
class <xsl:value-of select="name" /> {

	private :
	<!-- liste des attributs privés de la classe -->
		<!-- type nomAttr; -->
	/**
	<xsl:for-each select="class/param/var[public = 'false']" >
		<xsl:value-of select="concat(name,' : ',type)" />
			<xsl:value-of select="description" />
	</xsl:for-each>
	**/
	<xsl:for-each select="class/param/var[public = 'false']" >
		<xsl:value-of select="type" /> <xsl:value-of select="name" />;
	</xsl:for-each>
	
	public :
	<!-- liste des attributs public de la classe -->
		<!-- type nomAttr; -->
	/**
	<xsl:for-each select="class/param/var[public = 'true']" >
		<xsl:value-of select="concat(name,' : ',type)" />
			<xsl:value-of select="description" />
	</xsl:for-each>
	**/
	<xsl:for-each select="class/param/var[public = 'true']" >
		<xsl:value-of select="type" /> <xsl:value-of select="name" />;
	</xsl:for-each>
	
	<!-- liste des méthodes -->
		<!-- type fonctionName( type1, type2, ); -->
	<xsl:for-each select="class/function" >
	/**
		<xsl:value-of select="description" />
	**/
		<xsl:value-of select="concat(return/type, ' ', name" /> ( <xsl:for-each select="param/var" > <xsl:value-of select="type" >, </xsl:for-each> );
	</xsl:for-each>

};
</xsl:for-each>

<!-- liste des fonctions -->
	<!-- type fonctionName( type1, type2, ); -->
<xsl:for-each select="function" >
	/**
		<xsl:value-of select="description" />
	**/
	<xsl:value-of select="concat(return/type, ' ', name" /> ( <xsl:for-each select="param/var" > <xsl:value-of select="type" >, </xsl:for-each> );
</xsl:for-each>

</xsl:template>
</xsl:stylesheet>
