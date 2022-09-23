SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Casetas_CalculoGlobalMap] (@Id varchar(100), @tollCost decimal(10,2),@accion int)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	IF(@accion = 1)
	BEGIN
	--- update order costo casetas
	update orderheader
	set ord_toll_cost = @tollCost, ord_toll_cost_update_date = getdate()
	where  ord_number = @Id

	--		select  mov_number,ord_toll_cost,
 --ord_toll_cost_update_date,* from orderheader
 -- where ord_billto = 'pilgrims' and ord_status = 'cmp' and ord_invoicestatus = 'AVL' and ord_toll_cost is null
	select 0
	END
	IF(@accion = 2)
	BEGIN
		--cambiar os campos por los calculos de globalmap para casetas
		  update stops
			set stp_ord_toll_cost = @tollCost
		    where  stp_number = @Id
		select 0

	--select 
	--	ord_hdrnumber,
	--	stp_number,
	--	stops.stp_sequence, 
	--	(select cmp_name from company where  cmp_id = stops.cmp_id) as compania,
	--	(select cty_nmstct from company where  cmp_id = stops.cmp_id) as ciudad,
	--	stp_ord_mileage as kms,
	--	stp_ord_toll_cost as costocasetas,
	--	(select 
	--	(select trc_axles from tractorprofile where trc_number = evt_tractor) +
	--	(select trl_axles from trailerprofile where trl_number = evt_trailer1)+
	--	(select trl_axles from trailerprofile where trl_number =evt_trailer2)+
	--	(select trl_axles from trailerprofile where trl_number =evt_dolly)
	--		from event e where e.stp_number = stops.stp_number ) as ejes
		
	--	,(select max([Valor]) from [dbo].[Sl_Pilgrims_TipoVehiculo] tv where tv.ejes = (select 
	--	(select trc_axles from tractorprofile where trc_number = evt_tractor) +
	--	(select trl_axles from trailerprofile where trl_number = evt_trailer1)+
	--	(select trl_axles from trailerprofile where trl_number =evt_trailer2)+
	--	(select trl_axles from trailerprofile where trl_number =evt_dolly)
	--		from event e where e.stp_number = stops.stp_number )) as tipoVehiculo
		
	--select * from stops 
	--where lgh_number in (select lgh_number from legheader where ord_hdrnumber in (select  ord_hdrnumber from orderheader
	--			 where ord_billto = 'pilgrims' and ord_status = 'cmp' and ord_invoicestatus = 'AVL') )
	--order by ord_hdrnumber, stp_sequence asc


	END
		

END



GO
