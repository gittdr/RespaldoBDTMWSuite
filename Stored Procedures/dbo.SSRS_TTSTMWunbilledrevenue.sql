SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[SSRS_TTSTMWunbilledrevenue] 
			(		@sortoption char(30),
					@datetype varchar(4), /* values are SHIP or DELV */
					@frmdt datetime,
					@tdt datetime,
					@ordstatuslist varchar(120), /* OrderStatuses you want to include, comma sep list, no spaces */
				    @invstatuslist varchar(120),
					@revtype1 varchar(120),
					@revtype2 varchar(120),
					@revtype3 varchar(120),
                    @revtype4 varchar(120),
					@drivertype varchar(30),
					@masterbillstatuslist varchar(255)
			)
AS

--*************************************************************************
--Unbilled Revenue Report shows all revenue
--for orders that haven't been billed or
--invoiced. Typically all orders that have an 
--InvoiceStatus of Ready To Print on down are picked up in this report
--By Default this report looks at orders with an OrderStatus of
--Delivered, Users have the option to pick up started and available
--from the dropdown
--*************************************************************************

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

Declare @OnlyBranches as varchar(255)
Declare @datetoconvert as Char(25)

Select @datetoconvert = 'shipdate'

SET @tdt = convert(datetime, convert(varchar(11), @tdt, 101) + ' 23:59:59')

SELECT  @ordstatuslist = ',' + LTRIM(RTRIM(ISNULL(@ordstatuslist, ''))) + ','
SELECT  @invstatuslist= ',' + LTRIM(RTRIM(ISNULL(@invstatuslist, ''))) + ','
SELECT  @revtype1 = ',' + LTRIM(RTRIM(ISNULL(@revtype1, ''))) + ','
SELECT  @revtype2 = ',' + LTRIM(RTRIM(ISNULL(@revtype2, ''))) + ','
SELECT  @revtype3 = ',' + LTRIM(RTRIM(ISNULL(@revtype3, ''))) + ',' 
SELECT  @revtype4 = ',' + LTRIM(RTRIM(ISNULL(@revtype4, ''))) + ',' 
SELECT  @masterbillstatuslist= ',' + LTRIM(RTRIM(ISNULL(@masterbillstatuslist, ''))) + ','

/* >> GET DATA FOR ORDERS THAT DON'T HAVE INVOICEHEADER */

select 	ord_hdrnumber,
	ord_number, 
	mov_number,
    ord_status,
	ord_invoicestatus as 'InvoiceStatus',
	ord_startdate as ShipDate,
	ord_completiondate as DeliveryDate,
	'NI' as 'InvoiceNumber',
	'N' as 'Invoiced',
	'BillTo' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where orderheader.ord_billto = Company.cmp_id), 
	'Shipper' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where orderheader.ord_shipper = Company.cmp_id), 
	'Consignee' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where orderheader.ord_consignee = Company.cmp_id), 
	'origin_city_state' = (select City.cty_name + ', '+ City.cty_state from City WITH (NOLOCK) where orderheader.ord_origincity = City.cty_code), 
	'dest_city_state' = (select City.cty_name + ', '+ City.cty_state from City WITH (NOLOCK) where orderheader.ord_destcity = City.cty_code),
	Case When @drivertype = 'Original' Then	
             ord_driver1 
	Else
	     IsNull((Select Min(lgh_driver1) from legheader WITH (NOLOCK) ,stops a WITH (NOLOCK) where orderheader.ord_hdrnumber = a.ord_hdrnumber and a.lgh_number = legheader.lgh_number and a.stp_status = 'DNE' and a.stp_arrivaldate = (Select Max(b.stp_arrivaldate) from stops b WITH (NOLOCK) where b.ord_hdrnumber = a.ord_hdrnumber and b.stp_status = 'DNE')),ord_driver1)
	End As 'DriverID',
	ord_totalweight as Weight,
	ord_terms as Terms,
	convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(ord_totalcharge,0),ord_currency,'Revenue',ord_hdrnumber,ord_currencydate,ord_startdate,ord_completiondate,default,default,default,default,default,default,default,default),0)) as 'TotalCharge',
	ord_currency as Currency,
	Null as InvoiceHeaderNumber,
	Null as MasterBillStatus
	
into	#worklist
from 	orderheader WITH (NOLOCK)
where 	not exists (select * from invoiceheader WITH (NOLOCK) where orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber)
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

      
union

/* >> GET DATA FOR ORDERS WITH  INVOICEHEADERS */

select 	invoiceheader.ord_hdrnumber,
	invoiceheader.ord_number, 
	invoiceheader.mov_number, 
	orderheader.ord_status, 
	Case When invoiceheader.ivh_invoicestatus = 'XFR' or invoiceheader.ivh_mbstatus = 'XFR' Then 'XFR' Else invoiceheader.ivh_invoicestatus End as 'InvoiceStatus',
	invoiceheader.ivh_shipdate as ShipDate, 
	invoiceheader.ivh_deliverydate as DeliveryDate, 
	ivh_invoicenumber as 'InvoiceNumber',
	'Y' as 'Invoiced', 
	'BillTo' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where invoiceheader.ivh_billto = Company.cmp_id), 
	'Shipper' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where invoiceheader.ivh_shipper = Company.cmp_id),
	'Consignee' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where invoiceheader.ivh_consignee = Company.cmp_id),  
	'origin_city_state' = (select City.cty_name + ', '+ City.cty_state from City WITH (NOLOCK) where invoiceheader.ivh_origincity = City.cty_code), 
	'dest_city_state' = (select City.cty_name + ', '+ City.cty_state from City WITH (NOLOCK) where invoiceheader.ivh_destcity = City.cty_code), 
	Case When @drivertype = 'Original' Then	
             ivh_driver
	Else
	     IsNull((Select Min(lgh_driver1) from legheader WITH (NOLOCK),stops a WITH (NOLOCK) where invoiceheader.ord_hdrnumber = a.ord_hdrnumber and a.lgh_number = legheader.lgh_number and a.stp_status = 'DNE' and a.stp_arrivaldate = (Select Max(b.stp_arrivaldate) from stops b WITH (NOLOCK) where b.ord_hdrnumber = a.ord_hdrnumber and b.stp_status = 'DNE')),ivh_driver)
	End As 'DriverID',
	Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b WITH (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) then
		invoiceheader.ivh_totalweight 
	Else
		0
	End As 'Weight',
        invoiceheader.ivh_terms as Terms,
	convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'TotalCharge',
 	invoiceheader.ivh_currency as Currency,
	invoiceheader.ivh_hdrnumber as InvoiceHeaderNumber,
	Case When ivh_mbstatus = 'XFR' or ivh_invoicestatus = 'XFR' Then 'XFR' Else ivh_mbstatus End as MasterBillStatus
	
from 	orderheader WITH (NOLOCK),invoiceheader WITH (NOLOCK)
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
			Case When #worklist.ord_hdrnumber <> 0 and (InvoiceHeaderNumber Is Null Or InvoiceHeaderNumber = (select min(b.ivh_hdrnumber) from invoiceheader  b WITH (NOLOCK) where b.ord_hdrnumber = #worklist.ord_hdrnumber)) Then
				dbo.fnc_ssrs_MilesForOrder(#worklist.ord_hdrnumber,'ALL','DivideEvenly')
			Else
				0
			End as 'TraveledMiles'
  				
		from 	#worklist Left Join manpowerprofile On DriverID = mpp_id  
		where   --User Not Pulling any InvoiceStatuses
			(
	  			(@invstatuslist = ',,' And @masterbillstatuslist = ',,')
				Or --User Pulling Just InvoiceStatus drop-down
				(@invstatuslist <> ',,' And @masterbillstatuslist = ',,') And CHARINDEX(',' + InvoiceStatus + ',', @invstatuslist) > 0
	  			Or --User Pulling both InvoiceStatus or master bill status
				(@invstatuslist <> ',,' And @masterbillstatuslist <> ',,') And (CHARINDEX(',' + InvoiceStatus + ',', @invstatuslist) > 0 Or CHARINDEX(',' + MasterBillStatus + ',', @masterbillstatuslist) > 0)
				Or--User Pulling just master bill status
				(@invstatuslist = ',,' And @masterbillstatuslist <> ',,') And CHARINDEX(',' + MasterBillStatus + ',', @masterbillstatuslist) > 0
			)
			And
        		(@ordstatuslist = ',,' OR CHARINDEX(',' + ord_status + ',', @ordstatuslist) > 0) 	
		order by 
		case when @sortoption = 'Driver' then DriverID end,
		case when @sortoption = 'Shipper' then Shipper end,
		case when @sortoption = 'Ship Date' then ShipDate end,
		case when @sortoption = 'Delivery Date' then DeliveryDate end,
		case when @sortoption = 'Movement#' then mov_number end



GO
