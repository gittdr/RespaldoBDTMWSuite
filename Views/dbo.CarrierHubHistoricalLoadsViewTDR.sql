SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO














CREATE  view [dbo].[CarrierHubHistoricalLoadsViewTDR]
as
select 'TMWWF_CarrierHub_HISTORICAL' AS 'TMWWF_CarrierHub_HISTORICAL',
 leg.lgh_number,  
 leg.ord_hdrnumber,
 (select abbr from labelfile where leg.lgh_204status = name and labeldefinition = 'Lgh204Status') as 'Edi204Status',
 convert(varchar, leg.lgh_204date, 110) + '/n' + convert(varchar, leg.lgh_204date, 108) 'Edi204Date', 
 rtrim((select ord_number from orderheader where ord_hdrnumber = leg.ord_hdrnumber))+ case when isnull(lgh_split_flag,'N') = 'N' then '' else '-' + lgh_split_flag end ord_number, 
 
 leg.lgh_outstatus 'DispStatus',
 lgh_miles 'Mileage',
 startcompany.cmp_id 'PickupId',
 startcompany.cmp_name  'PickupName',
 startcity.cty_name 'PickupCity',
 lgh_startstate 'PickupState',
 LegStartStop.stp_arrivaldate 'PickupArrival',
 LegStartStop.stp_departuredate 'PickupDeparture', 
 endcompany.cmp_id 'ConsigneeId',
 endcompany.cmp_name 'ConsigneeName',
 endcity.cty_name 'ConsigneeCity',
 endcompany.cmp_state 'ConsigneeState',
 LegFinalStop.stp_arrivaldate 'DropArrival',
 LegFinalStop.stp_departuredate 'DropDeparture', 
 (select count(distinct ord_hdrnumber) from stops where stops.lgh_number = leg.lgh_number and ord_hdrnumber <> 0 ) 'OrdCnt',
 (select count(*) from stops where stops.lgh_number = leg.lgh_number and stp_type = 'PUP') 'PupCnt',
    (select count(*) from stops where stops.lgh_number = leg.lgh_number and stp_type = 'DRP') 'DrpCnt',
 ord.ord_totalvolume 'TotalVol',
 ord.ord_totalweight 'TotalWeight',
 lgh_primary_trailer 'Trailer',
 leg.lgh_instatus 'InStatus', --This is required by the WS.
 lgh_carrier 'Carrier', --This is required by the business objects.
 lgh_startdate 'StartDate', 
 lgh_enddate 'EndDate',




-- select * from paperwork where ord_hdrnumber = '266500'
 
cast((select count(distinct(abbr)) FROM  paperwork where  
 lgh_number >0 
and pw_received = 'Y'  and pw_imaged = 'Y' and paperwork.ord_hdrnumber =  leg.ord_hdrnumber) as varchar (4)) 

+' de '  +  
 
 cast((select count(bdt_doctype) FROM  BillDoctypes WHERE  cmp_id  = leg.ord_billto AND IsNull(bdt_inv_required,'Y') = 'Y') as varchar (4))
      'Evidencias',




 /*
cast((select count(distinct(abbr)) FROM BillDoctypes, paperwork where BillDoctypes.cmp_id  = ord.ord_billto and abbr = bdt_doctype AND IsNull(bdt_inv_required,'Y') = 'Y' and lgh_number >0 
and pw_received = 'Y'  and paperwork.ord_hdrnumber = ord_hdrnumber and BillDoctypes.cmp_id = ord.ord_billto) as varchar (4)) +' de '  +   cast((select count(bdt_doctype) FROM  BillDoctypes WHERE  cmp_id  = ord.ord_billto AND IsNull(bdt_inv_required,'Y') = 'Y') as varchar (4))
      'Evidencias',
	  */


isnull('$' + dbo.fnc_TMWRN_FormatNumbers((select sum(pyd_amount) from paydetail where  paydetail.lgh_number  =  leg.lgh_number),2),'NO CALCULADO')  'Pago',
(select top(1) pyd_currency from paydetail where  paydetail.lgh_number  =  leg.lgh_number) 'Moneda'


 from legheader as leg join city as startcity on lgh_startcty_nmstct = startcity.cty_nmstct
       join orderheader ord on leg.ord_hdrnumber = ord.ord_hdrnumber
       join company as startcompany on cmp_id_start = startcompany.cmp_id
       join company as endcompany on endcompany.cmp_id  = leg.cmp_id_end
       join city as endcity on endcity.cty_code = leg.lgh_endcity
       join stops as LegStartStop on LegStartStop.stp_number = leg.stp_number_start
       join stops as LegFinalStop on LegFinalStop.stp_number = leg.stp_number_end
       join trailerprofile on trailerprofile.trl_id = leg.lgh_primary_trailer













GO
