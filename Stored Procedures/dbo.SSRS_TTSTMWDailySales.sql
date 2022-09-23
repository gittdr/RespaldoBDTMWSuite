SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create PROCEDURE [dbo].[SSRS_TTSTMWDailySales]
			(		@frmdt datetime,
					@tdt datetime,
					@revtype1 varchar (MAX),
					@revtype2 varchar (MAX),
					@revtype3 varchar (MAX),
                    @revtype4 varchar (MAX),
					@originstate varchar (MAX),
					@deststate varchar (MAX),
					@originregion varchar (MAX),
					@destregion varchar (MAX),
					@shipper varchar (MAX),
					@billto varchar (MAX),
					@consignee varchar (MAX),
					@orderedby varchar (MAX),
					@driver varchar (MAX),
					@trailer varchar (MAX),
					@tractor varchar (MAX),
					@drvtype1 varchar (MAX),
					@drvtype2 varchar (MAX),
					@drvtype3 varchar (MAX),
					@drvtype4 varchar (MAX)
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
--6. Added the ICO OrderStatus restriction for cancelled loads but billable
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



/* >> GET DATA FOR ORDERS WITH NO INVOICEHEADERS */
select 	ord_hdrnumber,
	ord_number, 
	mov_number,
	'OriginCityState' = (select top 1 City.cty_name + ', '+ City.cty_state from City WITH (NOLOCK) where orderheader.ord_origincity = City.cty_code), 
	'DestinationCityState' = (select top 1 City.cty_name + ', '+ City.cty_state from City WITH (NOLOCK) where orderheader.ord_destcity = City.cty_code),
	ord_startdate as ShipDate,
	--get all empty miles for the order based on all empty miles for entire move
	dbo.fnc_ssrs_MilesForOrder(orderheader.ord_hdrnumber,'MT','DivideEvenly') as EmptyMiles,
	dbo.fnc_ssrs_MilesForOrder(orderheader.ord_hdrnumber,'LD','DivideEvenly') as LoadedMiles,
	'N' as Invoiced,
	ord_tractor Tractor,
	ord_trailer Trailer,
	ord_billto as BillToID,
	cmp_name BillTo,
	IsNull(mpp_firstname,' ') + ' ' + IsNull(mpp_lastname,' ') as Driver,
	mpp_id as DriverID,
	IsNull(orderheader.ord_totalcharge,0) as TotalCharge,

	
	ord_currency as Currency, 
	ord_completiondate as BillDate,
	ord_totalmiles as TotalOrderMiles,
	ord_company as OrderedByID,
	'OrderedBy' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where ord_company = Company.cmp_id),
	'NI' as InvoiceNumber
from 	orderheader WITH (NOLOCK)
	Left Join manpowerprofile WITH (NOLOCK) On manpowerprofile.mpp_id = orderheader.ord_driver1
	Left Join company WITH (NOLOCK) On company.cmp_id = orderheader.ord_billto
where 	not exists (select * from invoiceheader WITH (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber)
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
        And	(@revtype2 = ',,' OR CHARINDEX(',' + ord_revtype2 + ',', @revtype2) > 0) 
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



union

/* >> GET DATA FOR ORDERS WITH INVOICEHEADERS*/
select 	invoiceheader.ord_hdrnumber,
	invoiceheader.ord_number, 
	invoiceheader.mov_number, 
	'OriginCityState' = (select Top 1 City.cty_name + ', '+ City.cty_state from City WITH (NOLOCK) where invoiceheader.ivh_origincity = City.cty_code), 
	'DestinationCityState' = (select Top 1 City.cty_name + ', '+ City.cty_state from City WITH (NOLOCK) where invoiceheader.ivh_destcity = City.cty_code),
	ivh_shipdate as ShipDate,
	Case When ord_hdrnumber <> 0 and ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b WITH (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) and ord_hdrnumber > 0 then
	dbo.fnc_ssrs_MilesForOrder(invoiceheader.ord_hdrnumber,'MT','DivideEvenly')
	Else
	0
	End as 'EmptyMiles',
	Case When ord_hdrnumber <> 0 and ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b WITH (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) and ord_hdrnumber > 0 then
	dbo.fnc_ssrs_MilesForOrder(invoiceheader.ord_hdrnumber,'LD','DivideEvenly')
	Else
	0
	End as 'LoadedMiles',
	'Y' as Invoiced,
	ivh_tractor Tractor,
	ivh_trailer Trailer,
	ivh_billto as BillToID,
	cmp_name BillTo,
	IsNull(mpp_firstname,' ') + ' ' + IsNull(mpp_lastname,' ') as Driver,
	mpp_id as DriverID,
	IsNull(invoiceheader.ivh_totalcharge,0) as TotalCharge,
	ivh_currency as Currency,
	ivh_billdate as BillDate,

	Case When ivh_totalmiles = 0 Then
	(select ord_totalmiles from orderheader where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber)
	Else
	Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b WITH (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber and b.ivh_billto = invoiceheader.ivh_billto) then
	invoiceheader.ivh_totalmiles 
	Else
	0
	End 	
	End as 'TotalOrderMiles',	
	ivh_order_by as OrderedByID,
	'OrderedBy' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where ivh_order_by = Company.cmp_id),
	ivh_invoicenumber as InvoiceNumber
from 	invoiceheader WITH (NOLOCK)
	Left Join manpowerprofile WITH (NOLOCK) On manpowerprofile.mpp_id = invoiceheader.ivh_driver
	Left Join company WITH (NOLOCK) On company.cmp_id = invoiceheader.ivh_billto
       
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
	(@deststate = ',,' OR CHARINDEX(',' + ivh_deststate + ',', @deststate) > 0) 		And
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


GO
GRANT EXECUTE ON  [dbo].[SSRS_TTSTMWDailySales] TO [public]
GO
