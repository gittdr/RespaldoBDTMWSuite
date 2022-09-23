SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


--WatchDogProcessing 'LoadsInTransit' ,1
CREATE Proc [dbo].[WatchDog_LoadsInTransit]
(
	@MinThreshold float = 200,
	@MinsBack int=-10080,
	@TempTableName varchar(255) = '##WatchDogGlobalLoadsInTransit',
	@WatchName varchar(255)='WatchLoadsInTransit',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar(50) = 'Selected',
	@RevType1 varchar(255)='',
	@RevType2 varchar(255)='',
	@RevType3 varchar(255)='',
	@RevType4 varchar(255)='',
	@OrderStatus varchar(140)='STD,DSP',
	@ThresholdLevel varchar(140) = 'Movement',
	@OnlyShipperIDList varchar(255) = '',
	@ExcludeShipperIDList varchar(255)='',
	@OnlyConsigneeIDList varchar(255)='',
	@ExcludeConsigneeIDList varchar(255)='',
	@OnlyBillToIDList varchar(255)='',
	@ExcludeBillToIDList varchar(255)=''
)
						

As

	Set NoCount On
	
	
	/*
	Procedure Name:    WatchDog_CarrierLoads
	Author/CreateDate: Lori Brickley / 8-8-2005
	Purpose: 	   Returns all legs which were hauled by a carrier
	Revision History:
	*/
	

	/*
	if not exists (select WatchName from WatchDogItem where WatchName = 'LoadsInTransit')
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
	 VALUES ('LoadsInTransit','12/30/1899','12/30/1899','WatchDog_LoadsInTransit','','',0,0,'','','','','',1,0,'','','')
	*/
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables
	
	Set @RevType1= ',' + ISNULL(@RevType1,'') + ','
	Set @RevType2= ',' + ISNULL(@RevType2,'') + ','
	Set @RevType3= ',' + ISNULL(@RevType3,'') + ','
	Set @RevType4= ',' + ISNULL(@RevType4,'') + ','
	Set @OrderStatus= ',' + ISNULL(@OrderStatus,'') + ','
	Set @OnlyShipperIDList= ',' + ISNULL(@OnlyShipperIDList,'') + ','
	Set @ExcludeShipperIDList= ',' + ISNULL(@ExcludeShipperIDList,'') + ','
	Set @OnlyConsigneeIDList= ',' + ISNULL( @OnlyConsigneeIDList,'') + ','
	Set @ExcludeConsigneeIDList= ',' + ISNULL( @ExcludeConsigneeIDList,'') + ','
	Set @OnlyBillToIDList= ',' + ISNULL( @OnlyBillToIDList,'') + ','
	Set @ExcludeBillToIDList= ',' + ISNULL(@ExcludeBillToIDList,'') + ','
	
	Select 	Origin = (Select cty_name+', '+ cty_State from city (nolock) where cty_code = ord_origincity),
			Destination = (Select cty_name+', '+ cty_State from city (nolock) where cty_code = ord_destcity),
			Tractor = (Select top 1 lgh_tractor from legheader (Nolock) where legheader.ord_hdrnumber = orderheader.ord_hdrnumber and cmp_id_end = ord_consignee),
			DestinationLat = (select cty_latitude from city (NOLOCK) where cty_code = ord_destcity),
			DestinationLong = (select cty_longitude from city (NOLOCK) where cty_code = ord_destcity),
			Cast(0 as Decimal(20,6)) AS TractorLat,
			Cast(0 as Decimal(20,6)) AS TractorLong,
			9999 AS [Est Miles To Go],
			GETDATE() AS [GPS Date Time],
			Cast(' ' as VARCHAR(255)) AS [Last GPS],
			GETDATE() AS [ETA],
			ord_hdrnumber as [Order Number],
			ord_refnum AS [Ref Number]
	into #Order
	From orderheader(NOLOCK)
	Where ord_startdate >= DateAdd(mi,@MinsBack,GetDate())
		And (@RevType1 =',,' or CHARINDEX(',' + ord_RevType1 + ',', @RevType1) >0)
		AND	(@RevType2 =',,' or CHARINDEX(',' + ord_RevType2 + ',', @RevType2) >0)
		AND (@RevType3 =',,' or CHARINDEX(',' + ord_RevType3 + ',', @RevType3) >0)
		AND (@RevType4 =',,' or CHARINDEX(',' + ord_RevType4 + ',', @RevType4) >0)
		And (@OrderStatus =',,' or CHARINDEX(',' + ord_status + ',', @OrderStatus) >0)
		And (@OnlyBillToIDList = ',,' OR (CHARINDEX(',' + orderheader.ord_billto + ',', @OnlyBillToIDList) > 0))
		And (@ExcludeBillToIDList = ',,' OR Not (CHARINDEX(',' + orderheader.ord_billto + ',', @ExcludeBillToIDList) > 0))
		And (@OnlyShipperIDList = ',,' OR (CHARINDEX(',' + orderheader.ord_shipper + ',', @OnlyShipperIDList) > 0))
		And (@ExcludeShipperIDList = ',,' OR Not (CHARINDEX(',' + orderheader.ord_shipper + ',', @ExcludeShipperIDList) > 0))
		And (@OnlyConsigneeIDList = ',,' OR (CHARINDEX(',' + orderheader.ord_consignee + ',', @OnlyConsigneeIDList) > 0))
		And (@ExcludeConsigneeIDList = ',,' OR Not (CHARINDEX(',' + orderheader.ord_consignee + ',', @ExcludeConsigneeIDList) > 0))
	 
	Update #Order
	SET TractorLat = trc_gps_latitude,
		TractorLong = trc_gps_longitude,
		[GPS Date Time] = trc_gps_date,
		[Last GPS] = trc_gps_desc
	FROM TractorProfile (nolock) 
	WHERE Tractor = trc_number
			AND trc_gps_desc is not null

	Update #Order
	SET [Est Miles To Go] = dbo.fnc_AirMilesBetweenLatLongSeconds(TractorLat,DestinationLat*3600,TractorLong,DestinationLong*3600)

	Update #Order
	SET [ETA] = DateAdd(hour, [Est Miles To Go]/45.00,[GPS Date Time])
	WHERE [Est Miles To Go] >0

	Select 	Origin,
			Destination,
			Tractor,
			[Est Miles To Go],
			[GPS Date Time],
			[Last GPS],
			[ETA],
			[Order Number],
			[Ref Number]
	INTO #TempResults
	From #Order
	WHERE [Last GPS] <> ' '



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
