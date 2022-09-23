SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO









































































































/***Total View of Rev Analysis **/
CREATE                                                                     procEDURE [dbo].[sp_TTSTMWrevanalysis]
		(
		@ssort_option varchar(30),
		@datetype varchar(4),
		@from_dt datetime,
		@to_dt datetime,
		@invoicestatuslist varchar(255),
		@revtype1 varchar (255),
		@revtype2 varchar (255),
		@revtype3 varchar (255),
                @revtype4 varchar (255),
		@originstate varchar (255),
		@deststate varchar (255),
		@originregion varchar (255),
		@destregion varchar (255),
		@shipper varchar (255),
		@billto varchar (255),
		@consignee varchar (255),
		@orderedby varchar (255),
		@milealloc varchar(30),
		@currency_flag char(20),
                @targeted_currency char(20)
	)
AS

--Author: Brent Keeton
--********************************************************************
--Purpose: Revenue Analysis Report is intended more as a billed revenue report
--This Report shows total charge revenue, totaltrip revenue
--line haul revenue, and accessorial revenue and
--miles for invoices that are associated with trips 
--********************************************************************

--Revision History: 
--1. Tuesday September 24,2002 ver 3.2 Differentiated between total revenue
--   and total trip revenue on report
--2. Tuesday September 24,2002 ver 3.2 Fixed Allocating Orders Separately portion
--   Previously was using the InvoiceHeader Table to join stops table instead
--   of #workrevmiles temp table
--3. Eliminated the rate logic for Penske going to use currency functions
--   Ver 5.4
--4. Deleted Mile Allocation Methodology
--   Ver 5.4
--5. Added credit memo logic for Billed Miles and Weight to offset
--   when they are multiple invoices on a order
--   Ver 5.4     
--6. Added No Lock after all TMW tables Not Temp Tables
--   Ver 5.4
--7. Added Branch Code Ver 5.4 LBK
--8. Added New Region Code to look off city profile (In Testing for 5.6)

Declare @OnlyBranches as varchar(255)
Declare @datetoconvert as char(25)

Select @datetoconvert ='shipdate'

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

SELECT @invoicestatuslist = ',' + LTRIM(RTRIM(ISNULL(@invoicestatuslist, ''))) + ',' 

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


select  ord_hdrnumber,
	mov_number,
	ivh_billdate,
	ivh_shipdate,
	ivh_currency as Currency,
	--<TTS!*!TMW><Begin><SQLVersion=7>
	isNull(ivh_totalcharge,0) as Revenue,
	--<TTS!*!TMW><End><SQLVersion=7>  
	
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	--convert(money,IsNull(dbo.fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'Revenue',
	--<TTS!*!TMW><End><SQLVersion=2000+>          
	
	--<TTS!*!TMW><Begin><SQLVersion=7>
	isNull(ivh_charge,0) As LineHaulCharge,
	--<TTS!*!TMW><End><SQLVersion=7>
	
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	--convert(money,IsNull(dbo.fnc_convertcharge(IsNull(ivh_charge,0),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'LineHaulCharge',
	--<TTS!*!TMW><End><SQLVersion=2000+>   
 
	--<TTS!*!TMW><Begin><SQLVersion=7>
	isNull(ivh_totalcharge,0) - isNull(ivh_charge,0) As AccCharge,
	--<TTS!*!TMW><End><SQLVersion=7>		

	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	--convert(money,IsNull(dbo.fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0) - IsNull(dbo.fnc_convertcharge(IsNull(ivh_charge,0),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) As AccCharge,
	--<TTS!*!TMW><End><SQLVersion=2000+> 	

	--<TTS!*!TMW><Begin><SQLVersion=7>
	Case When ord_hdrnumber <> 0 Then
		  convert(money,IsNull(ivh_totalcharge,0)) 
	Else
		  0
	End as TripRevenue,
	--<TTS!*!TMW><End><SQLVersion=7>  
	
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
        --Case When ord_hdrnumber <> 0 Then
		--  convert(money,IsNull(dbo.fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) 
	--Else
	--	  0
	--End as TripRevenue,
	--<TTS!*!TMW><End><SQLVersion=2000+> 	
	--NoMovesForOrder = (select count distinct mov_number from stops (NOLOCK) where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber),
	
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
	Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber and b.ivh_billto = invoiceheader.ivh_billto) Then
		IsNull(invoiceheader.ivh_totalmiles,0)
	Else
		0
	End as 'TotalOrderMiles',
	Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) then
		IsNull(invoiceheader.ivh_totalweight,0)
	Else
		0
	End as 'Weight'
into #workfinalanalysis2 
from invoiceheader (NoLock) --Left Join city o (NOLOCK) On o.cty_code = ivh_origincity
     			    --Left Join city d (NOLOCK) On d.cty_code = ivh_destcity
     	
Where 
	((@DateType='SHIP' and ivh_shipdate between @from_dt and @to_dt )
	OR
	(@DateType='DELV' and ivh_deliverydate between @from_dt and @to_dt ) 
	OR
	(@DateType='BILL' and ivh_billdate between @from_dt and @to_dt ))
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
	(@orderedby = ',,' OR CHARINDEX(',' + ivh_company + ',', @orderedby) > 0) 	
	And
	(@invoicestatuslist = ',,' OR CHARINDEX(',' + ivh_invoicestatus + ',', @invoicestatuslist) > 0)  	
	
	
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


--SUM ALL MILES AND REVENUES
select isNull(Sum(isNull(Revenue,0)),0) as TotalRevenue,
       isNull(Sum(isNull(TripRevenue,0)),0) as TotalTripRevenue,  
       isNull(Sum(isNull(AccCharge,0)),0) as TotalAccessorialCharges,
       isNull(Sum(isNull(LineHaulCharge,0)),0) as TotalLineHaulCharges,
       isNull(Sum(isNull(Convert(float,LoadedMiles),0)),0) as TotalLoadedMiles,
       isNull(Sum(isNull(Convert(float,EmptyMiles),0)),0) as TotalEmptyMiles,
       isNull(Sum(isNull(Weight,0)),0) as TotalWeight,
       isNull(Sum(IsNull(TotalOrderMiles,0)),0) as TotalOrderMiles
into #workfinal2
from #workfinalanalysis2                 

--FINAL SELECT AND CALC REV PER MILES
select TotalRevenue,
       TotalTripRevenue,
       TotalAccessorialCharges,
       TotalLineHaulCharges,
       (TotalLoadedMiles+TotalEmptyMiles) as TotalTraveledMiles,
       Case when (TotalLoadedMiles + TotalEmptyMiles)=0 Then convert(money,0) Else convert(money,(TotalTripRevenue/(TotalLoadedMiles+TotalEmptyMiles))) End as RevPerMile,
       TotalLoadedMiles,
       Case when TotalLoadedMiles = 0 Then convert(money,0) Else convert(money,(TotalTripRevenue/TotalLoadedMiles)) End as RevPerLoadedMile,
       TotalEmptyMiles,
       Case when (TotalLoadedMiles + TotalEmptyMiles)=0 Then 0 Else (TotalEmptyMiles/(TotalLoadedMiles+TotalEmptyMiles)) End as DeadheadPercent,
       TotalWeight,
       TotalOrderMiles,
       Case when (TotalOrderMiles)=0 Then convert(money,0) Else convert(money,(TotalTripRevenue/TotalOrderMiles)) End as RevPerOrderMile,
       CountofOrders = (select count(distinct ord_hdrnumber) from #workfinalanalysis2 where ord_hdrnumber <> 0)	
from #workfinal2






         

























SET QUOTED_IDENTIFIER ON 





























































GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWrevanalysis] TO [public]
GO
