SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Eric Juarez
-- Create date: 16 nov 2018 2.17 pm 
-- Version: 4.0
-- Description:	

   /* Sentencia de prueba

       exec [sp_RecalculoOrdenesWorkCycle]
	*/

-- =============================================
CREATE PROCEDURE [dbo].[sp_sl_pilgrims_EnvioSap] (@action varchar(20), @ruta varchar(5000))
	
AS
BEGIN

IF(@action = 1)
	begin
			select ord_refnum
			 from orderheader oh
			inner join [dbo].[Sl_Pilgrims_Rutas] rt on oh.ord_refnum = rt.ruta
			where ord_billto= 'PILGRIMS' 
				and ord_completiondate > '01/12/2018'
				and rt.EnviadoSap is null and oh.ord_status = 'cmp'
	end
IF(@action = 2)
	begin
			update [dbo].[Sl_Pilgrims_Rutas]
			set  EnviadoSap = 'Enviado'
			where ruta = @ruta
	end

END


GO
