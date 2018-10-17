

DECLARE @iQtdeDias       INT          = 5 
      , @CODIGO_CLIENTE  VARCHAR(100) = NULL 
      , @CODIGO_FILIAL   CHAR(6)      = NULL 
      , @MinEmissao      DATETIME     = NULL 
      , @MaxEmissao      DATETIME     = NULL 
      , @MinRetorno      DATETIME     = NULL  
      , @MaxRetorno      DATETIME     = NULL 
      , @Consignado      INT          = NULL 

  IF OBJECT_ID('tempdb..#tNFCliente') IS NOT NULL
  BEGIN
    DROP TABLE #tNFCliente
  END
 
 
  SELECT ROW_NUMBER() OVER(ORDER BY A.CODIGO_FILIAL ASC)  AS NUMERO_LINHA 
       , A.CODIGO_CLIENTE 
       , A.CODIGO_FILIAL AS CODIGO_FILIAL_NF_SAIDA
       , A.NF_NUMERO     AS NUMERO_NF_SAIDA
       , A.EMISSAO       AS NF_EMISSAO_SAIDA
       , A.SERIE_NF      AS SERIE_NF_SAIDA 
       , A.VALOR_TOTAL   AS VALOR_NF_SAIDA
       , A.QTDE_TOTAL    AS QUANTIDADE_NF_SAIDA
       , C.CODIGO_FILIAL AS CODIGO_FILIAL_NF_RETORNO
       , C.NF_NUMERO     AS NUMERO_NF_RETORNO
       , C.EMISSAO       AS NF_EMISSAO_RETORNO  
       , C.SERIE_NF      AS SERIE_NF_RETORNO 
       , C.VALOR_TOTAL   AS VALOR_NF_RETORNO
       , C.QTDE_TOTAL    AS QUANTIDADE_NF_RETORNO
       , cProcessado ='0' 
       
    INTO #tNFCliente
 
 FROM LINX..LOJA_NOTA_FISCAL A 
         OUTER APPLY (SELECT TOP 1  B.NF_NUMERO 
                                   , B.CODIGO_FILIAL
                                   , B.SERIE_NF   



                       FROM LINX..LOJA_NOTA_FISCAL_REFERENCIADA_ITEM B WITH (NOLOCK) WHERE  B.CHAVE_NFE_REF            = A.CHAVE_NFE 
                                                                             AND B.TIPO_ORIGEM = '9'
                                                                             AND (  ISNUMERIC(B.NF_NUMERO)=1 )  )  B
						 OUTER APPLY (select  top 1  C.CODIGO_FILIAL
                                  , C.NF_NUMERO    
                                  , C.EMISSAO      
                                  , C.SERIE_NF     
                                  , C.VALOR_TOTAL  
                                  , C.QTDE_TOTAL   

 from   LINX..LOJA_NOTA_FISCAL C                   WITH (NOLOCK) where C.NF_NUMERO				                            = B.NF_NUMERO 
                                                                             AND C.CODIGO_FILIAL                  = B.CODIGO_FILIAL  
                                                                             AND C.SERIE_NF						                 = B.SERIE_NF   
											                                                                  AND C.NATUREZA_OPERACAO_CODIGO       = '1918' 
                                                                             AND C.STATUS_NFE ='5'
                                                                             AND C.CHAVE_NFE IS NOT NULL  
order by c.EMISSAO desc ) c
   WHERE A.NATUREZA_OPERACAO_CODIGO = '5917'    
	    AND A.DATA_CANCELAMENTO IS NULL
     AND A.STATUS_NFE               = '5'
     AND A.CODIGO_CLIENTE IS NOT NULL 
    --AND  A.NF_NUMERO='000020949            '
    --AND A.CODIGO_FILIAL = 'ALPP05'
ORDER BY A.CODIGO_FILIAL ASC 
       , CODIGO_CLIENTE
       , A.EMISSAO ASC 
 

 
  WHILE EXISTS ( SELECT TOP  1 1 
                   FROM #tNFCliente 
                  WHERE cProcessado ='0' )
  BEGIN
    IF OBJECT_ID('tempdb..#tApoioLoopNF') IS NOT NULL
    BEGIN
      DROP TABLE #tApoioLoopNF
    END
   SELECT TOP 1 @CODIGO_CLIENTE=  CODIGO_CLIENTE
        , @CODIGO_FILIAL = CODIGO_FILIAL_NF_SAIDA 
        , @MinEmissao = MIN(NF_EMISSAO_SAIDA) 
     FROM #tNFCliente   
    WHERE cProcessado ='0'
    GROUP BY CODIGO_CLIENTE, CODIGO_FILIAL_NF_SAIDA 
      ORDER BY CODIGO_FILIAL_NF_SAIDA ASC 
  
  SET @MaxEmissao  = DATEADD(DD,@iQtdeDias, @MinEmissao) 

   SELECT  * 
     INTO #tApoioLoopNF
     FROM #tNFCliente
    WHERE CODIGO_CLIENTE= @CODIGO_CLIENTE
      AND CODIGO_FILIAL_NF_SAIDA = @CODIGO_FILIAL
      AND cProcessado ='0' 
      AND NF_EMISSAO_SAIDA BETWEEN @MinEmissao AND @MaxEmissao 
 

    SELECT @Consignado = ISNULL(MAX(CODIGO_CONSIGADO),0)  + 1 
      FROM WAREHOUSE..SHBI_TAB_CONSIGNADO
   

  INSERT INTO WAREHOUSE..SHBI_TAB_CONSIGNADO

    SELECT @Consignado AS CODIGO_CONSIGNADO
         , CODIGO_CLIENTE 
         , MIN(NF_EMISSAO_SAIDA) AS DATA_EMISSAO
         ,  MAX(NF_EMISSAO_RETORNO) AS DATA_RETORNO
         , CODIGO_FILIAL_NF_SAIDA 
         , NULL AS STATUS_CONSIGNADO
      FROM #tApoioLoopNF 
  GROUP BY CODIGO_CLIENTE
         , CODIGO_FILIAL_NF_SAIDA 

  

    INSERT INTO WAREHOUSE..SHBI_TAB_CONSIGNADO_NF
    SELECT CODIGO_CONSIGNADO = @Consignado 
         , ITEM = ROW_NUMBER() OVER(ORDER BY NUMERO_NF_SAIDA)  
         , NUMERO_NF_SAIDA
         , SERIE_NF_SAIDA
         , CODIGO_FILIAL_NF_SAIDA
         , NF_EMISSAO_SAIDA
         , VALOR_NF_SAIDA
         , QUANTIDADE_NF_SAIDA
         , NUMERO_NF_RETORNO
         , SERIE_NF_RETORNO
         , CODIGO_FILIAL_NF_RETORNO
         , NF_EMISSAO_RETORNO
         , VALOR_NF_RETORNO
         , QUANTIDADE_NF_RETORNO
      FROM #tApoioLoopNF 
    
/* PUXA AS DATAS PARA O CONSIGADO */

   
    SELECT @MinRetorno = ISNULL(MIN(NF_EMISSAO_RETORNO), '20991231')
         , @MaxRetorno = ISNULL(DATEADD(DD, @iQtdeDias, MAX(NF_EMISSAO_RETORNO) ) , '20991231')
      FROM #tApoioLoopNF 

    INSERT INTO WAREHOUSE..SHBI_TAB_CONSIGNADO_TICKET
    SELECT CODIGO_CONSIGNADO = @Consignado
         ,  LV.CODIGO_FILIAL
         ,  LV.TICKET
         ,  LV.DATA_VENDA
      FROM  LINX..LOJA_VENDA LV 
     WHERE  LV.CODIGO_CLIENTE         = @CODIGO_CLIENTE
       AND  LV.CODIGO_FILIAL = @CODIGO_FILIAL
       AND  LV.DATA_VENDA BETWEEN  @MinRetorno AND @MaxRetorno 
       AND  LV.DATA_HORA_CANCELAMENTO IS NULL
       AND NOT EXISTS ( SELECT TOP 1 1
                        FROM WAREHOUSE..SHBI_TAB_CONSIGNADO_TICKET CT
                       WHERE CT.CODIGO_FILIAL = LV.CODIGO_FILIAL
                         AND CT.DATA_VENDA    = LV.DATA_VENDA
                         AND CT.TICKET        = LV.TICKET ) 
    
IF NOT EXISTS ( SELECT TOP 1 1 
                 FROM WAREHOUSE..SHBI_TAB_CONSIGNADO_NF
                WHERE NF_EMISSAO_RETORNO IS NULL
                  AND CODIGO_CONSIGNADO = @Consignado)

BEGIN

UPDATE WAREHOUSE..SHBI_TAB_CONSIGNADO
SET STATUS_CONSIGNADO = 'FINALIZADO'
WHERE CODIGO_CONSIGADO = @Consignado 

END 


IF   EXISTS ( SELECT TOP 1 1 
                 FROM WAREHOUSE..SHBI_TAB_CONSIGNADO_NF
                WHERE NF_EMISSAO_RETORNO IS NULL
                  AND CODIGO_CONSIGNADO = @Consignado)
AND EXISTS ( SELECT TOP 1 1 
                    FROM WAREHOUSE..SHBI_TAB_CONSIGNADO_NF
                WHERE NF_EMISSAO_RETORNO IS NOT NULL
                  AND CODIGO_CONSIGNADO = @Consignado )

BEGIN

UPDATE WAREHOUSE..SHBI_TAB_CONSIGNADO
SET STATUS_CONSIGNADO = 'INCOMPLETO'
WHERE CODIGO_CONSIGADO = @Consignado 

END 
IF  EXISTS ( SELECT TOP 1 1 
                    FROM WAREHOUSE..SHBI_TAB_CONSIGNADO 
                WHERE DATA_RETORNO IS   NULL
                  AND CODIGO_CONSIGADO = @Consignado )
BEGIN 
UPDATE WAREHOUSE..SHBI_TAB_CONSIGNADO
SET STATUS_CONSIGNADO = 'EM ABERTO '
WHERE CODIGO_CONSIGADO = @Consignado 

END 
 


     UPDATE #tNFCliente
        SET cProcessado  = '1'
       FROM #tNFCliente 
            INNER JOIN #tApoioLoopNF ON #tApoioLoopNF.NUMERO_LINHA = #tNFCliente.NUMERO_LINHA
--BREAK
  END 

 