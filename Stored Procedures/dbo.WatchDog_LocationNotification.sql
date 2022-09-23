SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[WatchDog_LocationNotification]           
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
		@LocationLatitudeInDegrees FLOAT =0,
		@LocationLongitudeInDegrees FLOAT=0,
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
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateT
ype, Description)
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

	/*****************************************************************************
	Select the Tractor, DTSent, Contents, Position, DistanceFromLocation
		for all messages within the minThreshold distance radius
	
	*****************************************************************************/
	
	SELECT 	distinct Tractor, 
			[GPS Date], 
			[Location Description], 
			Latitude,  
			Longitude,  
			'Distance From Location' = dbo.fnc_AirMilesBetweenLatLongSeconds (Latitude, @LocationLatitudeInDegrees*3600, Longitude, @LocationLongitudeInDegrees*3600)  
	INTO #TempResults
	FROM #TempResultsStep1
	WHERE dbo.fnc_AirMilesBetweenLatLongSeconds (Latitude, @LocationLatitudeInDegrees*3600, Longitude, @LocationLongitudeInDegrees*3600)   <= @MinThreshold
	
	--Commits the results to be used in the wrapper
	IF @ColumnNamesOnly = 1 OR @ExecuteDirectly = 1
	BEGIN
		SET @SQL = 'SELECT * FROM #TempResults'
	END
	ELSE
	BEGIN
		SET @COLSQL = ''
		EXEC WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		SET @SQL = 'SELECT identity(INT,1,1) AS RowID ' + @COLSQL + ' INTO ' + @TempTableName + ' FROM #TempResults'
	END
	
	EXEC (@SQL)
	
	SET NOCOUNT OFF
	
	
GO
