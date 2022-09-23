SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO










--select * from [dbo].[vista_convoy_pendientes]
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view  [dbo].[vista_convoy_pendientes]
as


select 
 exp_id as driver
 ,exp_key as exphandle
 ,(select name from labelfile (nolock) where abbr = exp_code and labeldefinition = 'DrvExp') as expname
 --,exp_expirationdate as expduedate
 ,substring(cast(CONVERT(datetimeoffset,exp_expirationdate,127) as varchar(50)),1,10)+'T'+ substring(cast(CONVERT(datetimeoffset,exp_expirationdate,127) as varchar(50)),12,5)+':00.0000+00:00'  as expduedate
 ,case exp_description 
  when 'LICEN' then 'Renovar licencia de manejo antes de: ' + cast(exp_expirationdate as varchar(24))
  when '' then 'NA'
  else isnull(exp_description,'NA')        -- + ' de ' + cast(exp_expirationdate as varchar(24))  + ' a '  + cast(exp_compldate as varchar(24)) 
 end 
  as expdesc,
 'transaction-editor' as actiontype,
 'WANTS-HOME' as formname,
 case exp_description  when 'LICEN' then 'Renovar licencia de manejo antes de: ' + cast(exp_expirationdate as varchar(24))
 when  null then '---' else exp_description + ' de ' + cast(exp_expirationdate as varchar(24))  + ' a '  + cast(exp_compldate as varchar(24)) 
 end  as data1,
 '' as data2
 from expiration 
 where exp_completed = 'N'
 and exp_idtype = 'DRV'
 and (select name from labelfile (nolock) where abbr = exp_code and labeldefinition = 'DrvExp')  <> 'BAJA'
 
 /*
 union



  select 
   (select max(mpp_id) from manpowerprofile (nolock) where cast(mpp_tractornumber as varchar(20)) =  cast(tractor as varchar(20)) and mpp_status <> 'OUT' ) as driver,
     160215 as exphandle, 
	 'Agendar Mantenimiento Preventivo Tractor' as expname,
  substring(cast(CONVERT(datetimeoffset,fsigserv,127)as varchar(50)),1,10)+'T'+ substring(cast(CONVERT(datetimeoffset,fsigserv,127) as varchar(50)),12,5)+':00.0000+00:00' as expduedate, 
   'Tractor: ' + cast(tractor  as varchar(20)) + ' en ' + isnull(cast(fsigserv as varchar(12)),'--') as expdesc,
  -- null as expdesc,
   'transaction-editor' as actiontype,
   'SCHEDULE-TRC-SRV' as formname,
   'Mantenimiento preventivo' as data1,
   cast(tractor as varchar(20)) as data2
   
   
   
    from vista_kmsxmttto
*/


/*
	union

   (select 
   asgn_id as driver,
   lgh_number as exphandle,
   'Escanear evidencias de la orden: ' +  cast( (select ord_hdrnumber from legheader (nolock) where a.lgh_number =legheader.lgh_number )  as varchar(20)) as expname,
    substring(cast(CONVERT(datetimeoffset,dateadd(dd,5,asgn_date),127)as varchar(50)),1,10)+'T'+ substring(cast(CONVERT(datetimeoffset,dateadd(dd,5,asgn_date),127) as varchar(50)),12,5)+':00.0000+00:00' as expduedate, 
   
   (select 'Cliente:' +ord_billto+' Origen:'+ ord_shipper + ' Destino:'+ ord_consignee + ' Fecha:' + cast(ord_completiondate as varchar(120)) + '  Documentos:  '  from orderheader where ord_hdrnumber = (select ord_hdrnumber from legheader (nolock) where a.lgh_number =legheader.lgh_number )) +
   isnull(STUFF(( select ','+ doc_name from v_paperwork_required  
    where isrequired = 'Y' and cmp_id = 
   (select ord_billto from orderheader where ord_hdrnumber = (select ord_hdrnumber from legheader le where le.lgh_number = a.lgh_number))
   and doc_type not in (
   select abbr  from paperwork where paperwork.lgh_number = a.lgh_number and pw_received = 'Y' )   FOR XML PATH('') ), 1, 1, '') ,'NA' )  as expdesc,
     'transaction-editor' as actiontype,
   'TRIP-DOCUMENT-METADATA' as formname,
   'Orden' as data1,
   (select ord_hdrnumber from legheader (nolock) where a.lgh_number =legheader.lgh_number ) as data2
    from assetassignment a where pyd_status = 'NPD' and asgn_type = 'DRV' and asgn_id <> ''
	and (select ord_hdrnumber from legheader (nolock) where a.lgh_number =legheader.lgh_number ) <> 0 )


	*/

	union

	select 
	asg_id =   (select max(mpp_id) from manpowerprofile (nolock) where mpp_tractornumber = tractoraccesories.tca_tractor and mpp_status <> 'OUT' ),
	exphandle = tractoraccessory_id,
	expname = case when tca_type = 'RFM' then 'Revision Fisico Mecanica Tractor: ' + tca_tractor 
	               when tca_type  = 'DECP2' then 'Revision de Emision de Contaminantes Segundo Periodo Tractor: ' + tca_tractor  
				   when tca_type  = 'DECP1' then 'Revision de Emision de Contaminantes Primer Periodo Tractor: ' + tca_tractor 
				   end,
	expduedate =  substring(cast(CONVERT(datetimeoffset,dateadd(dd,5,tca_expire_date),127)as varchar(50)),1,10)+'T'+ substring(cast(CONVERT(datetimeoffset,dateadd(dd,5,tca_expire_date),127) as varchar(50)),12,5)+':00.0000+00:00' ,
	expdesc  = 'Realizar antes de: ' + cast( tca_expire_date as varchar(120)),
	actiontype =   'transaction-editor',
	formname = 'TRIP-DOCUMENT-METADATA',
	   'SCHEDULE-TRC-SRV' as data1,
   tca_tractor as data2
	 from tractoraccesories
    where tca_type in ('RFM','DECP2','DECP1')

	






GO
