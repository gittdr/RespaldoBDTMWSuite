SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[SSRS_TTSTMWrevanalysis]
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
        @targeted_currency char(20),
		@masterbillstatuslist varchar(255)= ''
		)
AS


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

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
SELECT @masterbillstatuslist = ',' + LTRIM(RTRIM(ISNULL(@masterbillstatuslist, ''))) + ',' 

SET @to_dt = convert(datetime, convert(varchar(11), @to_dt, 101) + ' 23:59:59')

select  
    ivh_invoicenumber as [InvoiceNumber],
	ord_number as [OrderNumber],
	mov_number as [MoveNumber],
	ivh_currency as [Currency],
	ivh_shipdate as [ShipDate],
	ivh_billdate as [BillDate],
	ivh_trailer as [Trailer],
    ivh_billto as [BillToID],
	'BillTo' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where invoiceheader.ivh_billto = Company.cmp_id), 	
	'Shipper' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where invoiceheader.ivh_shipper = Company.cmp_id), 	
	'Consignee' = (select Top 1 Company.cmp_name from Company WITH (NOLOCK) where invoiceheader.ivh_consignee = Company.cmp_id), 		
	
	--<TTS!*!TMW><Begin><SQLOptimizedForVersion=2000+>
	Case When ord_hdrnumber <> 0 and ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b WITH (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) Then
		dbo.fnc_ssrs_MilesForOrder(invoiceheader.ord_hdrnumber,'ALL','DivideEvenly')
	Else
		0
	End as 'TraveledMiles',
	--<TTS!*!TMW><End><SQLOptimizedForVersion=2000+>
	

	
	--<TTS!*!TMW><Begin><SQLVersion=7>
--	isNull(ivh_totalcharge,0) as Revenue,
	--<TTS!*!TMW><End><SQLVersion=7>  
	
	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(isNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'Revenue',
	--<TTS!*!TMW><End><SQLVersion=2000+>        

	--<TTS!*!TMW><Begin><SQLVersion=7>
--	isNull(ivh_charge,0) As LineHaulCharge,
	--<TTS!*!TMW><End><SQLVersion=7> 	

	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(ivh_charge,0),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) as 'LineHaulCharge',
        --<TTS!*!TMW><End><SQLVersion=2000+>  
	
	--<TTS!*!TMW><Begin><SQLVersion=7>
--	isNull(ivh_totalcharge,0) - isNull(ivh_charge,0) As AccCharge,
	--<TTS!*!TMW><End><SQLVersion=7>  	

	--<TTS!*!TMW><Begin><SQLVersion=2000+>
	convert(money,IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(ivh_totalcharge,0)-(IsNull(ivh_taxamount1,0) + IsNull(ivh_taxamount2,0) + IsNull(ivh_taxamount3,0) + IsNull(ivh_taxamount4,0)),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0) - IsNull(dbo.TMWSSRS_fnc_convertcharge(IsNull(ivh_charge,0),ivh_currency,'Revenue',ivh_hdrnumber,ivh_currencydate,ivh_shipdate,ivh_deliverydate,ivh_billdate,ivh_revenue_date,ivh_xferdate,default,ivh_printdate,default,default,default),0)) As AccCharge,
	--<TTS!*!TMW><End><SQLVersion=2000+> 	


	Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b WITH (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber and b.ivh_billto = invoiceheader.ivh_billto) then
		invoiceheader.ivh_totalmiles 
	Else
		0
	End as 'TotalOrderMiles',
	
	Case When ivh_hdrnumber = (select min(b.ivh_hdrnumber) from invoiceheader  b WITH (NOLOCK) where b.ord_hdrnumber = invoiceheader.ord_hdrnumber) then
		invoiceheader.ivh_totalweight 
	Else
		0
	End As 'Weight'
	
from    invoiceheader WITH (NOLOCK)
Where 
	((@DateType='SHIP' and ivh_shipdate between @from_dt and @to_dt )
	OR
	(@DateType='DELV' and ivh_deliverydate between @from_dt and @to_dt ) 
	OR
	(@DateType='BILL' and ivh_billdate between @from_dt and @to_dt )
	OR
	(@DateType='TRAN' and ivh_xferdate between @from_dt and @to_dt ))
	And 
	--(@revtype1 = ',,' OR ivh_revtype1 in (select * from Split(@revtype1,',')))
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
	And --User Not Pulling any InvoiceStatuses
	(
	  			(@invoicestatuslist = ',,' And @masterbillstatuslist = ',,')
				Or --User Pulling Just InvoiceStatus drop-down
				(@invoicestatuslist <> ',,' And @masterbillstatuslist = ',,') And CHARINDEX(',' + Case When ivh_invoicestatus = 'XFR' Or ivh_mbstatus = 'XFR' Then 'XFR' Else ivh_invoicestatus End + ',', @invoicestatuslist) > 0
	  			Or --User Pulling both InvoiceStatus or master bill status
				(@invoicestatuslist <> ',,' And @masterbillstatuslist <> ',,') And (CHARINDEX(',' + Case When ivh_invoicestatus = 'XFR' Or ivh_mbstatus = 'XFR' Then 'XFR' Else ivh_invoicestatus End + ',', @invoicestatuslist) > 0 Or CHARINDEX(',' + Case When ivh_mbstatus = 'XFR' or ivh_invoicestatus = 'XFR' Then 'XFR' Else ivh_mbstatus End + ',', @masterbillstatuslist) > 0)
				Or--User Pulling just master bill status
				(@invoicestatuslist = ',,' And @masterbillstatuslist <> ',,') And CHARINDEX(',' + Case When ivh_invoicestatus = 'XFR' Or ivh_mbstatus = 'XFR' Then 'XFR' Else ivh_mbstatus End + ',', @masterbillstatuslist) > 0
	)




GO
GRANT EXECUTE ON  [dbo].[SSRS_TTSTMWrevanalysis] TO [public]
GO
