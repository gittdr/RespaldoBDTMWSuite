SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[OrderStopOnTimePerformanceView]
as
select orderheader.ord_number as 'Order Number',
       orderheader.ord_completiondate as 'Delivery Date',
       orderheader.ord_startdate as 'Ship Date',
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

      IsNull((select max(invoiceheader.ivh_ref_number) from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber),orderheader.ord_refnum) as [Reference Number],
      (select city.cty_name from city (NOLOCK) where city.cty_code = orderheader.ord_origincity) as 'Origin City',
      (select city.cty_name from city (NOLOCK) where city.cty_code = orderheader.ord_destcity) as 'Dest City', 
      orderheader.ord_originstate as 'Origin State', 
      orderheader.ord_deststate as 'Destination State', 
      'Reason Late Description' = IsNull((select labelfile.name from labelfile (NOLOCK) where labelfile.abbr = stops.stp_reasonlate and labelfile.labeldefinition = 'ReasonLate'),stops.stp_reasonlate),

       datediff( mi,stops.stp_schdtlatest,stops.stp_arrivaldate) as SchdLatArrDateMinDiff,
       

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
       '' as 'Booked RevType1'
       --<TTS!*!TMW><End><FeaturePack=Other>
       --<TTS!*!TMW><Begin><FeaturePack=Euro>
       --legheader.lgh_booked_revtype1 as 'Booked RevType1'
       --<TTS!*!TMW><End><FeaturePack=Euro>  

from stops (NOLOCK),orderheader (NOLOCK),legheader (NOLOCK)
Where
stops.ord_hdrnumber = orderheader.ord_hdrnumber
And
legheader.lgh_number = stops.lgh_number
And
stops.stp_status='DNE' and stops.stp_type <> 'None'  and stops.stp_type <> 'UNK'

GO
GRANT DELETE ON  [dbo].[OrderStopOnTimePerformanceView] TO [public]
GO
GRANT INSERT ON  [dbo].[OrderStopOnTimePerformanceView] TO [public]
GO
GRANT SELECT ON  [dbo].[OrderStopOnTimePerformanceView] TO [public]
GO
GRANT UPDATE ON  [dbo].[OrderStopOnTimePerformanceView] TO [public]
GO
