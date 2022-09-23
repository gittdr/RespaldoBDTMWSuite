SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE View [dbo].[vSSRSB_AvailableLoads]

As


Select 
	[Arrival Date],
	[Arrival Date Military],
	[Arrival Date Only],
	[Bill To],
	[Bill To ID],
	[Billed Miles],
	[Commodity],
	[Company City],
	[Company City State],
	[Company State],
	[CompanyID],
	[Consignee],
	[Departure Date],
	[Destination State] = (select City.cty_state from City WITH (NOLOCK),stops WITH (NOLOCK) where stp_city = cty_code and stops.lgh_number = max_LegHeaderNumber and stp_mfh_sequence = maxopenseq),
	[DispatchStatus],
	[Driver] = (select lgh_driver1 from legheader WITH (NOLOCK) where Min_LegHeaderNumber = legheader.lgh_number),
	[DrvType1] = (select mpp_type1 from legheader WITH (NOLOCK) where Min_LegHeaderNumber = legheader.lgh_number),
    [DrvType2] = (select mpp_type2 from legheader WITH (NOLOCK) where Min_LegHeaderNumber = legheader.lgh_number),
    [DrvType3] = (select mpp_type3 from legheader WITH (NOLOCK) where Min_LegHeaderNumber = legheader.lgh_number),
    [DrvType4] = (select mpp_type3 from legheader WITH (NOLOCK) where Min_LegHeaderNumber = legheader.lgh_number),
	[Event],
	[lgh_number],
	[Max_LegHeaderNumber],
	[max_stpmfh_seq],
	[maxopenseq],
	[Min_LegHeaderNumber],
	[min_stpmfh_seq],
	[minopenseq],
	[mov_number],
	[NewOrdStatus],
	[ord_hdrnumber],
	[OrderNo],
	[OrdStatus],
    [Origin State] = (select City.cty_state from City WITH (NOLOCK),stops WITH (NOLOCK) where stp_city = cty_code and stops.lgh_number = Min_LegHeaderNumber and stp_mfh_sequence = minopenseq),
	[Remarks],
	[Revenue],
	[RevType1],
	[RevType1 Name],
	[RevType2],
	[RevType2 Name],
	[RevType3],
	[RevType3 Name],
	[RevType4],
	[RevType4 Name],
	[Scheduled_DateTime],
	[Seq],
	[Ship Date],
	[Shipper],
	[Start Date],
	[Stop Status],
	[Tractor] = (select lgh_tractor from legheader WITH (NOLOCK) where Min_LegHeaderNumber = legheader.lgh_number),
	[Trailer] = (select lgh_primary_trailer from legheader WITH (NOLOCK) where Min_LegHeaderNumber = legheader.lgh_number),
	[TrailerType],
	[Travel Miles],
	[Weight]

From

(


Select  TempAVL.*,
	stp_arrivaldate as Scheduled_DateTime, --ETA date
	stp_event as Event,
	'CompanyID' =  (select Company.cmp_name from Company WITH (NOLOCK) where stops.cmp_id = Company.cmp_id), 
	'Company City State' = (select City.cty_name + ', '+ City.cty_state from City WITH (NOLOCK) where stops.stp_city = City.cty_code),
	'Commodity' = (select cmd_name from Commodity WITH (NOLOCK) where stops.cmd_code = Commodity.cmd_code), 
	stp_mfh_sequence as Seq,
	stp_status as [Stop Status],
	legheader.lgh_number,
	lgh_outstatus as [DispatchStatus],
	lgh_startdate as [Start Date], 				
	'Company State' = (select City.cty_state from City WITH (NOLOCK) where stops.stp_city = City.cty_code),
	'Company City' = (select City.cty_name from City WITH (NOLOCK) where stops.stp_city = City.cty_code),
	Case When OrdStatus = 'STD' Then
 		lgh_outstatus
 	else
		OrdStatus
	End As NewOrdStatus,
	'Min_LegHeaderNumber' = (select Min(B.lgh_number) from stops B WITH (NOLOCK) Where B.ord_hdrnumber = TempAVL.ord_hdrnumber and B.stp_status = 'OPN'),
	'minopenseq' = (select Min(A.stp_mfh_sequence) from stops A WITH (NOLOCK) where A.stp_status = 'OPN' and A.lgh_number = (select Min(B.lgh_number) from stops B WITH (NOLOCK) Where B.ord_hdrnumber = TempAVL.ord_hdrnumber and B.stp_status = 'OPN')),
	'Max_LegHeaderNumber' = (select Max(B.lgh_number) from stops B WITH (NOLOCK) Where B.ord_hdrnumber = TempAVL.ord_hdrnumber and B.stp_status = 'OPN'),
	'maxopenseq' = (select Max(A.stp_mfh_sequence) from stops A WITH (NOLOCK) where A.stp_status = 'OPN' and A.lgh_number = (select Min(B.lgh_number) from stops B WITH (NOLOCK) Where B.ord_hdrnumber = TempAVL.ord_hdrnumber and B.stp_status = 'OPN')),
	 (Cast(Floor(Cast(stops.stp_arrivaldate as float))as smalldatetime)) AS [Arrival Date Only],
	 stops.stp_arrivaldate as 'Arrival Date',
	 cast(DatePart(yyyy,stp_arrivaldate) as varchar(4)) + '-' + cast(DatePart(mm,stp_arrivaldate) as varchar(4)) + '-' + cast(DatePart(dd,stp_arrivaldate) as varchar(2)) + ' ' + cast(DatePart(hh,stp_arrivaldate) as varchar(2)) + ':' + case when len(cast(DatePart(mm,stp_arrivaldate) as varchar(2))) < 2 Then '0' + cast(DatePart(mm,stp_arrivaldate) as varchar(2)) Else cast(DatePart(mm,stp_arrivaldate) as varchar(2)) End as 'Arrival Date Military',
         stops.stp_departuredate as 'Departure Date',
	 IsNull(stops.stp_lgh_mileage,0) as 'Travel Miles',
         IsNull(stops.stp_ord_mileage,0) as 'Billed Miles'
			
From

(

select 	'Shipper' = (select Company.cmp_name from Company WITH (NOLOCK) where ord.ord_shipper = Company.cmp_id), 
	'Consignee' = (select Company.cmp_name from Company WITH (NOLOCK) where ord.ord_consignee = Company.cmp_id), 
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
	ord_totalcharge as Revenue,
	--<TTS!*!TMW><End><SQLVersion=7> 	

	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	--IsNull(dbo.TMWSSRS_fnc_convertcharge(ord_totalcharge,ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00) as Revenue,
	--<TTS!*!TMW><End><SQLVersion=2000+> 	

	ord_totalweight as Weight,
	ord_hdrnumber,
	mov_number,
	'min_stpmfh_seq' = (select Min(stp_mfh_sequence) from stops WITH (NOLOCK) where ord.ord_hdrnumber = stops.ord_hdrnumber),	
	'max_stpmfh_seq' = (select Max(stp_mfh_sequence) from stops WITH (NOLOCK) where ord.ord_hdrnumber = stops.ord_hdrnumber),
	--'maxopenseq' = (select Max(stp_mfh_sequence) from stops where orderheader.ord_hdrnumber = stops.ord_hdrnumber  and stp_status = 'OPN'),
	'TrailerType' = IsNull((select Top 1 name from labelfile WITH (NOLOCK) where abbr = ord.trl_type1 and labeldefinition = 'TrlType1'),trl_type1),
	ord_startdate as [Ship Date],
	ord_remark as Remarks,
	ord_billto as 'Bill To ID', 
	'Bill To' = (select cmp_name from company WITH (NOLOCK) where cmp_id = ord_billto),
	ord.ord_revtype1 as 'RevType1', --RevType1
	isnull(RevType1.name,'') as 'RevType1 Name',--RevType1 Name
	ord.ord_revtype2 as 'RevType2', --RevType2
	isnull(RevType2.name,'') as 'RevType2 Name',--RevType2 Name
	ord.ord_revtype3 as 'RevType3', --RevType3
	isnull(RevType3.name,'') as 'RevType3 Name',--RevType3 Name
	ord.ord_revtype4 as 'RevType4', --RevType4
	isnull(RevType4.name,'') as 'RevType4 Name'--RevType4 Name
	

from 	orderheader ord WITH (NOLOCK)
left join labelfile RevType1 WITH (NOLOCK) on RevType1.abbr = ord.ord_revtype1 and RevType1.labeldefinition = 'RevType1'
left join labelfile RevType2 WITH (NOLOCK) on RevType2.abbr = ord.ord_revtype2 and RevType2.labeldefinition = 'RevType2'
left join labelfile RevType3 WITH (NOLOCK) on RevType3.abbr = ord.ord_revtype3 and RevType3.labeldefinition = 'RevType3'
left join labelfile RevType4 WITH (NOLOCK) on RevType4.abbr = ord.ord_revtype4 and RevType4.labeldefinition = 'RevType4'

Where
	(ord_status = 'AVL' or ord_status = 'STD' or ord_status = 'PRK')
) as TempAVL,stops WITH (NOLOCK),legheader WITH (NOLOCK)
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
GRANT SELECT ON  [dbo].[vSSRSB_AvailableLoads] TO [public]
GO
