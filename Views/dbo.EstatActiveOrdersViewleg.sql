SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE view [dbo].[EstatActiveOrdersViewleg]
as
select 

--NO TOCAR NECESARIOS PARA LA VISTA---------------------------------------------------

    'TMWWF_ESTAT_ACTIVE' as 'TMWWF_ESTAT_ACTIVE',  
	 (select cmp_name from company where cmp_id = li.ord_billto ) 'BillTo', 
     li.ord_billto 'BillToID',
     (select cmp_name from company where cmp_id = li.ord_company) 'OrderBy',
     li.ord_company 'OrderByID',  
	'DispStatus' = 'STD' , 
	 ord.ord_revtype1 'RevType1', ord.ord_revtype2 'RevType2', ord.ord_revtype3 'RevType3', ord.ord_revtype4 'RevType4',
---------------------------------------------------------------------------------------


 [Viaje/Transporte] =  ord.ord_refnum ,

 EstatusLogistico =   'En transito',


 EstadoViaje =  'Iniciado',
                             

 Trailer1 = lgh_primary_trailer ,
 Trailer2 = lgh_primary_pup,
 Ontime =  (case when getdate() >

  (select  stp_schdtearliest from stops  where stops.ord_hdrnumber = ord.ord_hdrnumber 
 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = ord.ord_hdrnumber and stp_status = 'OPN'))
 then 'Retraso'
 else 'En Tiempo'
 End
 )
,

proxcita=(select stp_schdtlatest from  stops where stops.ord_hdrnumber = ord.ord_hdrnumber 
 and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = ord.ord_hdrnumber and stp_status = 'OPN')),

proxevento = ( select name from eventcodetable  where abbr = (select stp_event from  stops where stops.ord_hdrnumber = ord.ord_hdrnumber 
and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = ord.ord_hdrnumber and stp_status = 'OPN'))),

proxdestino = (select cmp_name from company where cmp_id =
(select cmp_id from  stops where stops.ord_hdrnumber = ord.ord_hdrnumber 
and stp_mfh_sequence = (select min(stp_mfh_sequence) from  stops where stops.ord_hdrnumber = ord.ord_hdrnumber and stp_status = 'OPN'))),

FechaGPS = (select trc_gps_date from tractorprofile where trc_number = li.lgh_tractor),
UbicacionGPS = (select trc_gps_desc from tractorprofile where trc_number = li.lgh_tractor),



 ord.ord_startdate 'StartDate', 
 scompany.cmp_id 'PickupID',
 scompany.cmp_name 'PickupName',
 scity.cty_name 'PickupCity',
 scity.cty_state 'PickupState',


 ord.ord_completiondate 'EndDate', 
 ccompany.cmp_id 'ConsigneeID',
 ccompany.cmp_name 'ConsigneeName',
 ccity.cty_name 'ConsigneeCity',
 ccity.cty_state 'ConsigneeState', 





 Carrier = replace(ord_carrier,'UNKNOWN','TDR'),
 Tractor = li.lgh_tractor,



 ord.ord_hdrnumber,
 ord.ord_number


from legheader_active as li

  join orderheader as ord on ord.mov_number = li.mov_number
  join city as scity on ord.ord_origincity = scity.cty_code
  join company as scompany on ord.ord_originpoint = scompany.cmp_id
  join city as ccity on ord.ord_destcity = ccity.cty_code
  join company as ccompany on ord_destpoint = ccompany.cmp_id

















GO
