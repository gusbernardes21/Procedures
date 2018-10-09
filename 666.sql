
/*
   -FAZ O CONTROLE DOS PERÍODOS EM ABERTO
   -BUSCA CADASTROS
   -BUSCA VENDAS
   - CALCULA DIVERGÊNCIA DOS PERÍODOS COM O PRÉ-FECHAMENTO LIGAD */


  USE WAREHOUSE

--CREATE PROCEDURE SHBI_PROC_COM_COMISSAO
  
  IF OBJECT_ID('tempdb..#tPeriodoComissao') IS NOT NULL
  BEGIN 
    DROP TABLE #tPeriodoComissao 
  END 
 /*RECUPERA OS PERÍODOS A SEREM CALCULADOS
   NESTA ETAPA TEMOS OS PERÍODOS EM ABERTO (QUE SEMPRE CALCULAM TUDO) */

  SELECT CODIGO_PERIODO
       , DATA_INICIO_PERIODO
       , DATA_FIM_PERIODO
       , PERIODO_PRE_FECHAMENTO
       , TIPO_PERIODO 
       , '0'AS cCalculado  
    INTO #tPeriodoComissao 
    FROM WAREHOUSE..SHBI_TAB_COM_PERIODO_COMISSAO
   WHERE PERIODO_CALCULADO ='0'
     AND PERIODO_PRE_FECHAMENTO ='0' 

WHILE EXISTS ( SELECT TOP 1 1 
                 FROM #tPeriodoComissao
               WHERE cCalculado = '0' ) 

BEGIN 

 /* CARREGA AS FILIAIS QUE IRÃO COMPOR O PERÍODO */

 EXECUTE WAREHOUSE..SHBI_PROC_COM_CARREGA_FILIAIS_PERIODO 


/* CARREGA AS GERENTES QUE IRÃO COMPOR O PERÍODO */


 SELECT TOP 100 * FROM WAREHOUSE..SHBI_TAB_COM_GERENTES
 SELECT TOP 100 * FROM WAREHOUSE..SHBI_TAB_COM_GERENTES_AFASTAMENTO
 SELECT TOP 100 * FROM WAREHOUSE..SHBI_TAB_COM_VENDEDORAS
 SELECT TOP 100 * FROM WAREHOUSE..SHBI_TAB_COM_SUPERVISORAS
 
 SELECT TOP 100 * FROM WAREHOUSE..SHBI_TAB_COM_FILIAIS_BONUS
 SELECT TOP 100 * FROM WAREHOUSE..SHBI_TAB_COM_EVENTOS
 SELECT TOP 100 * FROM WAREHOUSE..SHBI_TAB_COM_VENDEDORES_EVENTOS
 SELECT TOP 100 * FROM WAREHOUSE..SHBI_TAB_COM_GERENTES_EVENTOS



--CREATE TABLE SHBI_TAB_COM_CADASTRO_EVENTOS ( CODIGO_EVENTO VARCHAR(20)
-- ALTER TABLE SHBI_TAB_COM_EVENTOS DROP COLUMN CODIGO_PERIODO 
--ALTER TABLE SHBI_TAB_COM_EVENTOS ADD ATIVO CHAR(1)
-- ALTER TABLE SHBI_TAB_COM_FILIAIS ADD DOBRA_DOMINGO CHAR(1)



--ALTER TABLE SHBI_TAB_COM_PERIODO_COMISSAO ADD TIPO_PERIODO CHAR(1) 

--UPDATE SHBI_TAB_COM_PERIODO_COMISSAO
--SET TIPO_PERIODO ='1' 


--CREATE TABLE SHBI_TAB_COM_PERIODO_VENDEDOR 
--CREATE TABLE SHBI_TAB_COM_PERIODO_LOJA
--CREATE TABLE SHBI_TAB_COM_PERIODO_GERENTE 

--CONGELA OS CADASTROS

-- CREATE PROCEDURE  SHBI_PROC_COM_GERA_CADASTRO_COMISSAO_PERIODO  



--SHBI_TAB_COM_GERENTES


-- BUSCA AS VENDAS CREATE PROCURE SHBI_PROC_COM_BUSCA_VENDA_PERIODO


--CLASSIFICA AS VENDAS 



-- REALIZA OS CALCULOS SHBI_PROC_COM_CALCULA_COMISSAO_PERIODO 

--PRESISTES OS CALCULCULOS



-- NOTIFICA ERRO 



  --BUSCA VENDA NO FÍISICO DOS PROCESSOS DA LOJA 
  IF OBJECT_ID('tempdb..#tTickets') IS NOT NULL
    BEGIN
      DROP TABLE #tTickets
    END

  IF OBJECT_ID('tempdb..#tVendedores') IS NOT NULL
    BEGIN
      DROP TABLE #tVendedores
    END


  --BUSCA TICKETS
  DECLARE @DATA_INICIO_PERIODO DATETIME
        , @DATA_FIM_PERIODO    DATETIME

  SELECT TOP 1 @DATA_INICIO_PERIODO = DATA_INICIO_PERIODO
             , @DATA_FIM_PERIODO   =  DATA_FIM_PERIODO
  FROM WAREHOUSE..SHBI_TAB_COM_PERIODO_COMISSAO
  WHERE PERIODO_CALCULADO ='0'

  SELECT LV.CODIGO_FILIAL
       , LV.TICKET
       , LV.DATA_VENDA
       , TERMINAL
       , LANCAMENTO_CAIXA
       , LV.VENDEDOR AS VENDEDORA_TICKET
    INTO #tTickets
    FROM LINX..LOJA_VENDA LV
   WHERE NOT EXISTS ( SELECT TOP  1 1 
                        FROM WAREHOUSE..SHBI_TAB_DIM_FILIAIS  A
                       WHERE A.CODIGO_FILIAL =  LV.CODIGO_FILIAL  
                         AND ECOMMERCE = '1'  )
    AND DATA_VENDA BETWEEN @DATA_INICIO_PERIODO AND @DATA_FIM_PERIODO 
    AND DATA_HORA_CANCELAMENTO IS NULL 
    AND TICKET_IMPRESSO = '1'


  SELECT DISTINCT  _ID_FILIAL_CODIGO AS CODIGO_FILIAL
       , _ID_LJVV_TICKET             AS TICKET
       , LJVVV_DTVENDA               AS DATA_VENDA
       , LJVVV_IDVENDEDOR            AS ID_VENDEDOR
       , _ID_LJVD_CODIGO             AS VENDEDOR 
    INTO    #tVendedores
    FROM ( SELECT A.* 
             FROM ( SELECT LVV."CODIGO_FILIAL"																							                                                                   AS _ID_FILIAL_CODIGO 
                         , LVV."DATA_VENDA"																							                                                                      AS LJVVV_DTVENDA
                         , LVV."ID_VENDEDOR"																							                                                                     AS LJVVV_IDVENDEDOR
                         , LVV.TICKET																								                                                                          	AS _ID_LJVV_TICKET 
                         , CONVERT(VARCHAR(4), LVV.VENDEDOR)																			                                                         AS _ID_LJVD_CODIGO 
                         , LVV.DATA_PARA_TRANSFERENCIA                                                                                  AS DATA_PARA_TRANSFERENCIA 
                      FROM LINX..LOJA_VENDA_VENDEDORES 	       	AS 	LVV 		WITH(NOLOCK)
                           INNER JOIN  LINX..LOJA_VENDEDORES 				AS 	LV 			WITH(NOLOCK) ON LVV.VENDEDOR      = LV.VENDEDOR
                           INNER JOIN  LINX..LOJA_VENDA_PRODUTO 	AS 	LP 			WITH(NOLOCK) ON	LVV.CODIGO_FILIAL = LP.CODIGO_FILIAL 				
                                                                                AND LVV.TICKET        = LP.TICKET 							
                                                                                AND LVV.DATA_VENDA    = LP.DATA_VENDA 				
                                                                                AND LVV.ID_VENDEDOR   = LP.ID_VENDEDOR 					
                                                                                AND LP.ITEM_EXCLUIDO=0 								
                                                                                AND LP.QTDE>0
                      WHERE LVV.DATA_VENDA >= '20180701'
                   GROUP BY  LVV."CODIGO_FILIAL"																	
                          ,  LVV."DATA_VENDA"																				
                          ,  LVV."ID_VENDEDOR"																			
                          ,  LVV.TICKET																								  
                          ,  CONVERT(VARCHAR(4), LVV.VENDEDOR)			
                          ,  LVV.DATA_PARA_TRANSFERENCIA ) A 
             INNER JOIN (SELECT LVV.CODIGO_FILIAL 				
                              ,  LVV.TICKET 							
                              ,  LVV.DATA_VENDA		
                              ,  LVV.ID_VENDEDOR 					
                              , MAX(LVV.DATA_PARA_TRANSFERENCIA) AS DATA_PARA_TRANSFERENCIA 
                           FROM LINX.."LOJA_VENDA_VENDEDORES"  LVV 
                       GROUP BY LVV.CODIGO_FILIAL 				
                              , LVV.TICKET 						
	                             ,	LVV.DATA_VENDA		 
                              ,	LVV.ID_VENDEDOR ) B ON A._ID_FILIAL_CODIGO       = B.CODIGO_FILIAL 				
                                                   AND A._ID_LJVV_TICKET         = B.TICKET 							
                                                   AND A.LJVVV_DTVENDA           = B.DATA_VENDA 					
                                                   AND A.LJVVV_IDVENDEDOR        = B.ID_VENDEDOR 					
                                                   AND A.DATA_PARA_TRANSFERENCIA = B.DATA_PARA_TRANSFERENCIA
  UNION 

  SELECT A.* 
    FROM ( SELECT LVV."CODIGO_FILIAL"																		AS _ID_FILIAL_CODIGO 
                , LVV."DATA_VENDA"																					AS LJVVV_DTVENDA
                , LVV."ID_VENDEDOR"																				AS LJVVV_IDVENDEDOR
                , LVV.TICKET																								   AS _ID_LJVV_TICKET 
                , CONVERT(VARCHAR(4), LVV.VENDEDOR)				AS _ID_LJVD_CODIGO 
                , LVV.DATA_PARA_TRANSFERENCIA          AS DATA_PARA_TRANSFERENCIA 
             FROM  LINX.."LOJA_VENDA_VENDEDORES" 	       	AS 	LVV 		WITH(NOLOCK)
                  INNER JOIN  LINX.."LOJA_VENDEDORES" 				AS 	LV 			WITH(NOLOCK) ON LVV.VENDEDOR      = LV.VENDEDOR
                  INNER JOIN  LINX.."LOJA_VENDA_TROCA"   	AS 	LT 			WITH(NOLOCK) ON	LVV.CODIGO_FILIAL = LT.CODIGO_FILIAL 				
                                                                                AND LVV.TICKET        = LT.TICKET 							
                                                                                AND LVV.DATA_VENDA    = LT.DATA_VENDA 				
                                                                                AND LVV.ID_VENDEDOR   = LT.ID_VENDEDOR 					
                                                                                AND LT.ITEM_EXCLUIDO=0 								
                                                                                AND LT.QTDE>0
            WHERE LVV.DATA_VENDA >= '20180701'
         GROUP BY          LVV."CODIGO_FILIAL"																							                                                                   
                         , LVV."DATA_VENDA"																							                                                                      
                         , LVV."ID_VENDEDOR"																							                                                                     
                         , LVV.TICKET																								                                                                           
                         , CONVERT(VARCHAR(4), LVV.VENDEDOR)																			                                                         
                         , LVV.DATA_PARA_TRANSFERENCIA ) A 
                                    INNER JOIN (SELECT LVV.CODIGO_FILIAL 				
                                                     ,  LVV.TICKET 							
                                                     ,  LVV.DATA_VENDA		
                                                     ,  LVV.ID_VENDEDOR 					
                                                     , MAX(LVV.DATA_PARA_TRANSFERENCIA) AS DATA_PARA_TRANSFERENCIA 
                                                  FROM LINX.."LOJA_VENDA_VENDEDORES"  LVV 
                                              GROUP BY LVV.CODIGO_FILIAL 				
                                                     , LVV.TICKET 						
	                                                    ,	LVV.DATA_VENDA		 
                                                     ,	LVV.ID_VENDEDOR ) B ON A._ID_FILIAL_CODIGO       = B.CODIGO_FILIAL 				
                                                                          AND A._ID_LJVV_TICKET         = B.TICKET 							
                                                                          AND A.LJVVV_DTVENDA           = B.DATA_VENDA 					
                                                                          AND A.LJVVV_IDVENDEDOR        = B.ID_VENDEDOR 					
                                                                          AND A.DATA_PARA_TRANSFERENCIA = B.DATA_PARA_TRANSFERENCIA) A



   SELECT LVP.TICKET
        , LVP.CODIGO_FILIAL
        , LVP.DATA_VENDA
        , V.VENDEDOR
        , 'FISICO' AS TIPO
        , 'VENDA' AS SUB_TIPO
        , SUM((LVP.PRECO_LIQUIDO *  LVP.QTDE ) -( (LVP.PRECO_LIQUIDO *  LVP.QTDE)  * FATOR_DESCONTO_VENDA)) AS VALOR_PAGO_VENDA_PRODUTO 
     --INTO #tProdutos
     FROM LINX..LOJA_VENDA_PRODUTO LVP
        INNER JOIN #tTickets T ON T.CODIGO_FILIAL = LVP.CODIGO_FILIAL 
                              AND T.DATA_VENDA    = LVP.DATA_VENDA
                              AND T.TICKET        = LVP.TICKET
      
        INNER JOIN #tVendedores V  ON V.CODIGO_FILIAL = LVP.CODIGO_FILIAL 
                              AND V.DATA_VENDA    = LVP.DATA_VENDA
                              AND V.TICKET        = LVP.TICKET
                              AND V.ID_VENDEDOR   = LVP.ID_VENDEDOR 
     WHERE LVP.ITEM_EXCLUIDO='0' 
       AND LVP.QTDE > 0 
       AND LVP.PRODUTO NOT IN ( '121300020', '121300021', '121300022', '121300023', '121300024' ) 
GROUP BY   LVP.TICKET
        , LVP.CODIGO_FILIAL
        , LVP.DATA_VENDA
        , V.VENDEDOR


   SELECT LVP.TICKET
        , LVP.CODIGO_FILIAL
        , LVP.DATA_VENDA
        , V.VENDEDOR
        , 'FISICO' AS TIPO
        , 'TROCA' AS SUB_TIPO
        , SUM((LVP.PRECO_LIQUIDO *  LVP.QTDE ) -( (LVP.PRECO_LIQUIDO *  LVP.QTDE)  * FATOR_DESCONTO_VENDA)) AS VALOR_PAGO_VENDA_PRODUTO 
     FROM LINX..LOJA_VENDA_TROCA LVP
          INNER JOIN #tTickets T     ON T.CODIGO_FILIAL = LVP.CODIGO_FILIAL 
                                    AND T.DATA_VENDA    = LVP.DATA_VENDA
                                    AND T.TICKET        = LVP.TICKET
          INNER JOIN #tVendedores V  ON V.CODIGO_FILIAL = LVP.CODIGO_FILIAL 
                                    AND V.DATA_VENDA    = LVP.DATA_VENDA
                                    AND V.TICKET        = LVP.TICKET
                                    AND V.ID_VENDEDOR   = LVP.ID_VENDEDOR 
     WHERE LVP.ITEM_EXCLUIDO='0' 
       AND LVP.QTDE > 0  
  GROUP BY   LVP.TICKET
          , LVP.CODIGO_FILIAL
          , LVP.DATA_VENDA
          , V.VENDEDOR
    
  SELECT A.CODIGO_FILIAL
       , A.TICKET
       , A.DATA_VENDA
       ,	A.VENDEDOR
       , 'VITRINE' AS TIPO
       ,	'VENDA' AS SUB_TIPO
       , CONVERT(NUMERIC(15,2),SUM(E.PRECO_LIQUIDO*E.QTDE - ((E.PRECO_LIQUIDO*E.QTDE/VALOR_TOTAL_PEDIDO)*(D.DESCONTO)))) AS VALOR 
    FROM LINX..LOJA_VENDA A WITH(NOLOCK)
         INNER JOIN LINX..LOJA_VENDA_PARCELAS B WITH(NOLOCK) ON A.CODIGO_FILIAL        = B.CODIGO_FILIAL 
                                                            AND A.TERMINAL             = B.TERMINAL 
                                                            AND A.LANCAMENTO_CAIXA     = B.LANCAMENTO_CAIXA
         INNER JOIN LINX..LOJA_PEDIDO D WITH(NOLOCK)        	ON A.TICKET               = D.TICKET_VENDA 
                                                            AND A.CODIGO_FILIAL        = D.CODIGO_FILIAL_VENDA
         INNER JOIN LINX..LOJA_PEDIDO_PRODUTO E WITH(NOLOCK)	ON D.PEDIDO               = E.PEDIDO
                                                            AND D.CODIGO_FILIAL_ORIGEM = E.CODIGO_FILIAL_ORIGEM
        CROSS APPLY ( SELECT SUM (F.PRECO_LIQUIDO * F.QTDE) AS VALOR_TOTAL_PEDIDO
                        FROM LINX..LOJA_PEDIDO_PRODUTO F WITH(NOLOCK)
                       WHERE  F.PEDIDO = E.PEDIDO
                         AND  F.CODIGO_FILIAL_ORIGEM = E.CODIGO_FILIAL_ORIGEM) Total_Pedido
    WHERE B.TIPO_PGTO = '\' 
      AND B.VALOR < 0 
      AND A.CODIGO_FILIAL NOT IN (SELECT CODIGO_FILIAL
                                    FROM WAREHOUSE..SHBI_TAB_DIM_FILIAIS  
                                   WHERE ECOMMERCE = '1'   ) 
      AND E.CANCELADO = 0 
      AND D.CANCELADO =0 
 GROUP BY 
	  A.CODIGO_FILIAL, 
	  A.TICKET, 
	  A.DATA_VENDA, 
	  A.CODIGO_CLIENTE, 
	  A.VENDEDOR 

 

  SELECT H.CODIGO_FILIAL
       , A.TICKET
       , A.DATA_VENDA
       , A.VENDEDOR
       , 'CROSS SALE' AS TIPO
       , 'VENDA'      AS SUB_TIPO
	      , CONVERT(NUMERIC(15,2),SUM(E.PRECO_LIQUIDO*E.QTDE - ((E.PRECO_LIQUIDO*E.QTDE/VALOR_TOTAL_PEDIDO)*(D.DESCONTO)))) AS VALOR   
  FROM LINX..LOJA_PEDIDO D
       INNER JOIN  LINX..LOJA_VENDA A  ON  A.TICKET = D.TICKET_VENDA 
                                      AND A.CODIGO_FILIAL = D.CODIGO_FILIAL_VENDA  
       INNER JOIN LINX..LOJA_PEDIDO_PRODUTO E WITH(NOLOCK) ON D.PEDIDO = E.PEDIDO  
                                                          AND D.CODIGO_FILIAL_ORIGEM = E.CODIGO_FILIAL_ORIGEM
       INNER JOIN LINX..LOJA_PEDIDO_VENDA F WITH(NOLOCK)   ON  F.PEDIDO       = D.PEDIDO 
	                                                         AND F.ITEM          = E.ITEM 
	                                                         AND F.CODIGO_FILIAL = D.CODIGO_FILIAL_ORIGEM

       INNER JOIN LINX..LOJAS_VAREJO G                     ON A.CODIGO_FILIAL = G.CODIGO_FILIAL
       INNER JOIN LINX..LOJA_VENDEDORES H                  ON A.VENDEDOR      = H.VENDEDOR
       INNER JOIN LINX..LOJAS_VAREJO I                     ON H.CODIGO_FILIAL = I.CODIGO_FILIAL
       CROSS APPLY ( SELECT SUM (F.PRECO_LIQUIDO * F.QTDE) AS VALOR_TOTAL_PEDIDO
                       FROM LINX..LOJA_PEDIDO_PRODUTO F WITH(NOLOCK)
                      WHERE  F.PEDIDO = E.PEDIDO
                        AND  F.CODIGO_FILIAL_ORIGEM = E.CODIGO_FILIAL_ORIGEM ) Total_Pedido

 WHERE D.VENDEDOR NOT IN ('B999','0001','001') 
   AND D.CODIGO_FILIAL_VENDA IN ( SELECT CODIGO_FILIAL
                                    FROM WAREHOUSE..SHBI_TAB_DIM_FILIAIS  
                                   WHERE ECOMMERCE = '1' ) 
   AND YEAR(D.DATA)>=2017 
   AND D.DIGITACAO_ENCERRADA = '1'
   AND D.CANCELADO = '0' 
   AND D.STATUS_B2C = '4'
  GROUP BY H.CODIGO_FILIAL
	        , A.TICKET
	        , A.DATA_VENDA
	        , A.VENDEDOR 

  SELECT LVP.TICKET
       , LVP.CODIGO_FILIAL
       , LVP.DATA_VENDA
       , V.VENDEDOR
       , 'AJUSTE' AS TIPO
       , 'DESCONTO' AS SUB_TIPO
       , SUM((LVP.PRECO_LIQUIDO *  LVP.QTDE ) -( (LVP.PRECO_LIQUIDO *  LVP.QTDE)  * FATOR_DESCONTO_VENDA)) AS VALOR_PAGO_VENDA_PRODUTO 
    FROM LINX..LOJA_VENDA_PRODUTO LVP
         INNER JOIN #tTickets T ON T.CODIGO_FILIAL = LVP.CODIGO_FILIAL 
                               AND T.DATA_VENDA    = LVP.DATA_VENDA
                               AND T.TICKET        = LVP.TICKET
        INNER JOIN #tVendedores V  ON V.CODIGO_FILIAL = LVP.CODIGO_FILIAL 
                               AND V.DATA_VENDA    = LVP.DATA_VENDA
                               AND V.TICKET        = LVP.TICKET
                               AND V.ID_VENDEDOR   = LVP.ID_VENDEDOR 
     WHERE LVP.ITEM_EXCLUIDO='0' 
       AND LVP.QTDE > 0 
       AND LVP.PRODUTO  IN ( '121300020', '121300021', '121300022', '121300023', '121300024' ) 
  GROUP BY LVP.TICKET
        , LVP.CODIGO_FILIAL
        , LVP.DATA_VENDA
        , V.VENDEDOR

  SELECT LP.CODIGO_FILIAL 
       , LP.TICKET
       , LP.DATA_VENDA
       , V.VENDEDOR
       , 'AJUSTE' AS TIPO
       , 'CAMPANHA' AS SUB_TIPO
       , ROUND(SUM(((PRECO_LIQUIDO*QTDE)  /   (TOTAL_SEMDESCONTO) ) * LPAC.CONSERTOS  )  ,2)  AS VALOR_CONCERTO_ADD
    FROM LINX..UNICO_CAMPANHA_ATIVADA UA
         INNER JOIN LINX..LOJA_VENDA_PRODUTO LP ON LP.TICKET        = UA.TICKET
                                               AND LP.CODIGO_FILIAL = UA.CODIGO_FILIAL
                                               AND LP.DATA_VENDA	   = CONVERT(DATE,UA.DATA_VENDA) 
         INNER JOIN #tVendedores V              ON V.CODIGO_FILIAL = LP.CODIGO_FILIAL 
                                               AND V.DATA_VENDA    = LP.DATA_VENDA
                                               AND V.TICKET        = LP.TICKET
                                               AND V.ID_VENDEDOR   = LP.ID_VENDEDOR 
         INNER JOIN #tTickets T                 ON T.CODIGO_FILIAL = LP.CODIGO_FILIAL 
                                               AND T.DATA_VENDA    = LP.DATA_VENDA
                                               AND T.TICKET        = LP.TICKET
         CROSS APPLY ( SELECT SUM (PRECO_LIQUIDO*QTDE) AS TOTAL_SEMDESCONTO
	   			  	               FROM LINX..LOJA_VENDA_PRODUTO LPA 
	   				                WHERE LPA.TICKET          = T.TICKET 
					                     AND LPA.CODIGO_FILIAL	  = T.CODIGO_FILIAL 
					                     AND LPA.DATA_VENDA	 	   = T.DATA_VENDA 
					                     AND LEFT(CODIGO_BARRA,9) NOT IN   ('121300020', '121300021', '121300022', '121300023', '121300024') ) LPA
         CROSS APPLY ( SELECT SUM((PRECO_LIQUIDO * QTDE)-((PRECO_LIQUIDO * QTDE) * FATOR_DESCONTO_VENDA)) AS CONSERTOS
					                    FROM LINX..LOJA_VENDA_PRODUTO LPAC
					                   WHERE LPAC.TICKET        = T.TICKET 
							                   AND LPAC.CODIGO_FILIAL	= T.CODIGO_FILIAL 
							                   AND LPAC.DATA_VENDA	 	 = T.DATA_VENDA 
						                    AND LEFT(CODIGO_BARRA,9)  IN   ('121300020', '121300021', '121300022', '121300023', '121300024') ) LPAC
   WHERE ID_CAMPANHA ='468'
     AND LP.ITEM_EXCLUIDO ='0'
     AND LP.DATA_VENDA >='20180224'  
     AND LP.PRODUTO NOT IN  ('121300020', '121300021', '121300022', '121300023', '121300024') 
 GROUP BY   LP.CODIGO_FILIAL 
        , LP.TICKET
        , LP.DATA_VENDA
        , V.VENDEDOR



  SELECT LV.CODIGO_FILIAL
       , LV.TICKET
       , LV.DATA_VENDA
       , LV.VENDEDORA_TICKET
       , 'GIFT CARD' AS TIPO
       , 'VENDA' AS SUB_TIPO
       , (LVP.VALOR) * -1  AS VALOR_GIFT
  FROM   #tTickets LV WITH (NOLOCK)         
         LEFT  JOIN LINX..LOJA_VENDA_PARCELAS LVP WITH(NOLOCK) ON LVP.LANCAMENTO_CAIXA = LV.LANCAMENTO_CAIXA             
                                                              AND LVP.CODIGO_FILIAL    = LV.CODIGO_FILIAL      
                                                              AND LVP.TERMINAL         = LV.TERMINAL 
WHERE LEFT( LVP.NUMERO_TITULO , 2 ) = '98'
AND LVP.VALOR <0  
AND TIPO_PGTO  ='&' 
 
  SELECT LV.CODIGO_FILIAL
       , LV.TICKET
       , LV.DATA_VENDA
       , LV.VENDEDORA_TICKET
       , 'GIFT CARD' AS TIPO
       , 'TROCA' AS SUB_TIPO
       , LVP.VALOR
  FROM   #tTickets LV WITH (NOLOCK)         
         LEFT  JOIN LINX..LOJA_VENDA_PARCELAS LVP WITH(NOLOCK) ON LVP.LANCAMENTO_CAIXA = LV.LANCAMENTO_CAIXA             
                                                              AND LVP.CODIGO_FILIAL    = LV.CODIGO_FILIAL      
                                                              AND LVP.TERMINAL         = LV.TERMINAL 
WHERE LEFT( LVP.NUMERO_TITULO , 2 ) = '98'
AND LVP.VALOR > 0  
AND TIPO_PGTO  ='&' 

END  