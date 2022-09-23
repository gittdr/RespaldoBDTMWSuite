SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		erik juarez
-- Create date: getdate()
-- Description:	<Description,,>
-- exec [dbo].[sp_ConvoyCorreoClienteInnovador] 1
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConvoyCorreoClienteInnovador] (@accion int)
	
AS
BEGIN
IF(@accion = 1)
BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;
		--buscar los mensajes a enviar
		DECLARE Cur CURSOR FOR
	select ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'OC' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber)
			from legheader lg
			inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
			inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
			where oh.ord_billto = 'INOVADOR'  and oh.ord_status in ('STD') and lgh_outstatus <> ('CMP')  AND lgh_carrier = 'UNKNOWN' and tp.trc_licnum is not null 
			and (DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))) is not null
			

		OPEN Cur 

		WHILE ( @@FETCH_STATUS = 0 )
			BEGIN
				
				DECLARE @tempID Varchar(5000)
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
					select @Body= '<p>'+'Fecha de viaje: ' + cast((select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)) as varchar)
					+ ' <p> Ultima Posición: ' + (select ckc_comment from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)) + '</p> <p> Ver la ubicación en GoogleMaps <a href="'+
			'https://maps.google.com/?q=' +
CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00 as varchar)  + ',' +
cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00)*-1 as varchar) +'">Ir a la ubicacion </a></p>'
			+ ' <p> Placas:  '+ Cast (tp.trc_licnum as varchar)+ '</p><p> Tractor: '+lg.lgh_tractor + '</p><p> Caja: '+ lg.lgh_primary_trailer + '</p>'
			,@subject = 'Viaje cliente Innovador: ' +ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'OC' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber)
			from legheader lg
			inner join orderheader oh on oh.ord_hdrnumber = lg.ord_hdrnumber
			inner join tractorprofile tp on tp.trc_number = lg.lgh_tractor
			where oh.ord_billto = 'INOVADOR'  and oh.ord_status in ('STD') and lgh_outstatus <> ('CMP')  AND lgh_carrier = 'UNKNOWN' and tp.trc_licnum is not null and (DATEADD(second, DATEDIFF(second, GETDATE(), GETUTCDATE()), (select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)))) is not null
			--and oh.ord_originpoint = 'HACATO'
			and ISNULL((select TOP 1 ref_number from referencenumber where REF_TYPE = 'OC' AND ord_hdrnumber in (select ord_hdrnumber from orderheader oh where lg.ord_hdrnumber = ord_hdrnumber)),lg.ord_hdrnumber) = @tempID
			--and oh.ord_completiondate >= cast(GETDATE() as date)
			
						print @IDOperador 
						print @Email 
						print @Subject 
						print @Body 
						--enviar correo
					
						EXEC msdb.dbo.sp_send_dbmail  
							@profile_name = 'smtp TDR',  
							@recipients = 'monitoreo@innovador.com.mx;alejandro@innovador.com.mx;mbarcenas@innovador.com.mx;rvega@innovador.com.mx;mrodriguez@innovador.com.mx;sacnorte@tdr.com.mx',  
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
