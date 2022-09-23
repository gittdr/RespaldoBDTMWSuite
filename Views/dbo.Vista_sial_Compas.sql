SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view  [dbo].[Vista_sial_Compas]
as
select --oh.ord_hdrnumber,
	ord_refnum as 'FolioViaje',
	'003188' as 'CodigoProv',
	'TDR' as 'Proveedor',
	'' as 'DepotCode',
	'' as 'CodigoEventoViaje',
	'' as 'NoConsecutivoCont',
	(select stp.stp_sequence from stops stp where stp.stp_number = (select top 1 stp.stp_number from stops stp where oh.ord_hdrnumber = stp.ord_hdrnumber and stp.stp_status = 'OPN'))  as 'IdPuntoEvento', -- ' *traernos el numero de stop activo*'
	(select stp.stp_event from stops stp where stp.stp_number = (select top 1 stp.stp_number from stops stp where oh.ord_hdrnumber = stp.ord_hdrnumber and stp.stp_status = 'OPN')) as 'PuntoControl',--'*nombre del tipo de evento*' 
	'' as 'AETC',
	 ord_trailer as 'NoContenedor',
	'*referencia carta porte*' as 'CartaPorte',
	(select stp.stp_arrivaldate from stops stp where stp.stp_number = (select top 1 stp.stp_number from stops stp where lg.lgh_number = stp.lgh_number and stp.stp_status = 'OPN')) as 'FechaHoraInicioReal',-- '*inicio de stop actual*'
	(select stp.stp_departuredate from stops stp where stp.stp_number = (select top 1 stp.stp_number from stops stp where lg.lgh_number = stp.lgh_number and stp.stp_status = 'OPN')) as 'FechaHoraFinReal',-- '*fin de stop actual*'
	(select ckc_date from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)) as 'FechaHoraUltReporte',--'*Ultima fecha pocision gps*'
	 CAST( CAST((select ckc_latseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00 as dec(16,4)) AS VARCHAR) +','+
		CAST(	cast(((select ckc_longseconds from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor))/3600.00)*-1 as dec(16,4)) AS VARCHAR) + ' | ' +
			(select ckc_comment from checkcall where ckc_number =( select max(ckc_number) from checkcall where ckc_tractor = lg.lgh_tractor)) as 'UltUbicacion',--'descripcion ubicacion'
	(select mpp.mpp_lastfirst from manpowerprofile mpp where mpp.mpp_id = lg.lgh_driver1) as 'Operador',
	(select TP.trc_licnum from tractorprofile TP where TP.trc_number = lg.lgh_tractor and trc_status <> 'out' ) as 'PlacasTractor', --'*Placas Tractor*'
	(select trl_licnum from trailerprofile where trl_number = lg.lgh_primary_trailer and trl_status <> 'out') as 'PlacasContenedor',
	oh.ord_dest_earliestdate as 'ETA'

from orderheader oh
inner join legheader lg on oh.ord_hdrnumber = lg.ord_hdrnumber
where oh.ord_status = 'cmp'   
and oh.ord_billto = 'nissan'
and oh.ord_bookdate > '2020-03-01'
--and lgh_outstatus <> ('CMP')
GO
