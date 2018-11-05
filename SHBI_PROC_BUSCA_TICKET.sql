ALTER PROCEDURE SHBI_PROC_BUSCA_TICKET ( @TICKET VARCHAR(100) = NULL , @CODIGO_FILIAL VARCHAR(100) = NULL , @DATA_VENDA DATETIME = NULL)                  
AS                  
BEGIN                  
                  
  SELECT 'LOJA_VENDA' AS TABELA                   
       , LV.CODIGO_FILIAL                  
       , LOJV.FILIAL                  
       , LV.TICKET                  
       , LV.DATA_VENDA                   
       , LV.CODIGO_CLIENTE                   
       , CV.CLIENTE_VAREJO                  
       , LV.VENDEDOR                  
       , LVV.NOME_VENDEDOR                    
       , LV.TICKET_IMPRESSO                  
       , LV.TERMINAL                    
       , LV.LANCAMENTO_CAIXA                   
       , LV.DATA_HORA_CANCELAMENTO                   
       , LV.DATA_PARA_TRANSFERENCIA                     
       , LV.DATA_DIGITACAO                   
       , LV.QTDE_TOTAL                  
       , LV.VALOR_TIKET                  
       , LV.VALOR_PAGO                  
       , LV.VALOR_VENDA_BRUTA                  
       , LV.VALOR_TROCA                  
       , LV.QTDE_TROCA_TOTAL                  
       , LV.VALOR_CANCELADO                  
       , LV.TOTAL_QTDE_CANCELADA                  
       , LV.QTDE_PONTOS_ACUMULADOS                  
       , LV.QTDE_PONTOS_RESGATADOS                    
    FROM LINX..LOJA_VENDA LV WITH (NOLOCK)                   
         INNER JOIN LINX..LOJAS_VAREJO LOJV WITH(NOLOCK)  ON LOJV.CODIGO_FILIAL = LV.CODIGO_FILIAL                   
         LEFT  JOIN LINX..CLIENTES_VAREJO CV WITH(NOLOCK) ON CV.CODIGO_CLIENTE  = LV.CODIGO_CLIENTE                  
         LEFT  JOIN LINX..LOJA_VENDEDORES LVV WITH(NOLOCK) ON LVV.VENDEDOR      = LV.VENDEDOR                  
WHERE  ( ISNULL(@TICKET,'1') = '1'                  
        OR LV.TICKET = @TICKET )                   
  AND ( ISNULL(@DATA_VENDA,'19000101') = '19000101'                  
          OR LV.DATA_VENDA = @DATA_VENDA )                   
  AND ( ISNULL(@CODIGO_FILIAL,'1') = '1'                  
          OR LV.CODIGO_FILIAL = @CODIGO_FILIAL )                    
                  
                  
                  
  SELECT 'LOJA_VENDA_PRODUTO' AS TABELA                   
       , LV.CODIGO_FILIAL                  
       , LOJV.FILIAL                  
       , LV.TICKET                  
       , LV.DATA_VENDA                  
       , LVP.ITEM                  
       , LVP.CODIGO_BARRA                  
       , LVP.PRODUTO                  
       , P.DESC_PRODUTO   
       , P.GRIFFE               
       , LVP.COR_PRODUTO                  
       , LVP.TAMANHO                  
       , LVP.QTDE                  
       , LVP.PRECO_LIQUIDO                  
       , LVP.DESCONTO_ITEM                   
       , LVP.QTDE_CANCELADA                   
       , LVP.DATA_PARA_TRANSFERENCIA                   
       , LVP.FATOR_DESCONTO_VENDA                    
       , LVP.ID_VENDEDOR                  
       , LVP.ITEM_EXCLUIDO                   
       , LVP.RATEIO_DESCONTO_VENDA                 
       , LVP.VALOR_TOTAL                     
    FROM LINX..LOJA_VENDA LV WITH (NOLOCK)                   
         INNER JOIN LINX..LOJAS_VAREJO LOJV WITH(NOLOCK)       ON  LOJV.CODIGO_FILIAL  = LV.CODIGO_FILIAL                   
         LEFT  JOIN LINX..LOJA_VENDA_PRODUTO LVP WITH(NOLOCK)  ON  LVP.TICKET         = LV.TICKET                         
                                                               AND LVP.CODIGO_FILIAL  = LV.CODIGO_FILIAL                  
                                                               AND LVP.DATA_VENDA     = LV.DATA_VENDA                     
         LEFT  JOIN  LINX..PRODUTOS P                          ON  P.PRODUTO          = LVP.PRODUTO                   
WHERE  ( ISNULL(@TICKET,'1') = '1'                   
        OR LV.TICKET = @TICKET )                   
  AND ( ISNULL(@DATA_VENDA,'19000101') = '19000101'                  
          OR LV.DATA_VENDA = @DATA_VENDA )                   
  AND ( ISNULL(@CODIGO_FILIAL,'1') = '1'                  
          OR LV.CODIGO_FILIAL = @CODIGO_FILIAL )                    
                  
                  
  SELECT 'LOJA_VENDA_TROCA' AS TABELA                   
       , LV.CODIGO_FILIAL                  
       , LOJV.FILIAL                  
       , LV.TICKET                  
       , LV.DATA_VENDA                  
       , LVP.ITEM                  
       , LVP.CODIGO_BARRA                  
       , LVP.PRODUTO                  
       , P.DESC_PRODUTO   
       , P.GRIFFE           
       , LVP.COR_PRODUTO                  
       , LVP.TAMANHO                  
       , LVP.QTDE                  
       , LVP.PRECO_LIQUIDO                  
       , LVP.DESCONTO_ITEM                   
       , LVP.QTDE_CANCELADA                   
       , LVP.DATA_PARA_TRANSFERENCIA                   
       , LVP.FATOR_DESCONTO_VENDA                    
       , LVP.ID_VENDEDOR                  
       , LVP.ITEM_EXCLUIDO                    
    FROM LINX..LOJA_VENDA LV WITH (NOLOCK)                   
         INNER JOIN LINX..LOJAS_VAREJO LOJV WITH(NOLOCK)    ON  LOJV.CODIGO_FILIAL  = LV.CODIGO_FILIAL                   
         LEFT  JOIN LINX..LOJA_VENDA_TROCA LVP WITH(NOLOCK) ON  LVP.TICKET         = LV.TICKET                         
                                                            AND LVP.CODIGO_FILIAL  = LV.CODIGO_FILIAL                  
                                AND LVP.DATA_VENDA     = LV.DATA_VENDA                     
         LEFT  JOIN  LINX..PRODUTOS P   WITH(NOLOCK)                    ON  P.PRODUTO          = LVP.PRODUTO                   
WHERE  ( ISNULL(@TICKET,'1') = '1'                   
        OR LV.TICKET = @TICKET )                   
  AND ( ISNULL(@DATA_VENDA,'19000101') = '19000101'                  
          OR LV.DATA_VENDA = @DATA_VENDA )                   
  AND ( ISNULL(@CODIGO_FILIAL,'1') = '1'                  
          OR LV.CODIGO_FILIAL = @CODIGO_FILIAL )                    
                  
  SELECT 'LOJA_VENDA_VENDEDORES' AS TABELA                   
       , LV.CODIGO_FILIAL                  
       , LOJV.FILIAL                  
       , LV.TICKET                  
       , LV.ID_VENDEDOR                  
       , LV.DATA_VENDA                    
       , LV.VENDEDOR          
       , LV.DATA_PARA_TRANSFERENCIA            
       , LVV.NOME_VENDEDOR         
       , LVV.DESC_CARGO             
       , LVV.DATA_ATIVACAO      
       , LVV.DATA_DESATIVACAO             
    FROM LINX..LOJA_VENDA_VENDEDORES LV WITH (NOLOCK)                   
                           
         INNER JOIN LINX..LOJAS_VAREJO LOJV WITH(NOLOCK)  ON LOJV.CODIGO_FILIAL = LV.CODIGO_FILIAL                    
         LEFT  JOIN LINX..LOJA_VENDEDORES LVV WITH(NOLOCK) ON LVV.VENDEDOR      = LV.VENDEDOR                  
WHERE  ( ISNULL(@TICKET,'1') = '1'                  
        OR LV.TICKET = @TICKET )                   
  AND ( ISNULL(@DATA_VENDA,'19000101') = '19000101'                  
          OR LV.DATA_VENDA = @DATA_VENDA )                   
  AND ( ISNULL(@CODIGO_FILIAL,'1') = '1'                  
          OR LV.CODIGO_FILIAL = @CODIGO_FILIAL )                    
                  
  SELECT 'LOJA_VENDA_PARCELAS' AS TABELA                   
       , LV.CODIGO_FILIAL                  
       , LOJV.FILIAL                    
       , LV.LANCAMENTO_CAIXA                  
       , LV.TERMINAL                    
       , LVP.PARCELA                  
       , LVP.CODIGO_ADMINISTRADORA                  
       , LVP.TIPO_PGTO                  
       , P.DESC_TIPO_PGTO                  
       , LVP.VALOR                  
       , LVP.VENCIMENTO                  
       , LVP.NUMERO_TITULO                   
       , LVP.NUMERO_APROVACAO_CARTAO                  
       , LVP.PARCELAS_CARTAO                  
       , LVP.VALOR_CANCELADO                  
       , LVP.CHEQUE_CARTAO                  
       , LVP.DATA_PARA_TRANSFERENCIA                  
    FROM LINX..LOJA_VENDA LV WITH (NOLOCK)                   
         INNER JOIN LINX..LOJAS_VAREJO LOJV WITH(NOLOCK)    ON  LOJV.CODIGO_FILIAL  = LV.CODIGO_FILIAL                   
         LEFT  JOIN LINX..LOJA_VENDA_PARCELAS LVP WITH(NOLOCK) ON  LVP.LANCAMENTO_CAIXA         = LV.LANCAMENTO_CAIXA                         
   AND LVP.CODIGO_FILIAL  = LV.CODIGO_FILIAL                  
                                                            AND LVP.TERMINAL     = LV.TERMINAL                     
         LEFT  JOIN  LINX..TIPOS_PGTO P   WITH(NOLOCK)                         ON  P.TIPO_PGTO          = LVP.TIPO_PGTO                   
WHERE  ( ISNULL(@TICKET,'1') = '1'                  
        OR LV.TICKET = @TICKET )                   
  AND ( ISNULL(@DATA_VENDA,'19000101') = '19000101'                  
          OR LV.DATA_VENDA = @DATA_VENDA )                   
  AND ( ISNULL(@CODIGO_FILIAL,'1') = '1'                  
          OR LV.CODIGO_FILIAL = @CODIGO_FILIAL )                    
                  
                  
                  
                  
  SELECT 'LOJA_VENDA_PGTO' AS TABELA                   
      , LV.CODIGO_FILIAL                  
       , LOJV.FILIAL                  
       , LV.TERMINAL                   
       , LV.LANCAMENTO_CAIXA                   
       , LVP.TERMINAL                  
       , LVP.LANCAMENTO_CAIXA                  
       , LVP.COD_FORMA_PGTO                  
       , P.DESC_COND_PGTO                  
       , LVP.CAIXA_VENDEDOR                  
       , LVP.DIGITACAO                  
       , LVP.DATA                  
       , LVP.NUMERO_CUPOM_FISCAL                  
       , LVP.DESCONTO_PGTO                  
       , LVP.TOTAL_VENDA                  
       , LVP.VALOR_CANCELADO                   
       , LVP.DATA_PARA_TRANSFERENCIA                    
       , LVP.VENDA_FINALIZADA                   
       , LVP.LX_STATUS_VENDA                   
    FROM LINX..LOJA_VENDA LV WITH (NOLOCK)                   
         INNER JOIN LINX..LOJAS_VAREJO LOJV WITH(NOLOCK)    ON  LOJV.CODIGO_FILIAL  = LV.CODIGO_FILIAL                   
         LEFT  JOIN LINX..LOJA_VENDA_PGTO LVP WITH(NOLOCK) ON  LVP.LANCAMENTO_CAIXA   = LV.LANCAMENTO_CAIXA                         
                                                            AND LVP.CODIGO_FILIAL  = LV.CODIGO_FILIAL                  
                      AND LVP.TERMINAL     = LV.TERMINAL                     
         LEFT  JOIN  LINX..FORMA_PGTO P         WITH(NOLOCK)                   ON  P.CONDICAO_PGTO          = LVP.COD_FORMA_PGTO                   
WHERE  ( ISNULL(@TICKET,'1') = '1'                   
        OR LV.TICKET = @TICKET )                   
  AND ( ISNULL(@DATA_VENDA,'19000101') = '19000101'                  
          OR LV.DATA_VENDA = @DATA_VENDA )                   
  AND ( ISNULL(@CODIGO_FILIAL,'1') = '1'                  
          OR LV.CODIGO_FILIAL = @CODIGO_FILIAL )                    
              
  SELECT 'LOJA_PEDIDO' AS TABELA                   
       , LV.CODIGO_FILIAL                  
       , LOJV.FILIAL                  
       , LV.TERMINAL                   
       , LV.LANCAMENTO_CAIXA                   
       , D.PEDIDO              
       , D.VALOR_TOTAL              
       , D.STATUS_B2C              
       , D.CANCELADO           
       , D.MOTIVO_CANCELAMENTO            
       , D.*          
    FROM LINX..LOJA_VENDA LV WITH (NOLOCK)                   
         INNER JOIN LINX..LOJAS_VAREJO LOJV WITH(NOLOCK)    ON  LOJV.CODIGO_FILIAL  = LV.CODIGO_FILIAL                   
         INNER JOIN LINX..LOJA_VENDA_PARCELAS B WITH(NOLOCK) ON LV.CODIGO_FILIAL        = B.CODIGO_FILIAL               
                                                            AND LV.TERMINAL             = B.TERMINAL               
                                                            AND LV.LANCAMENTO_CAIXA     = B.LANCAMENTO_CAIXA              
         INNER JOIN LINX..LOJA_PEDIDO D WITH(NOLOCK)         ON LV.TICKET               = D.TICKET_VENDA               
      AND LV.CODIGO_FILIAL        = D.CODIGO_FILIAL_VENDA               
WHERE  ( ISNULL(@TICKET,'1') = '1'                   
        OR LV.TICKET = @TICKET )                   
  AND ( ISNULL(@DATA_VENDA,'19000101') = '19000101'                  
          OR LV.DATA_VENDA = @DATA_VENDA )                   
  AND ( ISNULL(@CODIGO_FILIAL,'1') = '1'                  
          OR LV.CODIGO_FILIAL = @CODIGO_FILIAL )               
   AND  B.TIPO_PGTO = '\'               
      AND B.VALOR < 0               
            
            
  SELECT 'LOJA_PEDIDO_PRODUTO' AS TABELA                   
       , LV.CODIGO_FILIAL                  
       , LOJV.FILIAL                  
       , LV.TERMINAL                   
       , LV.LANCAMENTO_CAIXA                   
       , D.*            
                     
    FROM LINX..LOJA_VENDA LV WITH (NOLOCK)                   
         INNER JOIN LINX..LOJAS_VAREJO LOJV WITH(NOLOCK)    ON  LOJV.CODIGO_FILIAL  = LV.CODIGO_FILIAL                   
         INNER JOIN LINX..LOJA_VENDA_PARCELAS B WITH(NOLOCK) ON LV.CODIGO_FILIAL        = B.CODIGO_FILIAL               
                                                            AND LV.TERMINAL             = B.TERMINAL               
                                                            AND LV.LANCAMENTO_CAIXA     = B.LANCAMENTO_CAIXA              
         INNER JOIN LINX..LOJA_PEDIDO C WITH(NOLOCK)         ON LV.TICKET               = c.TICKET_VENDA               
                                    AND LV.CODIGO_FILIAL        = c.CODIGO_FILIAL_VENDA               
         INNER JOIN LINX..LOJA_PEDIDO_PRODUTO D WITH(NOLOCK)         ON D.PEDIDO               = C.PEDIDO            
                                                            AND c.CODIGO_FILIAL_ORIGEM        = D.CODIGO_FILIAL_ORIGEM               
WHERE  ( ISNULL(@TICKET,'1') = '1'                   
        OR LV.TICKET = @TICKET )                   
  AND ( ISNULL(@DATA_VENDA,'19000101') = '19000101'                  
          OR LV.DATA_VENDA = @DATA_VENDA )                   
  AND ( ISNULL(@CODIGO_FILIAL,'1') = '1'                  
          OR LV.CODIGO_FILIAL = @CODIGO_FILIAL )               
   AND  B.TIPO_PGTO = '\'               
      AND B.VALOR < 0               
                
  SELECT 'UNICO_CAMPANHA_ATIVADA' AS TABELA                   
       , LV.CODIGO_FILIAL                 
       , LOJV.FILIAL                
       , LV.TICKET              
       , LV.DATA_VENDA              
       , UCA.ID_CAMPANHA              
       , UC.NOME_CAMPANHA              
       , UCA.PONTOS_ADICIONAIS              
       , UCA.VALOR_DESCONTO               
       , UCA.NSU              
       , UC.DATA_INICIO              
       , UC.DATA_FIM              
       , UC.DATA_CRIACAO               
    FROM LINX..LOJA_VENDA LV WITH (NOLOCK)                   
         INNER JOIN LINX..LOJAS_VAREJO LOJV WITH(NOLOCK)    ON  LOJV.CODIGO_FILIAL  = LV.CODIGO_FILIAL                   
         INNER JOIN LINX..UNICO_CAMPANHA_ATIVADA UCA WITH(NOLOCK) ON  UCA.TICKET   = LV.TICKET                         
                                                            AND CONVERT(DATE,UCA.DATA_VENDA)  = LV.DATA_VENDA                  
                                                            AND UCA.CODIGO_FILIAL     = LV.CODIGO_FILIAL                 
         INNER JOIN LINX..UNICO_CAMPANHA UC WITH(NOLOCK) ON  UC.ID_CAMPANHA = UCA.ID_CAMPANHA               
              
WHERE  ( ISNULL(@TICKET,'1') = '1'                   
        OR LV.TICKET = @TICKET )                   
  AND ( ISNULL(@DATA_VENDA,'19000101') = '19000101'                  
          OR LV.DATA_VENDA = @DATA_VENDA )                   
  AND ( ISNULL(@CODIGO_FILIAL,'1') = '1'                  
          OR LV.CODIGO_FILIAL = @CODIGO_FILIAL )                 
                  
                    
END 