<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:bml="http://www.wbf.org/xml/B2MML-V0401" xmlns:bmlx="http://www.wbf.org/xml/B2MML-V0401-AllExtensions">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/">
      <NewDataSet>      
        <xsl:for-each select="bml:BatchInformation/bml:MasterRecipe/bml:RecipeElement">
        <xsl:if test="bmlx:UnitProcedureInformation">
            <xsl:for-each select="bmlx:UnitProcedureInformation/bmlx:ProcessInstance[not(preceding::bmlx:UnitProcedureInformation/bmlx:ProcessInstance/. = .)]">
              <SQL>    
                <processes_key>
                   <xsl:value-of select="../../../bml:ID"/> - <xsl:value-of select="." />
                </processes_key>
                <recipe_id>
                   <xsl:value-of select="../../../bml:ID"/>
                 </recipe_id>
                  <process_instance>   
                   <xsl:value-of select="." />
                  </process_instance>    
            </SQL>
            </xsl:for-each> 
        </xsl:if>               
        </xsl:for-each>
      </NewDataSet>
    </xsl:template>
</xsl:stylesheet> 