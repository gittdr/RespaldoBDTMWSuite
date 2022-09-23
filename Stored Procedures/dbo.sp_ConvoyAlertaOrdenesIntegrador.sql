SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		erik juarez
-- Create date: getdate()
-- Description:	<Description,,>
-- exec [dbo].[sp_ConvoyAlertaOrdenesIntegrador] 1213970, 'WALMART'
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConvoyAlertaOrdenesIntegrador] (@accion int, @cliente varchar(100))
	
AS
BEGIN
DECLARE @bodyC varchar(1000)
DECLARE @subjectC varchar(1000)

set @bodyC = 'Se creo la orden del cliente '+ @cliente + ' con el proceso de carga: ' + CAST((select max(ord_hdrnumber) from legheader where mov_number =@accion) AS varchar) +' para su revisión y seguimiento';
set @subjectC = 'Se creo la orden del cliente '+ @cliente + ' con el proceso de carga: ' + CAST((select max(ord_hdrnumber) from legheader where mov_number =@accion) AS varchar);

IF(@cliente = 'SAYER')
BEGIN
	
	EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'smtp TDR',  
    --@recipients = 'lbarron@convoy360.mx',  
	@recipients = 'despachosayer@tdr.com.mx;erikrene1991@gmail.com;jcherrera@bgcapitalgroup.mx;jrlopez@bgcapitalgroup.mx',  
    --@body = 'DX > 500 Alerta de creacion masiva de Ordenes!!!!!', 
	@body = @bodyC ,
    @subject = @subjectC;  

END
ELSE IF(@cliente = 'WALMART')
BEGIN
	
	EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'smtp TDR',  
    --@recipients = 'lbarron@convoy360.mx',  
	@recipients = 'lpcwmvh@tdr.com.mx;erikrene1991@gmail.com;coperaciones@tdr.com.mx;jsolis@tdr.com.mx;jcherrera@bgcapitalgroup.mx;jrlopez@bgcapitalgroup.mx',  
    --@body = 'DX > 500 Alerta de creacion masiva de Ordenes!!!!!', 
	@body = @bodyC ,
    @subject = @subjectC;  

END

END

GO
