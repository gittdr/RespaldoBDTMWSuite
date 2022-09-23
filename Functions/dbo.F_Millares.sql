SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--Función para millares 
---Función que devuelve en letra los millares. El párametro @Estilo permite identificar los distintos valores que puede tener un mismo número. 
---Figura 5. 
--CREATE FUNCTION F_Millares(@Numero as bigint, @Estilo as bit=0) 
CREATE FUNCTION [dbo].[F_Millares](@Numero as bigint, @Estilo as bit=0) 
RETURNS varchar(500) AS 
BEGIN 
DECLARE @Texto varchar(500)
DECLARE @EstiloCentenas bit
SELECT @EstiloCentenas=CONVERT(bit,LEN(@Numero)-4)
SELECT @Texto=
CASE 
WHEN @Numero=0000 THEN ' '
WHEN @Numero=1000 THEN 'MIL'
WHEN (@Numero>1000 and @Numero<2000) THEN 'MIL ' + 
dbo.F_Centenas(RIGHT(CONVERT(varchar, @Numero), 3), 1)

WHEN (@Numero>=2000 and @Numero=2000)  THEN 
dbo.F_Centenas(LEFT(CONVERT(varchar, @Numero), LEN(@Numero)-3), 
@EstiloCentenas) + 
' MIL ' + 
dbo.F_Centenas(RIGHT(CONVERT(varchar, @Numero), 3), 1)

WHEN (@Numero>2000 and @Numero<1000000) THEN 
dbo.F_Centenas(LEFT(CONVERT(varchar, @Numero), LEN(@Numero)-3), 
@EstiloCentenas) + 
' MIL ' + 
dbo.F_Centenas(RIGHT(CONVERT(varchar, @Numero), 3), 1)


WHEN @Numero<10 THEN dbo.F_Unidades(@Numero, 0)
WHEN @Numero<100 THEN dbo.F_Decenas(@Numero, @Estilo)
WHEN @Numero<1000 THEN dbo.F_Centenas(@Numero, @Estilo)
END
RETURN @Texto
END 
GO
