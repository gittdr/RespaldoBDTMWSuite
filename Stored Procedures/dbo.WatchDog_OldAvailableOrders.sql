SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_OldAvailableOrders] 
(
	@MinThreshold float = 0,
	@MinsBack int=0,
	@TempTableName varchar(255)='##WatchDogGlobalOldAvailableOrders',
	@WatchName varchar(255) = 'OldAvailableOrders',
	@ThresholdFieldName varchar(255) = 'Available',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
    @DaysBackToStart int = 1,
    @MinsBackToStart int = 0,
	@RevType1 varchar(140)='',
    @RevType2 varchar(140)='',
    @RevType3 varchar(140)='',
    @RevType4 varchar(140)='',
    @OrderStatus varchar(255) = 'AVL',
	@OnlyOriginRegion varchar(255) = '',
	@OnlyBillToList varchar(255) = '',
	@UseLghActiveTableYN char(1) = 'N',
	@UseLghOutStatusYN char(1) = 'N',
	@LghOutStatus varchar(255)='AVL',
	@OrderPriorityList varchar(128) = '',
	@ParameterToUseForDynamicEmail varchar(255)=''
)

As

	Set NoCount On

	/*
	Procedure Name:    WatchDog_OldAvailableOrders
	Author/CreateDate: Brent Keeton / 6-15-2004
	Purpose: 	   To Return All Available Orders
			By Default All Orders that are available
			from the beginning of time to yesterday
	Revision History:
		4/19/2005: DAG: For Arrow. 
						1) Added @UseLghActiveTableYN per Dave request.
						2) Added @OrderPriorityList
	*/


	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	Declare @DateToStart datetime

	If @MinsBackToStart = 0
		Set @DateToStart = dateadd(day,-@DaysBackToStart,getdate())
	Else
		Set @DateToStart = DateAdd(minute,-@MinsBackToStart,GetDate())

	Set @RevType1= ',' + RTrim(ISNULL(@RevType1,'')) + ','
	Set @RevType2= ',' + RTrim(ISNULL(@RevType2,'')) + ','
	Set @RevType3= ',' + RTrim(ISNULL(@RevType3,'')) + ','
	Set @RevType4= ',' + RTrim(ISNULL(@RevType4,'')) + ','
	Set @OrderStatus= ',' + RTrim(ISNULL(@OrderStatus,'')) + ','
	Set @OnlyOriginRegion= ',' + RTrim(ISNULL(@OnlyOriginRegion,'')) + ','
	Set @OnlyBillToList= ',' + RTrim(ISNULL(@OnlyBillToList,'')) + ','
	Set @OrderPriorityList = ',' + RTRIM(ISNULL(@OrderPriorityList, '')) + ','
	Set @LghOutStatus = ',' + RTRIM(ISNULL(@LghOutStatus, '')) + ','

	
	IF (@UseLghActiveTableYN <> 'Y')
	BEGIN
		select ord_number as [Order #],
			mov_number as [Move #],
			@DateToStart as StartDate,
			ord_startdate as [Ship Date],
			ord_completiondate as [Est Delivery Date],
			ord_shipper as [Shipper ID],
				ord_originregion1 as [Origin Region],
			IsNull((select cty_name from city (NOLOCK) Where cty_code = ord_origincity),'') as [Origin City],
			IsNull((select cty_state from city (NOLOCK) Where cty_code = ord_origincity),'') as [Origin State],
			ord_consignee as [Consignee ID],
			IsNull((select cty_name from city (NOLOCK) Where cty_code = ord_destcity),'') as [Destination City],
			IsNull((select cty_state from city (NOLOCK) Where cty_code = ord_destcity),'') as [Destination State],
			IsNull((select cmp_name from company (NOLOCK) Where cmp_id = ord_billto),'') as [BillTo],
			ord_billto as [BillTo ID],
			ord_tractor as [Tractor ID],
			ord_revtype1 as RevType1,
			ord_revtype2 as RevType2,
			ord_revtype3 as RevType3,
			ord_revtype4 as RevType4,
			ord_priority,
			ord_status AS OrderStatus,
			ord_bookedby as BookedBy,
			EmailSend = ISNULL(dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, default,default,default,default,default,default,default,default,default,ord_RevType1,ord_RevType2,ord_RevType3,ord_RevType4,default,default,default,default,default,default,default,default,default,default,default,default,ord_bookedby),'')

		into   #TempResults1
		From   orderheader (NOLOCK)
		where  	ord_startdate < @DateToStart
	       		AND (@OrderStatus =',,' or CHARINDEX(',' + ord_status + ',', @OrderStatus) >0)
	       		AND (@RevType1 =',,' or CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
	       		AND (@RevType2 =',,' or CHARINDEX(',' + ord_revtype2 + ',', @RevType2) >0)
	       		AND (@RevType3 =',,' or CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
	       		AND (@RevType4 =',,' or CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
				AND (@OnlyBillToList =',,' or CHARINDEX(',' + ord_billto + ',', @OnlyBillToList) >0)
				AND (@OnlyOriginRegion =',,' or CHARINDEX(',' + ord_originregion1 + ',', @OnlyOriginRegion) >0)
				AND (@OrderPriorityList =',,' or CHARINDEX(',' + ord_priority + ',', @OrderPriorityList) >0) 
	END
	ELSE
	BEGIN
		IF @UseLghOutStatusYN <> 'Y'
		BEGIN
			select t1.ord_number as [Order #],
				t1.mov_number as [Move #],
				@DateToStart as StartDate,
				t1.ord_startdate as [Ship Date],
				t1.ord_completiondate as [Est Delivery Date],
				t1.ord_shipper as [Shipper ID],
				t1.ord_originregion1 as [Origin Region],
				IsNull((select cty_name from city (NOLOCK) Where cty_code = t1.ord_origincity),'') as [Origin City],
				IsNull((select cty_state from city (NOLOCK) Where cty_code = t1.ord_origincity),'') as [Origin State],
				t1.ord_consignee as [Consignee ID],
				IsNull((select cty_name from city (NOLOCK) Where cty_code = t1.ord_destcity),'') as [Destination City],
				IsNull((select cty_state from city (NOLOCK) Where cty_code = t1.ord_destcity),'') as [Destination State],
				IsNull((select cmp_name from company (NOLOCK) Where cmp_id = t1.ord_billto),'') as [BillTo],
				t1.ord_billto as [BillTo ID],
				t1.ord_tractor as [Tractor ID],
				t1.ord_revtype1 as RevType1,
				t1.ord_revtype2 as RevType2,
				t1.ord_revtype3 as RevType3,
				t1.ord_revtype4 as RevType4,
				t1.ord_priority,
				ord_status AS OrderStatus,
				t1.ord_bookedby as BookedBy,
				EmailSend = ISNULL(dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, default,default,default,default,default,default,default,default,default,ord_RevType1,ord_RevType2,ord_RevType3,ord_RevType4,default,default,default,default,default,default,default,default,default,default,default,default,t1.ord_bookedby),'')
			INTO   #TempResults2
			From   legheader_active t2 (NOLOCK), orderheader t1 (NOLOCK)
			where  	t1.ord_hdrnumber = t2.ord_hdrnumber
					AND t1.ord_startdate < @DateToStart
	       			AND (@OrderStatus =',,' or CHARINDEX(',' + t1.ord_status + ',', @OrderStatus) >0)
	       			AND (@RevType1 =',,' or CHARINDEX(',' + t1.ord_revtype1 + ',', @RevType1) >0)
	       			AND (@RevType2 =',,' or CHARINDEX(',' + t1.ord_revtype2 + ',', @RevType2) >0)
	       			AND (@RevType3 =',,' or CHARINDEX(',' + t1.ord_revtype3 + ',', @RevType3) >0)
	       			AND (@RevType4 =',,' or CHARINDEX(',' + t1.ord_revtype4 + ',', @RevType4) >0)
					AND (@OnlyBillToList =',,' or CHARINDEX(',' + t1.ord_billto + ',', @OnlyBillToList) >0)
					AND (@OnlyOriginRegion =',,' or CHARINDEX(',' + t1.ord_originregion1 + ',', @OnlyOriginRegion) >0)
					AND (@OrderPriorityList =',,' or CHARINDEX(',' + t1.ord_priority + ',', @OrderPriorityList) >0) 
					AND (ISNULL(t2.lgh_tractor, 'UNKNOWN') = 'UNKNOWN' OR ISNULL(t2.lgh_driver1, 'UNKNOWN') = 'UNKNOWN')
		END
		ELSE
		BEGIN
			select t1.ord_number as [Order #],
				t1.mov_number as [Move #],
				@DateToStart as StartDate,
				t1.ord_startdate as [Ship Date],
				t2.lgh_startdate as [Leg Start Date],
				t2.lgh_outstatus as [Leg Out Status],
				t1.ord_completiondate as [Est Delivery Date],
				t1.ord_shipper as [Shipper ID],
				t1.ord_originregion1 as [Origin Region],
				IsNull((select cty_name from city (NOLOCK) Where cty_code = t1.ord_origincity),'') as [Origin City],
				IsNull((select cty_state from city (NOLOCK) Where cty_code = t1.ord_origincity),'') as [Origin State],
				t1.ord_consignee as [Consignee ID],
				IsNull((select cty_name from city (NOLOCK) Where cty_code = t1.ord_destcity),'') as [Destination City],
				IsNull((select cty_state from city (NOLOCK) Where cty_code = t1.ord_destcity),'') as [Destination State],
				IsNull((select cmp_name from company (NOLOCK) Where cmp_id = t1.ord_billto),'') as [BillTo],
				t1.ord_billto as [BillTo ID],
				t1.ord_tractor as [Tractor ID],
				t1.ord_revtype1 as RevType1,
				t1.ord_revtype2 as RevType2,
				t1.ord_revtype3 as RevType3,
				t1.ord_revtype4 as RevType4,
				t1.ord_priority,
				ord_status AS OrderStatus,
				t1.ord_bookedby as BookedBy,
				EmailSend = ISNULL(dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, default,default,default,default,default,default,default,default,default,ord_RevType1,ord_RevType2,ord_RevType3,ord_RevType4,default,default,default,default,default,default,default,default,default,default,default,default,t1.ord_bookedby),'')
			INTO   #TempResults3
			From   legheader t2 (NOLOCK), orderheader t1 (NOLOCK)
			where  	t1.ord_hdrnumber = t2.ord_hdrnumber
				AND t2.lgh_startdate < @DateToStart
	       			AND (@LghOutStatus =',,' or CHARINDEX(',' + t2.lgh_outstatus + ',', @LghOutStatus) >0)
	       			AND (@RevType1 =',,' or CHARINDEX(',' + t1.ord_revtype1 + ',', @RevType1) >0)
	       			AND (@RevType2 =',,' or CHARINDEX(',' + t1.ord_revtype2 + ',', @RevType2) >0)
	       			AND (@RevType3 =',,' or CHARINDEX(',' + t1.ord_revtype3 + ',', @RevType3) >0)
	       			AND (@RevType4 =',,' or CHARINDEX(',' + t1.ord_revtype4 + ',', @RevType4) >0)
					AND (@OnlyBillToList =',,' or CHARINDEX(',' + t1.ord_billto + ',', @OnlyBillToList) >0)
					AND (@OnlyOriginRegion =',,' or CHARINDEX(',' + t1.ord_originregion1 + ',', @OnlyOriginRegion) >0)
					AND (@OrderPriorityList =',,' or CHARINDEX(',' + t1.ord_priority + ',', @OrderPriorityList) >0) 
					AND (ISNULL(t2.lgh_tractor, 'UNKNOWN') = 'UNKNOWN' OR ISNULL(t2.lgh_driver1, 'UNKNOWN') = 'UNKNOWN')
			order by t1.ord_startdate
		END
		
	END
	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	BEGIN
		IF @UseLghActiveTableYN <> 'Y'
		BEGIN
			Set @SQL = 'Select * from #TempResults1'
		END
		ELSE
		BEGIN
			IF @UseLghOutStatusYN <>'Y'
				Set @SQL = 'Select * from #TempResults2'
			ELSE
				Set @SQL = 'Select * from #TempResults3'
		END
	END
	ELSE
	BEGIN
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		IF @UseLghActiveTableYN <> 'Y'
		BEGIN
			Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults1'
		END
		ELSE
		BEGIN
			IF @UseLghOutStatusYN <>'Y'
				Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults2'
			ELSE
				Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults3'
		END
	End

	Exec (@SQL)

	Set NoCount Off

GO
GRANT EXECUTE ON  [dbo].[WatchDog_OldAvailableOrders] TO [public]
GO
