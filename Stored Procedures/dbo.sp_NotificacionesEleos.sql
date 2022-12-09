SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_NotificacionesEleos](@leg varchar(100),@titulo varchar(100),@mensaje varchar(8000))
	
AS
BEGIN
DECLARE @bodyC varchar(8000)
DECLARE @subjectC varchar(1000)
DECLARE @files varchar(500)


set @bodyC = @leg +  @mensaje;
set @subjectC = @leg;
set @files = @titulo;

BEGIN
	
	EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'smtp liverpool',  
    --@recipients = 'lbarron@convoy360.mx',  
	@recipients = 'jcherrera@bgcapitalgroup.mx',  
    --@body = 'DX > 500 Alerta de creacion masiva de Ordenes!!!!!', 
	@body = @bodyC ,
	@file_attachments = @files,
    @subject = @subjectC; 

END
END
GO
