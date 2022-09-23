SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[EXTRACT_NUMPLACA_3digito](@placa AS VARCHAR(max))
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

 RETURN @Digito
END
GO
