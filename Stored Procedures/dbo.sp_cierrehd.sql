SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/********************************************************************************************************************************************************************************************************
Stored Procedure: sp_Cierre HD
Version 1.0
Fecha 15/04/2014
Creado por: Emilio Olvera

Descripción:
Stored Procedure que genera el reporte de cierre de viajes con Home Depot, recibe como parametro una fecha de inicio y una fecha de fin para obtener el rango de ordenes de viaje completadas durante
ese periodo seleccionado

Sentencia de ejemplo para pruebas:
exec sp_cierrehd '2014-04-01', '2014-04-15'
********************************************************************************************************************************************************************************************************/

CREATE  proc [dbo].[sp_cierrehd]  
(@fi datetime, @ff datetime)


as


--declaración de la tabla virtual----------------------------------------------------------------------------------------------------------------------------------------------------------------------

declare @cierre table 
(
ORDEN  varchar(20),
REFERENCIA  varchar(100),
[FECHA INICIO]  datetime,
[iniciovacio IBMT] varchar(100) ,
[iniciocargado HPL,LLD] varchar(100),
[destino LUL] varchar(100) ,
[termina IEMT,IEBT] varchar(100),
[KMS CARGADOS]  float,
[KMS VACIOS]  float,
[KMS TOTALES] float,
[PEAJE] float,
[PEAJE2] float,
[TOTAL PEAJE] float,
[PROV SAP/TARIFA] float,
[CIUDAD] varchar(200),
[TIPO DE VIAJE] varchar(20) ,
[ESTATUS] varchar(20),
[FACTURA] varchar(20) 
)

--Poblacion de la tabla virtual con los datos de tabla order header-------------------------------------------------------------------------------------------------------------------------------------

insert into @cierre

select 
ORDEN = ord_hdrnumber,
REFERENCIA = isnull(ord_refnum,''),
[FECHA INICIO] = ord_startdate,
[iniciovacio IBMT] = '' ,
[iniciocargado HPL,LLD]='',
[destino LUL] = '',
[termina IEMT,IEBT] =  '',
'KMS CARGADOS' = 0,
'KMS VACIOS' = 0,
'KMS TOTALES' = 0,
'PEAJE'=0,
'PEAJE2' = 0,
'TOTAL PEAJE' = 0,
'PROV SAP/TARIFA' = ord_Charge,
'CIUDAD' =  '' ,
'TIPO VIAJE' =  '' ,
'ESTATUS' = '',
'FACTURA' = ''
 from orderheader (NOLOCK) 
where ord_billto = 'HOMEDEP'
and ord_status = 'CMP'
and ord_startdate between @fi and @ff


--Obtenemos los datos de los stops que solamente utilizaremos----------------------------------------------------------------------------------------------------------------------------------------------
declare @stops table 
(
ord_hdrnumber varchar(20),
cmp_id varchar(100) ,
stp_lgh_mileage float,
stp_city varchar(100),
stp_event varchar(10),
stp_loadstatus varchar(10)
)

insert into @stops

select ord_hdrnumber,cmp_id,stp_lgh_mileage,stp_city,stp_event, stp_loadstatus from stops where stops.ord_hdrnumber in (select ORDEN from @cierre)


--Sección de Updates para completar la tabla virtual @cierre con info ajena a tabla orderheader------------------------------------------------------------------------------------------------------------

update @cierre set [iniciovacio IBMT] = isnull((select top 1 cmp_id from @stops st where st.ord_hdrnumber = orden and stp_event = 'IBMT'),'') 

update @cierre set [iniciocargado HPL,LLD]= isnull((select top 1 cmp_id from @stops  st where st.ord_hdrnumber = orden and (stp_event = 'HPL' or stp_event = 'LLD')  ),'')
update @cierre set [destino LUL] = isnull((select top 1 cmp_id from @stops st where st.ord_hdrnumber = orden and stp_event = 'LUL'),'') 
update @cierre set [termina IEMT,IEBT] =  isnull((select top 1 cmp_id from @stops st where st.ord_hdrnumber = orden and (stp_event = 'IEMT' or stp_event = 'IEBT')  ),'')
update @cierre set [KMS CARGADOS] = IsNull((select sum(stp_lgh_mileage) from @stops st where st.ord_hdrnumber = orden and stp_loadstatus = 'LD'),0)
update @cierre set [KMS VACIOS] = IsNull((select sum(stp_lgh_mileage) from @stops st where st.ord_hdrnumber = orden and stp_loadstatus <> 'LD'),0)
update @cierre set  [KMS TOTALES] = IsNull((select sum(stp_lgh_mileage) from @stops st where st.ord_hdrnumber = orden),0)
update @cierre set  [PEAJE]=''
update @cierre set [PEAJE2] = ''
update @cierre set [TOTAL PEAJE] = ''


update @cierre set [CIUDAD] = CASE WHEN  [iniciocargado HPL,LLD]  LIKE 'HD%'  THEN  
(select cty_nmstct from company where cmp_id =  [destino LUL])   else 
(select cty_nmstct from company where cmp_id =  [iniciocargado HPL,LLD])  end


update @cierre set  [TIPO DE VIAJE] = CASE WHEN  isnull((select top 1 cmp_id from @stops st where st.ord_hdrnumber = orden and (stp_event = 'HPL' or stp_event = 'LLD')  ),'')  LIKE 'HD%'
 THEN 'OUTBOUND' ELSE 'INBOUND' end 




update @cierre set  [FACTURA]  =  case when isnull((select top 1 ivh_ref_number from invoiceheader (NOLOCK)  where invoiceheader.ord_hdrnumber = orden),0) like 'TDR%' 
then  isnull((select top 1 ivh_ref_number from invoiceheader (NOLOCK)  where invoiceheader.ord_hdrnumber = orden),0)  else '' end


--Despliegue del resultado final en la tabla temporal ordenando por fecha de inicio de la orden--------------------------------------------------------------------------------------------------------------
select * from @cierre
order by [FECHA INICIO]  


GO
