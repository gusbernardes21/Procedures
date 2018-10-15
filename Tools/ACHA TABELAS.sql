DECLARE @Coluna VARCHAR(100)
      , @Valor  VARCHAR(100) 

SET @Coluna ='pis'
SET @Valor  = '000190664'

  SELECT DISTINCT 'SELECT TOP 100 '
       +''''
       +B.name
       +''''
       +' AS TABELA,' 
       +a.name
       +',* FROM ' 
       +C.name
       + '.'
       +b.name
       +' WITH(NOLOCK) WHERE '
       +a.name
       +' = ' 
       + CASE WHEN A.system_type_id IN ( 48, 52, 56, 59, 60, 62, 106 , 108, 122 , 127)
              THEN @Valor
              ELSE +''''+@Valor+''''
         END 
    FROM sys.all_columns A 
         INNER JOIN SYS.tables B ON A.object_id = B.object_id
         INNER JOIN SYS.schemas C ON C.schema_id = B.schema_id
    WHERE  A.name LIKE '%'+@Coluna+'%'
 