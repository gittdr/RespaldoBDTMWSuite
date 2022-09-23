SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--select dbo.NumeroEnLetra(117)


--CREATE FUNCTION NumeroEnLetra(@NumeroAProcesar as varchar(30)) 
CREATE FUNCTION [dbo].[NumeroEnLetra](@NumeroAProcesar as varchar(30)) 
RETURNS varchar(500) AS
BEGIN 
DECLARE @Numero bigint
DECLARE @Decimal varchar(30)
DECLARE @Texto varchar(500)
DECLARE @EstiloMillares bit
SELECT @Texto=''
/* Obtenemos parte entera */
IF patindex('%.%', @NumeroAProcesar)>0
BEGIN
SELECT @Numero=LEFT(@NumeroAProcesar, 
patindex('%.%', @NumeroAProcesar)-1)
END
ELSE
BEGIN
SELECT @Numero=CONVERT(bigint, @NumeroAProcesar)
END
SELECT @EstiloMillares=CONVERT(bit,LEN(@Numero)-7)
/* Proceso número negativos */
IF @Numero<0
BEGIN 
SELECT @Texto='menos ' 
SELECT @Numero=ABS(@Numero)
END
/* Proceso parte entera */
SELECT @Texto= @Texto +
CASE 
WHEN @Numero=1000000 THEN 'UN MILLON'

WHEN @Numero>1000000 AND @Numero< 2000000 THEN 
dbo.F_Millares(
LEFT(CONVERT(varchar, @Numero), LEN(@Numero)-6), 
@EstiloMillares) +
' MILLON ' +
dbo.F_Millares(RIGHT(CONVERT(varchar, @Numero), 6), 1)
WHEN @Numero<10 THEN dbo.F_Unidades(@Numero, 0)
WHEN @Numero<100 THEN dbo.F_Decenas(@Numero, 1)
WHEN @Numero<1000 THEN dbo.F_Centenas(@Numero, 1)
WHEN @Numero<1000000 THEN dbo.F_Millares(@Numero, 1)




WHEN @Numero>1000000 AND @Numero<1000000000000 THEN 
dbo.F_Millares(
LEFT(CONVERT(varchar, @Numero), LEN(@Numero)-6), 
@EstiloMillares) +
' MILLONES ' +
dbo.F_Millares(RIGHT(CONVERT(varchar, @Numero), 6), 1)
WHEN @Numero<10 THEN dbo.F_Unidades(@Numero, 0)
WHEN @Numero<100 THEN dbo.F_Decenas(@Numero, 1)
WHEN @Numero<1000 THEN dbo.F_Centenas(@Numero, 1)
WHEN @Numero<1000000 THEN dbo.F_Millares(@Numero, 1)
END


RETURN @Texto
END 
GO
