SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor: Emilio Olvera Yanez
Fecha: 26/08/2014
Version 1:00

Parametros: Fecha inicial y Fecha final en la que empezaron las ordenes
Descripción: SP que arroja los datos requeridos para generar la caratula de Liverpool
en base a las ordenes que ya estan en printed o en XFR, se pasan como parametros
las fecha de inicio y fin de la orden

Ejemplo 
exec sp_caratliver '2015-02-03', '2015-02-04', 'TODOS'

exec sp_caratliver '2015-02-03', '2015-02-04', 'NOFACT'

  (select sum(ivd_charge) from invoicedetail u where  u.ord_hdrnumber = '285191' and cht_itemcode = 'CAS')


isnull


*/

CREATE proc [dbo].[sp_caratliver]
 @fechaini datetime,
 @fechafin datetime,
 @status varchar(90)
 

as

BEGIN


--OPCION DESDE EL PUNTO DE VISTA DE STOPS---------------------------------------------------------------------------------------------------

-- Modificado por Manuel Guillen
-- 21-08-2014
-- OPCION DEL LENGUAGE PARA LAS FECHAS

SET LANGUAGE Spanish;

IF @status <> 'TODOS'



  BEGIN

	SELECT
	Numero = ''
	,Fecha =  (SELECT RIGHT('0' + DATENAME(DAY, stp_arrivaldate), 2) + ' ' + DATENAME(MONTH, stp_arrivaldate)+ ' ' + DATENAME(YEAR, stp_arrivaldate) AS [DD Month YYYY])
	,Unidad = ( select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number)
	,Operador = isnull((select mpp_firstname+' '+ mpp_lastname from manpowerprofile where mpp_id =(select lgh_driver1 from legheader where legheader.lgh_number = stops.lgh_number)),'N/A') 
	,[No Ruta] = ''
	--,Ruta = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)) + '-' + stops.cmp_id
	,Ruta = isnull((select cmp_altid from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_mfh_sequence  = (stops.stp_mfh_sequence  - 1) and (a.mov_number = stops.mov_number))),(select cmp_id from stops a with (nolock) where a.stp_mfh_sequence  = (stops.stp_mfh_sequence  - 1) and (a.mov_number = stops.mov_number))) + '-' + isnull((select cmp_altid from company where company.cmp_id = stops.cmp_id),stops.cmp_id)

	--,Ruta = isnull((select cmp_name from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))),(select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))) + '-' + isnull((select cmp_name from company where company.cmp_id = stops.cmp_id),stops.cmp_id)
	,Remolque1 = replace(trl_id,'UNKNOWN','**')
	,Remolque2 = replace( (select evt_trailer2 from event where event.stp_number = stops.stp_number),'UNKNOWN','**')


	,[Cargado/Vacio] = case when trl_id = 'UNKNOWN' and  (select evt_trailer2 from event where event.stp_number = stops.stp_number) = 'UNKNOWN' 
	                   then 'Tracto'
					   else
	                   replace(replace(stp_loadstatus,'MT','Vacio'),'LD','Cargado')
					   end
	,[Tipo de Viaje] = case when trl_id = 'UNKNOWN' and  (select evt_trailer2 from event where event.stp_number = stops.stp_number) = 'UNKNOWN' 
	                   then 'Tracto'
					   when trl_id <> 'UNKNOWN' and  (select evt_trailer2 from event where event.stp_number = stops.stp_number) <> 'UNKNOWN' 
	                   then 'Full'
					   when trl_id <> 'UNKNOWN' and  (select evt_trailer2 from event where event.stp_number = stops.stp_number) = 'UNKNOWN' 
	                   then 'Sencillo'
					   end

	,[Orden/Mov] = case ord_hdrnumber when 0 then (select top(1)ord_hdrnumber from stops t where t.mov_number = stops.mov_number and ord_hdrnumber <> 0)
					else ord_hdrnumber end
    ,[No. de Transporte] =case ord_hdrnumber when 0 then (select ord_refnum from orderheader o where o.ord_hdrnumber = (select top(1)ord_hdrnumber from stops t where t.mov_number = stops.mov_number and ord_hdrnumber <> 0))
					else (select ord_refnum from orderheader o where o.ord_hdrnumber = stops.ord_hdrnumber) end

	,Observaciones = ''
	


	,Bodegas = case when (select max(cmp_id) from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)) = 'CDTLIVTL'
					then (select sum(ivd_charge) from invoicedetail u where  u.ord_hdrnumber = stops.ord_hdrnumber and cht_itemcode = 'CAS')
					else '-'
					end

	,Almacenadora = case when (select max(cmp_id) from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)) = 'LIVHUEHUE'
					then (select sum(ivd_charge) from invoicedetail u where  u.ord_hdrnumber = stops.ord_hdrnumber and cht_itemcode = 'CAS')
					else '-'
					end
				
					
	,KMS = isnull(stp_lgh_mileage,0)
	,status = isnull((select ivh_invoicestatus from invoiceheader where invoiceheader.ord_hdrnumber =  stops.ord_hdrnumber and ivh_hdrnumber in (select max(ivh_hdrnumber) from invoiceheader where invoiceheader.ord_hdrnumber =  stops.ord_hdrnumber)), 'NOFACT')
	

	 from stops

	where lgh_number in (select lgh_number from legheader  where ord_hdrnumber in  (select ord_hdrnumber from orderheader where ord_billto IN ('ALMLIVER','LIVERTIJ','LIVERPOL') and ord_revtype4 = 'DED'))
	--stops.ord_hdrnumber in (select ord_hdrnumber  from orderheader where ord_billto IN ('ALMLIVER','LIVERTIJ','LIVERPOL') and ord_revtype4 = 'DED')
	and  stp_arrivaldate  between  @fechaini and @fechafin
	--and ord_hdrnumber <> '0'

	and isnull((select ivh_invoicestatus from invoiceheader where invoiceheader.mov_number =  stops.mov_number and ivh_hdrnumber 
	in (select max(ivh_hdrnumber) from invoiceheader where invoiceheader.mov_number =  stops.mov_number)), 'NOFACT') in (@status)
	and (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_mfh_sequence = (stops.stp_mfh_sequence - 1) and (a.mov_number = stops.mov_number))) is not null
	--and (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))) is not null
	


  END



ELSE


BEGIN
	SELECT
	Numero = ''
	,Fecha =  (SELECT RIGHT('0' + DATENAME(DAY, stp_arrivaldate), 2) + ' ' + DATENAME(MONTH, stp_arrivaldate)+ ' ' + DATENAME(YEAR, stp_arrivaldate) AS [DD Month YYYY])
	,Unidad = ( select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number)
	,Operador = isnull((select mpp_firstname+' '+ mpp_lastname from manpowerprofile where mpp_id =(select lgh_driver1 from legheader where legheader.lgh_number = stops.lgh_number)),'N/A') 
	,[No Ruta] = ''
	,Ruta = isnull((select cmp_altid from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_mfh_sequence  = (stops.stp_mfh_sequence  - 1) and (a.mov_number = stops.mov_number))),(select cmp_id from stops a with (nolock) where a.stp_mfh_sequence  = (stops.stp_mfh_sequence  - 1) and (a.mov_number = stops.mov_number))) + '-' + isnull((select cmp_altid from company where company.cmp_id = stops.cmp_id),stops.cmp_id)
	,Remolque1 = replace(trl_id,'UNKNOWN','**')
	,Remolque2 = replace( (select evt_trailer2 from event where event.stp_number = stops.stp_number),'UNKNOWN','**')

	,[Cargado/Vacio] = case when trl_id = 'UNKNOWN' and  (select evt_trailer2 from event where event.stp_number = stops.stp_number) = 'UNKNOWN' 
	                   then 'Tracto'
					   else
	                   replace(replace(stp_loadstatus,'MT','Vacio'),'LD','Cargado')
					   end
	,[Tipo de Viaje] = case when trl_id = 'UNKNOWN' and  (select evt_trailer2 from event where event.stp_number = stops.stp_number) = 'UNKNOWN' 
	                   then 'Tracto'
					   when trl_id <> 'UNKNOWN' and  (select evt_trailer2 from event where event.stp_number = stops.stp_number) <> 'UNKNOWN' 
	                   then 'Full'
					   when trl_id <> 'UNKNOWN' and  (select evt_trailer2 from event where event.stp_number = stops.stp_number) = 'UNKNOWN' 
	                   then 'Sencillo'
					   end

	,[Orden/Mov] =case ord_hdrnumber when 0 then (select top(1)ord_hdrnumber from stops t where t.mov_number = stops.mov_number and ord_hdrnumber <> 0)
					else ord_hdrnumber end

	,[No. de Transporte] =case ord_hdrnumber when 0 then (select ord_refnum from orderheader o where o.ord_hdrnumber = (select top(1)ord_hdrnumber from stops t where t.mov_number = stops.mov_number and ord_hdrnumber <> 0))
					else (select ord_refnum from orderheader o where o.ord_hdrnumber = stops.ord_hdrnumber) end
	
	,Observaciones = ''

	
	,Bodegas = case when (select max(cmp_id) from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)) = 'CDTLIVTL'
					then (select sum(ivd_charge) from invoicedetail u where  u.ord_hdrnumber = stops.ord_hdrnumber and cht_itemcode = 'CAS')
					else '-'
					end

	,Almacenadora = case when (select max(cmp_id) from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)) = 'LIVHUEHUE'
					then (select sum(ivd_charge) from invoicedetail u where  u.ord_hdrnumber = stops.ord_hdrnumber and cht_itemcode = 'CAS')
					else '-'
					end

					
	,KMS = isnull(stp_lgh_mileage,0)
	,status = isnull((select ivh_invoicestatus from invoiceheader where invoiceheader.ord_hdrnumber =  stops.ord_hdrnumber and ivh_hdrnumber in (select max(ivh_hdrnumber) from invoiceheader where invoiceheader.ord_hdrnumber =  stops.ord_hdrnumber)), 'NOFACT')
	from stops
	where lgh_number in (select lgh_number from legheader  where ord_hdrnumber in  (select ord_hdrnumber from orderheader where ord_billto IN ('ALMLIVER','LIVERTIJ','LIVERPOL') and ord_revtype4 = 'DED'))
	--stops.ord_hdrnumber in (select ord_hdrnumber  from orderheader where ord_billto IN ('ALMLIVER','LIVERTIJ','LIVERPOL') and ord_revtype4 = 'DED')
	and  stp_arrivaldate  between  @fechaini and @fechafin
	--and ord_hdrnumber <> '0'
	and (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_mfh_sequence = (stops.stp_mfh_sequence - 1) and (a.mov_number = stops.mov_number))) is not null
	--and (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))) is not null

END



SET LANGUAGE us_english;

END
GO
