SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		erik juarez
-- Create date: getdate()
-- Description:	<Description,,>
-- exec [dbo].[sp_ConvoyAlertaViajeNoIniciado] 1
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConvoyAlertaViajeNoIniciado] (@accion int)
	
AS
BEGIN
IF(@accion = 1)
BEGIN

		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;
		--buscar los mensajes a enviar
		DECLARE Cur CURSOR FOR
		 select  cast(l.ord_hdrnumber as varchar(20))
		  --(select  teamleader_email from labelfile where tp.trc_teamleader = abbr and labeldefinition = 'TeamLeader' )
			 from assetassignment a
			  inner join legheader (nolock) l on l.lgh_number =  a.lgh_number
			 inner join  manpowerprofile mpp on mpp.mpp_id =  asgn_id
			 inner join tractorprofile tp on  mpp.mpp_tractornumber = tp.trc_number 
			 where asgn_status = 'PLN'
				 and asgn_date >= DATEADD(HOUR,-10,GETDATE()) AND asgn_date <=  DATEADD(HOUR,-1,GETDATE())
				 and asgn_type = 'DRV'
				 and (select  teamleader_email from labelfile where mpp.mpp_teamleader = abbr and labeldefinition = 'TeamLeader' ) is not null

		OPEN Cur 

		WHILE ( @@FETCH_STATUS = 0 )
			BEGIN
				
				DECLARE @tempID INTEGER
				DECLARE @Viaje Varchar(5000)
				DECLARE @IDOperador Varchar(5000)
				DECLARE @Email Varchar(5000)
				DECLARE @Subject Varchar(5000)
				DECLARE @Body Varchar(5000)

				FETCH NEXT FROM Cur INTO @tempID
				--obtener variables
				print @tempID
				if (@tempID is not null)
				begin
					select @Body= 'La orden '+ cast(@tempID as varchar) +' no fue iniciado por el operador ' + cast(asgn_id as varchar)+ ' con la unidad '+ cast(mpp.mpp_tractornumber as varchar) + ' contacta al operador o reasigna el viaje para su próxima salida'
			,@subject = 'La orden '+ cast(@tempID as varchar) +' no fue iniciado por el operador ' +cast(asgn_id as varchar) + ' con la unidad '+ cast(mpp.mpp_tractornumber as varchar)
			,@Email = (select  teamleader_email from labelfile where mpp.mpp_teamleader = abbr and labeldefinition = 'TeamLeader' ) 
			
			 from assetassignment a
			  inner join legheader (nolock) l on l.lgh_number =  a.lgh_number
			 inner join  manpowerprofile mpp on mpp.mpp_id =  asgn_id
			 inner join tractorprofile tp on  mpp.mpp_tractornumber = tp.trc_number 
			 where asgn_status = 'PLN'
				 and asgn_date >= DATEADD(HOUR,-3,GETDATE()) AND asgn_date <=  DATEADD(HOUR,-1,GETDATE())
				 and asgn_type = 'DRV'
				 and l.ord_hdrnumber = @tempID
				 and (select  teamleader_email from labelfile where mpp.mpp_teamleader = abbr and labeldefinition = 'TeamLeader' ) is not null

						print @IDOperador 
						print @Email 
						print @Subject 
						print @Body 
						--enviar correo
					
						EXEC msdb.dbo.sp_send_dbmail  
							@profile_name = 'smtp TDR',  
							@recipients = @Email,
							@body = @Body,
							@body_format='HTML',
							@subject = @subject ; 
		
						select @IDOperador= '', @Email = '', @Subject = '',@Body ='',@tempID = null
				end
			END

		CLOSE Cur 
		DEALLOCATE Cur 


		
		
		

END
END

GO
