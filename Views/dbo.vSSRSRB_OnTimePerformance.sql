SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE                View [dbo].[vSSRSRB_OnTimePerformance]
As
/**
 *
 * NAME:
 * dbo.[vSSRSRB_OnTimePerformance]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * On time performance statistics
 
 *
**************************************************************************

Sample call


select * from [vSSRSRB_OnTimePerformance]


**************************************************************************
 * RETURNS:
 * ResultSet
 *
 * RESULT SETS:
 * DOn time performance data
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/18/2014 JR created example blurb
 * 08/28/2015 MREED added reasonlate depart text and code.  Added test for reasonlate
 **/
select orderheader.ord_number as 'Order Number',
       orderheader.ord_completiondate as 'Delivery Date',
       (Cast(Floor(Cast(orderheader.ord_completiondate as float))as smalldatetime)) AS [Delivery Date Only],
       orderheader.ord_startdate as 'Ship Date',
       (Cast(Floor(Cast(orderheader.ord_startdate as float))as smalldatetime)) AS [Ship Date Only],
       orderheader.ord_shipper as 'Shipper ID',
       'Shipper Name' = IsNull((select company.cmp_name from company WITH (NOLOCK) where company.cmp_id = orderheader.ord_shipper),orderheader.ord_shipper),
       orderheader.ord_consignee as 'Consignee ID',
       'Consignee Name' = IsNull((select company.cmp_name from company WITH (NOLOCK) where company.cmp_id = orderheader.ord_consignee),orderheader.ord_consignee),
       orderheader.ord_billto as 'Bill To ID',
       'Bill To Name' = IsNull((select company.cmp_name from company WITH (NOLOCK) where company.cmp_id = orderheader.ord_billto),orderheader.ord_billto),
       orderheader.ord_company  as 'Ordered By ID',
       'Ordered By Name' = IsNull((select company.cmp_name from company WITH (NOLOCK) where company.cmp_id = orderheader.ord_company),orderheader.ord_company),
       orderheader.ord_revtype1 as 'RevType1', 
       'RevType1 Name' = IsNull((select labelfile.name from labelfile WITH (NOLOCK) where labelfile.abbr = orderheader.ord_revtype1 and labelfile.labeldefinition = 'RevType1'),''),
       orderheader.ord_revtype2 as 'RevType2',
       'RevType2 Name' = IsNull((select labelfile.name from labelfile WITH (NOLOCK) where labelfile.abbr = orderheader.ord_revtype2 and labelfile.labeldefinition = 'RevType2'),''),
       orderheader.ord_revtype3 as 'RevType3',
       'RevType3 Name' = IsNull((select labelfile.name from labelfile WITH (NOLOCK) where labelfile.abbr = orderheader.ord_revtype3 and labelfile.labeldefinition = 'RevType3'),''), 
       orderheader.ord_revtype4 as 'RevType4',
       'RevType4 Name' = IsNull((select labelfile.name from labelfile WITH (NOLOCK) where labelfile.abbr = orderheader.ord_revtype4 and labelfile.labeldefinition = 'RevType4'),''),
       stops.cmp_id as 'Stop Company ID',
       'Stop Company Name' = IsNull((select company.cmp_name from Company WITH (NOLOCK) where Company.cmp_id = stops.cmp_id),''), 
       'Stop City' = IsNull((select city.cty_name from City WITH (NOLOCK) where stops.stp_city = city.cty_code),''),
       stops.stp_state  as 'Stop State',
       stops.stp_schdtearliest as 'Scheduled Earliest Date',
       (Cast(Floor(Cast(stops.stp_schdtearliest as float))as smalldatetime)) AS [Scheduled Earliest Date Only],
       stops.stp_origschdt as 'Original Scheduled Date',
       (Cast(Floor(Cast(stops.stp_origschdt as float))as smalldatetime)) AS [Original Scheduled Date Only],
       stops.stp_schdtlatest as 'Scheduled Latest Date',
       (Cast(Floor(Cast(stops.stp_schdtlatest as float))as smalldatetime)) AS [Scheduled Latest Date Only],
       stops.stp_arrivaldate as 'Arrival Date',
       (Cast(Floor(Cast(stops.stp_arrivaldate  as float))as smalldatetime)) AS [Arrival Date Only],
       stops.stp_departuredate as 'Departure Date',
       (Cast(Floor(Cast(stops.stp_departuredate  as float))as smalldatetime)) AS [Departure Date Only],
       stops.stp_type as 'Stop Type',
       stops.stp_number as 'Stop Number',
       stops.stp_event as 'Event',
       legheader.lgh_driver1 as 'Driver ID',
       legheader.lgh_carrier as 'Carrier ID',
       'Driver Name' = IsNull((select manpowerprofile.mpp_lastfirst from manpowerprofile WITH (NOLOCK) where manpowerprofile.mpp_id = legheader.lgh_driver1),legheader.lgh_driver1),
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
       lbl.name as 'Reason Late Text',
       stops.stp_reasonlate_depart as 'Reason Late Depart',
       lbl2.name as 'Reason Late Depart Text',
       stops.lgh_number as 'LegHeader Number',
       stops.mov_number as 'Move Number',
       stops.stp_mfh_sequence as 'Sequence in Movement',
       stops.stp_sequence as 'Sequence in Trip Segment',
       stops.stp_weight as 'Stop Weight',
       stops.stp_weightunit as 'Stop Weight Unit',
       stops.cmd_code as 'Commodity ID',
       legheader.fgt_description as [Commodity],
       stops.stp_comment as 'Comments',
       stops.stp_count as 'Stop Quantity',
       stops.stp_count as 'Stop Unit',       
       stops.stp_volume as 'Stop Volume',
       stops.stp_volumeunit as 'Stop Volume Unit', 
       stops.stp_status as 'Stop Status',
       stops.stp_description as 'Stop Description',
       IsNull(ord_trailer,lgh_primary_trailer) as 'Primary Trailer ID',


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

      IsNull((select max(invoiceheader.ivh_ref_number) 
      from invoiceheader WITH (NOLOCK) 
      where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber),orderheader.ord_refnum) as [Reference Number],
      (select city.cty_name from city WITH (NOLOCK) where city.cty_code = orderheader.ord_origincity) as 'Origin City',
      (select city.cty_name from city WITH (NOLOCK) where city.cty_code = orderheader.ord_destcity) as 'Dest City', 
      orderheader.ord_originstate as 'Origin State', 
      orderheader.ord_deststate as 'Destination State', 
      'Reason Late Description' = IsNull((select labelfile.name from labelfile WITH (NOLOCK) where labelfile.abbr = stops.stp_reasonlate and labelfile.labeldefinition = 'ReasonLate'),stops.stp_reasonlate),
      [Responsible Party] = Case When (select labelfile.code from labelfile WITH (NOLOCK) where labelfile.abbr = stops.stp_reasonlate and labelfile.labeldefinition = 'ReasonLate') between 0 and 99 Then
								'Carrier'
							       When (select labelfile.code from labelfile WITH (NOLOCK) where labelfile.abbr = stops.stp_reasonlate and labelfile.labeldefinition = 'ReasonLate') between 100 and 199 Then
								'Company'
								   When (select labelfile.code from labelfile WITH (NOLOCK) where labelfile.abbr = stops.stp_reasonlate and labelfile.labeldefinition = 'ReasonLate') >= 200 Then
								'No Fault'
								   Else	
										cast('' as varchar(1))
						     End,

       datediff( mi,stops.stp_schdtlatest,stops.stp_arrivaldate) as SchdLatArrDateMinDiff

from stops WITH (NOLOCK)
join orderheader WITH (NOLOCK) on stops.ord_hdrnumber = orderheader.ord_hdrnumber
join legheader WITH (NOLOCK) on legheader.lgh_number = stops.lgh_number
left join labelfile lbl with (nolock) on lbl.abbr = stops.stp_reasonlate and lbl.labeldefinition = 'ReasonLate'
left join labelfile lbl2 with (nolock) on lbl2.abbr = stops.stp_reasonlate_depart and lbl2.labeldefinition = 'ReasonLate'
Where
stops.ord_hdrnumber = orderheader.ord_hdrnumber
And
legheader.lgh_number = stops.lgh_number
And
stops.stp_status='DNE' and stops.stp_type <> 'None'  and stops.stp_type <> 'UNK'


GO
GRANT SELECT ON  [dbo].[vSSRSRB_OnTimePerformance] TO [public]
GO
