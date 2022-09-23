SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO














--select * from CarrierHubAssignedLoadsView where ord_hdrnumber =  '336697'





CREATE view [dbo].[CarrierHubAssignedLoadsViewTDR]
as
select 'TMWWF_CarrierHub_ASSIGNED' AS 'TMWWF_CarrierHub_ASSIGNED',
 leg.lgh_number,  
 leg.ord_hdrnumber,
 (select abbr from labelfile where leg.lgh_204status = name and labeldefinition = 'Lgh204Status') as 'Edi204Status',
 leg.lgh_204date 'Edi204Date', 
 rtrim((select ord_number from orderheader where ord_hdrnumber = leg.ord_hdrnumber))+ case when isnull(lgh_split_flag,'N') = 'N' then '' else '-' + lgh_split_flag end ord_number, 
 lgh_startdate 'Start Date', 
 lgh_enddate 'End Date', 
 replace(leg.lgh_outstatus,'AVL','PLN')  'DispStatus',
 lgh_miles 'Mileage',
 startcompany.cmp_id 'PickupId',
 UPPER(startcompany.cmp_name)  'PickupName',
 startcity.cty_nmstct 'PickupCity',
 lgh_startstate 'PickupState',
 LegStartStop.stp_arrivaldate 'PickupArrival',
 LegStartStop.stp_departuredate 'PickupDeparture', 
 endcompany.cmp_id 'ConsigneeId',
 UPPER(endcompany.cmp_name) 'ConsigneeName',
 endcity.cty_nmstct 'ConsigneeCity',
 endcompany.cmp_state 'ConsigneeState',
 LegFinalStop.stp_arrivaldate 'DropArrival',
 LegFinalStop.stp_departuredate 'DropDeparture', 
 (select count(distinct ord_hdrnumber) from stops where stops.lgh_number = leg.lgh_number and ord_hdrnumber <> 0 ) 'OrdCnt',
 (select count(*) from stops where stops.lgh_number = leg.lgh_number and stp_type = 'PUP') 'PupCnt',
    (select count(*) from stops where stops.lgh_number = leg.lgh_number and stp_type = 'DRP') 'DrpCnt',
 ord.ord_totalvolume 'TotalVol',
 ord.ord_totalweight 'TotalWeight',
 lgh_primary_trailer 'Trailer',
 lgh_carrier 'Carrier', --This is required by the business objects.
 dbo.tmw_legstopslate_fn(leg.lgh_number) 'Late Stops',
replace(isnull('$' + dbo.fnc_TMWRN_FormatNumbers((select sum(pyd_amount) from paydetail where  paydetail.lgh_number  =  leg.lgh_number),2),'NO CALCULADO'),'$0.00','NO CALCULADO')  'Pago',
ord.ord_currency     'ord_currency',
ord.ord_billto as Cliente,
ord.ord_Status,
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ord.ord_refnum 'Referencia',
ord_remark 'Comentarios',

case when datediff(dd,LegStartStop.stp_arrivaldate ,LegStartStop.stp_departuredate) = 0 then 
 
  case when len(cast(datepart(DAY,LegStartStop.stp_arrivaldate) as varchar (10))) = 1 then '0' + cast(datepart(DAY,LegStartStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(DAY,LegStartStop.stp_arrivaldate) as varchar (10))) end
		
		  +'/' + case when len(cast(month(LegStartStop.stp_arrivaldate) as varchar (10))) = 1 then '0' + cast(MONTH(LegStartStop.stp_arrivaldate) as varchar (10))
        else (cast(MONTH(LegStartStop.stp_arrivaldate) as varchar (10))) end

+'/' + cast(datepart(YEAR,LegStartStop.stp_arrivaldate) as varchar (10)) 


+ '@ [' +   case when len(cast(datepart(HOUR,LegStartStop.stp_arrivaldate) as varchar (10))) = 1 then '0' + cast(datepart(HOUR,LegStartStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(HOUR,LegStartStop.stp_arrivaldate) as varchar (10))) end

+':'+

 case when len(cast(datepart(MINUTE,LegStartStop.stp_arrivaldate) as varchar (10))) = 1 then '0' + cast(datepart(MINUTE,LegStartStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(MINUTE,LegStartStop.stp_arrivaldate) as varchar (10))) end

+'] - [' +

case when len(cast(datepart(HOUR,LegStartStop.stp_departuredate) as varchar (10))) = 1 then '0' + cast(datepart(HOUR,LegStartStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(HOUR,LegStartStop.stp_departuredate) as varchar (10))) end

+':'+

 case when len(cast(datepart(MINUTE,LegStartStop.stp_departuredate) as varchar (10))) = 1 then '0' + cast(datepart(MINUTE,LegStartStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(MINUTE,LegStartStop.stp_departuredate) as varchar (10))) end
 +']'

 else

   case when len(cast(datepart(DAY,LegStartStop.stp_arrivaldate) as varchar (10))) = 1 then '0' + cast(datepart(DAY,LegStartStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(DAY,LegStartStop.stp_arrivaldate) as varchar (10))) end
		
		  +'/' + case when len(cast(month(LegStartStop.stp_arrivaldate) as varchar (10))) = 1 then '0' + cast(MONTH(LegStartStop.stp_arrivaldate) as varchar (10))
        else (cast(MONTH(LegStartStop.stp_arrivaldate) as varchar (10))) end

+'/' + cast(datepart(YEAR,LegStartStop.stp_arrivaldate) as varchar (10)) 


+ '@ [' +   case when len(cast(datepart(HOUR,LegStartStop.stp_arrivaldate) as varchar (10))) = 1 then '0' + cast(datepart(HOUR,LegStartStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(HOUR,LegStartStop.stp_arrivaldate) as varchar (10))) end

+':'+

 case when len(cast(datepart(MINUTE,LegStartStop.stp_arrivaldate) as varchar (10))) = 1 then '0' + cast(datepart(MINUTE,LegStartStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(MINUTE,LegStartStop.stp_arrivaldate) as varchar (10))) end

+'] - ' +


  case when len(cast(datepart(DAY,LegStartStop.stp_departuredate) as varchar (10))) = 1 then '0' + cast(datepart(DAY,LegStartStop.stp_departuredate) as varchar (10))
        else (cast(datepart(DAY,LegStartStop.stp_arrivaldate) as varchar (10))) end
		
		  +'/' + case when len(cast(month(LegStartStop.stp_departuredate) as varchar (10))) = 1 then '0' + cast(MONTH(LegStartStop.stp_departuredate) as varchar (10))
        else (cast(MONTH(LegStartStop.stp_arrivaldate) as varchar (10))) end

+'/' + cast(datepart(YEAR,LegStartStop.stp_departuredate) as varchar (10))  + +'[' +


case when len(cast(datepart(HOUR,LegStartStop.stp_departuredate) as varchar (10))) = 1 then '0' + cast(datepart(HOUR,LegStartStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(HOUR,LegStartStop.stp_departuredate) as varchar (10))) end

		

+':'+

 case when len(cast(datepart(MINUTE,LegStartStop.stp_departuredate) as varchar (10))) = 1 then '0' + cast(datepart(MINUTE,LegStartStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(MINUTE,LegStartStop.stp_departuredate) as varchar (10))) end
 +']'


 end as 'VentanaCarga',

 case when datediff(dd,LegFinalStop.stp_arrivaldate ,LegFinalStop.stp_departuredate) = 0 then 
 
  case when len(cast(datepart(DAY,LegFinalStop.stp_arrivaldate) as varchar (10))) = 1 then '0' + cast(datepart(DAY,LegFinalStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(DAY,LegFinalStop.stp_arrivaldate) as varchar (10))) end
		
		  +'/' + case when len(cast(month(LegFinalStop.stp_arrivaldate) as varchar (10))) = 1 then '0' + cast(MONTH(LegFinalStop.stp_arrivaldate) as varchar (10))
        else (cast(MONTH(LegFinalStop.stp_arrivaldate) as varchar (10))) end

+'/' + cast(datepart(YEAR,LegFinalStop.stp_arrivaldate) as varchar (10)) 


+ '@ [' +   case when len(cast(datepart(HOUR,LegFinalStop.stp_arrivaldate) as varchar (10))) = 1 then '0' + cast(datepart(HOUR,LegFinalStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(HOUR,LegFinalStop.stp_arrivaldate) as varchar (10))) end

+':'+

 case when len(cast(datepart(MINUTE,LegFinalStop.stp_arrivaldate) as varchar (10))) = 1 then '0' + cast(datepart(MINUTE,LegFinalStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(MINUTE,LegFinalStop.stp_arrivaldate) as varchar (10))) end

+'] - [' +

case when len(cast(datepart(HOUR,LegFinalStop.stp_departuredate) as varchar (10))) = 1 then '0' + cast(datepart(HOUR,LegFinalStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(HOUR,LegFinalStop.stp_departuredate) as varchar (10))) end

+':'+

 case when len(cast(datepart(MINUTE,LegFinalStop.stp_departuredate) as varchar (10))) = 1 then '0' + cast(datepart(MINUTE,LegFinalStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(MINUTE,LegFinalStop.stp_departuredate) as varchar (10))) end
 +']'

 else

   case when len(cast(datepart(DAY,LegFinalStop.stp_arrivaldate) as varchar (10))) = 1 then '0' + cast(datepart(DAY,LegFinalStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(DAY,LegFinalStop.stp_arrivaldate) as varchar (10))) end
		
		  +'/' + case when len(cast(month(LegFinalStop.stp_arrivaldate) as varchar (10))) = 1 then '0' + cast(MONTH(LegFinalStop.stp_arrivaldate) as varchar (10))
        else (cast(MONTH(LegFinalStop.stp_arrivaldate) as varchar (10))) end

+'/' + cast(datepart(YEAR,LegFinalStop.stp_arrivaldate) as varchar (10)) 


+ '@ [' +   case when len(cast(datepart(HOUR,LegFinalStop.stp_arrivaldate) as varchar (10))) = 1 then '0' + cast(datepart(HOUR,LegFinalStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(HOUR,LegFinalStop.stp_arrivaldate) as varchar (10))) end

+':'+

 case when len(cast(datepart(MINUTE,LegFinalStop.stp_arrivaldate) as varchar (10))) = 1 then '0' + cast(datepart(MINUTE,LegFinalStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(MINUTE,LegFinalStop.stp_arrivaldate) as varchar (10))) end

+'] - ' +


  case when len(cast(datepart(DAY,LegFinalStop.stp_departuredate) as varchar (10))) = 1 then '0' + cast(datepart(DAY,LegFinalStop.stp_departuredate) as varchar (10))
        else (cast(datepart(DAY,LegFinalStop.stp_arrivaldate) as varchar (10))) end
		
		  +'/' + case when len(cast(month(LegFinalStop.stp_departuredate) as varchar (10))) = 1 then '0' + cast(MONTH(LegFinalStop.stp_departuredate) as varchar (10))
        else (cast(MONTH(LegFinalStop.stp_arrivaldate) as varchar (10))) end

+'/' + cast(datepart(YEAR,LegFinalStop.stp_departuredate) as varchar (10))  + +'[' +


case when len(cast(datepart(HOUR,LegFinalStop.stp_departuredate) as varchar (10))) = 1 then '0' + cast(datepart(HOUR,LegFinalStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(HOUR,LegFinalStop.stp_departuredate) as varchar (10))) end

		

+':'+

 case when len(cast(datepart(MINUTE,LegFinalStop.stp_departuredate) as varchar (10))) = 1 then '0' + cast(datepart(MINUTE,LegFinalStop.stp_arrivaldate) as varchar (10))
        else (cast(datepart(MINUTE,LegFinalStop.stp_departuredate) as varchar (10))) end
 +']'


 end as 'VentanaDescarga',


 '' as 'Estatus',

 (select count(*) from stops where stops.lgh_number = leg.lgh_number and stp_type in ('PUP','DRP'))   as 'Paradas'




 from legheader as leg join city as startcity on lgh_startcty_nmstct = startcity.cty_nmstct
       join orderheader ord on leg.ord_hdrnumber = ord.ord_hdrnumber
       join company as startcompany on cmp_id_start = startcompany.cmp_id
      join company as endcompany on endcompany.cmp_id  = leg.cmp_id_end
      join city as endcity on endcity.cty_code = leg.lgh_endcity
      join stops as LegStartStop on LegStartStop.stp_number = leg.stp_number_start
      join stops as LegFinalStop on LegFinalStop.stp_number = leg.stp_number_end
    --  join trailerprofile on trailerprofile.trl_id = leg.lgh_primary_trailer
	  where lgh_carrier <> 'UNKNOWN'





	  













GO
