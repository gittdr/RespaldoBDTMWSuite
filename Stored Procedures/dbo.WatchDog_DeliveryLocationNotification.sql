SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[WatchDog_DeliveryLocationNotification]           
	(
		@MinThreshold FLOAT = 50, --Miles
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalDeliveryLocationNotification',
		@WatchName VARCHAR(255)='DeliveryLocationNotification',
		@ThresholdFieldName VARCHAR(255) = 'Miles',
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@TotalMailFormID INT = 6,
		--@TotalMailMessageStampedWithLatLongYN = 'Y',
		@OnlyLocationLatitudeInDegrees FLOAT =0,
		@OnlyLocationLongitudeInDegrees FLOAT=0,
		@TrcType1 VARCHAR(255)='',
		@TrcType2 VARCHAR(255)='',
		@TrcType3 VARCHAR(255)='',
		@TrcType4 VARCHAR(255)='',
		@TrcFleet VARCHAR(255)='',
		@TrcDivision VARCHAR(255)='',
		@TrcCompany VARCHAR(255)='',
		@TrcTerminal VARCHAR(255)='',
		@ParameterToUseForDynamicEmail VARCHAR(255)=''  -- @TrcType1-4, @TrcDivision, @TrcCompany, @TrcTermainal
 	)
						
AS

	SET NOCOUNT ON
	
	/***************************************************************
	Procedure Name:    WatchDog_DeliveryLocationNotification
	Author/CreateDate: Lori Brickley / 7-5-2005
	Purpose: 	   	Provides a notification of deliveries (Arrive at
					Consignee) within a radius of a specified location
					and within the last x minutes		
	Revision History:	
	****************************************************************/
	
	/*

	if not exists (select WatchName from WatchDogItem where WatchName = 'DeliveryLocationNotification')
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
	 VALUES ('DeliveryLocationNotification','12/30/1899','12/30/1899','WatchDog_DeliveryLocationNotification','','',0,0,'','','','','',1,0,'','','')

	*/
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL VARCHAR(8000)
	Declare @COLSQL VARCHAR(4000)
	--Reserved/Mandatory WatchDog Variables
	
	--Standard Parameter Initialization
	SET @TrcType1= ',' + ISNULL(@TrcType1,'') + ','
	SET @TrcType2= ',' + ISNULL(@TrcType2,'') + ','
	SET @TrcType3= ',' + ISNULL(@TrcType3,'') + ','
	SET @TrcType4= ',' + ISNULL(@TrcType4,'') + ','
	
	SET @TrcTerminal = ',' + ISNULL(@TrcTerminal,'') + ','
	SET @TrcCompany = ',' + ISNULL(@TrcCompany,'') + ','
	SET @TrcFleet = ',' + ISNULL(@TrcFleet,'') + ','
	SET @TrcDivision = ',' + ISNULL(@TrcDivision,'') + ','
	
	/****************************************************************************
		Create temp table #TempResults where the following conditions are met:
		
		Select the Tractor, DTSent, Contents, Position for the FormID for all
		messages within the last x minutes
	
	*****************************************************************************/
	
	SELECT  distinct
		trc_number as [Tractor],
		trc_gps_date as [GPS Date],-- as [Message Sent Date],
	    trc_gps_desc as [Location Description],
		trc_gps_latitude as Latitude, 
		trc_gps_longitude as Longitude
		--EmailSend = ISNULL(dbo.fnc_TMWRN_EmailSend(@ParameterToUseForDynamicEmail, trc_company,trc_division,default,default,default,default,default,default,default,default,default,default,default,mpp_teamleader,trc_terminal,default,trc_type1,trc_type2,trc_type3,trc_type4,default,default,default,default,default,default),'')
	INTO #TempResultsStep1
	FROM tractorprofile (nolock)
	WHERE trc_retiredate > getdate() and trc_startdate <= getdate()
		AND (@TrcType1 =',,' OR CHARINDEX(',' + trc_type1 + ',', @TrcType1) >0)
	    AND (@TrcType2 =',,' OR CHARINDEX(',' + trc_type2 + ',', @TrcType2) >0)
	    AND (@TrcType3 =',,' OR CHARINDEX(',' + trc_type3 + ',', @TrcType3) >0)
	    AND (@TrcType4 =',,' OR CHARINDEX(',' + trc_type4 + ',', @TrcType4) >0)
		AND (@TrcTerminal =',,' OR CHARINDEX(',' + trc_terminal + ',', @TrcTerminal) >0)
	    AND (@TrcFleet =',,' OR CHARINDEX(',' + trc_fleet + ',', @TrcFleet) >0)
	    AND (@TrcCompany =',,' OR CHARINDEX(',' + trc_company + ',', @TrcCompany) >0)
	    AND (@TrcDivision =',,' OR CHARINDEX(',' + trc_division + ',', @TrcDivision) >0) 
	    AND IsNull(trc_gps_date, '19000101') >= dateadd(mi,@MinsBack,getdate())	

	
	
	/*****************************************************************************
	Select delivery Tractor, Lat, Long
	*****************************************************************************/
	select evt_tractor, event.ord_hdrnumber, ord_consignee, cmp_latseconds, cmp_longseconds, evt_eventcode, evt_startdate
	INTO #TempResultsStep2
	from orderheader (NOLOCK)
		join event (NOLOCK) on orderheader.ord_hdrnumber =event.ord_hdrnumber
		join company (NOLOCK) on ord_consignee = cmp_id
	WHERE evt_startdate >= dateadd(mi,@MinsBack,getdate())	


	/*****************************************************************************
	Combine Tractors and 
	*****************************************************************************/
	select * 
	INTO #TempResultsStep3
	from #TempResultsStep1 JOIN #TempResultsStep2 ON evt_tractor = tractor

	/*****************************************************************************
	Select the Tractor, DTSent, Contents, Position, DistanceFromLocation
		for all messages within the minThreshold distance radius
	
	*****************************************************************************/
	IF @OnlyLocationLatitudeInDegrees <> 0 AND @OnlyLocationLongitudeInDegrees <> 0 
	BEGIN
		SELECT 	distinct Tractor,
				ord_hdrnumber as [Order Number],
				evt_eventcode as [Event],
				evt_startdate as [Event Date],
				[GPS Date] as [Trc GPS Date], 
				[Location Description] as [Trc Location], 
				'Distance From Location' = dbo.fnc_AirMilesBetweenLatLongSeconds (Latitude, @OnlyLocationLatitudeInDegrees*3600, Longitude, @OnlyLocationLongitudeInDegrees*3600)  
		INTO #TempResults1
		FROM #TempResultsStep3
		WHERE dbo.fnc_AirMilesBetweenLatLongSeconds (Latitude, @OnlyLocationLatitudeInDegrees*3600, Longitude, @OnlyLocationLongitudeInDegrees*3600)   <= @MinThreshold
	END 
	ELSE
	BEGIN
		SELECT 	distinct Tractor,
				ord_hdrnumber as [Order Number],
				evt_eventcode as [Event],
				evt_startdate as [Event Date],
				[GPS Date] as [Trc GPS Date], 
				[Location Description] as [Trc Location], 
				'Distance From Location' = dbo.fnc_AirMilesBetweenLatLongSeconds (Latitude, cmp_latseconds, Longitude, cmp_longseconds)  
		INTO #TempResults2
		FROM #TempResultsStep3
		WHERE dbo.fnc_AirMilesBetweenLatLongSeconds (Latitude, cmp_latseconds, Longitude, cmp_longseconds)   <= @MinThreshold
	
	END
	--Commits the results to be used in the wrapper
	IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
	BEGIN
		IF @OnlyLocationLatitudeInDegrees <> 0 AND @OnlyLocationLongitudeInDegrees <> 0 
			SET @SQL = 'SELECT * FROM #TempResults1'
		ELSE
			SET @SQL = 'SELECT * FROM #TempResults2'
	END
	ELSE
	BEGIN
		IF @OnlyLocationLatitudeInDegrees <> 0 AND @OnlyLocationLongitudeInDegrees <> 0
		BEGIN
			SET @COLSQL = ''
			EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
			SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults1'
		END
		ELSE
		BEGIN
			SET @COLSQL = ''
			EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
			SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults2'
		END
	END
	
	EXEC (@SQL)
	
	SET NOCOUNT OFF
	

GO
GRANT EXECUTE ON  [dbo].[WatchDog_DeliveryLocationNotification] TO [public]
GO
