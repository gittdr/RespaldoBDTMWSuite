SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE                                     View [dbo].[vTTSTMW_AllStopDetails]
As

--Revision History
--1. Added Trend Analysis Fields For Ver 5.62
--2. Added stop company address and phone to resemble trip sheet Ver 5.7
--3. Added Carrier ID V 5.7


Select TempStopDetail.*,

       Case When Performance Like 'Early%' Then
            DateDiff(mi,[Scheduled Earliest Date],[Arrival date]) 
       When Performance Like 'Late%' Then
	    DateDiff(mi,[Scheduled Latest Date],[Arrival date])
       Else
	   0
       End As Tolerance,
       DateDiff(mi,[Arrival Date],[Departure date]) as ArrivalToDepartureLag

From

(

select orderheader.ord_number as 'Order Number',
       --**Delivery Date**
       ord_completiondate as 'Delivery Date', 
       (Cast(Floor(Cast(orderheader.[ord_completiondate] as float))as smalldatetime)) as [Delivery Date Only], 
       Cast(DatePart(yyyy,orderheader.[ord_completiondate]) as varchar(4)) +  '-' + Cast(DatePart(mm,orderheader.[ord_completiondate]) as varchar(2)) + '-' + Cast(DatePart(dd,orderheader.[ord_completiondate]) as varchar(2)) as [Delivery Day],
       --Month
       Cast(DatePart(mm,orderheader.[ord_completiondate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,orderheader.[ord_completiondate]) as varchar(4)) as [Delivery Month],
       DatePart(mm,orderheader.[ord_completiondate]) as [Delivery Month Only],
       --Year
       DatePart(yyyy,orderheader.[ord_completiondate]) as [Delivery Year], 
       --**Ship Date**
       orderheader.ord_startdate as 'Ship Date', 
       --Day
       (Cast(Floor(Cast(orderheader.[ord_startdate] as float))as smalldatetime)) as [Ship Date Only], 
       Cast(DatePart(yyyy,orderheader.[ord_startdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,orderheader.[ord_startdate]) as varchar(2)) + '-' + Cast(DatePart(dd,orderheader.[ord_startdate]) as varchar(2)) as [Ship Day],
       --Month
       Cast(DatePart(mm,orderheader.[ord_startdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,orderheader.[ord_startdate]) as varchar(4)) as [Ship Month],
       DatePart(mm,orderheader.[ord_startdate]) as [Ship Month Only],
       --Year
       DatePart(yyyy,orderheader.[ord_startdate]) as [Ship Year],
       orderheader.ord_shipper as 'Shipper ID',
       'Shipper' = IsNull((select company.cmp_name from company (NOLOCK) where company.cmp_id = orderheader.ord_shipper),orderheader.ord_shipper),
       orderheader.ord_consignee as 'Consignee ID',
       'Consignee' = IsNull((select company.cmp_name from company (NOLOCK) where company.cmp_id = orderheader.ord_consignee),orderheader.ord_consignee),
       orderheader.ord_billto as 'Bill To ID',
       'Bill To' = IsNull((select company.cmp_name from company (NOLOCK) where company.cmp_id = orderheader.ord_billto),orderheader.ord_billto),
       orderheader.ord_company  as 'Ordered By ID',
       'Ordered By' = IsNull((select company.cmp_name from company (NOLOCK) where company.cmp_id = orderheader.ord_company),orderheader.ord_company),
       orderheader.ord_revtype1 as 'RevType1', 
       'RevType1 Name' = IsNull((select labelfile.name from labelfile (NOLOCK) where labelfile.abbr = orderheader.ord_revtype1 and labelfile.labeldefinition = 'RevType1'),''),
       orderheader.ord_revtype2 as 'RevType2',
       'RevType2 Name' = IsNull((select labelfile.name from labelfile (NOLOCK) where labelfile.abbr = orderheader.ord_revtype2 and labelfile.labeldefinition = 'RevType2'),''),
       orderheader.ord_revtype3 as 'RevType3',
       'RevType3 Name' = IsNull((select labelfile.name from labelfile (NOLOCK) where labelfile.abbr = orderheader.ord_revtype3 and labelfile.labeldefinition = 'RevType3'),''), 
       orderheader.ord_revtype4 as 'RevType4',
       'RevType4 Name' = IsNull((select labelfile.name from labelfile (NOLOCK) where labelfile.abbr = orderheader.ord_revtype4 and labelfile.labeldefinition = 'RevType4'),''),
       stops.cmp_id as 'Stop Company ID',
       'Stop Company Name' = IsNull((select company.cmp_name from Company (NOLOCK) where Company.cmp_id = stops.cmp_id),''), 
       'Stop City' = IsNull((select city.cty_name from City (NOLOCK) where stops.stp_city = city.cty_code),''),
       stops.stp_state  as 'Stop State',
       stops.stp_schdtearliest as 'Scheduled Earliest Date',
       stops.stp_origschdt as 'Original Scheduled Date',
       stops.stp_schdtlatest as 'Scheduled Latest Date',
       stops.stp_arrivaldate as 'Arrival Date',
       stops.stp_departuredate as 'Departure Date',
       stops.stp_type as 'Stop Type',
       stops.stp_event as 'Event',
       legheader.lgh_carrier as 'Carrier ID',
       legheader.lgh_driver1 as 'Driver ID',
       'Driver Name' = IsNull((select manpowerprofile.mpp_lastfirst from manpowerprofile (NOLOCK) where manpowerprofile.mpp_id = legheader.lgh_driver1),legheader.lgh_driver1),
       legheader.lgh_tractor as 'Tractor ID',
       legheader.mpp_type1 'DrvType1', 
       legheader.mpp_type2 'DrvType2', 
       legheader.mpp_type3 'DrvType3', 
       legheader.mpp_type4 'DrvType4', 
       legheader.trc_type1 'TrcType1', 
       legheader.trc_type2 'TrcType2', 
       legheader.trc_type3 'TrcType3', 
       legheader.trc_type4 'TrcType4', 
       stops.stp_reasonlate as 'Reason Late',
       stops.lgh_number as 'LegHeader Number',
       stops.mov_number as 'Move Number',
       stops.stp_mfh_sequence as 'Sequence in Movement',
       stops.stp_sequence as 'Sequence in Trip Segment',
       stops.stp_weight as 'Stop Weight',
       stops.stp_weightunit as 'Stop Weight Unit',
       stops.cmd_code as 'Commodity ID',
       stops.stp_comment as 'Comments',
       stops.stp_count as 'Stop Quantity',
       stops.stp_count as 'Stop Unit',       
       stops.stp_volume as 'Stop Volume',
       stops.stp_volumeunit as 'Stop Volume Unit', 
       stops.stp_status as 'Stop Status',
       stops.stp_description as 'Stop Description',
       stops.stp_lgh_mileage as 'Travel Miles',
       stops.stp_ord_mileage as 'Billed Miles',                     
       stops.stp_loadstatus as 'Load Status',
       stops.ord_hdrnumber as [Order Header Number],
       orderheader.ord_status as 'Order Status',
       event.evt_trailer1 as 'Trailer1 ID',
       event.evt_trailer2 as 'Trailer2 ID',
       orderheader.ord_currencydate as 'Currency Date',
       orderheader.ord_remark as Remark,
       orderheader.ord_bookdate as 'Book Date',
       orderheader.ord_dest_earliestdate as 'Destination Earliest Date',
       orderheader.ord_dest_latestdate as 'Destination Latest Date',
       orderheader.ord_origin_earliestdate as 'Origin Earliest Date',
       orderheader.ord_origin_latestdate as 'Origin Latest Date',    
       orderheader.ord_availabledate as 'Available Date',
       orderheader.ord_bookedby as 'Booked By',
       orderheader.ord_destpoint as 'Destination Point',
       orderheader.ord_datetaken as 'Date Taken',	
       IsNull(event.evt_hubmiles,0) as 'Hub Mile Reading',
      'Hub Miles' = IsNull(event.evt_hubmiles,0) - IsNull((select Max(b.evt_hubmiles) from event b (NOLOCK),stops c (NOLOCK) where c.mov_number = stops.mov_number and c.stp_mfh_sequence = stops.stp_mfh_sequence - 1 and b.stp_number = c.stp_number),0),
       IsNull((select max(invoiceheader.ivh_ref_number) from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber),orderheader.ord_refnum) as [Reference Number],
      (select city.cty_name from city (NOLOCK) where city.cty_code = orderheader.ord_origincity) as 'Origin City',
      (select city.cty_name from city (NOLOCK) where city.cty_code = orderheader.ord_destcity) as 'Dest City', 
      orderheader.ord_originstate as 'Origin State', 
      orderheader.ord_deststate as 'Destination State', 
      ord_reftype as 'Ref Type', 
      stp_activitystart_dt as [Activity Start Date],
      stp_activityend_dt as [Activity End Date],
      'Reason Late Description' = IsNull((select labelfile.name from labelfile (NOLOCK) where labelfile.abbr = stops.stp_reasonlate and labelfile.labeldefinition = 'ReasonLate'),stops.stp_reasonlate),
      IsNull((select company.cmp_address1 from company (NOLOCK) where stops.cmp_id = company.cmp_id),'') as [Stop Company Address1],
      IsNull((select company.cmp_address2 from company (NOLOCK) where stops.cmp_id = company.cmp_id),'') as [Stop Company Address2],
      IsNull((select company.cmp_primaryphone from company (NOLOCK) where stops.cmp_id = company.cmp_id),'') as [Stop Company Phone],
      IsNull((select cast(company.cmp_directions as varchar(255)) from company (NOLOCK) where stops.cmp_id = company.cmp_id),'') as [Stop Company Directions],
  
      (select min(ref_type) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = stops.ord_hdrnumber and ref_sequence = 1 and ref_table = 'orderheader') as OrdRefType1,
      (select min(ref_number) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = stops.ord_hdrnumber and ref_sequence = 1 and ref_table = 'orderheader') as OrdRefNumber1,
      (select min(ref_type) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = stops.ord_hdrnumber and ref_sequence = 2 and ref_table = 'orderheader') as OrdRefType2,
      (select min(ref_number) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = stops.ord_hdrnumber and ref_sequence = 2 and ref_table = 'orderheader') as OrdRefNumber2,
      (select min(ref_type) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = stops.ord_hdrnumber and ref_sequence = 3 and ref_table = 'orderheader') as OrdRefType3,
      (select min(ref_number) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = stops.ord_hdrnumber and ref_sequence = 3 and ref_table = 'orderheader') as OrdRefNumber3,
      (select min(ref_type) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = stops.ord_hdrnumber and ref_sequence = 4 and ref_table = 'orderheader') as OrdRefType4,
      (select min(ref_number) from referencenumber (NOLOCK) where referencenumber.ref_tablekey = stops.ord_hdrnumber and ref_sequence = 4 and ref_table = 'orderheader') as OrdRefNumber4,
	

      (select Min(city.cty_region1) from city (NOLOCK) Where orderheader.ord_origincity = city.cty_code) as [Origin Region1],
      (select Min(city.cty_region2) from city (NOLOCK) Where orderheader.ord_origincity = city.cty_code) as [Origin Region2],
      (select Min(city.cty_region3) from city (NOLOCK) Where orderheader.ord_origincity = city.cty_code) as [Origin Region3],
      (select Min(city.cty_region4) from city (NOLOCK) Where orderheader.ord_origincity = city.cty_code) as [Origin Region4],
      (select Min(city.cty_region1) from city (NOLOCK) Where orderheader.ord_destcity = city.cty_code) as [Destination Region1],
      (select Min(city.cty_region2) from city (NOLOCK) Where orderheader.ord_destcity = city.cty_code) as [Destination Region2],
      (select Min(city.cty_region3) from city (NOLOCK) Where orderheader.ord_destcity = city.cty_code) as [Destination Region3],
      (select Min(city.cty_region4) from city (NOLOCK) Where orderheader.ord_destcity = city.cty_code) as [Destination Region4],	
      --**Segment Start Date**
      lgh_startDate	'Segment Start Date',
      --Day
      (Cast(Floor(Cast([lgh_startDate] as float))as smalldatetime)) as [Segment Start Date Only], 
      Cast(DatePart(yyyy,[lgh_startDate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[lgh_startDate]) as varchar(2)) + '-' + Cast(DatePart(dd,[lgh_startDate]) as varchar(2)) as [Segment Start Day],
      --Month
      Cast(DatePart(mm,[lgh_startDate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[lgh_startDate]) as varchar(4)) as [Segment Start Month],
      DatePart(mm,[lgh_startDate]) as [Segment Start Month Only],
      --Year
      DatePart(yyyy,[lgh_startDate]) as [Segment Start Year],
      --**Segment End Date**
      lgh_EndDate	'Segment End Date',
      --Day
      (Cast(Floor(Cast([lgh_EndDate] as float))as smalldatetime)) as [Segment End Date Only], 
      Cast(DatePart(yyyy,[lgh_EndDate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[lgh_endDate]) as varchar(2)) + '-' + Cast(DatePart(dd,[lgh_endDate]) as varchar(2)) as [End Day],
      --Month
      Cast(DatePart(mm,[lgh_EndDate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[lgh_endDate]) as varchar(4)) as [End Month],
      DatePart(mm,[lgh_EndDate]) as [End Month Only],
      --Year
      DatePart(yyyy,[lgh_EndDate]) as [End Year],


Case When stops.stp_arrivaldate < stops.stp_schdtearliest And stops.stp_type = 'PUP' Then
	'Early to Pickup'

     
     When stops.stp_arrivaldate > stops.stp_schdtlatest And stops.stp_type = 'PUP' Then
	'Late to Pickup'
     
     When stops.stp_arrivaldate >= stops.stp_schdtearliest and stops.stp_arrivaldate <= stops.stp_schdtlatest And stops.stp_type = 'PUP' Then
	'On-Time to Pickup'
     
     When stops.stp_arrivaldate < stops.stp_schdtearliest And stops.stp_type = 'DRP' Then
	'Early to Delivery'
     
     When stops.stp_arrivaldate > stops.stp_schdtlatest And stops.stp_type = 'DRP' Then
	'Late to Delivery'
     
     When stops.stp_arrivaldate >= stops.stp_schdtearliest and stops.stp_arrivaldate <= stops.stp_schdtlatest And stops.stp_type = 'DRP' Then
	'On-Time to Delivery'
    


End AS Performance,
     --<TTS!*!TMW><Begin><FeaturePack=Other>
     '' as 'Booked RevType1',
     --<TTS!*!TMW><End><FeaturePack=Other>
     --<TTS!*!TMW><Begin><FeaturePack=Euro>
     --legheader.lgh_booked_revtype1 as 'Booked RevType1',
     --<TTS!*!TMW><End><FeaturePack=Euro>
     
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Adv ReturnEmpty],
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --stops.stp_advreturnempty as [Adv ReturnEmpty], 
     --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Calculated Weight], 
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --stops.stp_calculated_weight as [Calculated Weight], 
     --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Cod Amount],  
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --stops.stp_cod_amount as [Cod Amount], 
     --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Cod Currency],  
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --stops.stp_cod_currency as [Cod Currency], 
     --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Country], 
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --stops.stp_country as [Country],
     --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     ''  as [LoadingMeters], 
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --stops.stp_loadingmeters as [LoadingMeters], 
     --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [LoadingMetersUnit],
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --stops.stp_loadingmetersunit as [LoadingMetersUnit], 
     --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Org Calculated Weight], 
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --stops.stp_ord_calculated_weight as [Org Calculated Weight],  
     --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Org Booked RevType1], 
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --stops.stp_org_booked_revtype1 as [Org Booked RevType1], 
     --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Org Earliest],
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --stops.stp_org_earliest as [Org Earliest], 
     --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Org Inbound CrossDock], 
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --stops.stp_org_inbound_crossdock as [Org Inbound CrossDock], 
     --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Org Latest], 
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --stops.stp_org_latest as [Org Latest],
     --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Org Outbound CrossDock],
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --stops.stp_org_outbound_crossdock as [Org Outbound CrossDock],
     --<TTS!*!TMW><End><FeaturePack=Euro> 
	 
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Org Scheduled], 
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --stops.stp_org_scheduled as [Org Scheduled],
     --<TTS!*!TMW><End><FeaturePack=Euro> 
	  
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Origin Country],
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --(select city.cty_country from city (NOLOCK) where city.cty_code = orderheader.ord_origincity) as 'Origin Country',
     --<TTS!*!TMW><End><FeaturePack=Euro> 

     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Destination Country],
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --(select city.cty_country from city (NOLOCK) where city.cty_code = orderheader.ord_destcity) as 'Destination Country',
     --<TTS!*!TMW><End><FeaturePack=Euro> 
	
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Origin Zip Code],
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --(select city.cty_zip from city (NOLOCK) where city.cty_code = orderheader.ord_origincity) as 'Origin Zip Code',
     --<TTS!*!TMW><End><FeaturePack=Euro> 

     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Destination Zip Code],
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --(select city.cty_zip from city (NOLOCK) where city.cty_code = orderheader.ord_destcity) as 'Destination Zip Code',
     --<TTS!*!TMW><End><FeaturePack=Euro> 

     stops.stp_zipcode as [Stop Zip Code],
	
     --<TTS!*!TMW><Begin><FeaturePack=Other> 
     '' as [Time Fix]
     --<TTS!*!TMW><End><FeaturePack=Other> 
     --<TTS!*!TMW><Begin><FeaturePack=Euro> 
     --stops.stp_time_fix as [Time Fix]
     --<TTS!*!TMW><End><FeaturePack=Euro>  

from stops (NOLOCK) Left Join  orderheader (NOLOCK) On stops.ord_hdrnumber = orderheader.ord_hdrnumber
	            Left Join legheader (NOLOCK) On legheader.lgh_number = stops.lgh_number
		    Left Join event (NoLock) on stops.stp_number = event.stp_number and event.evt_sequence = 1

) as TempStopDetail
















































GO
GRANT SELECT ON  [dbo].[vTTSTMW_AllStopDetails] TO [public]
GO
