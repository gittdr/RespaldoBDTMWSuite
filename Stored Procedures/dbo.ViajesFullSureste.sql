SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ViajesFullSureste] (@accion int )
	-- Add the parameters for the stored procedure here
	
AS

if (@accion = 1)
begin
		select leg.ord_hdrnumber,leg.lgh_tractor,leg.lgh_driver1,ord.ord_billto,stp.cmp_id,stp.stp_number, stp.lgh_number, stp.stp_event, cmp.cmp_name,cty.cty_name,stp.stp_schdtearliest as fecha,
		(Select cmp_id from stops where stops.stp_number = (Select max(stp_number) from stops where stops.lgh_number = stp.lgh_number and stops.stp_number < stp.stp_number) )as origen,
		(Select cty.cty_name from stops where stops.stp_number = (Select max(stp_number) from stops inner join company cmp on cmp.cmp_id = stp.cmp_id inner join city cty on cty.cty_code = cmp.cmp_city 
																						where stops.lgh_number = stp.lgh_number and stops.stp_number < stp.stp_number )) as OrigenNombre,
		datediff(Hour,(Select stp_schdtearliest from stops where stops.stp_number = (Select max(stp_number) from stops where stops.lgh_number = stp.lgh_number and stops.stp_number < stp.stp_number) ),stp.stp_schdtearliest) as TiempoRecorrido
		from stops stp
		inner join legheader leg on leg.lgh_number  = stp.lgh_number
		inner join orderheader ord on leg.ord_hdrnumber = ord.ord_hdrnumber
		inner join company cmp on cmp.cmp_id = stp.cmp_id
		inner join city cty on cty.cty_code = cmp.cmp_city

		where stp_schdtearliest > convert(date,getdate()) and stp_schdtearliest < convert(date,getdate()+1) and
		stp.stp_status = 'OPN' and 
		 cty.cty_name in ('Villahermosa','Merida','Cancun','RIO LAGARTOS','Playa del Carmen','Tapachula','TUXTLA GUTIERREZ','Tihuatlan','Orizaba','Veracruz','JUCHITAN DE ZARAGO','Salina Cruz','COMITAN DE DOMINGU','cardenas','Coatzacoalcos')
		and (Select cmp_id from stops where stops.stp_number = (Select max(stp_number) from stops where stops.lgh_number = stp.lgh_number and stops.stp_number < stp.stp_number) ) is not null
		order by ord.ord_billto asc, stp.stp_schdtearliest asc

end
else if (@accion = 2)
begin
		select leg.ord_hdrnumber,leg.lgh_tractor,leg.lgh_driver1,ord.ord_billto,stp.cmp_id,stp.stp_number, stp.lgh_number, stp.stp_event, cmp.cmp_name,cty.cty_name,stp.stp_schdtearliest as fecha,
		(Select cmp_id from stops where stops.stp_number = (Select max(stp_number) from stops where stops.lgh_number = stp.lgh_number and stops.stp_number < stp.stp_number) )as origen,
		
		(Select cty.cty_name from stops where stops.stp_number = (Select max(stp_number) from stops inner join company cmp on cmp.cmp_id = stp.cmp_id inner join city cty on cty.cty_code = cmp.cmp_city 
																						where stops.lgh_number = stp.lgh_number and stops.stp_number < stp.stp_number )) as OrigenNombre,
		datediff(Hour,(Select stp_schdtearliest from stops where stops.stp_number = (Select max(stp_number) from stops where stops.lgh_number = stp.lgh_number and stops.stp_number < stp.stp_number) ),stp.stp_schdtearliest) as TiempoRecorrido
		from stops stp
		inner join legheader leg on leg.lgh_number  = stp.lgh_number
		inner join orderheader ord on leg.ord_hdrnumber = ord.ord_hdrnumber
		inner join company cmp on cmp.cmp_id = stp.cmp_id
		inner join city cty on cty.cty_code = cmp.cmp_city

		where stp_schdtearliest > convert(date,getdate()+1) and stp_schdtearliest < convert(date,getdate()+4) and
		stp.stp_status = 'OPN' and 
		 cty.cty_name in ('Villahermosa','Merida','Cancun','RIO LAGARTOS','Playa del Carmen','Tapachula','TUXTLA GUTIERREZ','Tihuatlan','Orizaba','Veracruz','JUCHITAN DE ZARAGO','Salina Cruz','COMITAN DE DOMINGU','cardenas','Coatzacoalcos')
		and (Select cmp_id from stops where stops.stp_number = (Select max(stp_number) from stops where stops.lgh_number = stp.lgh_number and stops.stp_number < stp.stp_number) ) is not null
		order by ord.ord_billto asc, stp.stp_schdtearliest asc
end 

GO
