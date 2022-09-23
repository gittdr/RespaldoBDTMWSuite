SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_OrdenesCalculoGlobalMap] (@accion int)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	
	IF(@accion = 2)
	BEGIN
		--cambiar os campos por los calculos de globalmap para casetas
	select 
		ord_hdrnumber,
		stp_number,
		stops.stp_sequence, 
		--(select cmp_name from company where  cmp_id = stops.cmp_id) as compania,
		stops.cmp_id as compania,
		(select cty_nmstct from company where  cmp_id = stops.cmp_id) as ciudad,
		stp_ord_mileage as kms,
		stp_ord_toll_cost as costocasetas,
		(select 
		(select trc_axles from tractorprofile where trc_number = evt_tractor) +
		(select trl_axles from trailerprofile where trl_number = evt_trailer1)+
		(select trl_axles from trailerprofile where trl_number =evt_trailer2)+
		ISnull((select trl_axles from trailerprofile where trl_number =evt_dolly),1)
			from event e where e.stp_number = stops.stp_number ) as ejes
		
		,(select max([Valor]) from [dbo].[Sl_Pilgrims_TipoVehiculo] tv where tv.ejes = (select 
		(select trc_axles from tractorprofile where trc_number = evt_tractor) +
		(select trl_axles from trailerprofile where trl_number = evt_trailer1)+
		(select trl_axles from trailerprofile where trl_number =evt_trailer2)+
		ISnull((select trl_axles from trailerprofile where trl_number =evt_dolly),1)
			from event e where e.stp_number = stops.stp_number )) as tipoVehiculo,
				Isnull((select cmp_latseconds/3600 from company where  cmp_id = stops.cmp_id),0) as lat,
		Isnull((select (cmp_longseconds/3600)*-1 from company where  cmp_id = stops.cmp_id),0) as long
		

		
	from stops 
	where lgh_number in (select lgh_number from legheader where ord_hdrnumber --= '603120' or ord_hdrnumber = '602321')
	
	 in (select  ord_hdrnumber from orderheader where ord_billto = 'pilgrims' and ord_status = 'cmp' and ord_invoicestatus = 'AVL' and datediff(day,ord_completionDate,getdate()) < 30 ))
	and ord_hdrnumber <> 0 
	and (select 
		(select trc_axles from tractorprofile where trc_number = evt_tractor) +
		(select trl_axles from trailerprofile where trl_number = evt_trailer1)+
		(select trl_axles from trailerprofile where trl_number =evt_trailer2)+
		ISnull((select trl_axles from trailerprofile where trl_number =evt_dolly),1)
			from event e where e.stp_number = stops.stp_number ) is not null
	--and ord_hdrnumber = '619977'
	 
	order by ord_hdrnumber, stp_sequence asc
	

	END
	



END


GO
