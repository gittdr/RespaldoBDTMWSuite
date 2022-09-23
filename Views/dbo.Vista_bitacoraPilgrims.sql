SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [dbo].[Vista_bitacoraPilgrims] 
as

select

--encabezado
leg.lgh_number, ---<--- sera el numero de bitacora
leg.ord_hdrnumber,
leg.ord_hdrnumber as Orden,
(select mpp_firstname + ' ' + mpp_lastname from manpowerprofile (nolock) where mpp_id = lgh_driver1) Operador,
ord.ord_bookdate hrasig,
leg.lgh_schdtlatest as hrsalida,
leg.lgh_tractor  as Tractor,
replace((select car_name from carrier where car_id = leg.lgh_carrier),'UNKNOWN','TDR TRANSPORTES S.A. DE C.V.') as Carrier,
lgh_primary_trailer  as Trl1,
lgh_primary_pup as Trl2,
lgh_dolly as Dolly,
ord.ord_number,
leg.cmp_id_start  as ord_shipper,
scmp.cmp_name 'Shipper Name',
scmp.cmp_address1 'Shipper Add1',
scty.cty_name 'Shipper City',
scty.cty_state 'Shipper St',
scmp.cmp_zip 'Shipper Zip',
scty.cty_name + ', ' + scty.cty_state + ' ' + IsNull(scmp.cmp_zip,'') 'ShCityStZip',
leg.cmp_id_end as ord_consignee,
ccmp.cmp_name 'Consignee Name',
ccmp.cmp_address1 'Consignee Add1' ,
ccty.cty_name 'Consignee City',
ccty.cty_state 'Consignee St',
ccmp.cmp_zip 'Consignee Zip',
ccty.cty_name + ', ' + ccty.cty_state + ' ' + IsNull(ccmp.cmp_zip,'') 'CoCityStZip',
(select stp_comment from stops where stp_number = 
(select top 1 stp_number from stops where ord_hdrnumber = ord.ord_hdrnumber and cmp_id = ord.ord_consignee and stp_type = 'DRP'
 order by stp_mfh_sequence desc)) 'del_instruc',
ord.ord_remark as Comentarios,

 --Datos que deberemos de contener en tabla propia

 '' as valeplastico1,
 '' as fleje1,
 '' as valeplastico2,
 '' as fleje2,

--remolque1
 '' as tipoproducto,
 '' as flejesagarpa,
 '' as noremisiones1,
 '' as cajasplastico,
 '' as kgtransportados,
 '' as horasthermo1,
 '' as horasthermofinal,
 '' as horasthermotrab,
 '' as ltcombusinicial,
 '' as ltcombusfinal,
 '' as ltcombusconsumo,
 '' as rendimiento,
 '' as tempro,
 '' as tempplanta,
 '' as tempruta,
 '' as tempcliente,
--remolque 2
 '' as tipoproducto2,
 '' as flejesagarpa2,
 '' as noremisiones2,
 '' as cajasplastico2,
 '' as kgtransportados2,
 '' as horasthermo2,
 '' as horasthermofinal2,
 '' as horasthermotrab2,
 '' as ltcombusinicial2,
 '' as ltcombusfinal2,
 '' as ltcombusconsumo2,
 '' as rendimiento2,
  '' as tempro2,
 '' as tempplanta2,
 '' as tempruta2,
 '' as tempclient2

from legheader  leg

    left join orderheader ord on leg.ord_hdrnumber = ord.ord_hdrnumber
	inner join company scmp ON scmp.cmp_id = leg.cmp_id_start 
	inner join city scty on scty.cty_code = scmp.cmp_city
	inner join company ccmp ON ccmp.cmp_id = leg.cmp_id_end
	inner join city ccty on ccty.cty_code = ccmp.cmp_city


GO
