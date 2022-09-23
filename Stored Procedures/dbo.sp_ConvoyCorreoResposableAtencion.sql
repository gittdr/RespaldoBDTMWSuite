SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		erik juarez
-- Create date: getdate()
-- Description:	<Description,,>
-- exec [dbo].[sp_ConvoyCorreoResposableAtencion] 1
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConvoyCorreoResposableAtencion] (@accion int)
	
AS
BEGIN
IF(@accion = 1)
BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;
		--buscar los mensajes a enviar
		DECLARE Cur CURSOR FOR
		SELECT msg.sn from tblMessages msg
				inner join [dbo].[tblMsgProperties] prop on msg.SN = prop.MsgSN
				inner join [dbo].[tblForms] form on prop.[Value]  = form.SN
				inner join manpowerprofile mpp on replace(msg.[Subject], 'Macro de ','') = mpp.mpp_firstname +' ' + mpp.mpp_lastname
				left join [dbo].[tblFormEmail] femail on form.SN =  femail.IdForm
				where form.sn  in ('58','126','129') and msg.sn = msg.BaseSN and msg.SN not in (select [SNEnviado] from [dbo].[tblMsgEmail])
				and cast(DTSent as date) = cast(getdate() as date) and email is not null
				order by 1 desc 

		OPEN Cur 

		WHILE ( @@FETCH_STATUS = 0 )
			BEGIN
				
				DECLARE @tempID INTEGER
				DECLARE @IdConversacion Varchar(5000)
				DECLARE @IDOperador Varchar(5000)
				DECLARE @Email Varchar(5000)
				DECLARE @Subject Varchar(5000)
				DECLARE @Body Varchar(5000)

				FETCH NEXT FROM Cur INTO @tempID
				--obtener variables
				print @tempID
				if (@tempID is not null)
				begin
					select @IdConversacion = msg.NLCPosition,@IDOperador= mpp.mpp_id, @Email = femail.Email, @Subject = form.Name + ' Operador: '+ mpp.mpp_id,
					@Body = '<p>'+ form.Name + ' Operador: '+ mpp.mpp_id+ ' Mensaje: '+ replace(Cast(msg.Contents as varchar),'_',' ')+' </p> <a href="' + 'http://10.176.163.68:6063/ChatConvoy360.aspx?idChat='+msg.NLCPosition +'&idDriver=' +mpp.mpp_id+'">Ir a la conversación</a>'
						from tblMessages msg
						inner join [dbo].[tblMsgProperties] prop on msg.SN = prop.MsgSN
						inner join [dbo].[tblForms] form on prop.[Value]  = form.SN
						inner join manpowerprofile mpp on replace(msg.[Subject], 'Macro de ','') = mpp.mpp_firstname +' ' + mpp.mpp_lastname
						left join [dbo].[tblFormEmail] femail on form.SN =  femail.IdForm
						where form.sn  in ('58','126','129') and msg.sn = msg.BaseSN and msg.SN not in (select [SNEnviado] from [dbo].[tblMsgEmail])
						and msg.sn = @tempID

						print @IdConversacion
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
							@subject = @Subject ; 
		
						--insertarlos en una tabla como enviados
						insert into [dbo].[tblMsgEmail]([SNEnviado]) values (@tempID)
						select @IdConversacion = '',@IDOperador= '', @Email = '', @Subject = '',@Body ='',@tempID = null
				end
			END

		CLOSE Cur 
		DEALLOCATE Cur 


		
		
		

END
END
GO
