<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:bml="http://www.wbf.org/xml/B2MML-V0401" xmlns:bmlx="http://www.wbf.org/xml/B2MML-V0401-AllExtensions" xmlns:exsl="http://exslt.org/common">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/> 
    <xsl:template name="getMaterialID">
	<xsl:param name="formulaParameterID" /> 
                 <xsl:for-each select="../../../../bml:Formula/bml:Parameter[bml:ID=$formulaParameterID]">  
                      <xsl:variable name="value">
                       <xsl:value-of select="bmlx:MaterialID" />
                      </xsl:variable>
                      <xsl:value-of select="$value" />  
                 </xsl:for-each>
  </xsl:template>
    <xsl:template name="getMaterialquantity">
	<xsl:param name="formulaParameterID" /> 
                 <xsl:for-each select="../../../../bml:Formula/bml:Parameter[bml:ID=$formulaParameterID]">  
                      <xsl:variable name="value">
                       <xsl:value-of select="bml:Value/bml:ValueString" />
                      </xsl:variable>
                      <xsl:value-of select="$value" />  
                 </xsl:for-each>
  </xsl:template>
    <xsl:template match="/">
      <NewDataSet>      
        <xsl:for-each select="bml:BatchInformation/bml:MasterRecipe/bml:RecipeElement">
        <xsl:if test="bmlx:UnitProcedureInformation"> 
             <xsl:variable name="PName" select="bmlx:UnitProcedureInformation/bmlx:Name"/>
             <xsl:variable name="UPPI" select="bmlx:UnitProcedureInformation/bmlx:ProcessInstance"/>
             <xsl:for-each select="bml:RecipeElement/bml:RecipeElement"> 
                <xsl:if test="bml:Parameter/bmlx:FormulaParameterID">                   
                <xsl:for-each select="bml:Parameter">
                <xsl:if test="bml:ParameterType='ProcessInput'">  
               <SQL>  
                <processes_key>
                   <xsl:value-of select="../../../../bml:ID"/> - <xsl:value-of select="$UPPI" />
                </processes_key>
                <procedure_name>
                   <xsl:value-of select="$PName" />
                </procedure_name>
                <Material_id>
                      <xsl:call-template name="getMaterialID">
                          <xsl:with-param name="formulaParameterID" select="bmlx:FormulaParameterID"/>
                      </xsl:call-template>
                </Material_id> 
                <quantity>
                      <xsl:call-template name="getMaterialquantity">
                          <xsl:with-param name="formulaParameterID" select="bmlx:FormulaParameterID"/>
                      </xsl:call-template>
                </quantity> 
                <material_use>Consume</material_use>
              </SQL>
                 </xsl:if> 
                <xsl:if test="bml:ParameterType='ProcessOutput'">  
               <SQL>  
                <processes_key>
                   <xsl:value-of select="../../../../bml:ID"/> - <xsl:value-of select="$UPPI" />
                </processes_key>
                <procedure_name>
                   <xsl:value-of select="$PName" />
                </procedure_name>
                <Material_id>
                      <xsl:call-template name="getMaterialID">
                          <xsl:with-param name="formulaParameterID" select="bmlx:FormulaParameterID"/>
                      </xsl:call-template>
                </Material_id> 
                <quantity>
                      <xsl:call-template name="getMaterialquantity">
                          <xsl:with-param name="formulaParameterID" select="bmlx:FormulaParameterID"/>
                      </xsl:call-template>
                </quantity> 
                <material_use>Produce</material_use>
              </SQL>
                 </xsl:if> 
                </xsl:for-each>
                </xsl:if> 
                </xsl:for-each>
          </xsl:if>     
        </xsl:for-each>
      </NewDataSet>
    </xsl:template>
</xsl:stylesheet> 