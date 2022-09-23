SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE View [dbo].[vSSRSRB_AllStopDetails_RTfromLeg]
As
/**
 *
 * NAME:
 * dbo.[vSSRSRB_AllStopDetails_RTfromLeg]
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * TAll stop details view RTfromLeg version 
 
 *
**************************************************************************

Sample call

select * from vSSRSRB_AllStopDetails_RTfromLeg


**************************************************************************
 * RETURNS:
 * Recordset
 *
 * RESULT SETS:
 *Stop details plus RT from leg
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 --Revision History
--1. Added Trend Analysis Fields For Ver 5.62
--2. Added stop company address and phone to resemble trip sheet Ver 5.7
--3. Added Carrier ID V 5.7
 * 3/18/2014 JR created SSRS version of the view
 **/



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
       Cast(DatePart(yyyy,orderheader.[ord_completiondate]) as varchar(4)) 
       +  '-' + Cast(DatePart(mm,orderheader.[ord_completiondate]) as varchar(2)) + '-' 
       + Cast(DatePart(dd,orderheader.[ord_completiondate]) as varchar(2)) as [Delivery Day],
       --Month
       Cast(DatePart(mm,orderheader.[ord_completiondate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,orderheader.[ord_completiondate]) as varchar(4)) as [Delivery Month],
       DatePart(mm,orderheader.[ord_completiondate]) as [Delivery Month Only],
       --Year
       DatePart(yyyy,orderheader.[ord_completiondate]) as [Delivery Year], 
       --**Ship Date**
       orderheader.ord_startdate as 'Ship Date', 
       --Day
       (Cast(Floor(Cast(orderheader.[ord_startdate] as float))as smalldatetime)) as [Ship Date Only], 
       Cast(DatePart(yyyy,orderheader.[ord_startdate]) as varchar(4)) +  '-' + Cast(DatePart(mm,orderheader.[ord_startdate]) as varchar(2)) 
       + '-' + Cast(DatePart(dd,orderheader.[ord_startdate]) as varchar(2)) as [Ship Day],
       --Month
       Cast(DatePart(mm,orderheader.[ord_startdate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,orderheader.[ord_startdate]) as varchar(4)) as [Ship Month],
       DatePart(mm,orderheader.[ord_startdate]) as [Ship Month Only],
       --Year
       DatePart(yyyy,orderheader.[ord_startdate]) as [Ship Year],
       orderheader.ord_shipper as 'Shipper ID',
       'Shipper Name' = IsNull((select company.cmp_name from company  with(NOLOCK)  where company.cmp_id = orderheader.ord_shipper),orderheader.ord_shipper),
       orderheader.ord_consignee as 'Consignee ID',
       'Consignee' = IsNull((select company.cmp_name from company  with(NOLOCK)  where company.cmp_id = orderheader.ord_consignee),orderheader.ord_consignee),
       orderheader.ord_billto as 'Bill To ID',
       'Bill To Name' = IsNull((select company.cmp_name from company  with(NOLOCK)  where company.cmp_id = orderheader.ord_billto),orderheader.ord_billto),
       orderheader.ord_company  as 'Ordered By ID',
       'Ordered By Name' = IsNull((select company.cmp_name from company  with(NOLOCK)  where company.cmp_id = orderheader.ord_company),orderheader.ord_company),
       legheader.lgh_class1 as 'RevType1', 
       'RevType1 Name' = IsNull((select labelfile.name from labelfile  with(NOLOCK)  where labelfile.abbr = legheader.lgh_class1 and labelfile.labeldefinition = 'RevType1'),''),
       legheader.lgh_class2 as 'RevType2',
       'RevType2 Name' = IsNull((select labelfile.name from labelfile  with(NOLOCK)  where labelfile.abbr = legheader.lgh_class2 and labelfile.labeldefinition = 'RevType2'),''),
       legheader.lgh_class3 as 'RevType3',
       'RevType3 Name' = IsNull((select labelfile.name from labelfile  with(NOLOCK)  where labelfile.abbr = legheader.lgh_class3 and labelfile.labeldefinition = 'RevType3'),''), 
       legheader.lgh_class4 as 'RevType4',
       'RevType4 Name' = IsNull((select labelfile.name from labelfile  with(NOLOCK)  where labelfile.abbr = legheader.lgh_class4 and labelfile.labeldefinition = 'RevType4'),''),
       stops.cmp_id as 'Stop Company ID',
       'Stop Company Name' = IsNull((select company.cmp_name from Company  with(NOLOCK)  where Company.cmp_id = stops.cmp_id),''), 
       'Stop City' = IsNull((select city.cty_name from City  with(NOLOCK)  where stops.stp_city = city.cty_code),''),
       stops.stp_state  as 'Stop State',
       stops.stp_schdtearliest as 'Scheduled Earliest Date',
       (Cast(Floor(Cast(stops.stp_schdtearliest as float))as smalldatetime)) AS [Scheduled Earliest Date Only],
       stops.stp_origschdt as 'Original Scheduled Date',
       (Cast(Floor(Cast(stops.stp_origschdt as float))as smalldatetime)) AS [Original Scheduled Date Only],
       stops.stp_schdtlatest as 'Scheduled Latest Date',
        (Cast(Floor(Cast(stops.stp_schdtlatest as float))as smalldatetime)) AS [Scheduled Latest Date Only],
       stops.stp_arrivaldate as 'Arrival Date',
         (Cast(Floor(Cast(stops.stp_arrivaldate as float))as smalldatetime)) AS [Arrival Date Only],
       stops.stp_departuredate as 'Departure Date',
        (Cast(Floor(Cast(stops.stp_departuredate as float))as smalldatetime)) AS [Departure Date Only],
       stops.stp_type as 'Stop Type',
       stops.stp_event as 'Event',
       legheader.lgh_carrier as 'Carrier ID',
       legheader.lgh_driver1 as 'Driver ID',
       'Driver Name' = IsNull((select manpowerprofile.mpp_lastfirst from manpowerprofile  with(NOLOCK)  where manpowerprofile.mpp_id = legheader.lgh_driver1),legheader.lgh_driver1),
       legheader.mpp_terminal as 'Driver Terminal',
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
       stops.lgh_number as 'Leg Number',
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
       orderheader.ord_status as 'OrderStatus',
       event.evt_trailer1 as 'Trailer1 ID',
       event.evt_trailer2 as 'Trailer2 ID',
       orderheader.ord_currencydate as 'Currency Date',
        (Cast(Floor(Cast(orderheader.ord_currencydate as float))as smalldatetime)) AS [Currency Date Only],
       orderheader.ord_remark as Remarks,
       orderheader.ord_bookdate as 'Book Date',
       (Cast(Floor(Cast(orderheader.ord_bookdate as float))as smalldatetime)) AS [Book Date Only],
       orderheader.ord_dest_earliestdate as 'Destination Earliest Date',
       (Cast(Floor(Cast(orderheader.ord_dest_earliestdate as float))as smalldatetime)) AS [Destination Earliest Date Only],
       orderheader.ord_dest_latestdate as 'Destination Latest Date',
       (Cast(Floor(Cast(orderheader.ord_dest_latestdate as float))as smalldatetime)) AS [Destination Latest Date Only],
       orderheader.ord_origin_earliestdate as 'Origin Earliest Date',
        (Cast(Floor(Cast(orderheader.ord_origin_earliestdate as float))as smalldatetime)) AS [Origin Earliest Date Only],
       orderheader.ord_origin_latestdate as 'Origin Latest Date', 
        (Cast(Floor(Cast( orderheader.ord_origin_latestdate as float))as smalldatetime)) AS [Origin Latest Date Only],   
       orderheader.ord_availabledate as 'Available Date',
        (Cast(Floor(Cast(orderheader.ord_availabledate as float))as smalldatetime)) AS [Available Date Only],   
       orderheader.ord_bookedby as 'Booked By',
       orderheader.ord_destpoint as 'Destination Point',
       orderheader.ord_datetaken as 'Date Taken',
       (Cast(Floor(Cast(orderheader.ord_datetaken as float))as smalldatetime)) AS [Date Taken Date Only],     
       IsNull(event.evt_hubmiles,0) as 'Hub Mile Reading',
             Case When (select Top 1 'Y' from stops c  with(NOLOCK)  where c.mov_number = stops.mov_number and c.stp_mfh_sequence = stops.stp_mfh_sequence - 1) Is Null Then
            0
       Else 
            IsNull(event.evt_hubmiles,0) - IsNull((select Max(b.evt_hubmiles) from event b  with(NOLOCK) ,stops c  with(NOLOCK)  where c.mov_number = stops.mov_number and c.stp_mfh_sequence = stops.stp_mfh_sequence - 1 and b.stp_number = c.stp_number),0)
       End as [Hub Miles],
       IsNull((select max(invoiceheader.ivh_ref_number) from invoiceheader  with(NOLOCK)  where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber),orderheader.ord_refnum) as [Reference Number],
      (select city.cty_name from city  with(NOLOCK)  where city.cty_code = orderheader.ord_origincity) as 'Origin City',
      (select city.cty_name from city  with(NOLOCK)  where city.cty_code = orderheader.ord_destcity) as 'Destination City', 
      orderheader.ord_originstate as 'Origin State', 
      orderheader.ord_deststate as 'Destination State', 
      ord_reftype as 'Ref Type', 
      stp_activitystart_dt as [Activity Start Date],
      (Cast(Floor(Cast(stp_activitystart_dt as float))as smalldatetime)) AS [Activity Start Date Only],
      stp_activityend_dt as [Activity End Date],
      (Cast(Floor(Cast(stp_activityend_dt as float))as smalldatetime)) AS [Activity End Date Only],
      'Reason Late Description' = IsNull((select labelfile.name from labelfile  with(NOLOCK)  where labelfile.abbr = stops.stp_reasonlate and labelfile.labeldefinition = 'ReasonLate'),stops.stp_reasonlate),
      company.cmp_address1 as [Stop Company Address1],
      company.cmp_address2 as [Stop Company Address2],
      company.cmp_primaryphone  as [Stop Company Phone],
      cast(company.cmp_directions as varchar(255)) as [Stop Company Directions],
  
      (select min(ref_type) from referencenumber  with(NOLOCK)  where referencenumber.ref_tablekey = stops.ord_hdrnumber and ref_sequence = 1 and ref_table = 'orderheader') as OrdRefType1,
      (select min(ref_number) from referencenumber  with(NOLOCK)  where referencenumber.ref_tablekey = stops.ord_hdrnumber and ref_sequence = 1 and ref_table = 'orderheader') as OrdRefNumber1,
      (select min(ref_type) from referencenumber  with(NOLOCK)  where referencenumber.ref_tablekey = stops.ord_hdrnumber and ref_sequence = 2 and ref_table = 'orderheader') as OrdRefType2,
      (select min(ref_number) from referencenumber  with(NOLOCK)  where referencenumber.ref_tablekey = stops.ord_hdrnumber and ref_sequence = 2 and ref_table = 'orderheader') as OrdRefNumber2,
      (select min(ref_type) from referencenumber  with(NOLOCK)  where referencenumber.ref_tablekey = stops.ord_hdrnumber and ref_sequence = 3 and ref_table = 'orderheader') as OrdRefType3,
      (select min(ref_number) from referencenumber  with(NOLOCK)  where referencenumber.ref_tablekey = stops.ord_hdrnumber and ref_sequence = 3 and ref_table = 'orderheader') as OrdRefNumber3,
      (select min(ref_type) from referencenumber  with(NOLOCK)  where referencenumber.ref_tablekey = stops.ord_hdrnumber and ref_sequence = 4 and ref_table = 'orderheader') as OrdRefType4,
      (select min(ref_number) from referencenumber  with(NOLOCK)  where referencenumber.ref_tablekey = stops.ord_hdrnumber and ref_sequence = 4 and ref_table = 'orderheader') as OrdRefNumber4,
      

      (select Min(city.cty_region1) from city  with(NOLOCK)  Where orderheader.ord_origincity = city.cty_code) as [Origin Region1],
      (select Min(city.cty_region2) from city  with(NOLOCK)  Where orderheader.ord_origincity = city.cty_code) as [Origin Region2],
      (select Min(city.cty_region3) from city  with(NOLOCK)  Where orderheader.ord_origincity = city.cty_code) as [Origin Region3],
      (select Min(city.cty_region4) from city  with(NOLOCK)  Where orderheader.ord_origincity = city.cty_code) as [Origin Region4],
      (select Min(city.cty_region1) from city  with(NOLOCK)  Where orderheader.ord_destcity = city.cty_code) as [Destination Region1],
      (select Min(city.cty_region2) from city  with(NOLOCK)  Where orderheader.ord_destcity = city.cty_code) as [Destination Region2],
      (select Min(city.cty_region3) from city  with(NOLOCK)  Where orderheader.ord_destcity = city.cty_code) as [Destination Region3],
      (select Min(city.cty_region4) from city  with(NOLOCK)  Where orderheader.ord_destcity = city.cty_code) as [Destination Region4],  
      --**Segment Start Date**
      lgh_startDate     'Segment Start Date',
      --Day
      (Cast(Floor(Cast([lgh_startDate] as float))as smalldatetime)) as [Segment Start Date Only], 
      Cast(DatePart(yyyy,[lgh_startDate]) as varchar(4)) +  '-' + Cast(DatePart(mm,[lgh_startDate]) as varchar(2)) + '-' + Cast(DatePart(dd,[lgh_startDate]) as varchar(2)) as [Segment Start Day],
      --Month
      Cast(DatePart(mm,[lgh_startDate]) as varchar(2)) + '/' + Cast(DatePart(yyyy,[lgh_startDate]) as varchar(4)) as [Segment Start Month],
      DatePart(mm,[lgh_startDate]) as [Segment Start Month Only],
      --Year
      DatePart(yyyy,[lgh_startDate]) as [Segment Start Year],
      --**Segment End Date**
      lgh_EndDate 'Segment End Date',
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

    Stops.stp_number as [Stop Number],
     stops.stp_zipcode as [Stop Zip Code]

from stops  with(NOLOCK)  Left Join  orderheader  with(NOLOCK)  On stops.ord_hdrnumber = orderheader.ord_hdrnumber
                  Left Join legheader  with(NOLOCK)  On legheader.lgh_number = stops.lgh_number
                Left Join event  with(NOLOCK)  on stops.stp_number = event.stp_number and event.evt_sequence = 1
                left outer join company with(NOLOCK)  on stops.cmp_id = company.cmp_id and company.cmp_id <>'UNKNOWN'

) as TempStopDetail



GO
GRANT SELECT ON  [dbo].[vSSRSRB_AllStopDetails_RTfromLeg] TO [public]
GO
