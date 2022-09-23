SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		erik juarez
-- Create date: getdate()
-- Description:	<Description,,>
-- exec [dbo].[sp_ConvoyAlertaOrdenesDX] 1
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConvoyAlertaOrdenesDX] (@accion int)
	
AS
BEGIN
DECLARE @tempID int
DECLARE @ordenes int

set @tempID = (select count(*) from orderheader where ord_bookedby = 'DX' and ord_bookdate >= cast(getdate() as date))
set @ordenes = (select count(*) from orderheader where ord_bookedby = 'DX' and ord_bookdate >= cast(getdate() as date))
--ord_hdrnumber,ord_billto,ord_refnum

IF(@tempID > 500)
BEGIN
	
	EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'smtp TDR',  
    --@recipients = 'lbarron@convoy360.mx',  
	@recipients = 'lbarron@convoy360.mx;ejuarez@convoy360.mx',  
    --@body = 'DX > 500 Alerta de creacion masiva de Ordenes!!!!!', 
	@body = @ordenes,
    @subject = 'DX > 500 Alerta de creacion masiva de Ordenes!!!!!';  

END
if (@tempID > 300)
begin
	EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'smtp TDR',  
	--@recipients = 'lbarron@convoy360.mx',
    @recipients = 'lbarron@convoy360.mx;ejuarez@convoy360.mx',  
    @body = @ordenes,
    @subject = 'DX > 300 Alerta de creacion masiva de Ordenes!!!!! ' ;  
end
END

GO
