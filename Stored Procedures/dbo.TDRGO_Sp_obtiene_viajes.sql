SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [dbo].[TDRGO_Sp_obtiene_viajes] (@Usuario varchar(100) )
AS
SET NOCOUNT ON
SELECT TOP 10
   
   OrderId =  l.ord_hdrnumber, 
   LegId =    l.lgh_number,          
   
   LoadStatusCode = 

    case when l.lgh_outstatus = 'CMP' and a.pyd_status = 'PPD' then 'PDD' else
    ( case  l.lgh_outstatus when 'CMP'  then  
	  case when   isnull(pv.evs,0) = 0 
    then 'PPF' else 'NEV' end 
    else lgh_outstatus end) 
  end, 

   OrderStatus = 
     case when l.lgh_outstatus = 'CMP' and a.pyd_status = 'PPD' then 'Pagado' else
    ( case  l.lgh_outstatus when 'CMP'  then 
     case when  isnull(pv.evs,0) = 0  
  then 'Liberado' else 'Faltan evidencias' end 
    else lf.name end) 
  end, 

  CustomerName =  isnull(customer.cmp_name,'MOVIMIENTO EN VACIO'), 
  Compliance = case when l.lgh_outstatus = 'STD' then 'Yes' else 'No' end, 
  Pickup = l.lgh_startdate,
  TruckNumber = l.lgh_tractor,
  TrailerNumber = isnull(l.lgh_primary_trailer,'UNKNOWN'),
   Dolly = case when len(l.lgh_dolly) <1 then 'UNKNOWN' else isnull(replace(l.lgh_dolly,'','UNKNOWN'),'UNKNOWN') end,
  TrailerNumber2 = isnull(lgh_primary_pup,'UNKNOWN'),
  FullFlag = case when o.ord_carrier <> 'UNKNOWN' then 'C'  when l.lgh_type1='FULL' then 'T' else 'F' end ,
  
 
 TestFlag = 'T',
 -- TestFlag = case when l.lgh_driver1 in ('HEROM', 'HERJO17','ZAVIS','PERMA02','FLOJA','SARBE','MORMA02',
 -- 'ANGGA','ALDMI','AGUJO07','TORJO03','TORGE','ESCLU' ) then 'T' else 'F' end,
  
  Proy =  o.ord_revtype3,
  OrderRemarks = replace(isnull(o.ord_remark,''),'/','-') ,
  TripComments = isnull(l.lgh_comment,''),
  ActiveFlag =  CASE WHEN l.lgh_outstatus IN ('STD','DSP','PLN') THEN 'true' ELSE 'false' END, 
  CurrentFlag = CASE WHEN l.lgh_outstatus IN ('STD') THEN 'true' ELSE 'false' END, 
 
  TotalMiles = isnull(l.lgh_miles,0),
  EmptyMiles= '0',

  /*
  cast((select isnull(sum(isnull(stp_lgh_mileage,0)),0) from stops (nolock) where stp_loadstatus in ('MT','BT') and stops.lgh_number =  l.lgh_number) as varchar(20))  
     + ' ' + isnull('@ '+ cast(cast((Select avg(fcl_mpg) from fuelticket_calclog (nolock) where lgh_number = l.lgh_number and fcl_loadstatus in ('MT','EM') and
	  orden = (select max(orden) from fuelticket_calclog (nolock) where lgh_number = l.lgh_number  )) as float)  as varchar(20)),''),*/

  LoadedMiles= '0',
  
  /* cast((select isnull(sum(isnull(stp_lgh_mileage,0)),0) from stops (nolock) where stp_loadstatus = 'LD' and stops.lgh_number =  l.lgh_number) as varchar(20)) 
    + ' ' + isnull('@ '+ cast(cast((Select avg(fcl_mpg) from fuelticket_calclog (nolock) where lgh_number = l.lgh_number and fcl_loadstatus in ('LD') and
	 orden = (select max(orden) from fuelticket_calclog (nolock) where lgh_number = l.lgh_number  )) as float)  as varchar(20)),''), 
*/

  RefNum= case when l.ord_hdrnumber >0 then isnull((STUFF((select  '; '+(select name from labelfile (nolock) where ref_type = abbr and labeldefinition = 'ReferenceNumbers') 
  +':' + ref_number  from referencenumber where ord_hdrnumber  = replace(l.ord_hdrnumber,' 0 ',' 1 ') and ref_number <> '' FOR XML PATH('')) , 1, 1, '')),'')else '' end ,

  loadorigin= cmporig.cmp_name , 
  loaddestin= cmpdest.cmp_name,

  FuelAvg =  'NA',

  /*
  isnull((select cast(cast(round(sum(fcl_miles/(fcl_mpg+.000001)),2,0) as float(2)) as varchar(10)) + ' lts @ ' + cast(cast(avg(fcl_mpg)as float) as varchar(20)) from fuelticket_calclog (nolock) where lgh_number = l.lgh_number
   and orden = (select max(orden) from fuelticket_calclog (nolock) where lgh_number = l.lgh_number )),'NA') ,
   */

  StartButton=   'Y',-- case when l.lgh_startdate = (select min(lm.lgh_startdate) from legheader lm (nolock) where lm.ord_hdrnumber = o.ord_hdrnumber) then 'Yes' else 'No'  end ,

  SplitInd= isnull(replace(lgh_split_flag,'N',''),'')
 
  ,

  podsto =  isnull(STUFF((
            select ','+ doctypename from PaperworkRequirementsView where legnumber = l.lgh_number and received <> 'Yes' FOR XML PATH('')
            ), 1, 1, ''),'') 

 FROM legheader l (nolock)
   LEFT OUTER JOIN orderheader o (nolock) ON o.ord_hdrnumber = l.ord_hdrnumber 
   INNER JOIN labelfile lf ON l.lgh_outstatus = lf.abbr 
   left join (select * from assetassignment where asgn_type = 'DRV') a ON a.lgh_number = l.lgh_number and asgn_id = l.lgh_driver1 
   left join company as cmporig on cmporig.cmp_id = o.ord_shipper 
   left join company as cmpdest on cmpdest.cmp_id =o.ord_consignee 
   left join company as customer on customer.cmp_id = o.ord_billto 
   left join (select legnumber,count(*) as evs  from PaperworkRequirementsView pv where pv.received = 'No' group by legnumber) pv  on pv.legnumber = l.lgh_number
 WHERE  l.lgh_startdate BETWEEN dateadd(month,-1,getdate()) AND dateadd(week,1,getdate())   
  AND l.lgh_outstatus <> 'CAN' AND ( (l.lgh_driver1 = @Usuario)    or   (l.lgh_driver2 = @Usuario)     ) 
  AND lf.labeldefinition = 'DispStatus' 



 ORDER BY l.lgh_startdate desc 
GO
