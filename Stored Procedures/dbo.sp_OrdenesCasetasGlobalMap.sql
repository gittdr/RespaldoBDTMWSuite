SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- exec sp_OrdenesCasetasGlobalMap 2
-- =============================================
CREATE PROCEDURE [dbo].[sp_OrdenesCasetasGlobalMap] (@accion int)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	
	IF(@accion = 2)
	BEGIN
		--cambiar os campos por los calculos de globalmap para casetas
	select 
		lgh.ord_hdrnumber,
		stp_number,
		stp.stp_mfh_sequence-1 AS stp_mfh_sequence,

		--(select cmp_name from company where  cmp_id = stops.cmp_id) as compania,
		
		--(select max(cmp_id) from stops where stops.stp_number = (select stops.stp_number from stops where stops = lgh.ord_hdrnumber and stops.stp_sequence <= stp.stp_sequence-1 )) as stp_cmp_anterior,
		stp.cmp_id as compania,
		--lgh.lgh_tractor,
		(select cty_nmstct from company where  cmp_id = stp.cmp_id) as ciudad,
		stp_ord_mileage as kms,
		stp_ord_toll_cost as costocasetas,
		(select 
		isnull((select max(trc_axles) from tractorprofile where trc_number = evt_tractor),0) +
		isnull((select max(trl_axles) from trailerprofile where trl_number = evt_trailer1),0) +
		isnull((select max(trl_axles) from trailerprofile where trl_number =evt_trailer2),0)+
		ISnull((select max(trl_axles) from trailerprofile where trl_number =evt_dolly),1)
			from event e where e.stp_number = stp.stp_number ) as ejes
		,
		(select max([Valor]) from [dbo].[Sl_Pilgrims_TipoVehiculo] tv where tv.ejes = 
		(select 
		isnull((select max(trc_axles) from tractorprofile where trc_number = evt_tractor),0) +
		isnull((select max(trl_axles) from trailerprofile where trl_number = evt_trailer1),0) +
		isnull((select max(trl_axles) from trailerprofile where trl_number =evt_trailer2),0)+
		ISnull((select max(trl_axles) from trailerprofile where trl_number =evt_dolly),1)
			from event e where e.stp_number = stp.stp_number )) as tipoVehiculo,
		
		Isnull((select cmp_latseconds/3600 from company where  cmp_id = stp.cmp_id),0) as lat,
		Isnull((select (cmp_longseconds/3600)*-1 from company where  cmp_id = stp.cmp_id),0) as long
		

		
	from stops stp
	inner join legheader lgh on stp.lgh_number = lgh.lgh_number
	where lgh.ord_hdrnumber -- in (select lgh_number from legheader where ord_hdrnumber --= '603120' or ord_hdrnumber = '602321')
	
	 in (select  ord_hdrnumber from orderheader where  ord_status = 'cmp' and ord_billto = 'PILGRIMS'
	 and ord_invoicestatus = 'AVL' and datediff(day,ord_completionDate,getdate() ) < 30 ) 
	and lgh_tractor <> 'UNKNOWN'


	--and (select 
	--	(select trc_axles from tractorprofile where trc_number = evt_tractor) +
	--	(select trl_axles from trailerprofile where trl_number = evt_trailer1)+
	--	(select trl_axles from trailerprofile where trl_number =evt_trailer2)+
	--	ISnull((select trl_axles from trailerprofile where trl_number =evt_dolly),1)
	--		from event e where e.stp_number = stops.stp_number ) is not null
	--and ord_hdrnumber = '619977'
	 
	order by lgh.ord_hdrnumber, stp_mfh_sequence asc
	

	END
	



END


GO
