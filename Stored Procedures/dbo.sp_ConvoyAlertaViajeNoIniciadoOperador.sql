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
create PROCEDURE [dbo].[sp_ConvoyAlertaViajeNoIniciadoOperador] (@accion int)
	
AS
BEGIN
IF(@accion = 1)
BEGIN

declare @mensajeOperador as varchar(max)
	 declare @destino as  varchar(10)

		 select @mensajeOperador = (select 'Tienes una nueva orden asignada:  ' +  cast(l.ord_hdrnumber as varchar(20))),
	 @destino=  (select mpp_tractornumber from manpowerprofile (nolock)  where mpp_id =  asgn_id) 
		from assetassignment a
		inner join legheader (nolock) l on l.lgh_number =  a.lgh_number
		where asgn_status = 'PLN'
	 and asgn_date >= DATEADD(HOUR,-1,GETDATE()) AND asgn_date <= GETDATE()
	 and asgn_type = 'DRV'

	  exec tm_insertamensaje @mensajeOperador , @destino
END
END
GO
