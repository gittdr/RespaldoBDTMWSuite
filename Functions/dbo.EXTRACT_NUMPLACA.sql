SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[EXTRACT_NUMPLACA](@placa AS VARCHAR(max))
RETURNS VARCHAR(max)
AS
BEGIN
declare
 @Digito varchar(30)
WHILE PATINDEX('%[^0-9]%', @placa) > 0
 BEGIN
  SET @placa = REPLACE(@placa,SUBSTRING(@placa,PATINDEX('%[^0-9]%', @placa),1),'')
 END

 select @Digito = SUBSTRING(@placa, 3,1)

 IF @Digito = 5 or @Digito = 6 
	select @placa =  'Dígito-'+@Digito +' Vencimiento el '+'30-Abril'
 ELSE IF @Digito = 7 or @Digito = 8
	select @placa =  'Dígito-'+@Digito +' Vencimiento el '+'30-Junio' 
 ELSE IF @Digito = 3 or @Digito = 4
	select @placa =  'Dígito-'+@Digito +' Vencimiento el '+'31-Agosto' 
 ELSE IF @Digito = 1 or @Digito = 2
	select @placa =  'Dígito-'+@Digito +' Vencimiento el '+'31-Octubre' 
 ELSE IF @Digito = 9 or @Digito = 0
	select @placa =  'Dígito-'+@Digito +' Vencimiento el '+'30-Diciembre' 
 
 RETURN @placa
END
GO
