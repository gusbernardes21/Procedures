ALTER  PROCEDURE  PROC_SHBI_VENDAS_ZERO    
AS    
BEGIN    
  IF EXISTS(SELECT NAME 
              FROM SYS.OBJECTS 
             WHERE NAME = 'SHBI_VENDAS_ZERO') 
  BEGIN
    DROP TABLE SHBI_VENDAS_ZERO     
  END
  
  IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL
  BEGIN
    DROP TABLE #TEMP
  END 

  SELECT DISTINCT FILIAL
       , MONTH(DATA_VENDA) AS DT_MES
       , YEAR(DATA_VENDA) AS DT_ANO
       , CONVERT(CHAR,YEAR(DATA_VENDA))+'/'+CONVERT(CHAR,MONTH(DATA_VENDA))+'/'+'1' AS DT_DATA  
       , CASE WHEN  LEFT(FILIAL,3) != 'POP'  
              THEN 'SHOULDER' 
              ELSE 'POP UP STORE' 
         END  AS GRIFFE  
    INTO #TEMP    
    FROM LINX.DBO.LOJA_VENDA_PRODUTO P WITH(NOLOCK)    
         CROSS JOIN  (SELECT FILIAL    
                        FROM LINX.DBO.CADASTRO_CLI_FOR C WITH(NOLOCK)    
                             INNER JOIN LINX.DBO.FILIAIS L WITH(NOLOCK) ON L.FILIAL = C.NOME_CLIFOR    
                        WHERE INATIVO = 0 AND (L.TIPO_FILIAL = 'LOJAS - VAREJO'
                                                OR  L.FILIAL IN ('ARMAZEM - SHOW ROOM','ARMAZEM CGR - SHOW ROOM','CDSP ARMAZENAGEM')))F    
   WHERE DATA_VENDA >= GETDATE() -155   
    
    
  SELECT 'VENDAS' AS TIPO
       , FILIAL
       , DT_MES
       , DT_ANO
       , CONVERT(DATETIME,DT_DATA) AS DT_DATA
       , PRODUTO
       , COR_PRODUTO
       , TAMANHO
       , GRADE
       , GRUPO_PRODUTO
       , SUB_GRUPO_PRODUTO
       , CATEGORIA_PRODUTO
       , '0' AS QTDE    
    INTO WAREHOUSE..SHBI_VENDAS_ZERO    
    FROM( SELECT FILIAL
               , DT_MES
               , DT_ANO
               , REPLACE(DT_DATA,' ','') AS DT_DATA
               , P.PRODUTO
               , COR_PRODUTO
               , P.TAMANHO
               , P.GRADE
               , P1.GRUPO_PRODUTO AS GRUPO_PRODUTO
               , P1.GRIFFE AS GRIFFE
               , P1.SUBGRUPO_PRODUTO AS SUB_GRUPO_PRODUTO
               , CAT.CATEGORIA_PRODUTO AS CATEGORIA_PRODUTO
               , REPLACE(CONVERT(CHAR,FILIAL) + CONVERT(CHAR,DT_MES) + CONVERT(CHAR,DT_ANO) + CONVERT(CHAR,P.PRODUTO) + CONVERT(CHAR,COR_PRODUTO) + CONVERT(CHAR,TAMANHO),' ','') AS CHAVE
               , '0' AS QTDE    
            FROM LINX.DBO.PRODUTOS_BARRA P WITH(NOLOCK)    
                 INNER JOIN LINX.DBO.PRODUTOS P1 WITH(NOLOCK) ON P.PRODUTO = P1.PRODUTO 
                                                             AND P1.INATIVO = 0     
                                                             AND COLECAO IN ( SELECT DISTINCT COLECAO 
                                                                                FROM LINX..PRODUTOS WITH(NOLOCK) 
                                                                               WHERE( LEFT(COLECAO,4) >= YEAR(GETDATE())-1  AND LEFT(COLECAO,4)< '9000' ) 
                                                                                  OR COLECAO = '9000PE' )     
                 LEFT  JOIN LINX.DBO.PRODUTOS_CATEGORIA CAT WITH(NOLOCK) ON P1.COD_CATEGORIA = CAT.COD_CATEGORIA 
                                                                        AND CAT.INATIVO = 0    
                 CROSS JOIN #TEMP V  
 
           WHERE P.PRODUTO  NOT LIKE ('TESTE%')
             AND P.INATIVO = 0  
             AND V.GRIFFE = P1.GRIFFE 
             AND V.FILIAL NOT LIKE '%OUTLET%' 

UNION   

SELECT FILIAL
               , DT_MES
               , DT_ANO
               , REPLACE(DT_DATA,' ','') AS DT_DATA
               , P.PRODUTO
               , COR_PRODUTO
               , P.TAMANHO
               , P.GRADE
               , P1.GRUPO_PRODUTO AS GRUPO_PRODUTO
               , P1.GRIFFE AS GRIFFE
               , P1.SUBGRUPO_PRODUTO AS SUB_GRUPO_PRODUTO
               , CAT.CATEGORIA_PRODUTO AS CATEGORIA_PRODUTO
               , REPLACE(CONVERT(CHAR,FILIAL) + CONVERT(CHAR,DT_MES) + CONVERT(CHAR,DT_ANO) + CONVERT(CHAR,P.PRODUTO) + CONVERT(CHAR,COR_PRODUTO) + CONVERT(CHAR,TAMANHO),' ','') AS CHAVE
               , '0' AS QTDE    
            FROM LINX.DBO.PRODUTOS_BARRA P WITH(NOLOCK)    
                 INNER JOIN LINX.DBO.PRODUTOS P1 WITH(NOLOCK) ON P.PRODUTO = P1.PRODUTO 
                                                             AND P1.INATIVO = 0     
                                                             AND P1.PRODUTO  IN ( SELECT DISTINCT PRODUTO 
                                                                                FROM LINX..ESTOQUE_PRODUTOS WITH(NOLOCK) 
                                                                               WHERE FILIAL IN ('CDSP E-COMMERCE', 'CDCG ARMAZENAGEM') 
                                                                                 AND ESTOQUE >0 )     
                 LEFT  JOIN LINX.DBO.PRODUTOS_CATEGORIA CAT WITH(NOLOCK) ON P1.COD_CATEGORIA = CAT.COD_CATEGORIA 
                                                                        AND CAT.INATIVO = 0    
                 CROSS JOIN #TEMP V  
 
           WHERE P.PRODUTO  NOT LIKE ('TESTE%')
             AND P.INATIVO = 0  
             AND V.GRIFFE = P1.GRIFFE 
             AND V.FILIAL   LIKE '%OUTLET%' 

    ) A     
   WHERE CHAVE NOT IN (SELECT REPLACE(CONVERT(CHAR,LTRIM(RTRIM(FILIAL))) 
                            + CONVERT(CHAR,MONTH(DATA_VENDA)) 
                            + CONVERT(CHAR,YEAR(DATA_VENDA))  
                            + CONVERT(CHAR,LTRIM(RTRIM(PRODUTO))) 
                            + CONVERT(CHAR,LTRIM(RTRIM(COR_PRODUTO))) 
                            + CONVERT(CHAR,LTRIM(RTRIM(TAMANHO))),' ','') AS CHAVE    
                         FROM LINX.DBO.LOJA_VENDA_PRODUTO P WITH(NOLOCK)    
                              INNER JOIN LINX.DBO.LOJAS_VAREJO L WITH(NOLOCK) ON L.CODIGO_FILIAL = P.CODIGO_FILIAL    
                        WHERE DATA_VENDA >= GETDATE() -155)   
END  