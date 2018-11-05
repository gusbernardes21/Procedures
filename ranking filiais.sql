DECLARE @Filial       VARCHAR(20) = 'OIT033'
      , @DataInicial  DATETIME    = '20180926'
      , @DataFinal    DATETIME    = '20181025'


exec sp_executesql N'SELECT CONVERT(DATETIME, NULL) AS DATA
                           , CONVERT(CHAR(2), '''') AS PERIODO_FECHAMENTO
                           , CONVERT(CHAR(3), '''') AS TERMINAL
                           , CONVERT(CHAR(4), '''') AS CAIXA_VENDEDOR
                           , CONVERT(CHAR(25), '''') AS VENDEDOR_APELIDO
                           , C.VENDEDOR
                           , C.NOME_VENDEDOR
                           , B.TICKET, TOTAL_VENDA = CONVERT(NUMERIC(14, 2)
                           , SUM(C.VALOR_VENDA + ISNULL(E.VALOR_VITRINE, 0)))
                           , QTDE_TROCA   = SUM(C.PECAS_TROCA)
                           , QTDE_PRODUTO = SUM(C.PECAS_PRODUTO)
                           , QTDE_ITENS   = SUM(C.QTDE_ITENS_PRODUTO)
                           , QTDE_TICKET  = COUNT(DISTINCT C.TICKET)
                           , SUM(FATOR_LINHA) AS FATOR_LINHA 
                        FROM LOJA_VENDA_PGTO A 
                             INNER JOIN LOJA_VENDA B ON A.CODIGO_FILIAL    = B.CODIGO_FILIAL_PGTO 
                                                    AND A.TERMINAL         = B.TERMINAL_PGTO 
                                                    AND A.LANCAMENTO_CAIXA = B.LANCAMENTO_CAIXA 
                             INNER JOIN /*SalesCommissions*/FN_SALES_COMMISSIONS(@P1, @P2, @P3) C ON B.CODIGO_FILIAL = C.CODIGO_FILIAL 
                                                                                                 AND B.TICKET        = C.TICKET 
                                                                                                 AND B.DATA_VENDA    = C.DATA_VENDA 
                             INNER JOIN LOJA_VENDEDORES D ON A.CAIXA_VENDEDOR = D.VENDEDOR 
                             OUTER APPLY (SELECT SUM(ABS(VALOR)) AS VALOR_VITRINE 
                                            FROM LOJA_VENDA_PARCELAS AA 
                                           WHERE AA.CODIGO_FILIAL = A.CODIGO_FILIAL 
                                             AND AA.TERMINAL = A.TERMINAL 
                                             AND AA.LANCAMENTO_CAIXA = A.LANCAMENTO_CAIXA 
                                             AND AA.VALOR < 0 AND AA.TIPO_PGTO = ''\'') E 
                       WHERE A.CODIGO_FILIAL = @P4 
                         AND A.DATA >= @P5 
                         AND A.DATA <= @P6 
                         --AND B.TICKET = ''30130714''
                    GROUP BY C.VENDEDOR
                           , C.NOME_VENDEDOR
                           , B.TICKET 
                    ORDER BY C.VENDEDOR'
                    ,N'@P1 varchar(6),@P2 datetime,@P3 datetime,@P4 varchar(6),@P5 datetime,@P6 datetime'
                    ,@Filial
                    ,@DataInicial
                    ,@DataFinal
                    ,@Filial
                    ,@DataInicial
                    ,@DataFinal
