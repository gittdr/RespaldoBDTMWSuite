SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_NotificacionesPenafiel](@leg varchar(100),@titulo varchar(100),@mensaje varchar(8000))
	
AS
BEGIN
DECLARE @bodyC varchar(8000)
DECLARE @subjectC varchar(1000)

set @bodyC = @titulo + @leg + ' ' + 'Error: ' + @mensaje;
set @subjectC = @titulo + @leg;

BEGIN
	
	EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'smtp liverpool',  
    --@recipients = 'lbarron@convoy360.mx',  
	@recipients = 'jcherrera@bgcapitalgroup.mx;yarroyo@tdr.com.mx;coordinador.mx2@tdr.com.mx;ejecutivosac1@tdr.com.mx',  
    --@body = 'DX > 500 Alerta de creacion masiva de Ordenes!!!!!', 
	@body = @bodyC ,
    @subject = @subjectC;  

END
END
GO
