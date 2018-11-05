/*para saber os clientes novos por marca, primeiro  q eu tenho q fazer...
primeiramente cria um parametro para tirar os clientes das outras marcas..
como fazer isso : vamos la.. vc primeiramente veja toda as vendas únicas da marca tirando o conserto ... isso é só olhar a loja venda produto
pq se for troca nao importa importa a saída..
se a venda foi vitrine, tem q tirar da loja também.. 
agora eu preciso pegar todas as vendas da shoulder no periodo tirar as vendas popup e tirar as vendas vitrine do ecommerce considerando o vitrine como e-macomer e transformando o crossale em loja d eorigem*/

/*
===============================================
DECLARA AS DATAS
===============================================

*/

  DECLARE @DATA_BASE         DATETIME = CONVERT(DATE,GETDATE()) 
        , @DATA_INICIAL_LW   DATETIME
        , @DATA_FINAL_LW     DATETIME
        , @DATA_INICIAL_LW_C DATETIME
        , @DATA_FINAL_LW_C   DATETIME
        , @DATA_INICIAL_LY   DATETIME
        , @DATA_FINAL_LY     DATETIME

  SELECT @DATA_INICIAL_LW   = DATEADD(DD,-7 ,@DATA_BASE) 
       , @DATA_FINAL_LW     = DATEADD(DD,-1,@DATA_BASE) 
   
  SELECT @DATA_INICIAL_LW_C = DATEADD(DD,-7 ,@DATA_INICIAL_LW) 
       , @DATA_FINAL_LW_C   = DATEADD(DD,-1,@DATA_INICIAL_LW) 
  
  SELECT @DATA_INICIAL_LY   = DATEADD(Y,-1 ,@DATA_INICIAL_LW) 
       , @DATA_FINAL_LY     = DATEADD(Y,-1,@DATA_FINAL_LW) 

  IF OBJECT_ID('tempdb..#tClientes') IS NOT NULL
  BEGIN 
    DROP TABLE #tClientes
  END 

  IF OBJECT_ID('tempdb..#tTickets_Popup') IS NOT NULL
  BEGIN 
    DROP TABLE #tTickets_Popup
  END

  IF OBJECT_ID('tempdb..#tPedidoCrossVitrizne') IS NOT NULL
  BEGIN 
    DROP TABLE #tPedidoCrossVitrizne
  END

 IF OBJECT_ID('tempdb..#tMovimentacao') IS NOT NULL
  BEGIN 
    DROP TABLE #tMovimentacao
  END

 IF OBJECT_ID('tempdb..#tNovosClientes') IS NOT NULL
  BEGIN 
    DROP TABLE #tNovosClientes
  END

 IF OBJECT_ID('tempdb..#tTabelaFinal') IS NOT NULL
  BEGIN 
    DROP TABLE #tTabelaFinal
  END

 IF OBJECT_ID('tempdb..#tFinal') IS NOT NULL
  BEGIN 
    DROP TABLE #tFinal
  END

  IF OBJECT_ID('tempdb..#tRelatorio') IS NOT NULL
  BEGIN 
    DROP TABLE #tRelatorio
  END



CREATE TABLE #tFinal ( FILIAL VARCHAR(100)
                     , NOVOS_LW        decimal(10,2)
                     , EXISTENTES_LW   decimal(10,2) 
                     , NOVOS_LW_C      decimal(10,2)
                     , EXISTENTES_LW_C decimal(10,2)
                     , NOVOS_LY        decimal(10,2)
                     , EXISTENTES_LY   decimal(10,2)  ) 
 
/*
===============================================
Primeiro tira as vendas da pop up 
===============================================

*/
 SELECT   LV.CODIGO_FILIAL 
      , LV.DATA_VENDA
      , LV.TICKET 
      , COUNT(DISTINCT P.GRIFFE)  AS QTDE_GRIFFE 
   INTO #tClientes
   FROM LINX..LOJA_VENDA LV WITH(NOLOCK)
        INNER JOIN LINX..LOJA_VENDA_PRODUTO LVP WITH(NOLOCK) ON LV.CODIGO_FILIAL = LVP.CODIGO_FILIAL 
                                                            AND LV.DATA_VENDA    = LVP.DATA_VENDA
                                                            AND LV.TICKET        = LVP.TICKET
        INNER JOIN PRODUTOS            P WITH(NOLOCK) ON P.PRODUTO        = LVP.PRODUTO
  WHERE  LVP.PRODUTO NOT IN ( '121300020', '121300021', '121300022', '121300023', '121300024' ) 
   AND LV.DATA_VENDA >='20170101'
   AND LV.DATA_HORA_CANCELAMENTO IS NULL 
GROUP BY LV.CODIGO_FILIAL 
      , LV.DATA_VENDA
      , LV.TICKET 
 HAVING COUNT(DISTINCT P.GRIFFE)  =1 
 

SELECT DISTINCT LV.CODIGO_FILIAL 
      , LV.DATA_VENDA
      , LV.TICKET
INTO #tTickets_Popup
 FROM #tClientes   LV WITH(NOLOCK)
        INNER JOIN LINX..LOJA_VENDA_PRODUTO LVP WITH(NOLOCK) ON LV.CODIGO_FILIAL = LVP.CODIGO_FILIAL 
                                                            AND LV.DATA_VENDA    = LVP.DATA_VENDA
                                                            AND LV.TICKET        = LVP.TICKET
        INNER JOIN PRODUTOS            P WITH(NOLOCK) ON P.PRODUTO        = LVP.PRODUTO 
  WHERE  LVP.PRODUTO NOT IN ( '121300020', '121300021', '121300022', '121300023', '121300024' ) 
AND GRIFFE = 'POP UP STORE'

DROP TABLE #tClientes 

 INSERT INTO  #tTickets_Popup

 SELECT   A.CODIGO_FILIAL 
      , A.DATA_VENDA
      , A.TICKET 
  FROM LINX..LOJA_VENDA A WITH(NOLOCK)    
      INNER JOIN LINX..LOJA_VENDEDORES L                  ON L.VENDEDOR        = A.VENDEDOR    
      INNER JOIN LINX..LOJAS_VAREJO I                    ON I.CODIGO_FILIAL    = A.CODIGO_FILIAL    
      INNER JOIN LINX..LOJA_VENDA_PARCELAS B WITH(NOLOCK) ON A.CODIGO_FILIAL    = B.CODIGO_FILIAL    
                                                          AND A.TERMINAL        = B.TERMINAL    
                                                          AND A.LANCAMENTO_CAIXA = B.LANCAMENTO_CAIXA    
      INNER JOIN  LINX..LOJA_PEDIDO D WITH(NOLOCK)        ON A.TICKET          = D.TICKET_VENDA    
                                                          AND A.CODIGO_FILIAL    = D.CODIGO_FILIAL_VENDA    
                                                          AND D.CANCELADO =0    
                                                          AND D.STATUS_B2C ='4'    
INNER JOIN LINX..LOJA_PEDIDO_PRODUTO LPP WITH(NOLOCK) ON D.CODIGO_FILIAL_ORIGEM = LPP.CODIGO_FILIAL_ORIGEM 
                                                      AND D.PEDIDO   = LPP.PEDIDO

      INNER  JOIN LINX..PRODUTOS P            ON P.PRODUTO  = LPP.PRODUTO    
  WHERE B.TIPO_PGTO = '\'    
    AND B.VALOR < 0    
    AND A.CODIGO_FILIAL NOT IN ('CDSB2C','CDCARM')    
  AND   GRIFFE = 'POP UP STORE'
GROUP BY A.CODIGO_FILIAL 
      , A.DATA_VENDA
      , A.TICKET
 
 /*===============================================
Agora seleciona as vendas vitrine  e cross
===============================================*/

SELECT *
INTO #tPedidoCrossVitrizne
FROM (
 SELECT  A.CODIGO_FILIAL AS CODIGO_FILIAL_ORIGEM
      , Z.CODIGO_FILIAL  AS CODIGO_FILIAL_ECOMERCE
      , Z.TICKET
      , Z.DATA_VENDA  
   FROM LINX..LOJA_VENDA A WITH(NOLOCK)    
       INNER JOIN LINX..LOJA_VENDEDORES L                  ON L.VENDEDOR         = A.VENDEDOR    
       INNER JOIN LINX..LOJAS_VAREJO I                     ON I.CODIGO_FILIAL    = A.CODIGO_FILIAL    
       INNER JOIN LINX..LOJA_VENDA_PARCELAS B WITH(NOLOCK) ON A.CODIGO_FILIAL    = B.CODIGO_FILIAL     
                                                          AND A.TERMINAL         = B.TERMINAL     
                                                          AND A.LANCAMENTO_CAIXA = B.LANCAMENTO_CAIXA    
       LEFT JOIN  LINX..LOJA_PEDIDO D WITH(NOLOCK)         ON A.TICKET           = D.TICKET_VENDA     
                                                          AND A.CODIGO_FILIAL    = D.CODIGO_FILIAL_VENDA    
                                                          AND D.CANCELADO =0    
                                                          AND D.STATUS_B2C ='4'     
       LEFT JOIN  ( SELECT AA.CODIGO_FILIAL_ORIGEM    
                         , AA.PEDIDO    
                         , MAX(AA.ITEM) AS ITEM    
                         , AA.CODIGO_FILIAL    
                         , AA.TICKET    
                         , AA.DATA_VENDA     
                      FROM LINX..LOJA_PEDIDO_VENDA AA     
                  GROUP BY AA.CODIGO_FILIAL_ORIGEM    
             , AA.PEDIDO    
          , AA.CODIGO_FILIAL    
          , AA.TICKET    
          , AA.DATA_VENDA ) U               ON U.PEDIDO = D.PEDIDO    
       LEFT JOIN LINX..LOJA_VENDA Z ON Z.CODIGO_FILIAL  = U.CODIGO_FILIAL     
                                   AND Z.TICKET         = U.TICKET     
                                   AND Z.DATA_VENDA     = U.DATA_VENDA    
                                   AND Z.CODIGO_CLIENTE = A.CODIGO_CLIENTE    
       LEFT JOIN LINX..LOJA_VENDA_PRODUTO X ON X.CODIGO_FILIAL    = Z.CODIGO_FILIAL     
                                           AND X.TICKET           = Z.TICKET     
                                           AND X.DATA_VENDA       = Z.DATA_VENDA     
                                           AND X.ITEM_EXCLUIDO    = 0          
 
       LEFT JOIN LINX..PRODUTOS P            ON P.PRODUTO  = X.PRODUTO    
   WHERE B.TIPO_PGTO = '\'     
     AND B.VALOR < 0     
     AND A.CODIGO_FILIAL NOT IN ('CDSB2C','CDCARM')    
   
    
UNION ALL    
    
  SELECT H.CODIGO_FILIAL AS CODIGO_FILIAL_ORIGEM
       , F.CODIGO_FILIAL AS CODIGO_FILIAL_ECOMERCE
       , F.TICKET
       , F.DATA_VENDA    
    FROM LINX..LOJA_PEDIDO D    
         INNER JOIN  LINX..LOJA_VENDA A ON  A.TICKET = D.TICKET_VENDA     
                                       AND A.CODIGO_FILIAL = D.CODIGO_FILIAL_VENDA      
         INNER JOIN LINX..LOJA_PEDIDO_PRODUTO E WITH(NOLOCK) ON D.PEDIDO = E.PEDIDO      
                                                       AND E.CANCELADO = '0'     
   INNER JOIN LINX..PRODUTOS P WITH(NOLOCK)            ON P.PRODUTO = E.PRODUTO    
   INNER JOIN LINX..LOJA_PEDIDO_VENDA F WITH(NOLOCK)   ON  F.PEDIDO        = D.PEDIDO     
                                                            AND F.ITEM          = E.ITEM     
                                                            AND F.CODIGO_FILIAL = D.CODIGO_FILIAL_ORIGEM    
   INNER JOIN LINX..LOJAS_VAREJO G                     ON A.CODIGO_FILIAL  = G.CODIGO_FILIAL    
         INNER JOIN LINX..LOJA_VENDEDORES H                  ON A.VENDEDOR = H.VENDEDOR    
         INNER JOIN LINX..LOJAS_VAREJO I                     ON H.CODIGO_FILIAL = I.CODIGO_FILIAL    
         CROSS APPLY ( SELECT SUM (F.PRECO_LIQUIDO * F.QTDE) AS VALOR_TOTAL_PEDIDO    
                         FROM LINX..LOJA_PEDIDO_PRODUTO F WITH(NOLOCK)    
                        WHERE  F.PEDIDO = E.PEDIDO) Total_Pedido    
   WHERE D.VENDEDOR NOT IN ('B999','0001','001')     
     AND D.CODIGO_FILIAL_VENDA IN ('CDSB2C','CDCARM')      
     AND YEAR(D.DATA)>=2017     
     AND D.DIGITACAO_ENCERRADA = '1'    
     AND D.CANCELADO = '0'     
     AND D.STATUS_B2C = '4'   )  A 

/*===============================================
Seleciona as vendas do periodo 
===============================================*/

  SELECT CODIGO_CLIENTE
       , DATA_VENDA 
       , LV.CODIGO_FILIAL
       , TICKET
       , CASE WHEN  LVV.FILIAL  IN ( 'CDCG ARMAZENAGEM' , 'CDSP E-COMMERCE') 
                  THEN  'E-COMMERCE'
                  ELSE LVV.FILIAL 
              END AS FILIAL 
INTO #tMovimentacao
    FROM LINX..LOJA_VENDA LV WITH(NOLOCK) 
         INNER JOIN LINX..LOJAS_VAREJO LVV ON LVV.CODIGO_FILIAL = LV.CODIGO_FILIAL
   WHERE NOT EXISTS ( SELECT TOP 1 1 
                       FROM #tTickets_Popup T
                      WHERE T.TICKET        = LV.TICKET
                        AND T.DATA_VENDA    = LV.DATA_VENDA
                        AND T.CODIGO_FILIAL = LV.CODIGO_FILIAL ) 
  AND DATA_HORA_CANCELAMENTO IS NULL
  AND NOT EXISTS ( SELECT TOP 1 1 
                     FROM #tPedidoCrossVitrizne T
                   WHERE LV.CODIGO_FILIAL =  T.CODIGO_FILIAL_ECOMERCE 
                     AND LV.TICKET        = T.TICKET 
                     AND LV.DATA_VENDA   = T.DATA_VENDA ) 
 AND (DATA_VENDA BETWEEN @DATA_INICIAL_LW AND @DATA_FINAL_LW
OR DATA_VENDA BETWEEN @DATA_INICIAL_LW_C AND @DATA_FINAL_LW_C
OR DATA_VENDA BETWEEN @DATA_INICIAL_LY AND @DATA_FINAL_LY)
AND CODIGO_CLIENTE IS NOT NULL 

/*===============================================
seleciona os clientes novos no período 
===============================================*/


SELECT   CASE WHEN  LV.FILIAL  IN ( 'CDCG ARMAZENAGEM' , 'CDSP E-COMMERCE') 
                  THEN  'E-COMMERCE'
                  ELSE LV.FILIAL 
              END AS FILIAL 
     , TICKET
     , DATA_ATIVACAO
     , CODIGO_CLIENTE
     , CA.CODIGO_FILIAL 
 INTO #tNovosClientes
  FROM CLIENTES_VAREJO_ATIVACAO CA WITH(NOLOCK)
       INNER JOIN LINX..LOJAS_VAREJO LV  WITH(NOLOCK) ON LV.CODIGO_FILIAL  = CA.CODIGO_FILIAL
WHERE CA.MARCA ='SHOULDER'

/*===============================================
Gera a base do relatório
===============================================*/

SELECT *
INTO #tTabelaFinal 
 FROM (
SELECT T.FILIAL
     , COUNT(CODIGO_CLIENTE)  AS QTDE_CLIENTES 
     , 'NOVOS_LW' AS TIPO
 FROM #tNovosClientes T
 WHERE DATA_ATIVACAO BETWEEN @DATA_INICIAL_LW AND @DATA_FINAL_LW 
GROUP BY T.FILIAL
UNION ALL 
SELECT T.FILIAL
     , COUNT(CODIGO_CLIENTE)  AS QTDE_CLIENTES 
     , 'NOVOS_LW_C' AS TIPO
 FROM #tNovosClientes T
 WHERE DATA_ATIVACAO BETWEEN @DATA_INICIAL_LW_C AND @DATA_FINAL_LW_C
GROUP BY T.FILIAL

UNION ALL 
SELECT T.FILIAL
     , COUNT(CODIGO_CLIENTE)      AS QTDE_CLIENTES 
     , 'NOVOS_LW_Y' AS TIPO
 FROM #tNovosClientes T
 WHERE DATA_ATIVACAO BETWEEN @DATA_INICIAL_LY AND @DATA_FINAL_LY
GROUP BY T.FILIAL

UNION ALL 


SELECT T.FILIAL
     , COUNT(DISTINCT T.CODIGO_CLIENTE)       AS QTDE_CLIENTES 
     , 'EXISTENTES_LW' AS TIPO
 FROM #tMovimentacao T 
 WHERE DATA_VENDA BETWEEN @DATA_INICIAL_LW AND @DATA_FINAL_LW 
  AND T.CODIGO_CLIENTE NOT IN   ( SELECT CODIGO_CLIENTE FROM #tNovosClientes WHERE DATA_ATIVACAO BETWEEN @DATA_INICIAL_LW AND @DATA_FINAL_LW ) 
GROUP BY T.FILIAL

UNION ALL 

SELECT T.FILIAL
     , COUNT(DISTINCT T.CODIGO_CLIENTE)  AS  QTDE_CLIENTES 
     , 'EXISTENTES_LW_C' AS TIPO
 FROM #tMovimentacao T 
 WHERE DATA_VENDA BETWEEN @DATA_INICIAL_LW_C AND @DATA_FINAL_LW_C
  AND T.CODIGO_CLIENTE NOT IN   ( SELECT CODIGO_CLIENTE FROM #tNovosClientes WHERE DATA_ATIVACAO BETWEEN @DATA_INICIAL_LW_C AND @DATA_INICIAL_LW_C ) 
GROUP BY T.FILIAL

UNION ALL 


SELECT T.FILIAL
     , COUNT(DISTINCT T.CODIGO_CLIENTE)  AS   QTDE_CLIENTES 
     , 'EXISTENTES_LY' AS TIPO
 FROM #tMovimentacao T 
 WHERE DATA_VENDA BETWEEN @DATA_INICIAL_LY AND @DATA_FINAL_LY
  AND T.CODIGO_CLIENTE NOT IN   ( SELECT CODIGO_CLIENTE FROM #tNovosClientes WHERE DATA_ATIVACAO BETWEEN  @DATA_INICIAL_LY AND @DATA_FINAL_LY ) 
GROUP BY T.FILIAL ) A 

 /*===============================================
Gera as filiais e alimenta os campos de acordo com os cálculos 
===============================================*/
INSERT INTO #tFinal (FILIAL)

SELECT DISTINCT FILIAL
FROM #tTabelaFinal
 

UPDATE #tFinal
SET NOVOS_LW =ISNULL(#tTabelaFinal.QTDE_CLIENTES,0) 
FROM #tFinal
LEFT JOIN #tTabelaFinal ON #tTabelaFinal.FILIAL = #tFinal.FILIAL COLLATE SQL_Latin1_General_CP1_CI_AS
                        AND TIPO =  'NOVOS_LW'

UPDATE #tFinal
SET EXISTENTES_LW = ISNULL(#tTabelaFinal.QTDE_CLIENTES,0) 
FROM #tFinal
LEFT JOIN #tTabelaFinal ON #tTabelaFinal.FILIAL = #tFinal.FILIAL COLLATE SQL_Latin1_General_CP1_CI_AS
                        AND TIPO =  'EXISTENTES_LW'

UPDATE #tFinal
SET NOVOS_LW_C = ISNULL(#tTabelaFinal.QTDE_CLIENTES,0) 
FROM #tFinal
LEFT JOIN #tTabelaFinal ON #tTabelaFinal.FILIAL = #tFinal.FILIAL COLLATE SQL_Latin1_General_CP1_CI_AS
                        AND TIPO =  'NOVOS_LW_C'


UPDATE #tFinal
SET EXISTENTES_LW_C =ISNULL(#tTabelaFinal.QTDE_CLIENTES,0) 
FROM #tFinal
LEFT JOIN #tTabelaFinal ON #tTabelaFinal.FILIAL = #tFinal.FILIAL COLLATE SQL_Latin1_General_CP1_CI_AS
                        AND TIPO =  'EXISTENTES_LW_C'


UPDATE #tFinal
SET NOVOS_LY = ISNULL(#tTabelaFinal.QTDE_CLIENTES,0) 
FROM #tFinal
LEFT JOIN #tTabelaFinal ON #tTabelaFinal.FILIAL = #tFinal.FILIAL COLLATE SQL_Latin1_General_CP1_CI_AS
                        AND TIPO =  'NOVOS_LW_Y'


UPDATE #tFinal
SET EXISTENTES_LY = ISNULL(#tTabelaFinal.QTDE_CLIENTES,0) 
FROM #tFinal
LEFT JOIN #tTabelaFinal ON #tTabelaFinal.FILIAL = #tFinal.FILIAL COLLATE SQL_Latin1_General_CP1_CI_AS
                        AND TIPO =  'EXISTENTES_LY'

--DROP TABLE #tRelatorio
 /*===============================================
Finaliza o relatório 
===============================================*/
SELECT  FILIAL
     ,  TOTAL
     ,  NOVOS_LW  
     ,  FORMAT(PERCENTUAL_NOVOS_LW ,'N','PT-BR')      AS PERCENTUAL_NOVOS_LW
     ,  EXISTENTES_LW
     ,  FORMAT(PERCENTUAL_EXISTENTES_LW,'N','PT-BR')  AS PERCENTUAL_EXISTENTES_LW
     ,  TOTAL_LW_C
     ,  NOVOS_LW_C 
     ,  FORMAT(PERCENTUAL_NOVOS_LW_C,'N','PT-BR')     AS PERCENTUAL_NOVOS_LW_C
     ,  EXISTENTES_LW_C
     ,  FORMAT(PERCENTUAL_EXISTENTES_LW_C,'N','PT-BR')AS PERCENTUAL_EXISTENTES_LW_C
     ,  TOTAL_LY
     ,  NOVOS_LY 
     ,  FORMAT(PERCENTUAL_NOVOS_LY,'N','PT-BR')       AS PERCENTUAL_NOVOS_LY
     ,  EXISTENTES_LY
     ,  FORMAT(PERCENTUAL_EXISTENTES_LY,'N','PT-BR')  AS PERCENTUAL_EXISTENTES_LY
INTO #tRelatorio 
FROM ( 
SELECT FILIAL                                                                                                                 AS FILIAL
     , CONVERT(INT, SUM(NOVOS_LW + EXISTENTES_LW))                                                                            AS TOTAL
     , CONVERT(INT,SUM(NOVOS_LW))                                                                                             AS NOVOS_LW  
     , CONVERT(DECIMAL(10,2),ROUND(CONVERT(NUMERIC(15,2), SUM(NOVOS_LW) *100 / (SUM(NOVOS_LW + EXISTENTES_LW)  )),2),2)       AS PERCENTUAL_NOVOS_LW
     , CONVERT(INT,SUM(EXISTENTES_LW))                                                                                        AS EXISTENTES_LW
     , CONVERT(NUMERIC(15,2), SUM(EXISTENTES_LW)  *100  / (SUM(NOVOS_LW + EXISTENTES_LW)  ))                                  AS PERCENTUAL_EXISTENTES_LW
     , CONVERT(INT,SUM(NOVOS_LW_C + EXISTENTES_LW_C))                                                                         AS TOTAL_LW_C
     , CONVERT(INT,SUM(NOVOS_LW_C)                  )                                                                         AS NOVOS_LW_C 
     , CONVERT(DECIMAL(10,2), ROUND(CONVERT(NUMERIC(15,2),( SUM(NOVOS_LW) / (SUM(NOVOS_LW_C)     ) -1 ) *100 ),2) )           AS PERCENTUAL_NOVOS_LW_C
     , CONVERT(INT,SUM(EXISTENTES_LW_C))                                                                                      AS EXISTENTES_LW_C
     , CONVERT(DECIMAL(10,2), ROUND(CONVERT(NUMERIC(15,2),( SUM(EXISTENTES_LW) / (SUM(EXISTENTES_LW_C)     ) -1 ) *100 ),2) ) AS PERCENTUAL_EXISTENTES_LW_C 
     , CONVERT(INT,SUM(NOVOS_LY + EXISTENTES_LY))                                                                             AS TOTAL_LY
     , CONVERT(INT,SUM(NOVOS_LY))                                                                                             AS NOVOS_LY 
     , CONVERT(DECIMAL(10,2), ROUND(CONVERT(NUMERIC(15,2),( SUM(NOVOS_LW) / (SUM(NOVOS_LY)     ) -1 ) *100 ),2) )             AS PERCENTUAL_NOVOS_LY
     , CONVERT(INT,SUM(EXISTENTES_LY))                                                                                        AS EXISTENTES_LY
     , CONVERT(DECIMAL(10,2), ROUND(CONVERT(NUMERIC(15,2),( SUM(EXISTENTES_LW) / (SUM(EXISTENTES_LY)     ) -1 ) *100 ),2) )   AS PERCENTUAL_EXISTENTES_LY
  FROM #tFinal
GROUP BY FILIAL 

UNION ALL 


SELECT 'Z**TOTAL**Z' AS FILIAL
     , CONVERT(INT, SUM(NOVOS_LW + EXISTENTES_LW))                                                                            AS TOTAL
     , CONVERT(INT,SUM(NOVOS_LW))                                                                                             AS NOVOS_LW  
     , CONVERT(DECIMAL(10,2),ROUND(CONVERT(NUMERIC(15,2), SUM(NOVOS_LW) *100 / (SUM(NOVOS_LW + EXISTENTES_LW)  )),2),2)       AS PERCENTUAL_NOVOS_LW
     , CONVERT(INT,SUM(EXISTENTES_LW))                                                                                        AS EXISTENTES_LW
     , CONVERT(NUMERIC(15,2), SUM(EXISTENTES_LW)  *100  / (SUM(NOVOS_LW + EXISTENTES_LW)  ))                                  AS PERCENTUAL_EXISTENTES_LW
     , CONVERT(INT,SUM(NOVOS_LW_C + EXISTENTES_LW_C))                                                                         AS TOTAL_LW_C
     , CONVERT(INT,SUM(NOVOS_LW_C)                  )                                                                         AS NOVOS_LW_C 
     , CONVERT(DECIMAL(10,2), ROUND(CONVERT(NUMERIC(15,2),( SUM(NOVOS_LW) / (SUM(NOVOS_LW_C)     ) -1 ) *100 ),2) )           AS PERCENTUAL_NOVOS_LW_C
     , CONVERT(INT,SUM(EXISTENTES_LW_C))                                                                                      AS EXISTENTES_LW_C
     , CONVERT(DECIMAL(10,2), ROUND(CONVERT(NUMERIC(15,2),( SUM(EXISTENTES_LW) / (SUM(EXISTENTES_LW_C)     ) -1 ) *100 ),2) ) AS PERCENTUAL_EXISTENTES_LW_C 
     , CONVERT(INT,SUM(NOVOS_LY + EXISTENTES_LY))                                                                             AS TOTAL_LY
     , CONVERT(INT,SUM(NOVOS_LY))                                                                                             AS NOVOS_LY 
     , CONVERT(DECIMAL(10,2), ROUND(CONVERT(NUMERIC(15,2),( SUM(NOVOS_LW) / (SUM(NOVOS_LY)     ) -1 ) *100 ),2) )             AS PERCENTUAL_NOVOS_LY
     , CONVERT(INT,SUM(EXISTENTES_LY))                                                                                        AS EXISTENTES_LY
     , CONVERT(DECIMAL(10,2), ROUND(CONVERT(NUMERIC(15,2),( SUM(EXISTENTES_LW) / (SUM(EXISTENTES_LY)     ) -1 ) *100 ),2) )   AS PERCENTUAL_EXISTENTES_LY
  FROM #tFinal ) A 
 

 
 
 --Variáveis HTML  
 DECLARE @BODY     NVARCHAR(MAX)
       , @ASSUNTO  VARCHAR(100)
       , @MSGEERRO VARCHAR(100)  
 
  DECLARE CUR_CLIENTES CURSOR FOR  

  SELECT   
      ROW_NUMBER()OVER(ORDER BY FILIAL ASC) AS LINHA,  
      *
  FROM #tRelatorio A WITH(NOLOCK)  
 ORDER BY 2 ASC 

 OPEN CUR_CLIENTES   

  DECLARE  @LINHA               INT
        , @FILIAL                         VARCHAR(100)
        , @TOTAL                         INT 
        , @NOVOS_LW                      INT 
        , @PERCENTUAL_NOVOS_LW           varchar(100)
        , @EXISTENTES_LW                 INT 
        , @PERCENTUAL_EXISTENTES_LW      varchar(100)
        , @TOTAL_LW_C                    INT 
        , @NOVOS_LW_C                    INT 
        , @PERCENTUAL_NOVOS_LW_C         varchar(100)
        , @EXISTENTES_LW_C               INT 
        , @PERCENTUAL_EXISTENTES_LW_C    varchar(100)
        , @TOTAL_LY                      INT 
        , @NOVOS_LY                      INT 
        , @PERCENTUAL_NOVOS_LY           varchar(100)
        , @EXISTENTES_LY                 INT 
        , @PERCENTUAL_EXISTENTES_LY      varchar(100)


 FETCH NEXT FROM CUR_CLIENTES INTO   
 
   @LINHA                
, @FILIAL                     
, @TOTAL                      
, @NOVOS_LW                   
, @PERCENTUAL_NOVOS_LW        
, @EXISTENTES_LW              
, @PERCENTUAL_EXISTENTES_LW   
, @TOTAL_LW_C                 
, @NOVOS_LW_C                 
, @PERCENTUAL_NOVOS_LW_C      
, @EXISTENTES_LW_C            
, @PERCENTUAL_EXISTENTES_LW_C 
, @TOTAL_LY                   
, @NOVOS_LY                   
, @PERCENTUAL_NOVOS_LY        
, @EXISTENTES_LY              
, @PERCENTUAL_EXISTENTES_LY   

 
  
  SET @BODY = '<HTML><HEAD><TITLE>SHOULDER - INFORMAÇÕES CLIENTES NOVOS VS EXISTENTES </TITLE><style type="text/css"> table { border-collapse:collapse;border:1px solid #CCC;} #tabela tr {border:1px solid #CCC;} #tabela td {font-family: Courier New; font-size:2px width:40px;height:25px;padding:2px;border:1px solid #CCC}</style>'  
  SET @BODY = @BODY + '<font size="2" face="Verdana"><B>IMPORTANTE:</B><BR><BR><ul><li>E-Mail enviado automaticamente por nossos Servidores de TI;<LI>Abaixo a lista dos Clientes novos x existentes de acordo com o período</ul><br>'+CHAR(10)  
  --SET @BODY = @BODY + '<TABLE id="tabela" BORDER = "1"  bgcolor="#000000"><TR ALIGN="CENTER"><TD><B><font size="3" color="#FFFFFF" face="Courier New"><br>NOVOS VS EXISTENTES</FONT></B></TD></TR>'+ CHAR(10)  
  SET @BODY = @BODY + '<BR><TABLE id="tabela" BORDER = "1"  bgcolor="#FFFFFF" ><font size="2" face="Courier New">'  + CHAR(10)  
  SET @BODY = @BODY + '<TR ALIGN="CENTER">' + CHAR(10)      
  SET @BODY = @BODY + '<TD><B>FILIAL    </B></TD>'  + CHAR(10)            
  SET @BODY = @BODY + '<TD><B>TOTAL    </B></TD>'  + CHAR(10)            
  SET @BODY = @BODY + '<TD><B>NOVOS          </B></TD>'  + CHAR(10)            
  SET @BODY = @BODY + '<TD><B>%NOVOS             </B></TD>'  + CHAR(10)            
  SET @BODY = @BODY + '<TD><B>EXISTENTES </B></TD>'  + CHAR(10)  
  SET @BODY = @BODY + '<TD><B>%EXISTENTES    </B></TD>'  + CHAR(10)            
  SET @BODY = @BODY + '<TD><B>TOTAL LW          </B></TD>'  + CHAR(10)            
  SET @BODY = @BODY + '<TD><B>NOVOS LW             </B></TD>'  + CHAR(10)            
  SET @BODY = @BODY + '<TD><B>%NOVOS LW </B></TD>'  + CHAR(10)  
  SET @BODY = @BODY + '<TD><B>EXISTENTES LW    </B></TD>'  + CHAR(10)            
  SET @BODY = @BODY + '<TD><B>%EXISTENTES LW         </B></TD>'  + CHAR(10)            
  SET @BODY = @BODY + '<TD><B>TOTAL LY          </B></TD>'  + CHAR(10)            
  SET @BODY = @BODY + '<TD><B>NOVOS LY             </B></TD>'  + CHAR(10)            
  SET @BODY = @BODY + '<TD><B>%NOVOS LY </B></TD>'  + CHAR(10)  
  SET @BODY = @BODY + '<TD><B>EXISTENTES LY    </B></TD>'  + CHAR(10)            
  SET @BODY = @BODY + '<TD><B>%EXISTENTES LY         </B></TD>'  + CHAR(10)    
  SET @BODY = @BODY + '</FONT></TR>'+ CHAR(10)  
  
  
 WHILE @@FETCH_STATUS = 0  
 BEGIN  
  
  
  IF (@LINHA%2) = 1  
  BEGIN  
   SET @BODY = @BODY + '<TR BGCOLOR="#F0F8FF"><font size="2" face="Courier New" color="#696969">' + CHAR(10)       
--começa as tratativas aqui
   SET @BODY = @BODY + '<TD ALIGN="LEFT">'  + LTRIM(RTRIM(@FILIAL)) + '</TD>' + CHAR(10)               
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@TOTAL)) + '</TD>' + CHAR(10)               
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@NOVOS_LW))    + '</TD>' + CHAR(10)                
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@PERCENTUAL_NOVOS_LW))  + '</TD>' + CHAR(10)          
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@EXISTENTES_LW)) + '</TD>' + CHAR(10) 
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@PERCENTUAL_EXISTENTES_LW))  + '</TD>' + CHAR(10)          
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@TOTAL_LW_C)) + '</TD>' + CHAR(10)    
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@NOVOS_LW_C))  + '</TD>' + CHAR(10)          
   
   IF CONVERT(DECIMAL(10,2), REPLACE(@PERCENTUAL_NOVOS_LW_C,',','.') )   < = 0 
   BEGIN
      SET @BODY = @BODY + '<TD ALIGN="RIGHT" BGCOLOR="#ffc7ce"><font size="2" face="Courier New" color="#9c0006">'  + LTRIM(RTRIM(@PERCENTUAL_NOVOS_LW_C))  + '</font> </TD>' + CHAR(10)          
   END
   ELSE
   BEGIN
       SET @BODY = @BODY + '<TD ALIGN="RIGHT" BGCOLOR="#c6efce "><font size="2" face="Courier New" color="#006100 ">'  + LTRIM(RTRIM(@PERCENTUAL_NOVOS_LW_C))  + '</font> </TD>' + CHAR(10)          
   END
  

    SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@EXISTENTES_LW_C))  + '</TD>' + CHAR(10)  


   IF CONVERT(DECIMAL(10,2), REPLACE(@PERCENTUAL_EXISTENTES_LW_C,',','.')) < = 0 
   BEGIN
      SET @BODY = @BODY + '<TD ALIGN="RIGHT" BGCOLOR="#ffc7ce"><font size="2" face="Courier New" color="#9c0006">' + LTRIM(RTRIM(@PERCENTUAL_EXISTENTES_LW_C))  + '</font> </TD>' + CHAR(10)          
   END
   ELSE
   BEGIN
       SET @BODY = @BODY + '<TD ALIGN="RIGHT" BGCOLOR="#c6efce "><font size="2" face="Courier New" color="#006100 ">'  + LTRIM(RTRIM(@PERCENTUAL_EXISTENTES_LW_C))  + '</font> </TD>' + CHAR(10)          
   END
         
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@TOTAL_LY))  + '</TD>' + CHAR(10)          
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@NOVOS_LY)) + '</TD>' + CHAR(10)    
   
   IF CONVERT(DECIMAL(10,2), REPLACE(@PERCENTUAL_NOVOS_LY,',','.')) < = 0 
   BEGIN
      SET @BODY = @BODY + '<TD ALIGN="RIGHT" BGCOLOR="#ffc7ce"><font size="2" face="Courier New" color="#9c0006">'  + LTRIM(RTRIM(@PERCENTUAL_NOVOS_LY))  + '</font> </TD>' + CHAR(10)          
   END
   ELSE
   BEGIN
       SET @BODY = @BODY + '<TD ALIGN="RIGHT" BGCOLOR="#c6efce "><font size="2" face="Courier New" color="#006100 ">' + LTRIM(RTRIM(@PERCENTUAL_NOVOS_LY))  + '</font> </TD>' + CHAR(10)          
   END
   


   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@EXISTENTES_LY)) + '</TD>' + CHAR(10)    

   IF CONVERT(DECIMAL(10,2), REPLACE(@PERCENTUAL_EXISTENTES_LY ,',','.')) < = 0 
   BEGIN
      SET @BODY = @BODY + '<TD ALIGN="RIGHT" BGCOLOR="#ffc7ce"><font size="2" face="Courier New" color="#9c0006">'   + LTRIM(RTRIM(@PERCENTUAL_EXISTENTES_LY))  + '</font> </TD>' + CHAR(10)          
   END
   ELSE
   BEGIN
       SET @BODY = @BODY + '<TD ALIGN="RIGHT" BGCOLOR="#c6efce "><font size="2" face="Courier New" color="#006100 ">'  + LTRIM(RTRIM(@PERCENTUAL_EXISTENTES_LY))  + '</font> </TD>' + CHAR(10)          
   END
 
   SET @BODY = @BODY + '</FONT></TR>' + CHAR(10)  



  END  
  ELSE  
  BEGIN  
    SET @BODY = @BODY + '<TR><font size="2" face="Courier New" color="#696969">' + CHAR(10)       
    SET @BODY = @BODY + '<TD ALIGN="LEFT">'  + LTRIM(RTRIM(@FILIAL)) + '</TD>' + CHAR(10)               
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@TOTAL)) + '</TD>' + CHAR(10)               
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@NOVOS_LW))    + '</TD>' + CHAR(10)                
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@PERCENTUAL_NOVOS_LW))  + '</TD>' + CHAR(10)          
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@EXISTENTES_LW)) + '</TD>' + CHAR(10) 
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@PERCENTUAL_EXISTENTES_LW))  + '</TD>' + CHAR(10)          
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@TOTAL_LW_C)) + '</TD>' + CHAR(10)    
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@NOVOS_LW_C))  + '</TD>' + CHAR(10)          
   
   IF CONVERT(DECIMAL(10,2), REPLACE(@PERCENTUAL_NOVOS_LW_C,',','.') )   < = 0 
   BEGIN
      SET @BODY = @BODY + '<TD ALIGN="RIGHT" BGCOLOR="#ffc7ce"><font size="2" face="Courier New" color="#9c0006">'  + LTRIM(RTRIM(@PERCENTUAL_NOVOS_LW_C))  + '</font> </TD>' + CHAR(10)          
   END
   ELSE
   BEGIN
       SET @BODY = @BODY + '<TD ALIGN="RIGHT" BGCOLOR="#c6efce "><font size="2" face="Courier New" color="#006100 ">'  + LTRIM(RTRIM(@PERCENTUAL_NOVOS_LW_C))  + '</font> </TD>' + CHAR(10)          
   END
  

    SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@EXISTENTES_LW_C))  + '</TD>' + CHAR(10)  


   IF CONVERT(DECIMAL(10,2), REPLACE(@PERCENTUAL_EXISTENTES_LW_C,',','.')) < = 0 
   BEGIN
      SET @BODY = @BODY + '<TD ALIGN="RIGHT" BGCOLOR="#ffc7ce"><font size="2" face="Courier New" color="#9c0006">' + LTRIM(RTRIM(@PERCENTUAL_EXISTENTES_LW_C))  + '</font> </TD>' + CHAR(10)          
   END
   ELSE
   BEGIN
       SET @BODY = @BODY + '<TD ALIGN="RIGHT" BGCOLOR="#c6efce "><font size="2" face="Courier New" color="#006100 ">'  + LTRIM(RTRIM(@PERCENTUAL_EXISTENTES_LW_C))  + '</font> </TD>' + CHAR(10)          
   END
         
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@TOTAL_LY))  + '</TD>' + CHAR(10)          
   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@NOVOS_LY)) + '</TD>' + CHAR(10)    
   
   IF CONVERT(DECIMAL(10,2), REPLACE(@PERCENTUAL_NOVOS_LY,',','.')) < = 0 
   BEGIN
      SET @BODY = @BODY + '<TD ALIGN="RIGHT" BGCOLOR="#ffc7ce"><font size="2" face="Courier New" color="#9c0006">'  + LTRIM(RTRIM(@PERCENTUAL_NOVOS_LY))  + '</font> </TD>' + CHAR(10)          
   END
   ELSE
   BEGIN
       SET @BODY = @BODY + '<TD ALIGN="RIGHT" BGCOLOR="#c6efce "><font size="2" face="Courier New" color="#006100 ">' + LTRIM(RTRIM(@PERCENTUAL_NOVOS_LY))  + '</font> </TD>' + CHAR(10)          
   END
   


   SET @BODY = @BODY + '<TD ALIGN="RIGHT">'  + LTRIM(RTRIM(@EXISTENTES_LY)) + '</TD>' + CHAR(10)    

   IF CONVERT(DECIMAL(10,2), REPLACE(@PERCENTUAL_EXISTENTES_LY ,',','.')) < = 0 
   BEGIN
      SET @BODY = @BODY + '<TD ALIGN="RIGHT" BGCOLOR="#ffc7ce"><font size="2" face="Courier New" color="#9c0006">'   + LTRIM(RTRIM(@PERCENTUAL_EXISTENTES_LY))  + '</font> </TD>' + CHAR(10)          
   END
   ELSE
   BEGIN
       SET @BODY = @BODY + '<TD ALIGN="RIGHT" BGCOLOR="#c6efce "><font size="2" face="Courier New" color="#006100 ">'  + LTRIM(RTRIM(@PERCENTUAL_EXISTENTES_LY))  + '</font> </TD>' + CHAR(10)          
   END
 
    
   SET @BODY = @BODY + '</FONT></TR>' + CHAR(10)  
  END  




  FETCH NEXT FROM CUR_CLIENTES INTO   
 
   @LINHA                
, @FILIAL                     
, @TOTAL                      
, @NOVOS_LW                   
, @PERCENTUAL_NOVOS_LW        
, @EXISTENTES_LW              
, @PERCENTUAL_EXISTENTES_LW   
, @TOTAL_LW_C                 
, @NOVOS_LW_C                 
, @PERCENTUAL_NOVOS_LW_C      
, @EXISTENTES_LW_C            
, @PERCENTUAL_EXISTENTES_LW_C 
, @TOTAL_LY                   
, @NOVOS_LY                   
, @PERCENTUAL_NOVOS_LY        
, @EXISTENTES_LY              
, @PERCENTUAL_EXISTENTES_LY  

 END  
 SET @BODY = @BODY +
 --'</TABLE>
'</TABLE><br><img src="http://mkt.shoulder.com.br/negocios/news_retirada_socios_LOGOS_02.jpg" alt="Smiley face" height="80" width="270" ></BODY></HTML>'  
   select @BODY
 EXEC MSDB.DBO.SP_SEND_DBMAIL  
  @RECIPIENTS='gusbernardes21@gmail.com;rodrigo.righetto@shoulder.com.br', 
  --@COPY_RECIPIENTS='alerta-suporte@shoulder.com.br',  
  @SUBJECT=@ASSUNTO,  
  @BODY = @BODY,  
  @BODY_FORMAT='HTML'  
 CLOSE CUR_CLIENTES  
 DEALLOCATE CUR_CLIENTES  
    



select *
from produto 