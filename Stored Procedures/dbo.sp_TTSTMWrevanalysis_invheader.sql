SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





















/***Total View of Rev Analysis **/
CREATE                            procEDURE [dbo].[sp_TTSTMWrevanalysis_invheader]
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
		@milealloc varchar (30),
		@currency_flag char(20),
                @targeted_currency char(20)
		)
AS



--Author: Brent Keeton
--********************************************************************
--Purpose: Revenue Analysis InvoiceHeader Report is intended more as
--a billed revenue report
--This Report shows total charge revenue, totaltrip revenue
--line haul revenue, and accessorial revenue and
--miles for invoices that are associated with trips 
--********************************************************************

--Revision History: 
--1. Tuesday September 24,2002 ver 3.2 Differentiated between total revenue
--   and total trip revenue on report
--2. Tuesday September 24,2002 ver 3.2 added ivh_currency field for subqueries
--   in the column (allocating order separately)
--3. Tuesday October 1,2002 ver 3.2 added revtype4 field 
--4. Added Invoice Parameter restriction (MRUTH) Ver 5.3 LBK
--5. Eliminated Mile Allocation Methodology Ver 5.4 LBK
--6. Eliminated rate logic for Penske Ver 5.4 LBK
--7. Added Currency Converting Functionality using UDF's Ver 5.4 LBK
--8. Added No Lock after all TMW Tables Ver 5.4 LBK
--9. Added Branch Code Ver 5.4 LBK

Declare @datetoconvert as char(25)
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


select  ivh_invoicenumber,
	ivh_hdrnumber,
	ord_number,
	ord_hdrnumber,
	mov_number,
	ivh_currency,
	ivh_shipdate as ShipDate,
	ivh_billdate,
	ivh_trailer as Trailer,
        ivh_billto as BillToID,
	'BillTo' = (select Top 1 Company.cmp_name from Company (NoLock) where invoiceheader.ivh_billto = Company.cmp_id), 	
	'Shipper' = (select Top 1 Company.cmp_name from Company (NoLock) where invoiceheader.ivh_shipper = Company.cmp_id), 	
	'Consignee' = (select Top 1 Company.cmp_name from Company (NoLock) where invoiceheader.ivh_consignee = Company.cmp_id), 		
	
	--<TTS!*!TMW><Begin><SQLOptimizedForVersion=7>
	Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) Then
		(select isNull(sum(isnull(stp_lgh_mileage,0)),0) from stops (NoLock) where stops.mov_number = invoiceheader.mov_number)
	Else
		0
	End as 'TraveledMiles',
	--<TTS!*!TMW><End><SQLOptimizedForVersion=7>
	
	--<TTS!*!TMW><Begin><SQLOptimizedForVersion=2000+>
	--Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) Then
		--dbo.fnc_TMWRN_MilesForOrder(invoiceheader.ord_hdrnumber,'ALL','DivideEvenly')
	--Else
		--0
	--End as 'TraveledMiles',
	--<TTS!*!TMW><End><SQLOptimizedForVersion=2000+>
	

	
	--<TTS!*!TMW><Begin><SQLVersion=7>
	isNull(ivh_totalcharge,0) as Revenue,
	--<TTS!*!TMW><End><SQLVersion=7>  
	
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	--convert(money,IsNull(dbo.fnc_convertcharge(isNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'Revenue',
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


	Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber and b.ivh_billto = invoiceheader.ivh_billto) then
		invoiceheader.ivh_totalmiles 
	Else
		0
	End as 'TotalOrderMiles',
	
	Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) then
		invoiceheader.ivh_totalweight 
	Else
		0
	End As 'Weight'
	
from    invoiceheader (NoLock)
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







         
































GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWrevanalysis_invheader] TO [public]
GO
