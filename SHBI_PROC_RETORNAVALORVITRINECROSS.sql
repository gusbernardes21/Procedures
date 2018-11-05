Alter PROCEDURE [dbo].[SHBI_PROC_RETORNAVALORVITRINECROSS]    
AS    
BEGIN    
SELECT  BB.REGIAO 
     ,  I.FILIAL    
     , A.DATA_VENDA    
     , 'VITRINE' AS TIPO_VT    
     , A.CODIGO_CLIENTE    
     , L.NOME_VENDEDOR    
     , X.CODIGO_BARRA   
     , P.COLECAO    
     , P.GRIFFE   
    , SUM(X.QTDE) AS QTDE    
     , ISNULL(CONVERT(NUMERIC(15,2),SUM(X.PRECO_LIQUIDO*X.QTDE - ((X.PRECO_LIQUIDO*X.QTDE)*X.FATOR_DESCONTO_VENDA ))),0) AS VALOR      
     , CASE WHEN X.TICKET  IS NULL    
            THEN '1'    
            ELSE '0'    
            END AS CANCELADOVITRINE    
  , CASE WHEN X.TICKET  IS NULL    
            THEN SUM(B.VALOR*-1)     
            ELSE 0    
            END AS VALOR_CANCELADOVITRINE    
   FROM LINX..LOJA_VENDA A WITH(NOLOCK)    
       INNER JOIN LINX..LOJA_VENDEDORES L            ON L.VENDEDOR           = A.VENDEDOR    
       INNER JOIN LINX..LOJAS_VAREJO I                     ON I.CODIGO_FILIAL    = A.CODIGO_FILIAL    
       INNER JOIN LINX..LOJA_VENDA_PARCELAS B WITH(NOLOCK) ON A.CODIGO_FILIAL    = B.CODIGO_FILIAL     
                                                          AND A.TERMINAL         = B.TERMINAL     
                                                          AND A.LANCAMENTO_CAIXA = B.LANCAMENTO_CAIXA 
		 INNER JOIN LINX..FILIAIS					   BB ON BB.FILIAL                        = I.FILIAL												     
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
GROUP BY   BB.REGIAO
      ,I.FILIAL    
     , A.DATA_VENDA     
     , A.CODIGO_CLIENTE    
     , L.NOME_VENDEDOR      
     , X.CODIGO_BARRA      
  , X.TICKET    
  , P.COLECAO     
  , P.GRIFFE   
    
UNION ALL    
    
  SELECT  BB.REGIAO
    ,  I.FILIAL    
    , A.DATA_VENDA    
    , 'CROSS SALE' AS TIPO_VT     
    , A.CODIGO_CLIENTE    
    , H.NOME_VENDEDOR    
    , E.CODIGO_BARRA 
    , P.COLECAO  
     , P.GRIFFE     
    , SUM(E.QTDE) AS QTDE    
    , CONVERT(NUMERIC(15,2),SUM(E.PRECO_LIQUIDO*E.QTDE - ((E.PRECO_LIQUIDO*E.QTDE/VALOR_TOTAL_PEDIDO)*(D.DESCONTO)))) AS VALOR -- GHBP 20171220 - CORRE플O DO VALOR DO TICKET aplicando descontos    
    , 0 AS CANCELADOVITRINE    
    , 0 AS VALOR_CANCELADOVITRINE    
   --  ,0 AS VALOR_2    
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
    INNER JOIN LINX..FILIAIS					   BB ON BB.FILIAL                        = G.FILIAL	 
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
     AND D.STATUS_B2C = '4'    
GROUP BY   I.FILIAL    
    , A.DATA_VENDA    
    , A.CODIGO_CLIENTE    
    , H.NOME_VENDEDOR    
    , E.PRODUTO    
    , E.CODIGO_BARRA  
    , P.COLECAO    
   , P.GRIFFE
   ,BB.REGIAO   
    END