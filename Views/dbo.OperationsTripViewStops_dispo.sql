SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








/*

select * from  [dbo].[OperationsTripViewStops_dispo]  where OrderNumber = '1008815'

*/







CREATE VIEW [dbo].[OperationsTripViewStops_dispo]       
as       
      

--no tocar datos necesarios para que la vista funcione-------------------------------------------------------------------------------------------------------------------------------------
select 


-- Prueba añadir apartado fumigaciones a grid planning works sheet -- 
--(Select count(*) from expiration where exp_id=OperationsTripViewDetails_TDR.Trailer1 and exp_code='FUMI' and exp_expirationdate<=GETDATE() and exp_lastdate>=GETDATE())as trlfumi,

OperationsTripViewDetails_TDR.*, 
 stops.stp_number, stops.stp_mfh_sequence, stops.cmp_id, stops.cmp_name, city.cty_nmstct, city.cty_state, stops.stp_zipcode,      
  stops.stp_event, stops.stp_lgh_mileage, stops.stp_arrivaldate, stops.stp_departuredate, stops.stp_schdtearliest, stops.stp_schdtlatest,      
  stops.stp_status, stops.stp_departure_status, stops.ord_hdrnumber, stops.cmd_code, stops.stp_description,   
  IsNull(company.cmp_latseconds, 0)/3600.0 as Latitude, IsNull(company.cmp_longseconds, 0)/3600.0 as Longitude , 
  (SELECT count(DISTINCT ord_hdrnumber) FROM stops (nolock) WHERE stops.lgh_number = OperationsTripViewDetails_TDR.lgh_number AND ord_hdrnumber <> 0 ) 'OrdCnt',
  stops.stp_detstatus

---datos agregados por emolvera para diseño vistas----------------------------------------------------------------------------------------------------------------------------------------
, 
'****************' as trac
,

cast((stuff(( select ',' + lrq_equip_type+':' +lrq_type 
from legheader join loadrequirement on legheader.mov_number = loadrequirement.mov_number
where legheader.lgh_number = stops.lgh_number  for xml path('')),1,1,'')) as varchar(500)) as [Load_Req] 


 
,lhfsctm =  0 -- (select    round(isnull(ord_totalcharge,0)/replace(ord_totalmiles,0,1),2) from orderheader (nolock)  oh where oh.ord_hdrnumber = stops.ord_hdrnumber)
,nextdropcmp = ''--(select min(cmp_id) from stops  (nolock) st where st.ord_hdrnumber = stops.ord_hdrnumber and stp_type = 'DRP' and stp_sequence 
--= (select min(stp_sequence) from stops  (nolock)  sp  where  sp.ord_hdrnumber = stops.ord_hdrnumber and stp_type = 'DRP') ) 

,consigstate = isnull(ConsigneeCity,  (select cmp_city from company  (nolock)  where cmp_id = ConsigneeId))
,bookdate = (select ord_bookdate from orderheader (nolock)  oh where oh.ord_hdrnumber = stops.ord_hdrnumber) 
,DispStatus as Dspste
,case when ord_totalmiles = 0 then 0 else round((round(ord_totalcharge,2) / round(ord_totalmiles,2)),2) end as revxkm

/*
,idavuelt = case when (select count(lgh_number) from stops a (nolock) where stops.ord_hdrnumber = a.ord_hdrnumber and a.ord_hdrnumber is not null) > 2 then (case when stops.lgh_number
= (select min(lgh_number) from stops a (nolock) where stops.ord_hdrnumber = a.ord_hdrnumber and a.ord_hdrnumber is not null) then 'IDA' 
 when stops.lgh_number
= (select max(lgh_number) from stops a (nolock) where stops.ord_hdrnumber = a.ord_hdrnumber and a.ord_hdrnumber is not null) then 'VUELTA'  end
) else '' end 
*/


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
       
from OperationsTripViewDetails_TDR (nolock) join stops (nolock) on OperationsTripViewDetails_TDR.lgh_number = stops.lgh_number      
      join city on city.cty_code = stops.stp_city      
      join company on company.cmp_id = stops.cmp_id
	  and DispStatus not in ('MST','CAN')


	 











GO
GRANT SELECT ON  [dbo].[OperationsTripViewStops_dispo] TO [public]
GO
