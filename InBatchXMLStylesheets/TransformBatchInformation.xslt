<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:bml="http://www.wbf.org/xml/B2MML-V0401" xmlns:bmlx="http://www.wbf.org/xml/B2MML-V0401-AllExtensions">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/">
      <NewDataSet>      
        <xsl:for-each select="bml:BatchInformation/bml:MasterRecipe">
          <SQL>
              <recipe_id>
                <xsl:value-of select="bml:ID"/>
              </recipe_id>
              <recipe_name>
                <xsl:value-of select="bmlx:Name"/>
              </recipe_name>
              <product_name>
                <xsl:value-of select="bml:Header/bml:ProductName"/>
              </product_name>
              <nominal_batch_size>
                <xsl:value-of select="bml:Header/bml:BatchSize/bml:Nominal"/>
              </nominal_batch_size>
              <min_batch_size>
                <xsl:value-of select="bml:Header/bml:BatchSize/bml:Min"/>
              </min_batch_size>
              <max_batch_size>
                <xsl:value-of select="bml:Header/bml:BatchSize/bml:Max"/>
              </max_batch_size>
            </SQL>               
        </xsl:for-each>
      </NewDataSet>
    </xsl:template>
</xsl:stylesheet> 