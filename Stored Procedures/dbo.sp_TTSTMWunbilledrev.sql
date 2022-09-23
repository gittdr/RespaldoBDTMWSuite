SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO





































CREATE                                                    PROCEDURE [dbo].[sp_TTSTMWunbilledrev] 
			(		@sortoption char(30),
					@datetype varchar(4), /* values are SHIP or DELV */
					@frmdt datetime,
					@tdt datetime,
					@ordstatuslist varchar(120), /* order statuses you want to include, comma sep list, no spaces */
				        @invstatuslist varchar(120),
					@revtype1 varchar(120),
					@revtype2 varchar(120),
					@revtype3 varchar(120),
                                        @revtype4 varchar(120),
					@milealloc varchar(30),
					@currency_flag char(30),
					@targeted_currency char(20),
					@drivertype varchar(30),
					@entiremovecompleted char(1)='N'
			)
AS

--*************************************************************************
--Unbilled Revenue Report shows all revenue
--for orders that haven't been billed or
--invoiced. Typically all orders that have an 
--Invoice Status of Ready To Print on down are picked up in this report
--By Default this report looks at orders with an order status of
--Delivered, Users have the option to pick up started and available
--from the dropdown
--*************************************************************************

--Revision History
--1. Changed the way drivers are displayed to the driver that actually
--   delivers the load Version 4.8 LBK
--2. Added driver type option to allow users to take advantage of performance
--   by just taking first driver on the load, or take a performance hit
--   and return the delivered driver
--3. Added a new paramater which allows the option to set an 
--   order to be completed when all other orders on a movement are completed
--   If some orders on a move are started and others are completed
--   then the report sees the orders as started(and by default won't pick them up) 
--   Version 5.3 LBK
--4. Eliminated the rate logic for Penske going to use currency functions
--   Ver 5.4
--5. Deleted Mile Allocation Methodology V
--   Ver 5.4
--6. Added No Locks after TMW Tables    
--7. Added SET QUERY_GOVERNOR_COST_LIMIT 0 before report runs because
--   some users were getting the estimated cost of query has exceeded 
--   threshold errors. By setting this it ignores the fact that the estimated
--   cost has exceeded the threshold and just runs the query. This change
--   currently only affects the Unbilled Revenue report query only
--   Ver 5.4 LBK
--8. Added Branch Code Ver 5.4 LBK

SET QUERY_GOVERNOR_COST_LIMIT 0

Declare @OnlyBranches as varchar(255)
Declare @datetoconvert as Char(25)

Select @datetoconvert = 'shipdate'

SELECT  @ordstatuslist = ',' + LTRIM(RTRIM(ISNULL(@ordstatuslist, ''))) + ','
SELECT  @invstatuslist= ',' + LTRIM(RTRIM(ISNULL(@invstatuslist, ''))) + ','
SELECT  @revtype1 = ',' + LTRIM(RTRIM(ISNULL(@revtype1, ''))) + ','
SELECT  @revtype2 = ',' + LTRIM(RTRIM(ISNULL(@revtype2, ''))) + ','
SELECT  @revtype3 = ',' + LTRIM(RTRIM(ISNULL(@revtype3, ''))) + ',' 
SELECT  @revtype4 = ',' + LTRIM(RTRIM(ISNULL(@revtype4, ''))) + ',' 


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






/* >> GET DATA FOR ORDERS THAT DON'T HAVE INVOICEHEADER */

select 	ord_hdrnumber,
	ord_number, 
	mov_number,
	Case When @entiremovecompleted = 'Y' Then
		Case When ((select count(b.ord_number) from orderheader b (NoLock) where b.mov_number = orderheader.mov_number and b.ord_status = 'STD') > 0 OR 
		          (select count(b.ord_number) from orderheader b (NoLock) where b.mov_number = orderheader.mov_number and b.ord_status = 'CMP' and IsNull(b.ord_totalcharge,0) = 0) > 0) and ord_status = 'CMP' Then
			'STD'
		Else
			ord_status
		End
	Else	
		ord_status
	End as ord_status,
	ord_invoicestatus as 'InvoiceStatus',
	ord_startdate as ShipDate,
	ord_completiondate as DeliveryDate,
	'NI' as 'InvoiceNumber',
	'N' as 'Invoiced',
	'BillTo' = (select Top 1 Company.cmp_name from Company (NoLock) where orderheader.ord_billto = Company.cmp_id), 
	'Shipper' = (select Top 1 Company.cmp_name from Company (NoLock) where orderheader.ord_shipper = Company.cmp_id), 
	'Consignee' = (select Top 1 Company.cmp_name from Company (NoLock) where orderheader.ord_consignee = Company.cmp_id), 
	'origin_city_state' = (select City.cty_name + ', '+ City.cty_state from City (NoLock) where orderheader.ord_origincity = City.cty_code), 
	'dest_city_state' = (select City.cty_name + ', '+ City.cty_state from City (NoLock) where orderheader.ord_destcity = City.cty_code),
	Case When @drivertype = 'Original' Then	
             ord_driver1 
	Else
	     IsNull((Select Min(lgh_driver1) from legheader (NoLock) ,stops a (NoLock) where orderheader.ord_hdrnumber = a.ord_hdrnumber and a.lgh_number = legheader.lgh_number and a.stp_status = 'DNE' and a.stp_arrivaldate = (Select Max(b.stp_arrivaldate) from stops b (NoLock) where b.ord_hdrnumber = a.ord_hdrnumber and b.stp_status = 'DNE')),ord_driver1)
	End As 'DriverID',
	ord_totalweight as Weight,
	ord_terms as Terms,
	--<TTS!*!TMW><Begin><SQLVersion=7>
	IsNull(ord_totalcharge,0) as TotalCharge,
	--<TTS!*!TMW><End><SQLVersion=7> 

	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	--convert(money,IsNull(dbo.fnc_convertcharge(IsNull(ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) as 'TotalCharge',
	--<TTS!*!TMW><End><SQLVersion=2000+>         

	ord_currency as Currency,
	Null as InvoiceHeaderNumber
	
into	#worklist
from 	orderheader (NoLock)
where 	not exists (select * from invoiceheader (NoLock) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
	and
	((@DateType='SHIP'  and  ord_startdate between @frmdt and @tdt )
	OR
	(@DateType='delv' and 	 ord_completiondate between @frmdt and @tdt ))
	And 
	(@revtype1 = ',,' OR CHARINDEX(',' + ord_revtype1 + ',', @revtype1) > 0) 
        And
	(@revtype2 = ',,' OR CHARINDEX(',' + ord_revtype2 + ',', @revtype2) > 0) 
	And
	(@revtype3 = ',,' OR CHARINDEX(',' + ord_revtype3 + ',', @revtype3) > 0) 
	And
	(@revtype4 = ',,' OR CHARINDEX(',' + ord_revtype4 + ',', @revtype4) > 0) 
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

union

/* >> GET DATA FOR ORDERS WITH  INVOICEHEADERS */

select 	invoiceheader.ord_hdrnumber,
	invoiceheader.ord_number, 
	invoiceheader.mov_number, 
	orderheader.ord_status, 
	invoiceheader.ivh_invoicestatus as 'InvoiceStatus',
	invoiceheader.ivh_shipdate as ShipDate, 
	invoiceheader.ivh_deliverydate as DeliveryDate, 
	ivh_invoicenumber as 'InvoiceNumber',
	'Y' as 'Invoiced', 
	'BillTo' = (select Top 1 Company.cmp_name from Company (NoLock) where invoiceheader.ivh_billto = Company.cmp_id), 
	'Shipper' = (select Top 1 Company.cmp_name from Company (NoLock) where invoiceheader.ivh_shipper = Company.cmp_id),
	'Consignee' = (select Top 1 Company.cmp_name from Company (NoLock) where invoiceheader.ivh_consignee = Company.cmp_id),  
	'origin_city_state' = (select City.cty_name + ', '+ City.cty_state from City (NoLock) where invoiceheader.ivh_origincity = City.cty_code), 
	'dest_city_state' = (select City.cty_name + ', '+ City.cty_state from City (NoLock) where invoiceheader.ivh_destcity = City.cty_code), 
	Case When @drivertype = 'Original' Then	
             ivh_driver
	Else

	     IsNull((Select Min(lgh_driver1) from legheader (NoLock),stops a (NoLock) where invoiceheader.ord_hdrnumber = a.ord_hdrnumber and a.lgh_number = legheader.lgh_number and a.stp_status = 'DNE' and a.stp_arrivaldate = (Select Max(b.stp_arrivaldate) from stops b (NoLock) where b.ord_hdrnumber = a.ord_hdrnumber and b.stp_status = 'DNE')),ivh_driver)
	End As 'DriverID',
	Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) then
		invoiceheader.ivh_totalweight 
	Else
		0
	End As 'Weight',
        invoiceheader.ivh_terms as Terms,
	--<TTS!*!TMW><Begin><SQLVersion=7>
	IsNull(invoiceheader.ivh_totalcharge,0) as TotalCharge,
	--<TTS!*!TMW><End><SQLVersion=7>	

	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	--convert(money,IsNull(dbo.fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'TotalCharge',
	--<TTS!*!TMW><End><SQLVersion=2000+>        

	invoiceheader.ivh_currency as Currency,
	invoiceheader.ivh_hdrnumber as InvoiceHeaderNumber
	
from 	orderheader (NoLock),invoiceheader (NoLock)
where 	orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber 
	and
	(
	(@DateType='SHIP' and ivh_shipdate between @frmdt and @tdt ) 
	OR
	(@DateType='DELV' and ivh_deliverydate between @frmdt and @tdt ) 
	)
	And 
	(@revtype1 = ',,' OR CHARINDEX(',' + ivh_revtype1 + ',', @revtype1) > 0) 
        And
	(@revtype2 = ',,' OR CHARINDEX(',' + ivh_revtype2 + ',', @revtype2) > 0) 
	And
	(@revtype3 = ',,' OR CHARINDEX(',' + ivh_revtype3 + ',', @revtype3) > 0)
	And
	(@revtype4 = ',,' OR CHARINDEX(',' + ivh_revtype4 + ',', @revtype4) > 0) 
	--<TTS!*!TMW><Begin><FeaturePack=Other>
       
	--<TTS!*!TMW><End><FeaturePack=Other>
	--<TTS!*!TMW><Begin><FeaturePack=Euro>
	--And
	--(
	--(@onlyBranches = 'ALL')
	--Or
	--(@onlyBranches <> 'ALL' And CHARINDEX(',' + invoiceheader.ivh_booked_revtype1 + ',', @onlyBranches) > 0) 
	--)	
	--<TTS!*!TMW><End><FeaturePack=Euro>





		select 	#worklist.ord_hdrnumber, 
			#worklist.mov_number,  
			#worklist.ord_status, 
			#worklist.ShipDate,                                          
			#worklist.DeliveryDate,                                     
			#worklist.Billto,
			#worklist.Shipper,
			#worklist.Consignee,
			#worklist.origin_city_state OriginCityState,
			#worklist.dest_city_state DestinationCityState,
			IsNull(mpp_firstname,' ') + ' ' + IsNull(mpp_lastname,' ') as Driver,
			#worklist.Weight TotalWeight,
			#worklist.ord_number,
			#worklist.InvoiceNumber,
			#worklist.InvoiceStatus,
			#worklist.Terms,
			#worklist.DriverID,
			#worklist.TotalCharge,
			--<TTS!*!TMW><Begin><SQLOptimizedForVersion=7>
			Case When InvoiceHeaderNumber Is Null Or InvoiceHeaderNumber = (select min(b.ivh_hdrnumber) from invoiceheader  b (NOLOCK) where b.ord_hdrnumber = #worklist.ord_hdrnumber) Then
				(select isNull(sum(isnull(stp_lgh_mileage,0)),0) from stops (NoLock) where stops.mov_number = #worklist.mov_number)
			Else
				0
			End as 'TraveledMiles'
			--<TTS!*!TMW><End><SQLOptimizedForVersion=7>
	
			--<TTS!*!TMW><Begin><SQLOptimizedForVersion=2000+>
			--Case When InvoiceHeaderNumber Is Null Or InvoiceHeaderNumber = (select min(b.ivh_hdrnumber) from invoiceheader  b (NOLOCK) where b.ord_hdrnumber = #worklist.ord_hdrnumber) Then
				--dbo.fnc_TMWRN_MilesForOrder(#worklist.ord_hdrnumber,'ALL','DivideEvenly')
			--Else
				--0
			--End as 'TraveledMiles'
			--<TTS!*!TMW><End><SQLOptimizedForVersion=2000+>                        

					
		from 	#worklist Left Join manpowerprofile On DriverID = mpp_id  
		where   (@invstatuslist = ',,' OR CHARINDEX(',' + InvoiceStatus + ',', @invstatuslist) > 0) 	
			And
        		(@ordstatuslist = ',,' OR CHARINDEX(',' + ord_status + ',', @ordstatuslist) > 0) 	
		order by 
		case when @sortoption = 'Driver' then DriverID end,
		case when @sortoption = 'Shipper' then Shipper end,
		case when @sortoption = 'Ship Date' then ShipDate end,
		case when @sortoption = 'Delivery Date' then DeliveryDate end,
		case when @sortoption = 'Movement#' then mov_number end
































GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWunbilledrev] TO [public]
GO
