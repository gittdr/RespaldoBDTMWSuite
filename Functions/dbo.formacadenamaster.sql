SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION  [dbo].[formacadenamaster](@masterbill int)
RETURNS varchar(900) AS 
BEGIN 

declare @cadena  varchar(900)
declare @orden int


DECLARE master_Cursor CURSOR FOR

SELECT ord_number
FROM invoiceheader 
WHERE ivh_mbnumber= @masterbill and @masterbill > 0

OPEN master_Cursor


FETCH NEXT FROM master_Cursor 
INTO @orden

select   @cadena = 'Esta factura ampara las remisiones : ' + ltrim(rtrim(convert(char(6), @orden)))
--select   @cadena = @cadena + ' , '+ rtrim(convert(char(8), @orden))

WHILE @@FETCH_STATUS = 0
BEGIN
    FETCH NEXT FROM master_Cursor 
    INTO @orden

   If @@FETCH_STATUS = 0
   Select   @cadena = @cadena + ', '+ ltrim(rtrim(convert(char(6), @orden)))
--select @cadena 

END


CLOSE master_Cursor 
DEALLOCATE master_Cursor

Return @cadena

END
GO
