SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--En el proceso principal se delega el procesado de la parte entera y decimal de un número en las funciones de apoyo. 
--Función para unidades 
--Función que devuelve en letra las unidades. El párametro @Estilo permite identificar los distintos valores que puede tener un mismo número. 
--Figura 2. 
--alter FUNCTION F_Unidades(@Numero as bigint, @Estilo as bit=0) 
CREATE FUNCTION [dbo].[F_Unidades](@Numero as bigint, @Estilo as bit=0) 
RETURNS varchar(500) AS 
BEGIN 
DECLARE @Texto varchar(500)
SELECT @Texto=''
SELECT @Texto=
CASE 
WHEN @Numero=0 THEN 'CERO '
WHEN @Numero=1 THEN 'UN '
WHEN @Numero=2 AND @Estilo=0 THEN 'DOS '
WHEN @Numero=2 AND @Estilo=1 THEN 'DOS'
WHEN @Numero=3 AND @Estilo=0 THEN 'TRES '
WHEN @Numero=3 AND @Estilo=1 THEN 'TRES'
WHEN @Numero=4 AND @Estilo=0 THEN 'CUATRO '
WHEN @Numero=4 AND @Estilo=1 THEN 'CUATRO'
WHEN @Numero=5 THEN 'CINCO  '

WHEN @Numero=6 AND @Estilo=0 THEN 'SEIS '
WHEN @Numero=6 AND @Estilo=1 THEN 'SEIS'
WHEN @Numero=7 AND @Estilo=0 THEN 'SIETE '
WHEN @Numero=7 AND @Estilo=1 THEN 'SETE'
WHEN @Numero=8 AND @Estilo=0 THEN 'OCHO	'
WHEN @Numero=8 AND @Estilo=1 THEN 'OCHO'
WHEN @Numero=9 AND @Estilo=0 THEN 'NUEVE '
WHEN @Numero=9 AND @Estilo=1 THEN 'NOVE'
END
RETURN @Texto
END 
GO
