  SELECT  CONVERT(VARCHAR(4), VENDEDOR)  AS _ID_LJVD_CODIGO
       , LJ.CODIGO_FILIAL AS LJVD_FILIALCAD
       , FILIAL AS LJVD_FILIALCADNOME
       , VENDEDOR_APELIDO AS LJVD_APELIDO
       , NOME_VENDEDOR AS LJVD_NOME
       , COMISSAO AS LJVD_COMISSAO
       , DATA_DESATIVACAO AS LJVD_DTDESATIVACAO
       , DATA_ATIVACAO AS LJVD_DTATIVACAO
       , DESC_CARGO AS LJVD_CARGO
       , FUNC_SITUACAO
       --, DTINICIO
       --, DTFINAL 
       --, MOTIVO
    FROM LOJA_VENDEDORES LJ WITH(NOLOCK)
         INNER JOIN LINX.DBO.LOJAS_VAREJO V  WITH(NOLOCK) ON LJ.CODIGO_FILIAL = V.CODIGO_FILIAL
         INNER  JOIN(  SELECT	A.CODCOLIGADA                                        AS _ID_COLIGADA_CODIGO
	                           , CONVERT(VARCHAR(16), A.CHAPA)                        AS _ID_FUNC_CHAPA
	                           , CONVERT(VARCHAR(16), K.CPF)                          AS _ID_CLIVAR_CODIGO
	                           , CONVERT(VARCHAR(8), H.CODLINX)                       AS FUNC_CODLINX
	                           , A.CODSINDICATO                                       AS FUNC_CODSINDICATO
	                           , UPPER(A.NOME)                                        AS FUNC_NOME
	                           , UPPER(B.DESCRICAO)                                   AS FUNC_TIPORECEB
	                           , A.CODSITUACAO                                        AS FUNC_CODSITUACAO
	                           , ''                                                   AS FUNC_CODSITUACAO_RA
	                           , UPPER(D.DESCRICAO)                                   AS FUNC_SITUACAO
	                           , UPPER(C.DESCRICAO)                                   AS FUNC_TIPOFUNC
	                           , E.ESTADO                                             AS FUNC_ESTADOFILIALSECAO
	                           , E.CODFILIAL                                          AS FUNC_CODFILIALSECAO
	                           , I.NOMEFANTASIA                                       AS FUNC_NOMEFILIALSECAO
	                           , A.CODSECAO                                           AS FUNC_CODSECAO
	                           , LTRIM(RTRIM(REPLACE(E.NROCENCUSTOCONT, '.', ''))) 	  AS FUNC_COD_CENTROCUSTO
	                           , CC.DESC_CENTRO_CUSTO								                         AS FUNC_DESC_CENTROCUSTO
	                           , UPPER(E.DESCRICAO)                                   AS FUNC_SECAO
	                           , A.CODFILIAL                                          AS _ID_FILIAL_CODIGO
	                           , H.FLINX                                              AS FUNC_FILLINX
	                           , A.CODFUNCAO                                          AS _ID_FUNCAO_CODIGO
	                           , I.CODCALENDARIO                                      AS _ID_CALEND_CODIGO
	                           , UPPER(F.NOME)                                        AS FUNC_FUNCAO
	                           , A.CODHORARIO                                         AS _ID_HORARIO_CODIGO
	                           , UPPER(G.DESCRICAO)                                   AS FUNC_HORARIO
	                           , A.DATAADMISSAO                                       AS FUNC_DTADMISSAO
	                           , A.DATADEMISSAO                                       AS FUNC_DTDEMISSAO
	                           , A.TEMPRAZOCONTR										                            AS FUNC_TEMPRAZOCONTR
                            ,    A.FIMPRAZOCONTR										                         AS FUNC_FIMPRAZOCONTR
	                           , MOT.DESCRICAO	                                       AS FUNC_MOTIVODEMISSAO
	                           , TP.DESCRICAO 	                                       AS FUNC_TIPODEMISSAO
	                           , UPPER(MOTADM.DESCRICAO)                              AS FUNC_MOTIVOADMISSAO
	                           , UPPER(TPADM.DESCRICAO)                               AS FUNC_TIPOADMISSAO	
	                           , A.TIPODEMISSAO                                       AS _ID_CODIGO_TIPODEM
	                           , UPPER(J.DESCRICAO)                                   AS FUNC_TIPODEM
	                           , A.ANTIGADTADM                                        AS FUNC_DTADMANTIGA 
	                           , A.PERCENTADIANT                                      AS FUNC_PERCADIANTAMENTO
	                           , A.DTVENCFERIAS                                       AS FUNC_PROXFERIAS
	                           , M.INICIOPERAQUIS                                     AS FUNC_INIPERFERIAS
	                           , A.INICPROGFERIAS1	                                   AS FUNC_INIPROGFERIAS_1
	                           , A.FIMPROGFERIAS1	                                    AS FUNC_FIMPROGFERIAS_1
	                           , A.INICPROGFERIAS2	                                   AS FUNC_INIPROGFERIAS_2
	                           , A.FIMPROGFERIAS2	                                    AS FUNC_FIMPROGFERIAS_2
	                           , CASE WHEN ISNULL(A.INICPROGFERIAS1, 0)=0 THEN 0 ELSE DATEDIFF(DD, A.INICPROGFERIAS1, A.FIMPROGFERIAS1)+1 END AS FUNC_DIASPROGFERIAS_1
	                           , CASE WHEN ISNULL(A.INICPROGFERIAS2, 0)=0 THEN 0 ELSE DATEDIFF(DD, A.INICPROGFERIAS2, A.FIMPROGFERIAS2)+1 END AS FUNC_DIASPROGFERIAS_2
                         FROM RMCorpore_RHU..PFUNC A
                              INNER JOIN RMCorpore_RHU..PCODRECEB B    ON A.CODRECEBIMENTO = B.CODCLIENTE
	                             INNER JOIN RMCorpore_RHU..PTPFUNC C  	   ON A.CODTIPO        = C.CODCLIENTE
    	                         INNER JOIN RMCorpore_RHU..PCODSITUACAO D	ON A.CODSITUACAO    = D.CODCLIENTE
                              INNER JOIN RMCorpore_RHU..PSECAO E      	ON A.CODSECAO       = E.CODIGO
	                                                                     AND A.CODCOLIGADA    = E.CODCOLIGADA
                              INNER JOIN RMCorpore_RHU..PFUNCAO F     	ON A.CODFUNCAO      = F.CODIGO
	                                                                     AND A.CODCOLIGADA    = F.CODCOLIGADA
                              INNER JOIN RMCorpore_RHU..AHORARIO G    	ON A.CODHORARIO     = G.CODIGO
                                                                     	AND A.CODCOLIGADA    = G.CODCOLIGADA
                              LEFT JOIN RMCorpore_RHU..PFCOMPL H      	ON A.CODCOLIGADA    = H.CODCOLIGADA
	                                                                     AND A.CHAPA          = H.CHAPA
                              LEFT JOIN RMCorpore_RHU..GFILIAL I      	ON A.CODCOLIGADA    = I.CODCOLIGADA
	                                                                     AND A.CODFILIAL      = I.CODFILIAL
                              LEFT JOIN RMCorpore_RHU..PTPDEMISSAO J  	ON A.TIPODEMISSAO = J.CODCLIENTE
                              LEFT JOIN RMCorpore_RHU..PPESSOA K      	ON A.CODPESSOA = K.CODIGO
                              LEFT JOIN (SELECT CODCOLIGADA
                                              , CHAPA
                                              , FIMPERAQUIS
                                              , INICIOPERAQUIS 
                                           FROM RMCorpore_RHU..PFUFERIAS 
                                          WHERE PERIODOABERTO = '1') M	ON A.CODCOLIGADA = M.CODCOLIGADA
	                                                                     AND A.CHAPA = M.CHAPA
	                                                                     AND A.DTVENCFERIAS = M.FIMPERAQUIS
                              LEFT JOIN LINX.DBO.CTB_CENTRO_CUSTO CC  	                 ON LTRIM(RTRIM(REPLACE(E.NROCENCUSTOCONT, '.', ''))) = CC.CENTRO_CUSTO COLLATE SQL_Latin1_General_CP1_CI_AI
                              LEFT JOIN RMCOrpore_RHU..PMOTDEMISSAO MOT WITH(NOLOCK)	  	ON A.CODCOLIGADA    = MOT.CODCOLIGADA
	                                                                                      AND A.MOTIVODEMISSAO = MOT.CODINTERNO
                              LEFT JOIN RMCorpore_RHU..PTPDEMISSAO TP WITH(NOLOCK)     	ON A.TIPODEMISSAO   = TP.CODINTERNO
                              LEFT JOIN RMCorpore_RHU..PMOTADMISSAO MOTADM WITH(NOLOCK)	ON A.CODCOLIGADA    = MOTADM.CODCOLIGADA
	                                                                                      AND A.MOTIVOADMISSAO = MOTADM.CODINTERNO
                              LEFT JOIN RMCorpore_RHU..PTPADMISSAO TPADM WITH(NOLOCK)  	ON A.TIPOADMISSAO   = TPADM.CODINTERNO	) A ON FUNC_CODLINX = LJ.VENDEDOR COLLATE SQL_Latin1_General_CP1_CI_AI
                              --LEFT JOIN (  SELECT DISTINCT A.CODCOLIGADA
                              --                  , CONVERT(VARCHAR(10), A.CHAPA) AS CHAPA
                              --                  , A.DTINICIO
                              --                  , A.DTFINAL
                              --                  , UPPER(B.DESCRICAO) AS TIPO
                              --                  ,	UPPER(C.DESCRICAO) AS MOTIVO 
                              --               FROM RMCorpore_RHU.DBO.PFHSTAFT A
                              --                    INNER JOIN RMCorpore_RHU.DBO.PCODAFAST B	   ON A.TIPO        = B.CODINTERNO
                              --                    INNER JOIN RMCorpore_RHU.DBO.PMUDSITUACAO C	ON A.CODCOLIGADA = C.CODCOLIGADA
	                             --                                                               AND A.MOTIVO      = C.CODINTERNO 
                              --              WHERE A.DTINICIO >='20140101' OR  A.DTFINAL >='20140101' ) AFA ON AFA.CHAPA = A._ID_FUNC_CHAPA 

                              --LEFT JOIN (SELECT A.CODCOLIGADA
                              --                , CONVERT(VARCHAR(10), A.CHAPA) AS CHAPA
                              --                ,	B.INICIOPERAQUIS
                              --                ,	B.FIMPERAQUIS FIMPERAQUIS_1
                              --                ,	A.FIMPERAQUIS  FIMPERAQUIS_2
                              --                ,	A.DATAINICIO
                              --                ,	A.DATAFIM
                              --                ,	DATEDIFF(DD, A.DATAINICIO, A.DATAFIM)+1 AS DIAS
                              --                ,	B.PERIODOABERTO
                              --             FROM RMCorpore_RHU.DBO.PFUFERIASPER  A
                              --                  INNER JOIN RMCorpore_RHU.DBO.PFUFERIAS B	ON A.CODCOLIGADA = B.CODCOLIGADA
	                             --                                                          AND A.CHAPA = B.CHAPA
	                             --                                                          AND A.FIMPERAQUIS = B.FIMPERAQUIS ) FER ON FER.CHAPA = A._ID_FUNC_CHAPA
                                          WHERE  DESC_CARGO LIKE '%GERENTE%' 
--AND FUNC_SITUACAO <> 'DEMITIDO'


--SELECT 
--	A.CODCOLIGADA,  
--	CONVERT(VARCHAR(10), A.CHAPA) AS CHAPA, 
--	B.INICIOPERAQUIS,
--	B.FIMPERAQUIS,
--	A.FIMPERAQUIS, 
--	A.DATAINICIO, 
--	A.DATAFIM,
--	DATEDIFF(DD, A.DATAINICIO, A.DATAFIM)+1 AS DIAS,
--	B.PERIODOABERTO
--FROM RMCorpore_RHU.DBO.PFUFERIASPER  A
--INNER JOIN RMCorpore_RHU.DBO.PFUFERIAS B
--	ON A.CODCOLIGADA = B.CODCOLIGADA
--	AND A.CHAPA = B.CHAPA
--	AND A.FIMPERAQUIS = B.FIMPERAQUIS
--AND B.INICIOPERAQUIS >='20170918'