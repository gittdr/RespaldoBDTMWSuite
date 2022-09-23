SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
Autor: Manuel Guillen Becerril
Fecha: 05/12/2014
Version 1:00

Parametros: Fecha inicial y Fecha final en la que empezaron las ordenes
Descripción: SP que arroja los datos requeridos para generar la caratula de Liverpool abierto
en base a las ordenes que ya estan en printed o en XFR, se pasan como parametros
las fecha de inicio y fin de la orden

Ejemplo 
exec sp_caratliverabierto '2015-01-18', '2015-01-26', 'TODOS'

*/

CREATE proc [dbo].[sp_caratliverabierto]
 @fechaini datetime,
 @fechafin datetime,
 @status varchar(90)
 

as

BEGIN


--OPCION DESDE EL PUNTO DE VISTA DE STOPS---------------------------------------------------------------------------------------------------

SET LANGUAGE Spanish;

IF @status <> 'TODOS'

  BEGIN

	SELECT
	Numero = ''
	,Fecha =  (SELECT RIGHT('0' + DATENAME(DAY, stp_arrivaldate), 2) + ' ' + DATENAME(MONTH, stp_arrivaldate)+ ' ' + DATENAME(YEAR, stp_arrivaldate) AS [DD Month YYYY])
	--,Fecha =  (SELECT RIGHT('0' + DATENAME(DAY, stp_departuredate), 2) + ' ' + DATENAME(MONTH, stp_departuredate)+ ' ' + DATENAME(YEAR, stp_departuredate) AS [DD Month YYYY])
	,Ida = (select ord_refnum from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber)
	,Regreso = ''
	,Origen =   (select cty_nmstct from city nolock  where cty_code =  (select stp_city from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)))
	,Destino = (select cty_nmstct from company where company.cmp_id  = stops.cmp_id)
	,Remolque = replace((select lgh_primary_trailer + '-' + lgh_primary_pup from legheader where legheader.lgh_number = stops.lgh_number),'-UNKNOWN','')		
	,[Tipo de Viaje] = case when trl_id = 'UNKNOWN' and  (select evt_trailer2 from event where event.stp_number = stops.stp_number) = 'UNKNOWN' 
	                   then 'Tracto'
					   when trl_id <> 'UNKNOWN' and  (select evt_trailer2 from event where event.stp_number = stops.stp_number) <> 'UNKNOWN' 
	                   then 'Full'
					   when trl_id <> 'UNKNOWN' and  (select evt_trailer2 from event where event.stp_number = stops.stp_number) = 'UNKNOWN' 
	                   then 'Sencillo'
					   end
	,Ida2 =  (select ord_rate from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber)
	,Regreso2 = ''
	,REMTDR = stops.ord_hdrnumber
	 from stops

	where lgh_number in (select lgh_number from legheader  where ord_hdrnumber in  (select ord_hdrnumber from orderheader where ord_billto IN ('ALMLIVER','LIVERTIJ','LIVERPOL') and ord_revtype3 in ('BAJ','FULS')))
	and  stp_arrivaldate  between  @fechaini and @fechafin
	--and  stp_departuredate  between  @fechaini and @fechafin


	and isnull((select ivh_invoicestatus from invoiceheader where invoiceheader.mov_number =  stops.mov_number and ivh_hdrnumber 
	in (select max(ivh_hdrnumber) from invoiceheader where invoiceheader.mov_number =  stops.mov_number)), 'NOFACT') in (@status)
	and (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_mfh_sequence = (stops.stp_mfh_sequence - 1) and (a.mov_number = stops.mov_number))) is not null
	

		AND stops.ord_hdrnumber <> 0
	AND (select stp_city from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)) IS NOT NULL
	order by stops.ord_hdrnumber

	


  END



ELSE


BEGIN
	SELECT
	Numero = ''
	,Fecha =  (SELECT RIGHT('0' + DATENAME(DAY, stp_arrivaldate), 2) + ' ' + DATENAME(MONTH, stp_arrivaldate)+ ' ' + DATENAME(YEAR, stp_arrivaldate) AS [DD Month YYYY])
	--,Fecha =  (SELECT RIGHT('0' + DATENAME(DAY, stp_departuredate), 2) + ' ' + DATENAME(MONTH, stp_departuredate)+ ' ' + DATENAME(YEAR, stp_departuredate) AS [DD Month YYYY])
	,Ida = (select ord_refnum from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber)
	,Regreso = ''
	
	,Origen =   (select cty_nmstct from city nolock  where cty_code =  (select stp_city from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)))
	,Destino = (select cty_nmstct from company where company.cmp_id  = stops.cmp_id)
	,Remolque = replace((select lgh_primary_trailer + '-' + lgh_primary_pup from legheader where legheader.lgh_number = stops.lgh_number),'-UNKNOWN','')	
	,[Tipo de Viaje] = case when trl_id = 'UNKNOWN' and  (select evt_trailer2 from event where event.stp_number = stops.stp_number) = 'UNKNOWN' 
	                   then 'Tracto'
					   when trl_id <> 'UNKNOWN' and  (select evt_trailer2 from event where event.stp_number = stops.stp_number) <> 'UNKNOWN' 
	                   then 'Full'
					   when trl_id <> 'UNKNOWN' and  (select evt_trailer2 from event where event.stp_number = stops.stp_number) = 'UNKNOWN' 
	                   then 'Sencillo'
					   end
	,Ida2 =  (select ord_rate from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber)
	,Regreso2 = ''
	,REMTDR = stops.ord_hdrnumber
	from stops
	where lgh_number in (select lgh_number from legheader  where ord_hdrnumber in  (select ord_hdrnumber from orderheader where ord_billto IN ('ALMLIVER','LIVERTIJ','LIVERPOL') and ord_revtype3 in ('BAJ','FULS')))
	and  stp_arrivaldate  between  @fechaini and @fechafin
	--and  stp_departuredate  between  @fechaini and @fechafin
	and (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_mfh_sequence = (stops.stp_mfh_sequence - 1) and (a.mov_number = stops.mov_number))) is not null
	
	AND stops.ord_hdrnumber <> 0
	AND (select stp_city from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)) IS NOT NULL
	order by stops.ord_hdrnumber

END



SET LANGUAGE us_english;

END
GO
