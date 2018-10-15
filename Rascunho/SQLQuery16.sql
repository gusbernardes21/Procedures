CREATE /*OR CREATE*/ PROCEDURE [dbo].[SHBI_REPOSICAOAUTOMATICA]    --AMD@20170216            
AS                                                                               
DECLARE @FILIAL_DESTINO VARCHAR(25)                                                                              
DECLARE @FILIAL_ORIGEM VARCHAR(25)                                                                              
DECLARE @FILIAL_DESTINO_CHAVE VARCHAR(25)                                                                              
DECLARE @FILIAL_ORIGEM_CHAVE VARCHAR(25)                                                                              
DECLARE @DATA DATETIME                                              
DECLARE @IGNORA_RESERVA  VARCHAR(50)                                                                  
DECLARE @ENTREGA DATETIME                                                                               
DECLARE @PEDIDO VARCHAR(8000)                                                                              
DECLARE @COUNT  INT                                                                              
DECLARE @COUNT_2  INT                                                                              
DECLARE @P4 VARCHAR(8000)                                                                            
                                                                              
DECLARE @PRODUTO  VARCHAR(20)                                                                              
DECLARE @ID VARCHAR(10)                                                                              
DECLARE @COR VARCHAR(10)                                                                              
DECLARE @FILIAL_CODIGO VARCHAR(20)                                                                              
DECLARE @TIPO_FILIAL VARCHAR(50)                                                                              
DECLARE @EMISSAO DATETIME                                                                              
DECLARE @USUARIO VARCHAR(40)             
declare @MARCA VARCHAR(30)       --AMD@20170216                                                                    
DECLARE @VE1 INT                                                                              
DECLARE @VE2 INT                                                                               
DECLARE @VE3 INT                                                                               
DECLARE @VE4 INT                                                                               
DECLARE @VE5 INT                                                                               
DECLARE @VE6 INT                                                                               
DECLARE @VE7 INT                                                                               
DECLARE @VE8 INT                                                                               
DECLARE @VE9 INT                                                                               
DECLARE @VE10 INT                                                                              
                                                                              
IF EXISTS (SELECT NAME FROM SYS.TABLES WHERE NAME = 'REP_AUTOMATICA') DROP TABLE LINX..REP_AUTOMATICA                                                                              
                                                                                        
 CREATE TABLE LINX.DBO.REP_AUTOMATICA     
       (ID     INT,     
     PRODUTO   VARCHAR(20),     
     COR    VARCHAR(10) ,     
     CODIGO_FILIAL  VARCHAR(20),    
     FILIAL_ORIGEM  VARCHAR(20),    
     EXPORTACAO   DATETIME,     
     USUARIO   VARCHAR(40),    
     MARCA    VARCHAR(30),    
     IGNORA_RESERVA  VARCHAR(50),     
     ENTREGA   DATETIME,                  
     VE1    INT,    
     VE2    INT,    
     VE3    INT,    
     VE4    INT,    
     VE5    INT,    
     VE6    INT,    
     VE7    INT,    
     VE8   INT,    
     VE9    INT,    
     VE10    INT)                
                                                                              
SET @COUNT = 0                                                                              
                     
------------------------------TRANSFORMA A COLUNA CODIGO_FILIAL EM FILIAL ORIGEM E FILIAL DESTINO-----------------------------------------------------------------                                
--EXEC SHBI_REPOSICAOAUTOMATICA_NEW               
                                                              
DECLARE VCURSOR_REPOSICAO CURSOR FOR                                                                        
SELECT DISTINCT                                                    
  ID_REP,                                                                          
  PRODUTO,                                                                            
  COR,                                                                               
  CODIGO_FILIAL,                                     
  CASE WHEN VENDAS = '***' THEN 'ORIGEM' ELSE 'DESTINO' END AS TIPO_FILIAL,                                                
  CONVERT(DATETIME,CONVERT(VARCHAR(08),EXPORTACAO,112))AS EXPORTACAO,                                                   
  USUARIO,           
  MARCA , -- AMD@20170216          
  IGNORA_RESERVA,                                                                     
  CONVERT(DATETIME,RIGHT(LIMITE_ENTREGA,4)+'-'+ REPLACE(LEFT(LIMITE_ENTREGA,5),LEFT(LEFT(LIMITE_ENTREGA,5),3),'')                                       
  +'-'+LEFT(LIMITE_ENTREGA,2)+' 00:00.000') AS ENTREGA,                                                                             
  CASE WHEN (POSICAOTAM = '1') THEN QTDE_ENVIAR_LOJA ELSE '0' END AS VE1,                                                                              
  CASE WHEN (POSICAOTAM = '2') THEN QTDE_ENVIAR_LOJA ELSE '0' END AS VE2,                                                                              
  CASE WHEN (POSICAOTAM = '3') THEN QTDE_ENVIAR_LOJA ELSE '0' END AS VE3,                                                                              
  CASE WHEN (POSICAOTAM = '4') THEN QTDE_ENVIAR_LOJA ELSE '0' END AS VE4,                                                                              
  CASE WHEN (POSICAOTAM = '5') THEN QTDE_ENVIAR_LOJA ELSE '0' END AS VE5,                                                                              
  CASE WHEN (POSICAOTAM = '6') THEN QTDE_ENVIAR_LOJA ELSE '0' END AS VE6,                                                                               
  CASE WHEN (POSICAOTAM = '7') THEN QTDE_ENVIAR_LOJA ELSE '0' END AS VE7,                                                                              
  CASE WHEN (POSICAOTAM = '8') THEN QTDE_ENVIAR_LOJA ELSE '0' END AS VE8,                                                                              
  CASE WHEN (POSICAOTAM = '9') THEN QTDE_ENVIAR_LOJA ELSE '0' END AS VE9,                                                             
  CASE WHEN (POSICAOTAM ='10') THEN QTDE_ENVIAR_LOJA ELSE '0' END AS VE10                                                                              
 FROM WAREHOUSE.dbo.SHBI_REP_AUTOMATICA_NEW                                                                      
 WHERE [STATUS] = 0                
 ORDER BY ID_REP ASC                                                           
                                                                              
OPEN VCURSOR_REPOSICAO                                                                               
--FETCH NEXT FROM VCURSOR_REPOSICAO INTO @ID, @PRODUTO, @COR, @FILIAL_CODIGO, @TIPO_FILIAL, @EMISSAO, @USUARIO, @IGNORA_RESERVA, @ENTREGA, @VE1, @VE2, @VE3, @VE4, @VE5, @VE6, @VE7, @VE8, @VE9, @VE10                                                        
  
     
      
        
                 
--AMD@20170216                                                                         
FETCH NEXT FROM VCURSOR_REPOSICAO     
 INTO @ID, @PRODUTO, @COR, @FILIAL_CODIGO, @TIPO_FILIAL, @EMISSAO, @USUARIO,@MARCA, @IGNORA_RESERVA, @ENTREGA, @VE1, @VE2, @VE3, @VE4, @VE5, @VE6, @VE7, @VE8, @VE9, @VE10                                                        
                                                                              
WHILE @@FETCH_STATUS = 0      
BEGIN                                                                              
  PRINT @TIPO_FILIAL                                                                              
  IF @TIPO_FILIAL = 'ORIGEM'                                                                              
  BEGIN                                                                              
    SET @FILIAL_ORIGEM = @FILIAL_CODIGO                                                                                    
  END                                                                              
  ELSE     
  IF @TIPO_FILIAL = 'DESTINO'                         
  BEGIN              
   SET @FILIAL_DESTINO = @FILIAL_CODIGO                                                     
  END                                                                                
                
  --INSERT INTO LINX..REP_AUTOMATICA (ID, PRODUTO,COR,CODIGO_FILIAL,FILIAL_ORIGEM,EXPORTACAO,USUARIO,IGNORA_RESERVA,ENTREGA,VE1,VE2,VE3,VE4,VE5,VE6,VE7,VE8,VE9,VE10)                     
  --VALUES (@ID, @PRODUTO,@COR,@FILIAL_CODIGO,@FILIAL_ORIGEM,@EMISSAO,@USUARIO,@IGNORA_RESERVA,@ENTREGA,@VE1,@VE2,@VE3,@VE4,@VE5,@VE6,@VE7,@VE8,@VE9,@VE10)                               
                                                                                
 --SET @COUNT = @COUNT + 1                                                                              
-- FETCH NEXT FROM VCURSOR_REPOSICAO INTO @ID, @PRODUTO, @COR, @FILIAL_CODIGO, @TIPO_FILIAL, @EMISSAO, @USUARIO,@IGNORA_RESERVA, @ENTREGA,@VE1, @VE2, @VE3, @VE4, @VE5, @VE6, @VE7, @VE8, @VE9, @VE10                                                          
  
    
     
         
           
  --amd@20170216          
  INSERT INTO LINX..REP_AUTOMATICA (ID, PRODUTO,COR,CODIGO_FILIAL,FILIAL_ORIGEM,EXPORTACAO,USUARIO,MARCA,IGNORA_RESERVA,ENTREGA,VE1,VE2,VE3,VE4,VE5,VE6,VE7,VE8,VE9,VE10)                     
  VALUES (@ID, @PRODUTO,@COR,@FILIAL_CODIGO,@FILIAL_ORIGEM,@EMISSAO,@USUARIO,@MARCA, @IGNORA_RESERVA,@ENTREGA,@VE1,@VE2,@VE3,@VE4,@VE5,@VE6,@VE7,@VE8,@VE9,@VE10)                               
                                                                                
 SET @COUNT = @COUNT + 1                                                                              
 FETCH NEXT FROM VCURSOR_REPOSICAO INTO @ID, @PRODUTO, @COR, @FILIAL_CODIGO, @TIPO_FILIAL, @EMISSAO, @USUARIO,@MARCA,@IGNORA_RESERVA, @ENTREGA,@VE1, @VE2, @VE3, @VE4, @VE5, @VE6, @VE7, @VE8, @VE9, @VE10                                                     
  
    
                 
                    
END                                                                 
CLOSE VCURSOR_REPOSICAO                                                                                   
DEALLOCATE VCURSOR_REPOSICAO                                             
                                                                           
 SELECT                                                                                                                                                         
   SH.ID, --INCLUSAO O CAMPO PARA VALIDAR O RELACIONAMENTO DO PEDIDO PARA GERAÇÃO DE LOG    
   L.FILIAL AS CODIGO_FILIAL,                                                               
   CASE WHEN (FILIAL_ORIGEM = 'REP_SP') THEN 'FABRICA'                                                                              
     WHEN (FILIAL_ORIGEM = 'REP_CG') THEN 'CDCG ARMAZENAGEM'                                                      
     WHEN (FILIAL_ORIGEM = 'CDSB2C') THEN 'CDSP E-COMMERCE'                                                                              
   WHEN (FILIAL_ORIGEM = 'CRS013') THEN 'CD REPOSICAO SP'                        
     WHEN (FILIAL_ORIGEM = 'CDSP2Q') THEN 'CDSP SEGUNDA QUALIDADE'            
     WHEN (FILIAL_ORIGEM = 'CDSARM') THEN 'CDSP ARMAZENAGEM'     
   END AS FILIAL_ORIGEM,                                                                              
  PRODUTO,                                                                 
  COR,                                             
  EXPORTACAO,                                                                               
  USUARIO,            
 MARCA, -- amd@20170216      ENTREGA,                                                                               
  SUM(VE1) AS VE1,                                                           
  SUM(VE2) AS VE2,                                                                       
  SUM(VE3) AS VE3,                                                                              
  SUM(VE4) AS VE4,                                                                              
  SUM(VE5) AS VE5,                                                 
  SUM(VE6) AS VE6,                                                                              
  SUM(VE7) AS VE7,                                                                              
  SUM(VE8) AS VE8,                                                                               
  SUM(VE9) AS VE9,                                                                              
  SUM(VE10)AS VE10                                                                              
INTO #REPOSICAO_AUTOMATICA                                                                               
FROM LINX..REP_AUTOMATICA SH WITH(NOLOCK)                                                                             
LEFT JOIN LOJAS_VAREJO L                 
  ON  SH.CODIGO_FILIAL = L.CODIGO_FILIAL COLLATE SQL_Latin1_General_CP1_CI_AS                                                                              
WHERE L.FILIAL IS NOT NULL                
GROUP BY SH.ID,L.FILIAL,FILIAL_ORIGEM,PRODUTO,COR,EXPORTACAO,USUARIO,MARCA --PRODUTO,COR,SH.CODIGO_FILIAL,EXPORTACAO,USUARIO,MARCA,FILIAL_ORIGEM,L.FILIAL,ENTREGA                     
ORDER BY 1 ASC, 2 ASC                                                                    
                                                                              
/*SELECT *                              
FROM #REP_AUTOMATICA */                                                                             
                                                                              
---------------------------------GERA CHAVE PARA INSERIR O PEDIDO----------------------------------------------------------------------------------------------                                                                              
--EXEC SHBI_REPOSICAOAUTOMATICA_NEW                       
                                                                              
DECLARE VCURSOR_TESTE1 CURSOR FOR                                      
 SELECT      
  --ID,                                                                  
  FILIAL_ORIGEM ,                                                                              
  CODIGO_FILIAL AS FILIAL_DESTINO,         
  MARCA,                                                                              
  EXPORTACAO AS DATA                                                                           
FROM #REPOSICAO_AUTOMATICA                                                                               
  GROUP BY    
  --ID,                                                                              
  FILIAL_ORIGEM,                                                                              
  CODIGO_FILIAL,            
  MARCA,                                     
  EXPORTACAO                                                                              
BEGIN TRAN                
OPEN VCURSOR_TESTE1     
 --DECLARE @ID_TAB  INT                                                                              
                                                                              
FETCH NEXT FROM VCURSOR_TESTE1 INTO @FILIAL_ORIGEM_CHAVE, @FILIAL_DESTINO_CHAVE,@MARCA, @DATA                                                                      
                                                                              
SET @COUNT_2 = 0                                                                              
                                                    
WHILE @@FETCH_STATUS = 0                                                                              
                                                                              
BEGIN                                                                              
                           
 EXEC SP_EXECUTESQL N'                                                                            
 /* VISUALLINX EXECUTENONQUERY()  */                                                                            
   EXEC LINX..LX_SEQUENCIAL @TABELA_COLUNA = ''VENDAS.PEDIDO'', @EMPRESA = @P1, @SEQUENCIA = @P2 OUTPUT, @UPDATE_SEQUENCIAL = 1, @NEWVALUE = ''''',N'@P1 INT,@P2 VARCHAR(8000) OUTPUT',1,@P4 OUTPUT                                                           
  
    
     
                                                                  
                                                                            
 --SET @P4=(SELECT SEQUENCIA FROM SEQUENCIAIS WHERE TABELA_COLUNA = 'VENDAS.PEDIDO')                                                                              
                                                                            
 SET @PEDIDO = (SELECT @P4)                                                                    
                                                                             
 PRINT 'pedido: ' + @PEDIDO                                                                               
  ------------------------------------INSERIR INFORMAÇÕES NA TABELA VENDAS--------------------------------------------------------                                                                              
  --EXEC SHBI_REPOSICAOAUTOMATICA_NEW                                                                             
                     
  INSERT INTO LINX.DBO.VENDAS                
                                                                                
 (PEDIDO,ROMANEIO,COLECAO,PEDIDO_EXTERNO,DATA_ENVIO,CODIGO_TAB_PRECO,TIPO,DATA_RECEBIMENTO,CONDICAO_PGTO,FILIAL, CLIENTE_ATACADO,TRANSPORTADORA,MOEDA,                                               
  REPRESENTANTE,COMISSAO,GERENTE,COMISSAO_GERENTE,EMISSAO,CADASTRAMENTO,TOT_QTDE_ORIGINAL,TOT_QTDE_ENTREGAR,TOT_VALOR_ORIGINAL,TOT_VALOR_ENTREGAR,                                                                
  ENTREGA_CIF,ENTREGA_ACEITAVEL,PRIORIDADE,[STATUS],APROVACAO,APROVADO_POR,CONFERIDO,CONFERIDO_POR,TABELA_FILHA,OBS,ACEITA_PECAS_PEQUENAS,ACEITA_PECAS_COM_CORTE,                                                                              
  FRETE_CORTESIA,TIPO_FRETE,CODIGO_LOCAL_ENTREGA,PROMOTOR,DATA_FATURAMENTO_RELATIVO,TIPO_CAIXA,FILIAL_DIGITACAO,NUMERO_ENTREGA,PERIODO_PCP,NOME_CLIFOR_ENTREGA,                                                                         
  TIPO_RATEIO,TRANSP_REDESPACHO,OBS_TRANSPORTE,NATUREZA_SAIDA,BANCO,AGENCIA,VALOR_SUB_ITENS,PEDIDO_CONFERENCIA,INDICADOR_VENDA,/*COD_LICENCIADO,                                                                              
  TAB_PRECO_SERVICO,*/CODIGO_CLIENTE_VAREJO,idEnderecoEntrega)                                                                        
                                                                            
  SELECT DISTINCT                                             
  @PEDIDO AS PEDIDO,                                                                              
  '' AS ROMANEIO,                                                              
  CASE WHEN MONTH(GETDATE())IN ('01','02','03','04','05','06') THEN LTRIM(RTRIM(CONVERT(CHAR,YEAR(GETDATE()))))+'OI' ELSE LTRIM(RTRIM(CONVERT(CHAR,YEAR(GETDATE()))))+'PV' END AS COLECAO,                                                  
  '' AS PEDIDO_EXTERNO,               
  '' AS DATA_ENVIO,                                                                                
  P.CODIGO_TAB_PRECO AS CODIGO_TAB_PRECO,                                                                              
  CASE WHEN @FILIAL_DESTINO_CHAVE = 'POLO MODAS' THEN 'RESERVA VAREJO'            
    --ELSE case when @MARCA = 'POP UP STORE' THEN 'PRONTA ENTREGA' -- AMD@20170523      
    ELSE 'VAREJO' END       
    --end -- AMD@20170523      
    AS TIPO,   --AMD@20170216                 
  '' AS DATA_RECEBIMENTO,                                                                              
  '01' CONDICAO_PGTO,                                                                              
  @FILIAL_ORIGEM_CHAVE  AS FILIAL,                                                                              
 @FILIAL_DESTINO_CHAVE AS CLIENTE_ATACADO,                                                                              
  C.TRANSPORTADORA AS  TRANSPORTADORA,                                                                              
  'R$' AS MOEDA,                                                                              
  'FABRICA' AS REPRESENTANTE,                                                                              
  0 AS COMISSAO,                                                                              
  'INDEFINIDO' AS GERENTE,                                                                              
  0 AS COMISSAO_GERENTE,                                                                              
  @DATA AS EMISSAO,                                                                              
  @DATA AS CADASTRAMENTO,                                                                               
  SUM(VE1+VE2+VE3+VE4+VE5+VE6+VE7+VE8+VE9+VE10) AS TOT_QTDE_ORIGINAL,                            SUM(VE1+VE2+VE3+VE4+VE5+VE6+VE7+VE8+VE9+VE10) AS TOT_QTDE_ENTREGAR,                                                                              
  SUM(P.PRECO1)*SUM(VE1+VE2+VE3+VE4+VE5+VE6+VE7+VE8+VE9+VE10) AS TOT_VALOR_ORIGINAL,                                                                              
  SUM(P.PRECO1)*SUM(VE1+VE2+VE3+VE4+VE5+VE6+VE7+VE8+VE9+VE10) AS TOT_VALOR_ENTREGAR,                                                                              
  --1 AS ENTREGA_CIF,                                         
  CASE WHEN FRETE_A_PAGAR = 0 THEN 0 ELSE 1 END AS ENTREGA_CIF,        
  0 AS ENTREGA_ACEITAVEL,                                                 
  0 AS PRIORIDADE,                                      
  'A' AS [STATUS],                                                                              
  'A' AS APROVACAO,                                                 
  'PLANEJAMENTO' AS APROVADO_POR,                                                                      
  '1' AS CONFERIDO,                                                                              
  'PLANEJAMENTO' AS CONFERIDO_POR,                                                        
  'VENDAS_PRODUTO' AS TABELA_FILHA,                                                                              
  'PROCESSO DE REPOSICAO AUTOMATICA'+ ' - ' + 'POR:' + USUARIO + ' - ' + @IGNORA_RESERVA +' - '+@MARCA+  
  iif(USUARIO='SHBI_REP_AUTO_AA','|AA','|QV') -- AMD@20171128   --Reposição Automatica Tipo AA Analytic Always, QV QLikview  
   AS OBS,                                                                          
  1 AS ACEITA_PECAS_PEQUENAS,                                                                             
  1 AS ACEITA_PECAS_COM_CORTE,     
  0 AS FRETE_CORTESIA,                                                                              
  CASE WHEN FRETE_A_PAGAR = 0 THEN '02' ELSE '01' END AS TIPO_FRETE,                    
  --'01' AS TIPO_FRETE,                                                                        
  '' AS CODIGO_LOCAL_ENTREGA,                                                   
  '' AS PROMOTOR,                                                                              
  '' AS DATA_FATURAMENTO_RELATIVO,                                                             
  'CAIXA' AS TIPO_CAIXA,                                                 
  CASE WHEN (FILIAL_ORIGEM = 'REP_SP') THEN 'FABRICA'                                                                              
    WHEN (FILIAL_ORIGEM = 'REP_CG') THEN 'CDCG ARMAZENAGEM'                                                                              
    WHEN (FILIAL_ORIGEM = 'CDSB2C') THEN 'CDSP E-COMMERCE'                                                                              
    WHEN (FILIAL_ORIGEM = 'CRS013') THEN 'CD REPOSICAO SP'                       
    WHEN (FILIAL_ORIGEM = 'CDSARM') THEN 'CDSP ARMAZENAGEM' END AS FILIAL_DIGITACAO,                                                                              
  '04' AS NUMERO_ENTREGA,                                                                                         
  '102 - ENTRADA 3' AS PERIODO_PCP,                                                                              
  @FILIAL_DESTINO_CHAVE AS NOME_CLIFOR_ENTREGA,                                   
  0 AS TIPO_RATEIO,                                                                              
  C.TRANSPORTADORA AS TRANSP_REDESPACHO,                                                                              
  '' AS OBS_TRANSPORTE,                                                                             
  '120.01' AS NATUREZA_SAIDA,                                                                              
  '' AS BANCO,                                                                              
  '' AS AGENCIA,                                                                              
  SUM(VE1+VE2+VE3+VE4+VE5+VE6+VE7+VE8+VE9+VE10) AS VALOR_SUB_ITENS,                                                                              
  NULL AS PEDIDO_CONFERENCIA,                                                                              
  'D' AS INDICADOR_VENDA,                                                                              
  --'' AS COD_LICENCIADO,                                                                              
  --'' AS TAB_PRECO_SERVICO,                                                                        
  '' AS CODIGO_CLIENTE_VAREJO,                                                                              
  '' AS IDENDERECOENTREGA                                                      
  FROM #REPOSICAO_AUTOMATICA SH                                                                              
  LEFT JOIN LINX..PRODUTOS_PRECOS P WITH(NOLOCK) ON SH.PRODUTO = P.PRODUTO COLLATE SQL_Latin1_General_CP1_CI_AS                                                                              
  LEFT JOIN LINX..LOJAS_VAREJO L WITH(NOLOCK) ON  SH.CODIGO_FILIAL = L.CODIGO_FILIAL COLLATE SQL_Latin1_General_CP1_CI_AS                                          
  LEFT JOIN LINX.DBO.CLIENTES_ATACADO C WITH(NOLOCK) ON SH.CODIGO_FILIAL = C.CLIENTE_ATACADO COLLATE SQL_Latin1_General_CP1_CI_AS                
  WHERE P.CODIGO_TAB_PRECO IN     
  (SELECT CODIGO_TAB_PRECO FROM LINX..CLIENTES_ATACADO WITH(NOLOCK) WHERE LTRIM(RTRIM(CLIENTE_ATACADO)) IN (SELECT FILIAL FROM LINX..LOJAS_VAREJO WITH(NOLOCK) WHERE FILIAL = @FILIAL_DESTINO_CHAVE))                                 
      
       
  AND FILIAL_ORIGEM = @FILIAL_ORIGEM_CHAVE                                                                               
  AND SH.CODIGO_FILIAL = @FILIAL_DESTINO_CHAVE                                                                     
  AND SH.EXPORTACAO = @DATA       
  AND SH.MARCA = @MARCA     -- AMD/AN 20170815    
  GROUP BY            
  TRANSPORTADORA,             
  FRETE_A_PAGAR,                                                                             
  USUARIO,                                                                            
  EXPORTACAO,                                               
  FILIAL_ORIGEM,                                                                              
  SH.CODIGO_FILIAL,                                                    
  L.FILIAL ,                                  
  P.CODIGO_TAB_PRECO                                                                             
         
--------------------INSERI INFORMAÇÕES NA TABELA VENDAS_PRODUTO----------------------------------------------------                                                                              
--EXEC SHBI_REPOSICAOAUTOMATICA_NEW                                                                              
                                                                                
  INSERT INTO LINX..VENDAS_PRODUTO                                                                              
  (PEDIDO,                                        
  PRODUTO,                                           
  COR_PRODUTO,                                                                              
  ENTREGA,                                                                              
  LIMITE_ENTREGA,                                                                              
  /*CODIGO_LOCAL_ENTREGA,*/                                                                              
  /*STATUS_VENDA_ATUAL,*/                                                                     
  QTDE_ORIGINAL,                                                      
  QTDE_ENTREGAR,                                                                              
  PRECO1,                                                                        
  VALOR_ORIGINAL,                                                                              
  VALOR_ENTREGAR,                                                                              
  VO1,VO2,VO3,VO4,VO5,VO6,VO7,VO8,VO9,VO10,VE1,VE2,VE3,VE4,VE5,VE6,VE7,VE8,VE9,VE10)                                                                              
  /*[TIMESTAMP],ORDEM_PRODUCAO,PEDIDO_COMPRA,TIPO_CAIXA,DESC_VENDA_CLIENTE,COMISSAO_ITEM,COMISSAO_ITEM_GERENTE,                                                                              
  ID_MODIFICACAO,ID_VENDA_ENTREGA_FUTURA)*/                                                          
         
  SELECT                                                                              
  @PEDIDO AS PEDIDO,                                                             
  SH.PRODUTO AS PRODUTO,                                                                              
  COR AS COR_PRODUTO,                                                      
  @ENTREGA AS ENTREGA,                                                                              
  @ENTREGA AS LIMITE_ENTREGA,                                                                              
  --'' AS CODIGO_LOCAL_ENTREGA,                                                                              
  --1 AS STATUS_VENDA_ATUAL,                                                                              
  sum(VE1+VE2+VE3+VE4+VE5+VE6+VE7+VE8+VE9+VE10) AS QTDE_ORIGINAL,                                                                              
  --0 AS QTDE_EMBALADA,                                                
  sum(VE1+VE2+VE3+VE4+VE5+VE6+VE7+VE8+VE9+VE10) AS QTDE_ENTREGAR,                                                                              
  P.PRECO1 AS PRECO1,                                                     
  P.PRECO1*sum(VE1+VE2+VE3+VE4+VE5+VE6+VE7+VE8+VE9+VE10) AS VALOR_ORIGINAL,                                                                              
  P.PRECO1*sum(VE1+VE2+VE3+VE4+VE5+VE6+VE7+VE8+VE9+VE10) AS VALOR_ENTREGAR,                                                                              
  sum(VE1) AS VO1,                               
  sum(VE2) AS VO2,                                                                              
  sum(VE3) AS VO3,                                                                              
  sum(VE4) AS VO4,                                               
  sum(VE5) AS VO5,                                                                              
  sum(VE6) AS VO6,                                                                              
  sum(VE7) AS VO7,                                                                              
  sum(VE8) AS VO8,                     
  sum(VE9) AS VO9,                     
  sum(VE10) AS VO10,                                                                              
  sum(VE1) AS VE1,                                                                              
  sum(VE2) AS VE2,                                                                              
  sum(VE3) AS VE3,                                                              
  sum(VE4) AS VE4,                                                                              
  sum(VE5) AS VE5,                                                
  sum(VE6) AS VE6,                                                                              
  sum(VE7) AS VE7,                                                                     
  sum(VE8) AS VE8,                                                                              
  sum(VE9) AS VE9,                                                                              
  sum(VE10) AS VE10                                                                              
  --'' AS [TIMESTAMP],                                                                              
  --'' AS ORDEM_PRODUCAO,                                           
  --'' AS PEDIDO_COMPRA,                                                                          
  --'' AS TIPO_CAIXA,                                                                             
  --'' AS DESC_VENDA_CLIENTE,                                                                              
  --0 AS COMISSAO_ITEM,                                                                              
  --0 AS COMISSAO_ITEM_GERENTE,                                                                              
  --'' AS ID_MODIFICAO,                                                                              
  --'' AS ID_VENDA_ENTREGA_FUTURA                                                                 
  FROM #REPOSICAO_AUTOMATICA  SH                                                                              
  LEFT JOIN LINX..PRODUTOS_PRECOS P WITH(NOLOCK) ON SH.PRODUTO = P.PRODUTO COLLATE SQL_Latin1_General_CP1_CI_AS                                       
  WHERE P.CODIGO_TAB_PRECO IN (SELECT CODIGO_TAB_PRECO FROM LINX..CLIENTES_ATACADO WITH(NOLOCK) WHERE LTRIM(RTRIM(CLIENTE_ATACADO)) IN (SELECT FILIAL FROM LINX..LOJAS_VAREJO WITH(NOLOCK) WHERE FILIAL = @FILIAL_DESTINO_CHAVE))                             
  
    
  AND SH.FILIAL_ORIGEM = @FILIAL_ORIGEM_CHAVE                                                                               
  AND SH.CODIGO_FILIAL = @FILIAL_DESTINO_CHAVE                                                                               
  AND SH.EXPORTACAO = @DATA                                                                            
  AND SH.MARCA = @MARCA     -- AMD/AN 20170815      
  GROUP BY SH.PRODUTO,COR,P.PRECO1    
    
  /*Adequação 16/11/2017 - Rodrigo Righetto - Código para geração de LOG para rastreabilidade*/    
  INSERT INTO SH_LOG_REP_AUTOMATICA    
  SELECT DISTINCT ID,@PEDIDO,FILIAL_ORIGEM,CODIGO_FILIAL,EXPORTACAO,USUARIO,MARCA,PRODUTO,COR,VE1,VE2,VE3,VE4,VE5,VE6,VE7,VE8,VE9,VE10,GETDATE(),SYSTEM_USER    
  FROM #REPOSICAO_AUTOMATICA    
  WHERE FILIAL_ORIGEM=@FILIAL_ORIGEM_CHAVE AND    
  CODIGO_FILIAL=@FILIAL_DESTINO_CHAVE AND    
  EXPORTACAO=@DATA AND    
  MARCA=@MARCA    
                                                          
 SET @COUNT_2 = @COUNT_2 + 1                                                                              
 FETCH NEXT FROM VCURSOR_TESTE1 INTO @FILIAL_ORIGEM_CHAVE, @FILIAL_DESTINO_CHAVE,@MARCA, @DATA             
END                                        
CLOSE VCURSOR_TESTE1                                        
                                        
                                                                                 
DEALLOCATE VCURSOR_TESTE1                                                        
                                                                  
UPDATE WAREHOUSE..SHBI_REP_AUTOMATICA_NEW                                              
SET [STATUS] = '1'                                                                            
WHERE [STATUS] = 0   
  
  
/*Rodrigo Righetto  
  Adequação: Realiza os recalculos dos pedidos com inconsistência entre o cabeçalho e os itens*/  
  DECLARE CUR_AJUSTAPEDIDO CURSOR FOR  
  
 SELECT DISTINCT A.PEDIDO  
    /* A.PEDIDO,  
     TOT_QTDE_ORIGINAL,  
     TOT_QTDE_ENTREGAR,  
     TOT_QTDE_EMBALADA,  
     TOT_QTDE_CANCELADA,  
     TOT_QTDE_ENTREGUE,  
     'ITENS'AS INFO,  
     QTDE_ORIGINAL,  
     QTDE_ENTREGAR,  
     QTDE_EMBALADA,  
     QTDE_CANCELADA,  
     QTDE_ENTREGUE,  
     OBS */  
 FROM  LINX.DBO.VENDAS   A WITH(NOLOCK)  
 JOIN (          
  
   SELECT PEDIDO,  
    SUM(QTDE_ORIGINAL)AS  QTDE_ORIGINAL,  
    SUM(QTDE_ENTREGAR)AS  QTDE_ENTREGAR,  
    SUM(QTDE_EMBALADA)AS  QTDE_EMBALADA,  
    SUM(QTDE_CANCELADA)AS QTDE_CANCELADA,  
    SUM(QTDE_ENTREGUE)AS QTDE_ENTREGUE  
   FROM LINX.DBO.VENDAS_PRODUTO  WITH(NOLOCK)                                                                                                                                                              
   GROUP BY PEDIDO  
    ) B ON A.PEDIDO=B.PEDIDO  
 WHERE (  
    QTDE_ORIGINAL  != TOT_QTDE_ORIGINAL OR  
    QTDE_ENTREGAR  != TOT_QTDE_ENTREGAR OR  
    QTDE_EMBALADA  != TOT_QTDE_EMBALADA OR  
    QTDE_CANCELADA != TOT_QTDE_CANCELADA  
    ) AND YEAR(EMISSAO)>='2018'  
  
OPEN CUR_AJUSTAPEDIDO  
 DECLARE @SHPEDIDO VARCHAR(10)  
FETCH NEXT FROM CUR_AJUSTAPEDIDO INTO @SHPEDIDO  
WHILE @@FETCH_STATUS = 0  
BEGIN  
 EXEC LINX.DBO.LX_MOVIMENTA_VENDAS_PA  @SHPEDIDO     
FETCH NEXT FROM CUR_AJUSTAPEDIDO INTO @SHPEDIDO  
END  
CLOSE CUR_AJUSTAPEDIDO  
DEALLOCATE CUR_AJUSTAPEDIDO  
  
  
  
                                                                         
COMMIT 