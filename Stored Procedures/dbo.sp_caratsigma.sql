SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor: Emilio Olvera Yanez
Fecha: 09/06/2014
Version 1:00

Parametros: Fecha inicial y Fecha final en la que empezaron las ordenes
Descripción: SP que arroja los datos requeridos para generar la caratula de Sigma
en base a las ordenes que ya estan en printed o en XFR, se pasan como parametros
las fecha de inicio y fin de la orden

Ejemplo 
exec sp_caratsigma '2014-07-01', '2014-07-31', 'TODOS'
  (select sum(ivd_charge) from invoicedetail u where  u.ord_hdrnumber = '285191' and cht_itemcode = 'CAS')


isnull


*/

CREATE proc [dbo].[sp_caratsigma]
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
	Operador = isnull((select mpp_firstname+' '+ mpp_lastname from manpowerprofile where mpp_id =(select lgh_driver1 from legheader where legheader.lgh_number = stops.lgh_number)),'N/A') 
	
	,Fecha =  (SELECT RIGHT('0' + DATENAME(DAY, stp_arrivaldate), 2) + ' ' + DATENAME(MONTH, stp_arrivaldate)+ ' ' + DATENAME(YEAR, stp_arrivaldate) AS [DD Month YYYY]) --stp_arrivaldate
	
	,Tractor = ( select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number)
	--,Viaje = case  when stp_event in ('TRP','IEMT') then '' else 'P.T.' end
	--,Origen =  (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)))
	--,Destino = (select cty_nmstct from company where company.cmp_id  = stops.cmp_id)
	,Origen =  (select cmp_name from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)))
	,Destino = (select cmp_name from company where company.cmp_id  = stops.cmp_id)
	,TipoCasetas= 

	STUFF((select distinct  '; ' + replace(replace(pyt_itemcode,'CASEFE','EFECTIVO'),'CASIAV','IAVE') from [tollbooth]
	where tb_ident in
	(select  tb_ident from [tollroute_booth_mapping]
	where tr_ident in
	(select tr_ident from [toll_route] where tr_origin_city= (select stp_city from  stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1)
	 and (a.ord_hdrnumber = stops.ord_hdrnumber)) and tr_dest_city =stops.stp_city))FOR XML PATH('') ), 1, 1, '')

	,Casetas = 
			(select [dbo].[fnc_TollsBetweenCityCodes] 
				(
				(select cmp_city from company where company.cmp_id =
					(select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)
					)
				),
				(select cmp_city from company where company.cmp_id  = stops.cmp_id),
				3
				)
			)

	,Km = isnull(stp_lgh_mileage,0)
	--,Kg = (isnull(stp_count,isnull(stp_weight,0)*1000))
	,Kg = case stp_count when '0.00' then (isnull(stp_weight,0)*1000)
		  else (isnull(stp_count,0))
		  end
	--replace('0.00',stp_count,isnull(stp_weight,0)*1000)
	,[$9.82] = isnull(stp_lgh_mileage,0) * 9.82
	--,[$0.66] = isnull(stp_lgh_mileage,0)* 0.66
	,[$0.76] = isnull(stp_lgh_mileage,0)* 0.76
	,Themro = trl_id
	,Orden = ord_hdrnumber
	,Folio = (select ord_refnum from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber)
	,status = isnull((select ivh_invoicestatus from invoiceheader where invoiceheader.ord_hdrnumber =  stops.ord_hdrnumber and ivh_hdrnumber in (select max(ivh_hdrnumber) from invoiceheader where invoiceheader.ord_hdrnumber =  stops.ord_hdrnumber)), 'NOFACT')
	--,Referencia = case  when stp_refnum in ('VACIO','CANASTILLAS') then stp_refnum else '' end
	,Referencia = stp_refnum

	
	
	 from stops

	where stops.ord_hdrnumber in (select ord_hdrnumber  from orderheader where ord_billto = 'SIGMAALI'
	 and ord_revtype4 = 'ESP')
	and  stp_arrivaldate  between  @fechaini and @fechafin
	and ord_hdrnumber <> '0'

	and isnull((select ivh_invoicestatus from invoiceheader where invoiceheader.ord_hdrnumber =  stops.ord_hdrnumber and ivh_hdrnumber 
	in (select max(ivh_hdrnumber) from invoiceheader where invoiceheader.ord_hdrnumber =  stops.ord_hdrnumber)), 'NOFACT') in (@status)

	and (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))) is not null

	order by stp_mfh_sequence asc
	
	

  END



ELSE


BEGIN
	select 
	Operador = isnull((select mpp_firstname+' '+ mpp_lastname from manpowerprofile where mpp_id =(select lgh_driver1 from legheader where legheader.lgh_number = stops.lgh_number)),'N/A') 
	,Fecha =  (SELECT RIGHT('0' + DATENAME(DAY, stp_arrivaldate), 2) + ' ' + DATENAME(MONTH, stp_arrivaldate)+ ' ' + DATENAME(YEAR, stp_arrivaldate) AS [DD Month YYYY]) --stp_arrivaldate
	,Tractor = ( select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number)
	--,Viaje = case  when stp_event in ('TRP','IEMT') then '' else 'P.T.' end
	--,Origen =  (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)))
	--,Destino = (select cty_nmstct from company where company.cmp_id  = stops.cmp_id)
	,Origen =  (select cmp_name from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)))
	,Destino = (select cmp_name from company where company.cmp_id  = stops.cmp_id)
	,TipoCasetas= 

	STUFF((select distinct  '; ' + replace(replace(pyt_itemcode,'CASEFE','EFECTIVO'),'CASIAV','IAVE') from [tollbooth]
	where tb_ident in
	(select  tb_ident from [tollroute_booth_mapping]
	where tr_ident in
	(select tr_ident from [toll_route] where tr_origin_city= (select stp_city from  stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1)
	 and (a.ord_hdrnumber = stops.ord_hdrnumber)) and tr_dest_city =stops.stp_city))FOR XML PATH('') ), 1, 1, '')


	,Casetas = 
			(select [dbo].[fnc_TollsBetweenCityCodes] 
				(
				(select cmp_city from company where company.cmp_id =
					(select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)
					)
				),
				(select cmp_city from company where company.cmp_id  = stops.cmp_id),
				3
				)
			)
	 
	
	,Km = isnull(stp_lgh_mileage,0)
	--,Kg = (isnull(stp_count,isnull(stp_weight,0)*1000))
	,Kg = case stp_count when '0.00' then (isnull(stp_weight,0)*1000)
		  else (isnull(stp_count,0))
		  end
	--replace('0.00',stp_count,isnull(stp_weight,0)*1000)
	,[$9.82] = isnull(stp_lgh_mileage,0) * 9.82
	--,[$0.66] = isnull(stp_lgh_mileage,0)* 0.66
	,[$0.76] = isnull(stp_lgh_mileage,0)* 0.76
	,Themro = trl_id
	,Orden = ord_hdrnumber
	,Folio = (select ord_refnum from orderheader where orderheader.ord_hdrnumber =  stops.ord_hdrnumber)
	,Status = isnull((select ivh_invoicestatus from invoiceheader where invoiceheader.ord_hdrnumber =  stops.ord_hdrnumber and ivh_hdrnumber in (select max(ivh_hdrnumber) from invoiceheader where invoiceheader.ord_hdrnumber =  stops.ord_hdrnumber)), 'NOFACT')
	--,Referencia = case  when stp_refnum in ('VACIO','CANASTILLAS') then stp_refnum else '' end
	,Referencia = stp_refnum

	 from stops
	where stops.ord_hdrnumber in (select ord_hdrnumber  from orderheader where ord_billto = 'SIGMAALI'
	 and ord_revtype4 = 'ESP')
	and  stp_arrivaldate  between  @fechaini and @fechafin
	and ord_hdrnumber <> '0'
	and (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))) is not null

	order by stp_mfh_sequence asc

END



SET LANGUAGE us_english;

END
GO
