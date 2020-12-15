<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:bml="http://www.wbf.org/xml/B2MML-V0401" xmlns:bmlx="http://www.wbf.org/xml/B2MML-V0401-AllExtensions" xmlns:exsl="http://exslt.org/common">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/> 
    <xsl:template name="gettime">
	<xsl:param name="formulaParameterID" /> 
                 <xsl:for-each select="../../../../bml:Formula/bml:Parameter[bml:ID=$formulaParameterID]">  
                      <xsl:variable name="value">
                        <xsl:choose>
                         <xsl:when test="bml:ParameterType='ProcessParameter'">
                          <xsl:choose>
                           <xsl:when test="bmlx:Name='Time'">
                             <xsl:value-of select="bml:Value/bml:ValueString" />
                            </xsl:when>
                            <xsl:otherwise>
                               <xsl:value-of select="bml:ID - bml:ID" />
                            </xsl:otherwise>
                          </xsl:choose>
                         </xsl:when>
                          <xsl:otherwise>
                             <xsl:value-of select="bml:ID - bml:ID" />
                          </xsl:otherwise>
                      </xsl:choose>
                      </xsl:variable>
                      <xsl:value-of select="$value" />  
                 </xsl:for-each>
  </xsl:template>
    <xsl:template match="/">
      <NewDataSet>      
        <xsl:for-each select="bml:BatchInformation/bml:MasterRecipe/bml:RecipeElement">
        <xsl:if test="bmlx:UnitProcedureInformation">
        <xsl:for-each select="bmlx:UnitProcedureInformation/bmlx:ProcessInstance[not          (preceding::bmlx:UnitProcedureInformation/bmlx:ProcessInstance/. = .)]">
               <SQL>
                <sequence_number>10</sequence_number>  
                <processes_key>
                   <xsl:value-of select="../../../bml:ID"/> - <xsl:value-of select="." />
                </processes_key>
                <procedure_name>Setup</procedure_name>
                <process_type>SequenceDependentSetup</process_type>
                <time>0</time> 
               </SQL>
            </xsl:for-each>     
             <xsl:variable name="PName" select="bmlx:UnitProcedureInformation/bmlx:Name"/>
             <xsl:variable name="UPPI" select="bmlx:UnitProcedureInformation/bmlx:ProcessInstance"/>
               <xsl:variable name="time">
             <xsl:for-each select="bml:RecipeElement/bml:RecipeElement"> 
                <xsl:if test="bml:Parameter/bmlx:FormulaParameterID">                   
                <xsl:for-each select="bml:Parameter">
                    <amt>
                      <xsl:call-template name="gettime">
                          <xsl:with-param name="formulaParameterID" select="bmlx:FormulaParameterID"/>
                      </xsl:call-template>
                      </amt>
                </xsl:for-each>
                </xsl:if> 
                </xsl:for-each>
                </xsl:variable> 
               <SQL>
                <sequence_number>
                  <xsl:value-of select="bml:ID"/>
                </sequence_number>   
                <processes_key>
                   <xsl:value-of select="../bml:ID"/> - <xsl:value-of select="$UPPI" />
                </processes_key>
                <procedure_name>
                   <xsl:value-of select="$PName" />
                </procedure_name>
                <process_type>Specifictime</process_type>
                <time>
                   <xsl:value-of select="sum(exsl:node-set($time)/amt)" />
                </time> 
              </SQL>
          </xsl:if>     
        </xsl:for-each>
      </NewDataSet>
    </xsl:template>
</xsl:stylesheet> 