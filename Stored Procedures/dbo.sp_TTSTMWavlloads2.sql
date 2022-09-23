SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO













CREATE                      PROCEDURE [dbo].[sp_TTSTMWavlloads2] 
					(@sortoption char(30),
					 @frmdt datetime,
					 @tdt datetime,
					 @revtype1 varchar(120),
					 @revtype2 varchar(120),
					 @revtype3 varchar(120),
                                         @revtype4 varchar(120),
					 @originstate varchar (255),
					 @deststate varchar (255),
					 @originregion varchar (120),
					 @destregion varchar (120),
					 @drvtype1 varchar (255),
					 @drvtype2 varchar (255), 					
					 @drvtype3 varchar (255),
					 @drvtype4 varchar (255),
					 @orderstatus varchar (255)
					)
AS

--********************************************************************
--Available Loads Report is intended to see all orders and their
--associated stops that 
--are marked with an Order Status of either Available or Parked 
--********************************************************************

--Revision History
--1. Added UDF Currency Conversion Functionality
--2. Added Branch Code Ver 5.4 LBK


Declare @OnlyBranches as varchar(255)

SELECT @revtype1 = ',' + LTRIM(RTRIM(ISNULL(@revtype1, ''))) + ','
SELECT @revtype2 = ',' + LTRIM(RTRIM(ISNULL(@revtype2, ''))) + ','
SELECT @revtype3 = ',' + LTRIM(RTRIM(ISNULL(@revtype3, ''))) + ','
SELECT @revtype4 = ',' + LTRIM(RTRIM(ISNULL(@revtype4, ''))) + ','  

SELECT @originstate = ',' + LTRIM(RTRIM(ISNULL(@originstate, ''))) + ','
SELECT @deststate = ',' + LTRIM(RTRIM(ISNULL(@deststate, ''))) + ',' 

SELECT @originregion = ',' + LTRIM(RTRIM(ISNULL(@originregion, ''))) + ',' 
SELECT @destregion = ',' + LTRIM(RTRIM(ISNULL(@destregion, ''))) + ',' 

SELECT @drvtype1 = ',' + LTRIM(RTRIM(ISNULL(@drvtype1, ''))) + ','
SELECT @drvtype2 = ',' + LTRIM(RTRIM(ISNULL(@drvtype2, ''))) + ','
SELECT @drvtype3 = ',' + LTRIM(RTRIM(ISNULL(@drvtype3, ''))) + ',' 
SELECT @drvtype4 = ',' + LTRIM(RTRIM(ISNULL(@drvtype4, ''))) + ',' 

SELECT @orderstatus = ',' + LTRIM(RTRIM(ISNULL(@orderstatus, ''))) + ','

--<TTS!*!TMW><Begin><FeaturePack=Other>

--<TTS!*!TMW><End><FeaturePack=Other>
--<TTS!*!TMW><Begin><FeaturePack=Euro>
--Set @OnlyBranches = ',' + ISNULL( (Select usr_booking_terminal from ttsusers where usr_userid= user),'UNK') + ','
--If (Select count(*) from ttsusers where usr_userid= user and (usr_supervisor='Y' or usr_sysadmin='Y')) > 0 or user = 'dbo' 
--
--BEGIN
--
--Set @onlyBranches = 'ALL'
--
--END
--<TTS!*!TMW><End><FeaturePack=Euro>


--Grabs all orders with an order status of Available or Parked
--and all of the stops pertaining to the order
select 	'Shipper' = (select Company.cmp_name from Company where orderheader.ord_shipper = Company.cmp_id), 
	'Consignee' = (select Company.cmp_name from Company where orderheader.ord_consignee = Company.cmp_id), 
	'origin_city_state' = (select City.cty_name + ', '+ City.cty_state from City where orderheader.ord_origincity = City.cty_code), 
	'dest_city_state' = (select City.cty_name + ', '+ City.cty_state from City where orderheader.ord_destcity = City.cty_code),
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
	--IsNull(dbo.fnc_convertcharge(IsNull(ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0.00) as Revenue,
	--<TTS!*!TMW><End><SQLVersion=2000+> 	

	ord_totalweight as Weight,
	ord_hdrnumber,
	mov_number,
	'min_stpmfh_seq' = (select Min(stp_mfh_sequence) from stops where orderheader.ord_hdrnumber = stops.ord_hdrnumber),	
	'max_stpmfh_seq' = (select Max(stp_mfh_sequence) from stops where orderheader.ord_hdrnumber = stops.ord_hdrnumber),
	'TrailerType' = IsNull((select Top 1 name from labelfile where abbr = orderheader.trl_type1 and labeldefinition = 'TrlType1'),trl_type1)

into 	#TempAvlLoads
from 	orderheader
where 	
	(ord_startdate between @frmdt and @tdt)
	And 
	(@revtype1 = ',,' OR CHARINDEX(',' + ord_revtype1 + ',', @revtype1) > 0) 
        And
	(@revtype2 = ',,' OR CHARINDEX(',' + ord_revtype2 + ',', @revtype2) > 0) 
	And
	(@revtype3 = ',,' OR CHARINDEX(',' + ord_revtype3 + ',', @revtype3) > 0) 
	And
	(@revtype4 = ',,' OR CHARINDEX(',' + ord_revtype4 + ',', @revtype4) > 0) 
        And
	(ord_status = 'AVL' or ord_status = 'STD' or ord_status = 'PRK')
	--<TTS!*!TMW><Begin><FeaturePack=Other>
       
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--And
	--(
	--(@onlyBranches = 'ALL')
	--Or
	--(@onlyBranches <> 'ALL' And CHARINDEX(',' + orderheader.ord_booked_revtype1 + ',', @onlyBranches) > 0) 
	--)	
	--<TTS!*!TMW><End><FeaturePack=Euro>	

	
Select  #TEmpAvlLoads.*,
	stp_arrivaldate as Scheduled_DateTime, --ETA date
	stp_event as Event,
	'Company' =  (select Company.cmp_name from Company where stops.cmp_id = Company.cmp_id), 
	'company_city_state' = (select City.cty_name + ', '+ City.cty_state from City where stops.stp_city = City.cty_code),
	'Commodity' = (select cmd_name from Commodity where stops.cmd_code = Commodity.cmd_code), 
	stp_mfh_sequence as Seq,
	stp_status,
	legheader.lgh_number,
	lgh_outstatus,
	lgh_startdate, 				
	'company_state' = (select City.cty_state from City where stops.stp_city = City.cty_code),
	'company_city' = (select City.cty_name from City where stops.stp_city = City.cty_code)

into   #TempLoadsWithStops
from   #TEmpAvlLoads,stops,legheader
where  #TempAvlLoads.mov_number=stops.mov_number
   	and
	stops.lgh_number = legheader.lgh_number
	and
       	(stops.stp_mfh_sequence >= min_stpmfh_seq and stops.stp_mfh_sequence <= max_stpmfh_seq and (stops.ord_hdrnumber = #TempAvlLoads.ord_hdrnumber Or stops.ord_hdrnumber = 0))
       	and
       	(stops.stp_status = 'OPN')
	


select #TempLoadsWithStops.*,
        Case When OrdStatus = 'STD' Then
 		lgh_outstatus
 	else
		OrdStatus
	End As NewOrdStatus,
	
	'Min_LegHeaderNumber' = (select Min(lgh_number) from #TempLoadsWithStops B Where B.ord_hdrnumber = #TempLoadsWithStops.ord_hdrnumber)
	
	
into   #TempSetupAvlLoads
from   #TempLoadsWithStops


Select  #TempSetupAvlLoads.*,
	'Driver' =    (select lgh_driver1 from legheader where Min_LegHeaderNumber = legheader.lgh_number),
	'Tractor' =   (select lgh_tractor from legheader where Min_LegHeaderNumber = legheader.lgh_number),
	'Trailer' =   (select lgh_primary_trailer from legheader where Min_LegHeaderNumber = legheader.lgh_number),
	'mpp_type1' = (select mpp_type1 from legheader where Min_LegHeaderNumber = legheader.lgh_number),
	'mpp_type2' = (select mpp_type2 from legheader where Min_LegHeaderNumber = legheader.lgh_number),
	'mpp_type3' = (select mpp_type3 from legheader where Min_LegHeaderNumber = legheader.lgh_number),
	'mpp_type4' = (select mpp_type3 from legheader where Min_LegHeaderNumber = legheader.lgh_number)
	

into    #TempFinalAvlLoads
from    #TempSetupAvlLoads



select #TempFinalAvlLoads.*,
       'ord_originstate' = (select company_state from #TempSetupAvlLoads A where A.ord_hdrnumber = #TempFinalAvlLoads.ord_hdrnumber and A.Seq = (select Min(B.Seq) from #TempSetupAvlLoads B where A.ord_hdrnumber = B.ord_hdrnumber)),
       'ord_deststate' =   (select company_state from #TempSetupAvlLoads A where A.ord_hdrnumber = #TempFinalAvlLoads.ord_hdrnumber and A.Seq = (select Max(B.Seq) from #TempSetupAvlLoads B where A.ord_hdrnumber = B.ord_hdrnumber)),
       'origin_city' =     (select company_city from #TempSetupAvlLoads A where A.ord_hdrnumber = #TempFinalAvlLoads.ord_hdrnumber and A.Seq = (select Min(B.Seq) from #TempSetupAvlLoads B where A.ord_hdrnumber = B.ord_hdrnumber)),
       'dest_city' =       (select company_city from #TempSetupAvlLoads A where A.ord_hdrnumber = #TempFinalAvlLoads.ord_hdrnumber and A.Seq = (select Max(B.Seq) from #TempSetupAvlLoads B where A.ord_hdrnumber = B.ord_hdrnumber)),
       'ord_origin_earliestdate' = (select Scheduled_DateTime from #TempSetupAvlLoads A where A.ord_hdrnumber = #TempFinalAvlLoads.ord_hdrnumber and A.Seq = (select Min(B.Seq) from #TempSetupAvlLoads B where A.ord_hdrnumber = B.ord_hdrnumber)),
       'ord_dest_earliestdate' = (select Scheduled_DateTime from #TempSetupAvlLoads A where A.ord_hdrnumber = #TempFinalAvlLoads.ord_hdrnumber and A.Seq = (select Max(B.Seq) from #TempSetupAvlLoads B where A.ord_hdrnumber = B.ord_hdrnumber))

into #TempFinalRestrictAvlLoads
from #TempFinalAvlLoads

Select  *
From    #TempFinalRestrictAvlLoads
Where
	(@orderstatus = ',,' OR CHARINDEX(',' + NewOrdStatus + ',', @orderstatus) > 0)
	And
	(@drvtype1 = ',,' OR CHARINDEX(',' + mpp_type1 + ',', @drvtype1) > 0) 
	And
	(@drvtype2 = ',,' OR CHARINDEX(',' + mpp_type2  + ',', @drvtype2) > 0) 
	And
	(@drvtype3 = ',,' OR CHARINDEX(',' + mpp_type3  + ',', @drvtype3) > 0) 
	And
	(@drvtype4 = ',,' OR CHARINDEX(',' + mpp_type4  + ',', @drvtype4) > 0)
	And
	(@originstate = ',,' OR CHARINDEX(',' + ord_originstate + ',', @originstate) > 0) 
 	And 
 	(@deststate = ',,' OR CHARINDEX(',' + ord_deststate + ',', @deststate) > 0) 	















GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWavlloads2] TO [public]
GO
