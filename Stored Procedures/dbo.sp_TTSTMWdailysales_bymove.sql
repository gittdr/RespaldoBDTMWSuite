SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




















CREATE                                                        Procedure [dbo].[sp_TTSTMWdailysales_bymove](
					@sortoption char(30),
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
					@supplier varchar (30),
					@driver varchar (30),
					@trailer varchar (30),
					@tractor varchar (30),
					@drvtype1 varchar (120),
					@drvtype2 varchar (120),
					@drvtype3 varchar (120),
					@drvtype4 varchar (120),
					@milealloc varchar(30),
					@currency_flag char(20),
                			@targeted_currency char(20),
					@IncludeInvoicedOnly char(1) = 'N'
					)
			         

As


--Author: Brent Keeton
--*************************************************************************
--Purpose: Daily Sales By Move Report is intended to see all revenue and 
--associated miles (grouped by move *Each row represents a trip segment on a move)  
--currently out there regardless if the revenue has been billed or not.
--*************************************************************************

--Revision History:
--1. September 10, 2002 Added Currency Conversion Functionality
--2. Eliminated the rate logic for Penske going to use currency functions
--   Ver 5.4 LBK
--3. Deleted Mile Allocation Methodology V
--   Ver 5.4 LBK
--4. Added credit memo logic for Billed Miles to offset
--   when they are multiple invoices on a order(avoid duplication)
--   Ver 5.4 LBK   
--5. Added the ICO order status restriction for cancelled loads but billable
--   Ver 5.4 LBK
--6. Added Invoiced Orders Only Option which uses bill date instead of
--   ship date and only shows orders that have an invoiced prepared
--   and are not cancelled
--   Ver 5.4 LBK
--7. Added No Lock after all TMW tables Not Temp Tables
--8. Added Branch Code Ver 5.4 LBK

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
SELECT @supplier = ',' + LTRIM(RTRIM(ISNULL(@supplier, ''))) + ','    

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


--get the total revenue for the move
--No Restrictions except for Ship Date,orderstatus,invoicestatus
--Restrictions like Rev Classes,BillTo would hinder
--the report all together (For Example.  A Move may
--show less revenue because you restricted by a specific billto)

select --<TTS!*!TMW><Begin><SQLVersion=7>
       IsNull(orderheader.ord_totalcharge,0) as Revenue,
       --<TTS!*!TMW><End><SQLVersion=7>  
       
       --<TTS!*!TMW><Begin><SQLVersion=2000+>
       --convert(money,IsNull(dbo.fnc_convertcharge(IsNull(ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) as 'Revenue',
       --<TTS!*!TMW><End><SQLVersion=2000+> 
       
       ord_number,
       ord_currency as Currency,
       ord_startdate as ShipDate,
       ord_completiondate as BillDate,
       mov_number 
into #tempdailysalesbymove
from orderheader (NoLock)
where not exists (select * from invoiceheader (NoLock) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
     And 
     (@IncludeInvoicedOnly = 'N' and ord_startdate between @frmdt and @tdt ) 
     And
     --return everything that has been parked, started, or delivered, or can but billable
     (ord_status = 'CMP' or ord_status = 'PKD' or ord_status = 'STD' or ord_status = 'ICO')
     And
     --don't return orders that were stamped with Do Not Invoice
     (ord_invoicestatus <> 'XIN')
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
 
select --<TTS!*!TMW><Begin><SQLVersion=7>
       IsNull(ivh_totalcharge,0) as Revenue,
       --<TTS!*!TMW><End><SQLVersion=7>

       --<TTS!*!TMW><Begin><SQLVersion=2000+>
       --convert(money,IsNull(dbo.fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'Revenue',
       --<TTS!*!TMW><End><SQLVersion=2000+>          

       ord_number,
       ivh_currency as Currency,
       ivh_shipdate as ShipDate,
       ivh_billdate as BillDate,
       mov_number
from invoiceheader (NoLock)
where exists (select * from orderheader (NoLock) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber) 
      And 
      (
        (@IncludeInvoicedOnly = 'Y' and ivh_billdate between @frmdt and @tdt)
         Or
        (@IncludeInvoicedOnly = 'N' and ivh_shipdate between @frmdt and @tdt)
      )
      And
      ivh_invoicestatus <> 'CAN' 
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
     
--Perform sums on charges after rates were applied and group by the move
Select 
	Sum(Revenue) as Revenue,
	mov_number
	into #worklist
	from #tempdailysalesbymove
	Group By mov_number

--Group records by legheaders for the move
--and restrict on any driver types or driver id's if any are given
select legheader.lgh_driver1 as Driver, 
       legheader.lgh_startcty_nmstct as StartCity,
       legheader.lgh_endcty_nmstct as EndCity,
       'TravelMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NoLock) where stops.lgh_number = legheader.lgh_number),
       'LoadedMiles' = (Select IsNull(sum(stp_lgh_mileage),0) from stops (NoLock) where stops.lgh_number = legheader.lgh_number and stops.stp_loadstatus = 'LD'),
       'EmptyMiles' = (Select IsNUll(sum(stp_lgh_mileage),0) from stops (NoLock) where  stops.lgh_number = legheader.lgh_number  and stops.stp_loadstatus <> 'LD'),
       'MoveMiles' =  (Select IsNUll(sum(stp_lgh_mileage),0) from stops (NoLock) where stops.mov_number= legheader.mov_number), 
	legheader.mov_number
into #worklist3
from legheader (NoLock) ,#worklist
where #worklist.mov_number = legheader.mov_number
	
Group By legheader.mov_number,legheader.lgh_driver1,legheader.lgh_number,legheader.lgh_startcty_nmstct,legheader.lgh_endcty_nmstct


Select   mpp_firstname + ' ' + mpp_lastname as DriverName,
         mpp_id as DriverID,
         Revenue,
         MoveMiles,
         TravelMiles,
         LoadedMiles,
         EmptyMiles,
         #worklist3.mov_number,
         StartCity,
         EndCity 
from     #worklist3,#worklist,manpowerprofile (NoLock)
where    #worklist3.mov_number = #worklist.mov_number and manpowerprofile.mpp_id = #worklist3.Driver
order by #worklist3.mov_number	 
















































GO
GRANT EXECUTE ON  [dbo].[sp_TTSTMWdailysales_bymove] TO [public]
GO
