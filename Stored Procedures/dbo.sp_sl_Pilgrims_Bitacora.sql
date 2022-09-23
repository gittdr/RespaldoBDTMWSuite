SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_sl_Pilgrims_Bitacora] (@lgh_number int, @ConjuntoDatos varchar(50) )
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
IF(@ConjuntoDatos = 'leg') 
BEGIN
select

--encabezado
leg.lgh_number, ---<--- sera el numero de bitacora
leg.ord_hdrnumber,
leg.ord_hdrnumber as Orden,
(select mpp_firstname + ' ' + mpp_lastname from manpowerprofile (nolock) where mpp_id = rt.[Operador]) as Operador,
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

 CASE 
  WHEN bt.[valeplastico1] is null THEN rt.[ValePlastico]
  else bt.[valeplastico1] end as valeplastico1,
 CASE  
  WHEN bt.[fleje1] is null THEN rt.[FlejePlastico]
  else bt.[fleje1] end as fleje1,
CASE 
  WHEN bt.[valeplastico2] is null THEN rt.[ValePlastico2]
  else bt.[valeplastico2] 
  end as valeplastico2,
CASE 
  WHEN bt.[fleje2]  is null THEN rt.[FlejePlastico2]
  else bt.[fleje2] end as fleje2,

--remolque1
 '' as tipoproducto,
 CASE 
  WHEN bt.[flejeSagarpa1] is null THEN rt.[Sellos]
  else bt.[flejeSagarpa1] end as flejesagarpa,
rt.[clientes] as noremisiones1,
rt.[Cajas] as cajasplastico,
rt.[CargaTon] as kgtransportados,
 bt.[InicialLT1] as horasthermo1,
 bt.[FinalHT1] as horasthermofinal,
 bt.[TrabajadasHT1] as horasthermotrab,
 bt.[InicialLT1] as ltcombusinicial,
 bt.[FinalLT1] as ltcombusfinal,
 bt.[ConsumoLT1] as ltcombusconsumo,
 bt.[Rendimiento1] as rendimiento,
 bt.[ProgramadaTemp1] as tempro,
 bt.[SalidaPlanta1] as tempplanta,
 bt.[Ruta1] as tempruta,
 bt.[Cliente1] as tempcliente,
--remolque 2
 '' as tipoproducto2,
 CASE 
  WHEN bt.[flejeSagarpa2] is null THEN rt.[Sellos2]
  else  bt.[flejeSagarpa2]  end as flejesagarpa2,


rt.[Remisiones2] as noremisiones2,
rt.[Cajas2] as cajasplastico2,
rt.[CargaTon2] as kgtransportados2,
bt.[InicialHT2] as horasthermo2,
bt.[FinalHT2] as horasthermofinal2,
bt.[TrabajadasHT2] as horasthermotrab2,
bt.[InicialLT2] as ltcombusinicial2,
bt.[FinalLT2] as ltcombusfinal2,
bt.[ConsumoLT2] as ltcombusconsumo2,
bt.[Rendimiento2] as rendimiento2,
bt.[ProgramadaTemp2] as tempro2,
bt.[SalidaPlanta2] as tempplanta2,
bt.[Ruta2] as tempruta2,
bt.[Cliente2] as tempclient2,
bt.[Observaciones] as observaciones,

rt.[FacturaDetalle] as FacturaDetalle,
rt.[PesoDetalle] as PesoDetalle,
rt.[CajasDetalle] as CajasDetalle,
rt.[ClienteDescripcion] as ClienteDescripcion,

rt.[FacturaDetalle2] as FacturaDetalle2,
rt.[PesoDetalle2] as PesoDetalle2,
rt.[CajasDetalle2] as CajasDetalle2,
rt.[ClienteDescripcion2] as ClienteDescripcion2,
leg.cmp_id_start +'-'+ cast(rt.[idBitacora] as varchar(1000)) as idBitacoraOrigen,
rt.[Ruta]

from legheader  leg

    left join orderheader ord on leg.ord_hdrnumber = ord.ord_hdrnumber
	inner join company scmp ON scmp.cmp_id = leg.cmp_id_start 
	inner join city scty on scty.cty_code = scmp.cmp_city
	inner join company ccmp ON ccmp.cmp_id = leg.cmp_id_end
	inner join city ccty on ccty.cty_code = ccmp.cmp_city
	left outer join Sl_Pilgrims_Bitacora_Lgh_Number bt on bt.[lgh_number] = leg.[lgh_number]
	left outer join [dbo].[Sl_Pilgrims_Rutas] rt on rt.[ruta] = ord.ord_refnum

	where leg.lgh_number = @lgh_number  --'679069'  --'691155' 
END

IF(@ConjuntoDatos = 'stops') 
BEGIN
 select ciudad, stp_arrivaldate,stp_arrivaldate as arrivaldate,stp_departuredate from Vista_bitacora_stops_Pilgrims vp
where lgh_number in (select lgh_number from legheader (nolock)
where legheader.lgh_number =@lgh_number)
order by stp_arrivaldate ASC
END

IF(@ConjuntoDatos = 'legPrint')
BEGIN
	SELECT leg.lgh_outstatus  from legheader  leg
		WHERE  leg.lgh_number =  @lgh_number
END
END

GO
