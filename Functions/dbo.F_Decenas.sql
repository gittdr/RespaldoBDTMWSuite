SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Función para decenas 
--Función que devuelve en letra las decenas. El párametro @Estilo permite identificar los distintos valores que puede tener un mismo número. 
--Figura 3. 
---CREATE FUNCTION F_Decenas(@Numero as bigint, @Estilo as bit=0) 
CREATE FUNCTION [dbo].[F_Decenas](@Numero as bigint, @Estilo as bit=0) 
RETURNS varchar(500) AS 
BEGIN 
DECLARE @Texto varchar(500)
SELECT @Texto=''
SELECT @Texto= 
CASE 
WHEN @Numero=0 THEN ' '
WHEN @Numero=10 THEN 'DIEZ '
WHEN @Numero=11 THEN 'ONCE '
WHEN @Numero=12 THEN 'DOCE '
WHEN @Numero=13 THEN 'TRECE '
WHEN @Numero=14 THEN 'CATORCE '
WHEN @Numero=15 THEN 'QUINCE '
WHEN @Numero=16 THEN 'DIECISEIS '
WHEN @Numero=17 THEN 'DIECISIETE '
WHEN @Numero=18 THEN 'DIECIOCHO '
WHEN @Numero=19 THEN 'DIECINUEVE '
WHEN @Numero=20 THEN 'VEINTE '
WHEN @Numero>20 and @Numero<30 THEN 'VEINTI' + 
dbo.F_Unidades(RIGHT(CONVERT(varchar, @Numero), 1), 0)
WHEN @Numero=30 THEN 'TREINTA '
WHEN @Numero>30 and @Numero<40 THEN 'TREINTA Y ' + 
dbo.F_Unidades(RIGHT(CONVERT(varchar, @Numero), 1), 0)
WHEN @Numero=40 THEN 'CUARENTA '
WHEN @Numero>40 and @Numero<50 THEN 'CUARENTA Y ' + 
dbo.F_Unidades(RIGHT(CONVERT(varchar, @Numero), 1), 0)
WHEN @Numero=50 THEN 'CINCUENTA '
WHEN @Numero>50 and @Numero<60 THEN 'CINCUENTA Y ' + 
dbo.F_Unidades(RIGHT(CONVERT(varchar, @Numero), 1), 0)
WHEN @Numero=60 THEN 'SESENTA '
WHEN @Numero>60 and @Numero<70 THEN 'SESENTA Y ' + 
dbo.F_Unidades(RIGHT(CONVERT(varchar, @Numero), 1), 0)
WHEN @Numero=70 THEN 'SETENTA '
WHEN @Numero>70 and @Numero<80 THEN 'SETENTA Y ' + 
dbo.F_Unidades(RIGHT(CONVERT(varchar, @Numero), 1), 0)
WHEN @Numero=80 THEN 'OCHENTA '
WHEN @Numero>80 and @Numero<90 THEN 'OCHENTA Y ' + 
dbo.F_Unidades(RIGHT(CONVERT(varchar, @Numero), 1), 0)
WHEN @Numero=90 THEN 'NOVENTA '
WHEN @Numero>90 and @Numero<100 THEN 'NOVENTA Y ' + 
dbo.F_Unidades(RIGHT(CONVERT(varchar, @Numero), 1), 0)
WHEN @Numero<10 THEN dbo.F_Unidades(@Numero, @Estilo)
END
RETURN @Texto
END 

GO
