SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name> Linda y Erik
-- Create date: <Create Date,,> 23/12/19
-- Description:	<Description,,> Actualiza la descripcion del anticipo y/o reembolso (pyd_description) con el concepto de la tabla 
--								Codigos_comprobacion correpondiente (id_codigo).También copia este número en el campo pyd_tprsplit_number 
--								el cual se utiliza para el analisis de los indicadores de normatividad en el cubo  
--								(VistaGratificacionesRoger_por_Orden)
-- Exec [dbo].[sp_ActualizarAnticiposYReembolsos] 1
-- =============================================
create PROCEDURE [dbo].[sp_ActualizarLiverReportUbicacion] (@accion int)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	IF(DATEPART(hour,getdate()) = 0)
	begin
	delete [liverReportUbicacion]

	end
	else
	BEGIN
		insert into [dbo].[liverReportUbicacion]([trc_number], [fecha], [hora], [trc_gps_desc], [Lat], [long])
			select trc_number,cast(getdate() as date) as fecha, DATEPART(hour,GETDATE()) as hora, trc_gps_desc
			,cast(trc_gps_latitude/3600.00 as dec(16,4)) as Lat,cast(trc_gps_longitude/3600.00 as dec(16,4)) as long
			from tractorprofile
			where trc_type3 = 'HED' and
			trc_gps_date >= cast(getdate() as date)
	END
END
GO
