SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		erik juarez
-- Create date: getdate()
-- Description:	<Description,,>
-- exec [dbo].[sp_ConvoyCorreoCliente_finalizado] 1
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConvoyCorreoCliente_finalizado] (@accion int)
	
AS
BEGIN
IF(@accion = 1)
BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;
		--buscar los mensajes a enviar
		DECLARE Cur CURSOR FOR
		select ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'BL#' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber)
	--oh.ord_completiondate,*
			from legheader lg
			inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
			inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
			where oh.ord_billto = 'WERGLOBA'  and oh.ord_status in ('CMP') and lgh_outstatus = ('CMP')  AND lgh_carrier = 'UNKNOWN' 
			and tp.trc_licnum is not null --and (DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))) is not null
			and oh.ord_completiondate >= cast(GETDATE() as date)
			AND ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'BL#' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber) 
			NOT IN (select [Referencia] from [dbo].[Convoy_EnviarViajeFinalizado])

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
					select @Body= 
			'<p>El viaje ha finalizado con exito Fecha: '+ cast(oh.ord_completiondate as varchar) + '</p><p> Fecha cita programada: '+cast(oh.ord_dest_latestdate as varchar) + '</p><p> Llegada: ' + cast(datediff(HOUR,oh.ord_dest_latestdate , lg.lgh_enddate_arrival) as varchar)+' Hora(s) a la cita </p>'
			+ ' <p> Placas:  '+ Cast (tp.trc_licnum as varchar)+ '</p><p> Tractor: '+lg.lgh_tractor + '</p><p> Caja: '+ lg.lgh_primary_trailer + '</p>'
			,@subject = 'Viaje Finalizado: ' +ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'BL#' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber) +' Fecha llegada: '+ cast(oh.ord_completiondate as varchar)
				from legheader lg
			inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
			inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
			where oh.ord_billto = 'WERGLOBA'  and oh.ord_status in ('CMP') and lgh_outstatus = ('CMP')  AND lgh_carrier = 'UNKNOWN' 
			and tp.trc_licnum is not null --and (DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))) is not null
			and oh.ord_originpoint = 'HACATO'
			and ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'BL#' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber) = @tempID
			and oh.ord_completiondate >= cast(GETDATE() as date)
						print @IDOperador 
						print @Email 
						print @Subject 
						print @Body 
						--enviar correo
					
						EXEC msdb.dbo.sp_send_dbmail  
							@profile_name = 'smtp TDR',  
							@recipients = 'ejuarez@tdr.com.mx;jferrer@tdr.com.mx;monitoreo@tequilapatron.com;jguzman@tequilapatron.com;amariscal@tequilapatron.com;etejeda@werner.com;evperez@werner.com;vmendiburu@werner.com;sacnorte@tdr.com.mx',  
							@body = @Body,
							@body_format='HTML',
							@subject = @subject ; 
		
						select @IDOperador= '', @Email = '', @Subject = '',@Body ='',@tempID = null
				end
			END

		CLOSE Cur 
		DEALLOCATE Cur 


		insert into [dbo].[Convoy_EnviarViajeFinalizado] ([Referencia])
		select ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'BL#' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber)
	--oh.ord_completiondate,*
			from legheader lg
			inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
			inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
			where oh.ord_billto = 'WERGLOBA'  and oh.ord_status in ('CMP') and lgh_outstatus = ('CMP')  AND lgh_carrier = 'UNKNOWN' 
			and tp.trc_licnum is not null --and (DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))) is not null
			and oh.ord_completiondate >= cast(GETDATE() as date)
			AND ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'BL#' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber) 
			NOT IN (select [Referencia] from [dbo].[Convoy_EnviarViajeFinalizado])

END
END

GO
