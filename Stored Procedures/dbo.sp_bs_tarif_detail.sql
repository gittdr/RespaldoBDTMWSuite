SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[sp_bs_tarif_detail] (@Cliente varchar(100), @modo varchar(10))

as

if (@cliente <> 'ALL')

	begin 
	if (@modo = 'all')
	begin

	select *,
	(select ord_revtype4 from orderheader (nolock) where ord_hdrnumber = orden) as Division,
	Errordesc as Tarifa
	from tts_bs_tarif_detail
	where Cliente = @Cliente

	end

	if (@modo = 'norate')
	begin
	select *,
		(select ord_revtype4 from orderheader (nolock) where ord_hdrnumber = orden) as Division,
		Errordesc as Tarifa
		from tts_bs_tarif_detail
		where Cliente = @Cliente
		and Errordesc = 'No Rate Found'

	end

	if (@modo = 'workc')
	begin
	select *,
		(select ord_revtype4 from orderheader (nolock) where ord_hdrnumber = orden) as Division,
		Errordesc as Tarifa
		from tts_bs_tarif_detail
		where Cliente = @Cliente
		and error = 'N'

	end

	if (@modo = 'orden')
	begin
	select *,
		(select ord_revtype4 from orderheader (nolock) where ord_hdrnumber = orden) as Division,
		Errordesc as Tarifa
		from tts_bs_tarif_detail
		where Cliente = @Cliente
		and Errordesc not in ('No Rate Found','Por Procesar')


	end

end




if (@cliente = 'ALL')

	begin 
	if (@modo = 'all')
	begin

	select *,
	(select ord_revtype4 from orderheader (nolock) where ord_hdrnumber = orden) as Division,
	Errordesc as Tarifa
	from tts_bs_tarif_detail


	end

	if (@modo = 'norate')
	begin
	select *,
		(select ord_revtype4 from orderheader (nolock) where ord_hdrnumber = orden) as Division,
		Errordesc as Tarifa
		from tts_bs_tarif_detail
		where Errordesc = 'No Rate Found'

	end

	if (@modo = 'workc')
	begin
	select *,
		(select ord_revtype4 from orderheader (nolock) where ord_hdrnumber = orden) as Division,
		Errordesc as Tarifa
		from tts_bs_tarif_detail
		where  error = 'N'

	end

	if (@modo = 'orden')
	begin
	select *,
		(select ord_revtype4 from orderheader (nolock) where ord_hdrnumber = orden) as Division,
		Errordesc as Tarifa
		from tts_bs_tarif_detail
		where Errordesc not in ('No Rate Found','Por Procesar')


	end

end
GO
