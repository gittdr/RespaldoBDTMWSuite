SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor: Emilio Olvera Yanez
Fecha: 03-09-2014
Version 1:00

Parametros: Fecha inicial y Fecha final en la que empezaron las ordenes
Descripción: SP que arroja los datos requeridos para generar la caratula de Eucomex
en base a las ordenes que ya estan en printed o en XFR, se pasan como parametros
las fecha de inicio y fin de la orden

Ejemplo 
exec sp_carateuco '2014-07-01', '2014-07-31', 'TODOS'
  (select sum(ivd_charge) from invoicedetail u where  u.ord_hdrnumber = '285191' and cht_itemcode = 'CAS')


isnull


*/

CREATE proc [dbo].[sp_carateuco]
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
	[Orden] = ord_hdrnumber
	--,Fecha =  (SELECT RIGHT('0' + DATENAME(DAY, stp_arrivaldate), 2) + ' ' + DATENAME(MONTH, stp_arrivaldate)+ ' ' + DATENAME(YEAR, stp_arrivaldate) AS [DD Month YYYY])
	,Unidad = ( select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number)

	,Pipa = ''

	,Origen =  (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)))
	,Destino = (select cty_nmstct from company where company.cmp_id  = stops.cmp_id)
	,KMS = isnull(stp_lgh_mileage,0)
	
	,FUELLMEX = ''
	,Casetas = 
	case when stp_number = (select min(stp_number)+1 from stops q where stops.ord_hdrnumber = q.ord_hdrnumber)
     then  	  (select sum(ivd_charge) from invoicedetail u where  u.ord_hdrnumber = stops.ord_hdrnumber and cht_itemcode in ('CAS','TOLL'))
	else 0
     end	
	,Adicional = ''

	 from stops

	where stops.ord_hdrnumber in (select ord_hdrnumber  from orderheader where ord_billto = 'EUCOMEX' and ord_revtype4 in ('INT', 'ESP', 'SEN'))
	and  stp_arrivaldate  between  @fechaini and @fechafin
	and ord_hdrnumber <> '0'

	and isnull((select ivh_invoicestatus from invoiceheader where invoiceheader.ord_hdrnumber =  stops.ord_hdrnumber and ivh_hdrnumber 
	in (select max(ivh_hdrnumber) from invoiceheader where invoiceheader.ord_hdrnumber =  stops.ord_hdrnumber)), 'NOFACT') in (@status)

	and (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))) is not null
	
	

  END



ELSE


BEGIN
	SELECT
	[Orden] = ord_hdrnumber
	--,Fecha =  (SELECT RIGHT('0' + DATENAME(DAY, stp_arrivaldate), 2) + ' ' + DATENAME(MONTH, stp_arrivaldate)+ ' ' + DATENAME(YEAR, stp_arrivaldate) AS [DD Month YYYY])
	,Unidad = ( select lgh_tractor from legheader where legheader.lgh_number = stops.lgh_number)

	,Pipa = ''

	,Origen =  (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber)))
	,Destino = (select cty_nmstct from company where company.cmp_id  = stops.cmp_id)
	,KMS = isnull(stp_lgh_mileage,0)
	
	,FUELLMEX = ''
	,Casetas = 
	case when stp_number = (select min(stp_number)+1 from stops q where stops.ord_hdrnumber = q.ord_hdrnumber)
     then  	  (select sum(ivd_charge) from invoicedetail u where  u.ord_hdrnumber = stops.ord_hdrnumber and cht_itemcode in ('CAS','TOLL'))
	else 0
     end	
	,Adicional = ''
	from stops
	where stops.ord_hdrnumber in (select ord_hdrnumber  from orderheader where ord_billto = 'EUCOMEX' and ord_revtype4 in ('INT', 'ESP', 'SEN'))
	and  stp_arrivaldate  between  @fechaini and @fechafin
	and ord_hdrnumber <> '0'
	and (select cty_nmstct from company where company.cmp_id = (select cmp_id from stops a with (nolock) where a.stp_sequence = (stops.stp_sequence - 1) and (a.ord_hdrnumber = stops.ord_hdrnumber))) is not null

END



SET LANGUAGE us_english;

END


select * from orderheader where ord_billto LIKE '%EUCO%'
GO
