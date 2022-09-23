SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO































CREATE                   PROCEDURE [dbo].[sp_TTSTMWLoadBasedReport] 
			(		@sortoption char(30),
					@DateType varchar (30),
					@frmdt datetime,
					@tdt datetime,
					@revtype1 varchar(255),
					@revtype2 varchar(255),
					@revtype3 varchar(255),
                                        @revtype4 varchar(255),
					@orderstatus varchar (255),
					@shipper varchar (255),
					@consignee varchar (255),
					@billto varchar (255),
					@orderedby varchar (255),
					@driver varchar (255),
					@tractor varchar (255),
					@trailer varchar (255),
					@commoditycode varchar (255),
					@originstate varchar (255),
					@deststate varchar (255),
					@originregion varchar (255),
					@destregion varchar (255)
			)
AS

--********************************************************************
--Available Loads Report is intended to see all orders and their
--associated stops that 
--are marked with an Order Status of either Available or Parked 
--********************************************************************

--Revision History
--1. Added Branch Code Ver 5.4 LBK


Declare @OnlyBranches as varchar(255)

SELECT @revtype1 = ',' + LTRIM(RTRIM(ISNULL(@revtype1, ''))) + ','
SELECT @revtype2 = ',' + LTRIM(RTRIM(ISNULL(@revtype2, ''))) + ','
SELECT @revtype3 = ',' + LTRIM(RTRIM(ISNULL(@revtype3, ''))) + ','
SELECT @revtype4 = ',' + LTRIM(RTRIM(ISNULL(@revtype4, ''))) + ','  

SELECT @originstate = ',' + LTRIM(RTRIM(ISNULL(@originstate, ''))) + ',' 
SELECT @deststate = ',' + LTRIM(RTRIM(ISNULL(@deststate, ''))) + ',' 
SELECT @originregion = ',' + LTRIM(RTRIM(ISNULL(@originregion, ''))) + ',' 
SELECT @destregion = ',' + LTRIM(RTRIM(ISNULL(@destregion, ''))) + ',' 

SELECT @orderstatus = ',' + LTRIM(RTRIM(ISNULL(@orderstatus, ''))) + ','
SELECT @shipper = ',' + LTRIM(RTRIM(ISNULL(@shipper, ''))) + ','
SELECT @consignee = ',' + LTRIM(RTRIM(ISNULL(@consignee, ''))) + ','
SELECT @billto = ',' + LTRIM(RTRIM(ISNULL(@billto, ''))) + ','
SELECT @orderedby = ',' + LTRIM(RTRIM(ISNULL(@orderedby, ''))) + ','
SELECT @driver= ',' + LTRIM(RTRIM(ISNULL(@driver, ''))) + ','
SELECT @tractor = ',' + LTRIM(RTRIM(ISNULL(@tractor, ''))) + ','
SELECT @trailer = ',' + LTRIM(RTRIM(ISNULL(@trailer, ''))) + ','
SELECT @commoditycode = ',' + LTRIM(RTRIM(ISNULL(@commoditycode, ''))) + ','

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
select 	ord_number as OrderNo,
	mov_number as MoveNo,
	'ord_shipper' = (select Company.cmp_name from Company where orderheader.ord_shipper = Company.cmp_id),
	'ord_consignee' = (select Company.cmp_name from Company where orderheader.ord_consignee = Company.cmp_id),
	'FromCityState' = (select City.cty_name + ', '+ City.cty_state from City where orderheader.ord_origincity = City.cty_code), 
	'ToCityState' = (select City.cty_name + ', '+ City.cty_state from City where orderheader.ord_destcity = City.cty_code),
	ord_originregion = (Select name from labelfile where abbr = ord_originregion1 and labeldefinition = 'Regions'),
	ord_destregion = (Select name from labelfile where abbr = ord_destregion1 and labeldefinition = 'Regions'),
	ord_shipper as ShipperID,
	ord_consignee as ConsigneeID,
	ord_billto as BillToID,
	ord_company as OrderedByID,
	ord_status as OrdStatus,
	ord_driver1,
	'DriverName' = IsNull((Select mpp_lastfirst from manpowerprofile where orderheader.ord_driver1 = manpowerprofile.mpp_id),''), 
	ord_tractor,
	ord_trailer,
	'commodity' = (Select cmd_name from commodity where orderheader.cmd_code = commodity.cmd_code),
	cmd_code as CommodityID,
	ord_revtype1 = (Select name from labelfile where abbr = ord_revtype1 and labeldefinition = 'RevType1'),
	ord_revtype2 = (Select name from labelfile where abbr = ord_revtype2 and labeldefinition = 'RevType2'),
	ord_revtype3 = (Select name from labelfile where abbr = ord_revtype3 and labeldefinition = 'RevType3'),
	ord_revtype4 = (Select name from labelfile where abbr = ord_revtype4 and labeldefinition = 'RevType4'),
	ord_bookdate as BookedDate,
	ord_startdate as ShipDate,
	ord_completiondate as DeliverDate, 
	ord_description as Comments
into    #TempLoadBased
from 	orderheader (NOLOCK) Left Join city origin (NOLOCK) On origin.cty_code = orderheader.ord_origincity
			     Left Join city destination (NOLOCK) On destination.cty_code = orderheader.ord_destcity
where	((@DateType='SHIP' and ord_startdate between @frmdt and @tdt )
	OR
	(@DateType='DELV' and ord_completiondate between @frmdt and @tdt ) 
	OR
	(@DateType='BOOK' and ord_bookdate between @frmdt and @tdt )) 	
	And 
	(@revtype1 = ',,' OR CHARINDEX(',' + ord_revtype1 + ',', @revtype1) > 0) 
        And
	(@revtype2 = ',,' OR CHARINDEX(',' + ord_revtype2 + ',', @revtype2) > 0) 
	And
	(@revtype3 = ',,' OR CHARINDEX(',' + ord_revtype3 + ',', @revtype3) > 0) 
	And
	(@revtype4 = ',,' OR CHARINDEX(',' + ord_revtype4 + ',', @revtype4) > 0) 
        And
        (@orderstatus = ',,' OR CHARINDEX(',' + ord_status + ',', @orderstatus) > 0)
	And
        (@shipper = ',,' OR CHARINDEX(',' + ord_shipper + ',', @shipper) > 0)
	And
        (@consignee = ',,' OR CHARINDEX(',' + ord_consignee + ',', @consignee) > 0) 
	And
        (@billto = ',,' OR CHARINDEX(',' + ord_billto + ',', @billto) > 0) 
	And
        (@orderedby = ',,' OR CHARINDEX(',' + ord_company + ',', @orderedby) > 0)
	And
        (@driver = ',,' OR CHARINDEX(',' + ord_driver1 + ',', @driver) > 0)   
	And
        (@tractor = ',,' OR CHARINDEX(',' + ord_tractor + ',', @tractor) > 0)   
	And
        (@trailer= ',,' OR CHARINDEX(',' + ord_trailer + ',', @trailer) > 0)   
	And
        (@commoditycode = ',,' OR CHARINDEX(',' + cmd_code + ',', @commoditycode) > 0)   
   	And
        (@originstate = ',,' OR CHARINDEX(',' + ord_originstate + ',', @originstate) > 0) 
	And
        (@deststate = ',,' OR CHARINDEX(',' + ord_deststate + ',', @deststate) > 0) 
	And
        (@originregion = ',,' OR CHARINDEX(',' + origin.cty_region1 + ',', @originregion) > 0) 
	And
        (@destregion = ',,' OR CHARINDEX(',' + destination.cty_region1 + ',', @destregion) > 0) 
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

select * from #TempLoadBased
Order By
        case when @sortoption = 'RevType1' then ord_revtype1 end,
        case when @sortoption = 'RevType2' then ord_revtype2 end,
        case when @sortoption = 'RevType3' then ord_revtype3 end,
	case when @sortoption = 'RevType4' then ord_revtype4 end,
	case when @sortoption = 'Shipper' then ord_shipper end,
	case when @sortoption = 'Consignee' then ord_consignee end,  
	case when @sortoption = 'origincitystate' then FromCityState end, 
	case when @sortoption = 'destcitystate' then ToCityState end,
	case when @sortoption = 'BookDate' then BookedDate end,
	case when @sortoption = 'ShipDate' then ShipDate end,
	case when @sortoption = 'DeliveryDate' then DeliverDate end,
	case when @sortoption = 'Commodity' then Commodity end,
	case when @sortoption = 'Driver' then DriverName end,
	case when @sortoption = 'Tractor' then ord_tractor end,
	case when @sortoption = 'Trailer' then ord_trailer end









































GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWLoadBasedReport] TO [public]
GO
