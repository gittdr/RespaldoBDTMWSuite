SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO




CREATE     PROCEDURE  [dbo].[forma_cadena_mb] (@masterbill int) AS
/*exec forma_cadena_mb  9026  */ 

declare @cadena  varchar(500),
@remark varchar(100),
@orden int


select  @remark =   isnull(ivh_remark,'')
from VISTA_TMW_header
where masterbill = @masterbill
 

DECLARE master_Cursor CURSOR FOR



SELECT ord_number
FROM invoiceheader 
WHERE ivh_mbnumber= @masterbill and @masterbill > 0



OPEN master_Cursor


FETCH NEXT FROM master_Cursor 
INTO @orden

select   @cadena = @remark + ' Esta factura ampara las remisiones : ' + ltrim(rtrim(convert(char(6), @orden)))
--select   @cadena = @cadena + ' , '+ rtrim(convert(char(8), @orden))

WHILE @@FETCH_STATUS = 0
BEGIN
    FETCH NEXT FROM master_Cursor 
    INTO @orden

   If @@FETCH_STATUS = 0
   Select   @cadena = @cadena + ', '+ ltrim(rtrim(convert(char(6), @orden)))
select @cadena 

END

Update  vTTSTMW_Header 
set   ivh_remark = @cadena
where masterbill  = @masterbill 

CLOSE master_Cursor 
DEALLOCATE master_Cursor
GO
