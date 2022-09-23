SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO















































































CREATE                                                                 PROCEDURE [dbo].[sp_TTSTMWdailysales]
			(		@sortoption char(30),
					@frmdt datetime,
					@tdt datetime,
					@revtype1 varchar (120),
					@revtype2 varchar (120),
					@revtype3 varchar (120),
                                        @revtype4 varchar (120),
					@originstate varchar (4),
					@deststate varchar (4),
					@originregion varchar (30),
					@destregion varchar (30),
					@shipper varchar (30),
					@billto varchar (30),
					@consignee varchar (30),
					@orderedby varchar (30),
					@driver varchar (30),
					@trailer varchar (30),
					@tractor varchar (30),
					@drvtype1 varchar (120),
					@drvtype2 varchar (120),
					@drvtype3 varchar (120),
					@drvtype4 varchar (120),
					@milealloc varchar (30),
					@currency_flag char(20),
                			@targeted_currency char(20),
					--Not being used
                                        @IncludeInvoicedOnly char(1) = 'N'
                          )
AS

--Author: Brent Keeton
--********************************************************************
--Purpose: Daily Sales Report is intended to see all revenue and associated
--miles (by order *Each row represents an order) currently out there 
--regardless if the order has been billed or not.
--********************************************************************

--Revision History: 
--1. Tuesday September 10,2002 Added Exchange Rates For Currency Conversions LBK
--2. Monday Setptember 16,2002 Added Ordered By(company actually calling in
--   cont.-> the order not necessarily BillTo
--   effective version 2.9 LBK
--3. Monday September 16, 2002 Found ivh_company is not the true field
--   for ordered by in the InvoiceHeader File,replaced with ivh_order_by
--   ord_company remains in tact when an order only exists in orderheader table
--   effective version 3.0 LBK
--4. Eliminated the rate logic for Penske going to use currency functions
--   Ver 5.4 LBK
--5. Deleted Mile Allocation Methodology (FOR NOW)
--   Ver 5.4 LBK
--6. Added the ICO order status restriction for cancelled loads but billable
--   Ver 5.4 LBK
--7. Deleted Temp Table Code for speed
--   Ver 5.4 LBK
--8. Added No Lock after all TMW tables Not Temp Tables
--9. Added Branch Code Ver 5.4 LBK

Declare @datetoconvert as Char(25)
Declare @OnlyBranches as varchar(255)

Select @datetoconvert = 'shipdate'
SELECT @revtype1 = ',' + LTRIM(RTRIM(ISNULL(@revtype1, ''))) + ','
SELECT @revtype2 = ',' + LTRIM(RTRIM(ISNULL(@revtype2, ''))) + ','
SELECT @revtype3 = ',' + LTRIM(RTRIM(ISNULL(@revtype3, ''))) + ',' 
SELECT @revtype4 = ',' + LTRIM(RTRIM(ISNULL(@revtype4, ''))) + ',' 

SELECT @originstate = ',' + LTRIM(RTRIM(ISNULL(@originstate, ''))) + ','
SELECT @deststate = ',' + LTRIM(RTRIM(ISNULL(@deststate, ''))) + ',' 

SELECT @originregion = ',' + LTRIM(RTRIM(ISNULL(@originregion, ''))) + ',' 
SELECT @destregion = ',' + LTRIM(RTRIM(ISNULL(@destregion, ''))) + ',' 
SELECT @shipper = ',' + LTRIM(RTRIM(ISNULL(@shipper, ''))) + ',' 
SELECT @billto = ',' + LTRIM(RTRIM(ISNULL(@billto, ''))) + ','
SELECT @consignee = ',' + LTRIM(RTRIM(ISNULL(@consignee, ''))) + ','
SELECT @orderedby = ',' + LTRIM(RTRIM(ISNULL(@orderedby, ''))) + ','    

SELECT @driver= ',' + LTRIM(RTRIM(ISNULL(@driver, ''))) + ','    
SELECT @tractor = ',' + LTRIM(RTRIM(ISNULL(@tractor, ''))) + ','    
SELECT @trailer = ',' + LTRIM(RTRIM(ISNULL(@trailer, ''))) + ','    

SELECT @drvtype1 = ',' + LTRIM(RTRIM(ISNULL(@drvtype1, ''))) + ','
SELECT @drvtype2 = ',' + LTRIM(RTRIM(ISNULL(@drvtype2, ''))) + ','
SELECT @drvtype3 = ',' + LTRIM(RTRIM(ISNULL(@drvtype3, ''))) + ',' 
SELECT @drvtype4 = ',' + LTRIM(RTRIM(ISNULL(@drvtype4, ''))) + ',' 

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

/* >> GET DATA FOR ORDERS WITH NO INVOICEHEADERS */
select 	ord_hdrnumber,
	ord_number, 
	mov_number,
	'OriginCityState' = (select top 1 City.cty_name + ', '+ City.cty_state from City (NoLock) where orderheader.ord_origincity = City.cty_code), 
	'DestinationCityState' = (select top 1 City.cty_name + ', '+ City.cty_state from City (NoLock) where orderheader.ord_destcity = City.cty_code),
	ord_startdate as ShipDate,
	--get all empty miles for the order based on all empty miles for entire move
	--<TTS!*!TMW><Begin><SQLOptimizedForVersion=7>
	(select isNull(sum(isnull(stp_lgh_mileage,0)),0) from stops (NoLock) where stops.stp_loadstatus <> 'LD' and stops.mov_number = orderheader.mov_number) as EmptyMiles,
	--<TTS!*!TMW><End><SQLOptimizedForVersion=7>	

	--<TTS!*!TMW><Begin><SQLOptimizedForVersion=2000+>
	--dbo.fnc_TMWRN_MilesForOrder(orderheader.ord_hdrnumber,'MT','DivideEvenly') as EmptyMiles,
	--<TTS!*!TMW><End><SQLOptimizedForVersion=2000+>

	--get all loaded miles for the order based on all loaded miles for entire move
	--<TTS!*!TMW><Begin><SQLOptimizedForVersion=7>
	(select isNull(sum(isnull(stp_lgh_mileage,0)),0) from stops (NoLock) where stops.stp_loadstatus = 'LD' and stops.mov_number = orderheader.mov_number ) as LoadedMiles,
	--<TTS!*!TMW><End><SQLOptimizedForVersion=7>

	--<TTS!*!TMW><Begin><SQLOptimizedForVersion=2000+>
	--dbo.fnc_TMWRN_MilesForOrder(orderheader.ord_hdrnumber,'LD','DivideEvenly') as LoadedMiles,
	--<TTS!*!TMW><End><SQLOptimizedForVersion=2000+>

	'N' as Invoiced,
	ord_tractor Tractor,
	ord_trailer Trailer,
	ord_billto as BillToID,
        cmp_name BillTo,
	IsNull(mpp_firstname,' ') + ' ' + IsNull(mpp_lastname,' ') as Driver,
	mpp_id as DriverID,
	
	--<TTS!*!TMW><Begin><SQLVersion=7>
	IsNull(orderheader.ord_totalcharge,0) as TotalCharge,
	--<TTS!*!TMW><End><SQLVersion=7>  
	
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	--convert(money,IsNull(dbo.fnc_convertcharge(IsNull(ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) as 'TotalCharge',
	--<TTS!*!TMW><End><SQLVersion=2000+>  
	
        ord_currency as Currency, 
	ord_completiondate as BillDate,
	ord_totalmiles as TotalOrderMiles,
        ord_company as OrderedByID,
        'OrderedBy' = (select Top 1 Company.cmp_name from Company (NoLock) where ord_company = Company.cmp_id),
        'NI' as InvoiceNumber
from 	orderheader (NoLock)
	Left Join manpowerprofile (NoLock) On manpowerprofile.mpp_id = orderheader.ord_driver1
	Left Join company (NoLock) On company.cmp_id = orderheader.ord_billto
where 	not exists (select * from invoiceheader (NoLock) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber)
	And 
	--restrict by shipdate
	(ord_startdate between @frmdt and @tdt )
	And
	--return everything that has been started, parked, or delivered, and cancelled but not billable
	(ord_status = 'CMP' or ord_status = 'STD' or ord_status = 'PKD' or ord_status = 'ICO')
	And
	--don't return orders that were stamped with Do Not Invoice
	(ord_invoicestatus <> 'XIN') 
	And
	(@revtype1 = ',,' OR CHARINDEX(',' + ord_revtype1 + ',', @revtype1) > 0) 
        And
	(@revtype2 = ',,' OR CHARINDEX(',' + ord_revtype2 + ',', @revtype2) > 0) 
	And
	(@revtype3 = ',,' OR CHARINDEX(',' + ord_revtype3 + ',', @revtype3) > 0) 
	And
	(@revtype4 = ',,' OR CHARINDEX(',' + ord_revtype4 + ',', @revtype4) > 0) 
        And
	(@originstate = ',,' OR CHARINDEX(',' + ord_originstate + ',', @originstate) > 0) 
	And
	(@originregion = ',,' OR CHARINDEX(',' + ord_originregion1 + ',', @originregion) > 0) 
	And 
	(@deststate = ',,' OR CHARINDEX(',' + ord_deststate + ',', @deststate) > 0) 	
	And
	(@destregion = ',,' OR CHARINDEX(',' + ord_destregion1 + ',', @destregion) > 0) 
	And 
	(@shipper = ',,' OR CHARINDEX(',' + ord_shipper + ',', @shipper) > 0) 
	And 
	(@billto = ',,' OR CHARINDEX(',' + ord_billto + ',', @billto) > 0) 
	And
	(@consignee = ',,' OR CHARINDEX(',' + ord_consignee + ',', @consignee) > 0) 
	And 
	(@orderedby = ',,' OR CHARINDEX(',' + ord_company + ',', @orderedby) > 0) 	
	And
	(@tractor= ',,' OR CHARINDEX(',' + ord_tractor + ',', @tractor) > 0)
	And

	(@trailer = ',,' OR CHARINDEX(',' + ord_trailer + ',', @trailer) > 0)
	And
        (@driver = ',,' OR CHARINDEX(',' + ord_driver1 + ',', @driver) > 0)
	And
	(@drvtype1 = ',,' OR CHARINDEX(',' + mpp_type1 + ',', @drvtype1) > 0) 
        And
	(@drvtype2 = ',,' OR CHARINDEX(',' + mpp_type2  + ',', @drvtype2) > 0) 
	And
	(@drvtype3 = ',,' OR CHARINDEX(',' + mpp_type3  + ',', @drvtype3) > 0) 
	And
	(@drvtype4 = ',,' OR CHARINDEX(',' + mpp_type4  + ',', @drvtype4) > 0)
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

/* >> GET DATA FOR ORDERS WITH INVOICEHEADERS*/
select 	invoiceheader.ord_hdrnumber,
	invoiceheader.ord_number, 
	invoiceheader.mov_number, 
	'OriginCityState' = (select Top 1 City.cty_name + ', '+ City.cty_state from City (NoLock) where invoiceheader.ivh_origincity = City.cty_code), 
	'DestinationCityState' = (select Top 1 City.cty_name + ', '+ City.cty_state from City (NoLock) where invoiceheader.ivh_destcity = City.cty_code),
	ivh_shipdate as ShipDate,
	--<TTS!*!TMW><Begin><SQLOptimizedForVersion=7>
	Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) then
		(select isNull(sum(isnull(stp_lgh_mileage,0)),0) from stops (NoLock) where stops.stp_loadstatus <> 'LD' and stops.mov_number = invoiceheader.mov_number )
	Else
		0
	End as 'EmptyMiles',
	--<TTS!*!TMW><End><SQLOptimizedForVersion=7>

	--<TTS!*!TMW><Begin><SQLOptimizedForVersion=2000+>
	--Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) then
		--dbo.fnc_TMWRN_MilesForOrder(invoiceheader.ord_hdrnumber,'MT','DivideEvenly')
	--Else
		--0
	--End as 'EmptyMiles',
	--<TTS!*!TMW><End><SQLOptimizedForVersion=2000+>
	--<TTS!*!TMW><Begin><SQLOptimizedForVersion=7>
	Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) then
		(select isNull(sum(isnull(stp_lgh_mileage,0)),0) from stops (NoLock) where stops.stp_loadstatus = 'LD' and stops.mov_number = invoiceheader.mov_number )
	Else
		0
	End as 'LoadedMiles',
	--<TTS!*!TMW><End><SQLOptimizedForVersion=7>

	--<TTS!*!TMW><Begin><SQLOptimizedForVersion=2000+>
	--Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) then
		--dbo.fnc_TMWRN_MilesForOrder(invoiceheader.ord_hdrnumber,'LD','DivideEvenly')
	--Else
		--0
	--End as 'LoadedMiles',
	--<TTS!*!TMW><End><SQLOptimizedForVersion=2000+>
	'Y' as Invoiced,
	ivh_tractor Tractor,
	ivh_trailer Trailer,
	ivh_billto as BillToID,
        cmp_name BillTo,
	IsNull(mpp_firstname,' ') + ' ' + IsNull(mpp_lastname,' ') as Driver,
	mpp_id as DriverID,
	
	--<TTS!*!TMW><Begin><SQLVersion=7>
	IsNull(invoiceheader.ivh_totalcharge,0) as TotalCharge,
	--<TTS!*!TMW><End><SQLVersion=7> 
	
	--<TTS!*!TMW><Begin><SQLVersion=2000+>	
	--convert(money,IsNull(dbo.fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'TotalCharge',
	--<TTS!*!TMW><End><SQLVersion=2000+>        

	ivh_currency as Currency,
	ivh_billdate as BillDate,
	--go to orderheader to get order miles if zero
	--is to accomodate users that have invoices with split
        --Bill To's(for some reason there billed miles were defaulted
        --to zero). This logic will stay until it is corrected in TMWSuite
	--Negate Miles if they are on a credit memo
        --this will avoid duplication of order miles spread
	--accross multiple invoices
	--Case  When invoiceheader.ivh_creditmemo = 'Y' Then
		--      Case When ivh_totalmiles = 0 Then  --if zero go to orderheader
 		--	((select ord_totalmiles from orderheader (NoLock) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber) * -1)
		--      Else	
			--(invoiceheader.ivh_totalmiles * -1)
		    --  End		
        --Else
		   --    Case When ivh_totalmiles = 0 Then --if zero go to orderheader
			--(select ord_totalmiles from orderheader (NoLock) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber)
		   --   Else
			-- invoiceheader.ivh_totalmiles
		     --  End
	--End As 'TotalOrderMiles',
	Case When ivh_totalmiles = 0 Then
		(select ord_totalmiles from orderheader where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber)
	Else
		Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber and b.ivh_billto = invoiceheader.ivh_billto) then
			invoiceheader.ivh_totalmiles 
		Else
			0
		End 	
        End as 'TotalOrderMiles',	
        ivh_order_by as OrderedByID,
        'OrderedBy' = (select Top 1 Company.cmp_name from Company (NoLock) where ivh_order_by = Company.cmp_id),
        ivh_invoicenumber as InvoiceNumber
from 	invoiceheader (NoLock)
	Left Join manpowerprofile (NoLock) On manpowerprofile.mpp_id = invoiceheader.ivh_driver
	Left Join company (NoLock) On company.cmp_id = invoiceheader.ivh_billto
       
where 	(ivh_shipdate between @frmdt and @tdt )
	And
        ivh_invoicestatus <> 'CAN'
        And 
	(@revtype1 = ',,' OR CHARINDEX(',' + ivh_revtype1 + ',', @revtype1) > 0) 
        And
	(@revtype2 = ',,' OR CHARINDEX(',' + ivh_revtype2 + ',', @revtype2) > 0) 
	And
	(@revtype3 = ',,' OR CHARINDEX(',' + ivh_revtype3 + ',', @revtype3) > 0) 
	And
	(@revtype4 = ',,' OR CHARINDEX(',' + ivh_revtype4 + ',', @revtype4) > 0) 
        And
	(@originstate = ',,' OR CHARINDEX(',' + ivh_originstate + ',', @originstate) > 0) 
	And
	(@originregion = ',,' OR CHARINDEX(',' + ivh_originregion1 + ',', @originregion) > 0) 
	And 
	(@deststate = ',,' OR CHARINDEX(',' + ivh_deststate + ',', @deststate) > 0) 	
	And
	(@destregion = ',,' OR CHARINDEX(',' + ivh_destregion1 + ',', @destregion) > 0) 
	And 
	(@shipper = ',,' OR CHARINDEX(',' + ivh_shipper + ',', @shipper) > 0) 
	And 
	(@billto = ',,' OR CHARINDEX(',' + ivh_billto + ',', @billto) > 0) 
	And
	(@consignee = ',,' OR CHARINDEX(',' + ivh_consignee + ',', @consignee) > 0) 
	And 
	(@orderedby = ',,' OR CHARINDEX(',' + ivh_order_by + ',', @orderedby) > 0) 	
	And
	(@tractor= ',,' OR CHARINDEX(',' + ivh_tractor + ',', @tractor) > 0)
	And
	(@trailer = ',,' OR CHARINDEX(',' + ivh_trailer + ',', @trailer) > 0)
	And

        (@driver = ',,' OR CHARINDEX(',' + ivh_driver + ',', @driver) > 0)
	And
	(@drvtype1 = ',,' OR CHARINDEX(',' + mpp_type1 + ',', @drvtype1) > 0) 
        And
	(@drvtype2 = ',,' OR CHARINDEX(',' + mpp_type2  + ',', @drvtype2) > 0) 
	And
	(@drvtype3 = ',,' OR CHARINDEX(',' + mpp_type3  + ',', @drvtype3) > 0) 
	And
	(@drvtype4 = ',,' OR CHARINDEX(',' + mpp_type4  + ',', @drvtype4) > 0)
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

	

















































































GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWdailysales] TO [public]
GO
