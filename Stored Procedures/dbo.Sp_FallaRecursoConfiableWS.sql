SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Sp_FallaRecursoConfiableWS]
AS
SET NOCOUNT ON

	
				DECLARE @tempID INTEGER
				DECLARE @Viaje Varchar(5000)
				DECLARE @IDOperador Varchar(5000)
				DECLARE @Email Varchar(5000)
				DECLARE @Subject Varchar(5000)
				DECLARE @Body Varchar(5000)
				select @Body = '<p>Falla en la integracion con RControl: </p>'
EXEC msdb.dbo.sp_send_dbmail  
							@profile_name = 'smtp TDR',  
							@recipients = 'em@tdr.com.mx;',  
							@body = @Body,
							@body_format='HTML',
							@subject = @subject ; 
GO
