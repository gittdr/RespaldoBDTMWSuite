SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_OrdersBookedAfterPickup] 
(
	@MinThreshold float = 1,
	@MinsBack int=-20,
	@TempTableName varchar(255) = '##WatchDogGlobalOrdersBookedAfterPickup',
	@WatchName varchar(255)='WatchOrdersBookedAfterPickup',
	@ThresholdFieldName varchar(255) = 'Orders',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar(50) = 'Selected',
	@RevType1 varchar(140)='',
	@RevType2 varchar(140)='',
	@RevType3 varchar(140)='',
	@RevType4 varchar(140)='',
	@OrderStatus varchar(255)='AVL,DSP,PLN,STD,CMP'
)
						
As

	Set NoCount On


	/*
	Procedure Name:    WatchDog_OrdersBookedAfterPickup
	Author/CreateDate: Brent Keeton / 6-15-2004
	Purpose: 	   Returns all empty legs above a specific threshold
	Revision History:
	*/

	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables


	Set @RevType1= ',' + ISNULL(@RevType1,'') + ','
	Set @RevType2= ',' + ISNULL(@RevType2,'') + ','
	Set @RevType3= ',' + ISNULL(@RevType3,'') + ','
	Set @RevType4= ',' + ISNULL(@RevType4,'') + ','

	Select ord_number as [Order #],
		mov_number as [Move #],
		ord_shipper as [Shipper ID],
		(select cty_name from city (NOLOCK) Where cty_code = ord_origincity) as [Origin City],
		(select cty_state from city (NOLOCK) Where cty_code = ord_origincity) as [Origin State],
		ord_consignee as [Consignee ID],
		(select cty_name from city (NOLOCK) Where cty_code = ord_destcity) as [Destination City],
		(select cty_state from city (NOLOCK) Where cty_code = ord_destcity) as [Destination State],
		(select cmp_name from company (NOLOCK) Where cmp_id = ord_billto) as [BillTo],
		ord_billto as [BillTo ID],
		ord_bookdate as [Book Date],
		ord_startdate as [Ship Date],
		ord_revtype1 as RevType1,
		ord_revtype2 as RevType2,
		ord_revtype3 as RevType3,
		ord_revtype4 as RevType4       
	into   #TempResults
	From   orderheader (NOLOCK)
	Where --Restricts Just On orders booked after pickup date
		ord_bookdate > ord_startdate
		AND ord_bookdate > Dateadd(mi,@MinsBack,GetDate())	 
		AND (@RevType1 =',,' or CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
		AND (@RevType2 =',,' or CHARINDEX(',' + ord_revtype2 + ',', @RevType2) >0)
		AND (@RevType3 =',,' or CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
		AND (@RevType4 =',,' or CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
		AND (@OrderStatus =',,' or CHARINDEX(',' + ord_status + ',', @OrderStatus) >0)

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


	Set NoCount Off

GO
