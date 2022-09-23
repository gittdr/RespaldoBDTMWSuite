SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_ZeroRatedOrders] 
(
	@MinThreshold float = 100,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalZeroRatedOrders',
	@WatchName varchar(255) = 'ZeroRatedOrders',
	@ThresholdFieldName varchar(255) = 'ZeroRatedOrders',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@ThresholdType varchar(255) = 'ZeroRatedOrders', --Choices:Dollars,PercentofRevenue
	@RevType1 varchar(140)='',
	@RevType2 varchar(140)='',
	@RevType3 varchar(140)='',
	@RevType4 varchar(140)='',
	@OnlyBillTo varchar(255) = '',
	@ExcludeBillTo varchar(255)='',
	@IncludeCommodity varchar(140)='',
	@ExcludeCommodity varchar(140)='',
	@OrderStatus varchar(255)='',
	@ExcludeOrderStatus varchar(255)='',
	@OnlyInvoiceStatus varchar(255)='',
	@ExcludeInvoiceStatus varchar(255)='',
	@AmountType varchar(255) = 'Total'
)

As

	set nocount on

	/*
	Procedure Name:    WatchDog_ZeroRatedOrders
	Author/CreateDate: Brent Keeton / 6-15-2004
	Purpose: 	   
	Revision History:
	1. 6/21/2004 -> Added IsNull around charge fields BK
	2. IncludeOnlyCommodity - LB 7-5-2005
	3. ExcludeCommodity - LB 7-5-2005
	*/



	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	Set @RevType1= ',' + RTrim(ISNULL(@RevType1,'')) + ','
	Set @RevType2= ',' + RTrim(ISNULL(@RevType2,'')) + ','
	Set @RevType3= ',' + RTrim(ISNULL(@RevType3,'')) + ','
	Set @RevType4= ',' + RTrim(ISNULL(@RevType4,'')) + ','
	Set @OrderStatus= ',' + RTrim(ISNULL(@OrderStatus,'')) + ','
	Set @ExcludeOrderStatus= ',' + RTrim(ISNULL(@ExcludeOrderStatus,'')) + ','
	Set @IncludeCommodity= ',' + RTrim(ISNULL(@IncludeCommodity,'')) + ','
	Set @ExcludeCommodity= ',' + RTrim(ISNULL(@ExcludeCommodity,'')) + ','
	Set @OnlyBillTo= ',' + RTrim(ISNULL(@OnlyBillTo,'')) + ','
	Set @ExcludeBillTo= ',' + RTrim(ISNULL(@ExcludeBillTo,'')) + ','
	Set @OnlyInvoiceStatus= ',' + RTrim(ISNULL(@OnlyInvoiceStatus,'')) + ','
	Set @ExcludeInvoiceStatus= ',' + RTrim(ISNULL(@ExcludeInvoiceStatus,'')) + ','

	select  ord_number as [Order #],
			mov_number as [Move #],
			ord_shipper as [Shipper ID],
			(select cty_name from city (NOLOCK) Where cty_code = ord_origincity) as [Origin City],
			ord_consignee as [Consignee ID],
			(select cty_name from city (NOLOCK) Where cty_code = ord_destcity) as [Destination City],
			(select cmp_name from company (NOLOCK) Where cmp_id = ord_billto) as [BillTo],
			ord_billto as [BillTo ID],
			Case @AmountType
				When 'Total' Then IsNull(ord_totalcharge,0)
				When 'LineHaul' Then IsNull(ord_charge,0)
				When 'Accessorial' Then IsNull(ord_accessorial_chrg,0)
			End as Charge,
			cmd_code as [Commodity]
	into   #TempResults
	From   orderheader (NOLOCK)
	where (@OrderStatus =',,' or CHARINDEX(',' + ord_status + ',', @OrderStatus) >0)
		AND (@ExcludeOrderStatus =',,' or CHARINDEX(',' + ord_status + ',', @ExcludeOrderStatus) =0)
		AND ord_status <> 'CAN'
		AND ord_status <> 'MST'
		And ord_invoicestatus <> 'XIN'
		And (@RevType1 =',,' or CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
		AND (@RevType2 =',,' or CHARINDEX(',' + ord_revtype2 + ',', @RevType2) >0)
		AND (@RevType3 =',,' or CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
		AND (@RevType4 =',,' or CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
		AND (@IncludeCommodity =',,' or CHARINDEX(',' + cmd_code + ',', @IncludeCommodity) >0)
		AND (@ExcludeCommodity =',,' or CHARINDEX(',' + cmd_code + ',', @ExcludeCommodity) =0)
		AND (@OnlyBillTo =',,' or CHARINDEX(',' + ord_billto + ',', @OnlyBillTo) >0)
		AND (@ExcludeBillTo =',,' or CHARINDEX(',' + ord_billto + ',', @ExcludeBillTo) =0)	
		AND (@OnlyInvoiceStatus =',,' or CHARINDEX(',' + ord_invoicestatus + ',', @OnlyInvoiceStatus) >0)
		AND (@ExcludeInvoiceStatus =',,' or CHARINDEX(',' + ord_invoicestatus + ',', @ExcludeInvoiceStatus) =0)
		AND (
				(@AmountType = 'Total' And IsNull(ord_totalcharge,0) = 0)
				Or
				(@AmountType = 'LineHaul' And IsNull(ord_charge,0) = 0)    
				Or
				(@AmountType = 'Accessorial' And IsNull(ord_accessorial_chrg,0) = 0)   
			)  
		AND ord_startdate > Dateadd(mi,@MinsBack,GetDate())	 
	 
	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResults'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'
	End

	Exec (@SQL)

	set nocount off































































































GO
