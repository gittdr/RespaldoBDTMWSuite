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
DECLARE @copy_to varchar(100)


set @bodyC = '';
set @subjectC = @leg;
set @files = @titulo;
set @copy_to = 'jcherrera@bgcapitalgroup.mx';

BEGIN
	
	EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'ApiEleos',  
    --@recipients = 'lbarron@convoy360.mx',  
	@recipients = 'eleos@universidadtdr.com.mx;jcherrera@bgcapitalgroup.mx',  
    --@body = 'DX > 500 Alerta de creacion masiva de Ordenes!!!!!', 
	@body = @bodyC ,
	@file_attachments = @files,
    @subject = @subjectC; 

END
END
GO
