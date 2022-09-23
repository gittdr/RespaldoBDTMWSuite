SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO






--select * from vTTSTMW_AvailableLoads where OrderNo ='2326'


--select ord_hdrnumber,stp_status,stp_mfh_sequence,* from stops where lgh_number=849

CREATE    View [dbo].[vTTSTMW_AvailableLoads]

As


Select TempLegHeaderAndStops.*,
       'Driver' =    (select lgh_driver1 from legheader where Min_LegHeaderNumber = legheader.lgh_number),
       'Tractor' =   (select lgh_tractor from legheader where Min_LegHeaderNumber = legheader.lgh_number),
       'Trailer' =   (select lgh_primary_trailer from legheader where Min_LegHeaderNumber = legheader.lgh_number),
       'DrvType1' = (select mpp_type1 from legheader where Min_LegHeaderNumber = legheader.lgh_number),
       'DrvType2' = (select mpp_type2 from legheader where Min_LegHeaderNumber = legheader.lgh_number),
       'DrvType3' = (select mpp_type3 from legheader where Min_LegHeaderNumber = legheader.lgh_number),
       'DrvType4' = (select mpp_type3 from legheader where Min_LegHeaderNumber = legheader.lgh_number),
       --'Origin State' = (select company_state from #TempSetupAvlLoads A where A.ord_hdrnumber = #TempFinalAvlLoads.ord_hdrnumber and A.Seq = (select Min(B.Seq) from #TempSetupAvlLoads B where A.ord_hdrnumber = B.ord_hdrnumber)),
       'Origin State' = (select City.cty_state from City (NOLOCK),stops (NOLOCK) where stp_city = cty_code and stops.lgh_number = Min_LegHeaderNumber and stp_mfh_sequence = minopenseq)
	--
	--'Destination State' =   (select company_state from #TempSetupAvlLoads A where A.ord_hdrnumber = #TempFinalAvlLoads.ord_hdrnumber and A.Seq = (select Max(B.Seq) from #TempSetupAvlLoads B where A.ord_hdrnumber = B.ord_hdrnumber)),
      -- 'Origin City' =     (select company_city from #TempSetupAvlLoads A where A.ord_hdrnumber = #TempFinalAvlLoads.ord_hdrnumber and A.Seq = (select Min(B.Seq) from #TempSetupAvlLoads B where A.ord_hdrnumber = B.ord_hdrnumber)),
      -- 'Dest City' =       (select company_city from #TempSetupAvlLoads A where A.ord_hdrnumber = #TempFinalAvlLoads.ord_hdrnumber and A.Seq = (select Max(B.Seq) from #TempSetupAvlLoads B where A.ord_hdrnumber = B.ord_hdrnumber)),
      -- 'Order Origin Earliest Date' = (select Scheduled_DateTime from #TempSetupAvlLoads A where A.ord_hdrnumber = #TempFinalAvlLoads.ord_hdrnumber and A.Seq = (select Min(B.Seq) from #TempSetupAvlLoads B where A.ord_hdrnumber = B.ord_hdrnumber)),
      -- 'Order Destination Earliest Date' = (select Scheduled_DateTime from #TempSetupAvlLoads A where A.ord_hdrnumber = #TempFinalAvlLoads.ord_hdrnumber and A.Seq = (select Max(B.Seq) from #TempSetupAvlLoads B where A.ord_hdrnumber = B.ord_hdrnumber))

From

(


Select  TempAVL.*,
	stp_arrivaldate as Scheduled_DateTime, --ETA date
	stp_event as Event,
	'CompanyID' =  (select Company.cmp_name from Company where stops.cmp_id = Company.cmp_id), 
	'Company City State' = (select City.cty_name + ', '+ City.cty_state from City where stops.stp_city = City.cty_code),
	'Commodity' = (select cmd_name from Commodity where stops.cmd_code = Commodity.cmd_code), 
	stp_mfh_sequence as Seq,
	stp_status as [Stop Status],
	legheader.lgh_number,
	lgh_outstatus as [Dispatch Status],
	lgh_startdate as [Start Date], 				
	'Company State' = (select City.cty_state from City where stops.stp_city = City.cty_code),
	'Company City' = (select City.cty_name from City where stops.stp_city = City.cty_code),
	Case When OrdStatus = 'STD' Then
 		lgh_outstatus
 	else
		OrdStatus
	End As NewOrdStatus,
	'Min_LegHeaderNumber' = (select Min(B.lgh_number) from stops B (NOLOCK) Where B.ord_hdrnumber = TempAVL.ord_hdrnumber and B.stp_status = 'OPN'),
	'minopenseq' = (select Min(A.stp_mfh_sequence) from stops A (NOLOCK) where A.stp_status = 'OPN' and A.lgh_number = (select Min(B.lgh_number) from stops B (NOLOCK) Where B.ord_hdrnumber = TempAVL.ord_hdrnumber and B.stp_status = 'OPN')),
	 stops.stp_arrivaldate as 'Arrival Date',
	 cast(DatePart(yyyy,stp_arrivaldate) as varchar(4)) + '-' + cast(DatePart(mm,stp_arrivaldate) as varchar(4)) + '-' + cast(DatePart(dd,stp_arrivaldate) as varchar(2)) + ' ' + cast(DatePart(hh,stp_arrivaldate) as varchar(2)) + ':' + case when len(cast(DatePart(mm,stp_arrivaldate) as varchar(2))) < 2 Then '0' + cast(DatePart(mm,stp_arrivaldate) as varchar(2)) Else cast(DatePart(mm,stp_arrivaldate) as varchar(2)) End as 'Arrival Date Military',
         stops.stp_departuredate as 'Departure Date',
	 IsNull(stops.stp_lgh_mileage,0) as 'Travel Miles',
         IsNull(stops.stp_ord_mileage,0) as 'Billed Miles'
			
From

(

select 	'Shipper' = (select Company.cmp_name from Company where orderheader.ord_shipper = Company.cmp_id), 
	'Consignee' = (select Company.cmp_name from Company where orderheader.ord_consignee = Company.cmp_id), 
	--'origin_city_state' = (select City.cty_name + ', '+ City.cty_state from City where orderheader.ord_origincity = City.cty_code), 
	--'dest_city_state' = (select City.cty_name + ', '+ City.cty_state from City where orderheader.ord_destcity = City.cty_code),
	--stp_schdtearliest as Scheduled_DateTime,	
	--stp_event as Event,
	--'Company' =  (select Company.cmp_name from Company where stops.cmp_id = Company.cmp_id), 
	--'company_city_state' = (select City.cty_name + ', '+ City.cty_state from City where stops.stp_city = City.cty_code), 		
	ord_number as OrderNo,
	--ord_trailer as Trailer,
	--'Commodity' = (select cmd_name from Commodity where stops.cmd_code = Commodity.cmd_code), 
	--ord_tractor as Tractor,
	--ord_driver1 as Driver,
	ord_status as OrdStatus,
	--stp_mfh_sequence as Seq,
	--Base Level Code
	
	--<TTS!*!TMW><Begin><SQLVersion=7>
--	ord_totalcharge as Revenue,
	--<TTS!*!TMW><End><SQLVersion=7> 	

	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	IsNull(dbo.fnc_convertcharge(ord_totalcharge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00) as Revenue,
	--<TTS!*!TMW><End><SQLVersion=2000+> 	

	ord_totalweight as Weight,
	ord_hdrnumber,
	mov_number,
	'min_stpmfh_seq' = (select Min(stp_mfh_sequence) from stops where orderheader.ord_hdrnumber = stops.ord_hdrnumber),	
	'max_stpmfh_seq' = (select Max(stp_mfh_sequence) from stops where orderheader.ord_hdrnumber = stops.ord_hdrnumber),
	--'maxopenseq' = (select Max(stp_mfh_sequence) from stops where orderheader.ord_hdrnumber = stops.ord_hdrnumber  and stp_status = 'OPN'),
	'TrailerType' = IsNull((select Top 1 name from labelfile where abbr = orderheader.trl_type1 and labeldefinition = 'TrlType1'),trl_type1),
	ord_startdate as [Ship Date],
	ord_remark as Remarks,
	ord_billto as 'Bill To ID', 
	'Bill To' = (select cmp_name from company (NOLOCK) where cmp_id = ord_billto)
	

from 	orderheader (NOLOCK)

Where
	(ord_status = 'AVL' or ord_status = 'STD' or ord_status = 'PRK')
) as TempAVL,stops (NOLOCK),legheader (NOLOCK)	
where   TempAVL.mov_number=stops.mov_number
   	and
	stops.lgh_number = legheader.lgh_number
	and
       	(stops.stp_mfh_sequence >= min_stpmfh_seq and stops.stp_mfh_sequence <= max_stpmfh_seq and (stops.ord_hdrnumber = TempAvl.ord_hdrnumber Or stops.ord_hdrnumber = 0))
       	and
       	(stops.stp_status = 'OPN')

) as TempLegHeaderAndStops

Where NewOrdStatus = 'AVL'







GO
GRANT SELECT ON  [dbo].[vTTSTMW_AvailableLoads] TO [public]
GO
