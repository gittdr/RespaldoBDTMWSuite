SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

--exec [sp_sl_Pilgrims_Aprobar] '667788','stpSequence'
-- =============================================
CREATE PROCEDURE [dbo].[sp_sl_Pilgrims_Aprobar] (@ord_header varchar(100),@ConjuntoDatos varchar(50))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
IF(@ConjuntoDatos = 'paperReq') 
BEGIN
	select *,
		(select nts.not_Text from notes nts where  nts.nre_tablekey =  @ord_header and nts.not_Text   like  '%' +ppw.DocTypeName + '%' ) as nota 
	from PaperworkRequirementsView ppw
	
	--order by orderNumber desc
	where ppw.ordernumber = @ord_header

END
ELSE IF(@ConjuntoDatos = 'otroMotivo') 
BEGIN
	select nts.not_Text from notes nts where  nts.nre_tablekey =  @ord_header and nts.not_Text   like  '%' +'Otra'+ '%' 
END
ELSE IF(@ConjuntoDatos = 'stpSequence') 
BEGIN

select 
	stp_event,
	stp_number,
	stops.stp_sequence, 
	(select cmp_name from company where  cmp_id = stops.cmp_id) as ciudad,
	--(select cty_nmstct from company where  cmp_id = stops.cmp_id) as ciudad,
	--stp_ord_mileage as kms,
	(select e.evt_tractor from event e where e.stp_number = stops.stp_number) as kms,
	--stp_ord_toll_cost as costocasetas,
		(select mpp_lastfirst from manpowerprofile where mpp_id = (select e.evt_driver1 from event e where e.stp_number = stops.stp_number)) as costocasetas,--traerme el nombre

	--(select 
	--(select trc_axles from tractorprofile where trc_number = evt_tractor) +
	--(select trl_axles from trailerprofile where trl_number = evt_trailer1)+
	--(select trl_axles from trailerprofile where trl_number =evt_trailer2)+
 --   ISnull((select trl_axles from trailerprofile where trl_number =evt_dolly),1)
	--	from event e where e.stp_number = stops.stp_number ) as ejes
		(select e.evt_trailer1 from event e where e.stp_number = stops.stp_number) as ejes
	,(select nts.not_Text from notes nts where  nts.nre_tablekey =  @ord_header and nts.not_Text   like  Convert(varchar(100), stops.stp_number) + '%' ) as nota 
	
	,(select max([Valor]) from [dbo].[Sl_Pilgrims_TipoVehiculo] tv where tv.ejes = (select 
	(select trc_axles from tractorprofile where trc_number = evt_tractor) +
	(select trl_axles from trailerprofile where trl_number = evt_trailer1)+
	(select trl_axles from trailerprofile where trl_number =evt_trailer2)+
	ISnull((select trl_axles from trailerprofile where trl_number =evt_dolly),1)
		from event e where e.stp_number = stops.stp_number )) as tipoVehiculo,
			(select cmp_latseconds/3600 from company where  cmp_id = stops.cmp_id) as lat,
		(select (cmp_longseconds/3600)*-1 from company where  cmp_id = stops.cmp_id) as long,
	(select cmp_name from company where  cmp_id = stops.cmp_id) as compania,	
		(select e.evt_tractor from event e where e.stp_number = stops.stp_number) as trc_number,
	(select e.evt_trailer1 from event e where e.stp_number = stops.stp_number) as evt_trailer1,
		(select e.evt_driver1 from event e where e.stp_number = stops.stp_number) as evt_driver1,
		(select mpp_lastfirst from manpowerprofile where mpp_id = (select e.evt_driver1 from event e where e.stp_number = stops.stp_number)) as evt_drivername--traerme el nombre



from stops 
where lgh_number in (select lgh_number from legheader where ord_hdrnumber = @ord_header )
order by stp_sequence asc

--select 
--	stp_event,
--	--(select e.evt_tractor from event e where e.stp_number = stops.stp_number) as trc_number,
--	--(select e.evt_trailer1 from event e where e.stp_number = stops.stp_number) as evt_trailer1,
--	--	(select e.evt_driver1 from event e where e.stp_number = stops.stp_number) as evt_driver1,
--		--(select e.evt_driver1 from event e where e.stp_number = stops.stp_number) as evt_driver1,--traerme el nombre
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
--    ISnull((select trl_axles from trailerprofile where trl_number =evt_dolly),1)
--		from event e where e.stp_number = stops.stp_number ) as ejes
		
--	,(select nts.not_Text from notes nts where  nts.nre_tablekey =  @ord_header and nts.not_Text   like  Convert(varchar(100), stops.stp_number) + '%' ) as nota 
	
--	,(select max([Valor]) from [dbo].[Sl_Pilgrims_TipoVehiculo] tv where tv.ejes = (select 
--	(select trc_axles from tractorprofile where trc_number = evt_tractor) +
--	(select trl_axles from trailerprofile where trl_number = evt_trailer1)+
--	(select trl_axles from trailerprofile where trl_number =evt_trailer2)+
--	ISnull((select trl_axles from trailerprofile where trl_number =evt_dolly),1)
--		from event e where e.stp_number = stops.stp_number )) as tipoVehiculo,
--			(select cmp_latseconds/3600 from company where  cmp_id = stops.cmp_id) as lat,
--		(select (cmp_longseconds/3600)*-1 from company where  cmp_id = stops.cmp_id) as long,
--	(select e.evt_tractor from event e where e.stp_number = stops.stp_number) as trc_number,
--	(select e.evt_trailer1 from event e where e.stp_number = stops.stp_number) as evt_trailer1,
--		(select e.evt_driver1 from event e where e.stp_number = stops.stp_number) as evt_driver1
--		--(select e.evt_driver1 from event e where e.stp_number = stops.stp_number) as evt_driver1,--traerme el nombre

		
--from stops (nolock)
--where lgh_number in (select lgh_number from legheader where ord_hdrnumber = @ord_header )
--order by stp_sequence asc
END

END


GO
