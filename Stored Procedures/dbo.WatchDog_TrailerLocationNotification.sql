SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[WatchDog_TrailerLocationNotification]           
	(
		@MinThreshold FLOAT = .5, --Miles
--select dbo.fnc_AirMilesBetweenLatLongSeconds (164229, 164243, 441503, 441528)  
		@MinsBack INT=-20,
		@TempTableName VARCHAR(255) = '##WatchDogGlobalTrailerLocationNotification',
		@WatchName VARCHAR(255)='TrailerLocationNotification',
		@ThresholdFieldName VARCHAR(255) = 'Miles',
		@ColumnNamesOnly bit = 0,
		@ExecuteDirectly bit = 0,
		@ColumnMode VARCHAR(50) = 'Selected',
		@OnlyLocationLatitudeInDegrees FLOAT =0, --45.621
		@OnlyLocationLongitudeInDegrees FLOAT=0, --122.643
		@TrcType1 VARCHAR(255)='',
		@TrcType2 VARCHAR(255)='',
		@TrcType3 VARCHAR(255)='',
		@TrcType4 VARCHAR(255)='',
		@TrcFleet VARCHAR(255)='',
		@TrcDivision VARCHAR(255)='',
		@TrcCompany VARCHAR(255)='',
		@TrcTerminal VARCHAR(255)=''
 	)
						
AS

	SET NOCOUNT ON
	
	/***************************************************************
	Procedure Name:    WatchDog_TrailerLocationNotification
	Author/CreateDate: David Wilks / 4-2-2006
	Purpose: 	   	Provides a notification of which trailers are in a yard and what commodity is in the trailers
	Revision History:	
	****************************************************************/
	
	/*

	if not exists (select WatchName from WatchDogItem where WatchName = 'TrailerLocationNotification')
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
	 VALUES ('TrailerLocationNotification','12/30/1899','12/30/1899','WatchDog_TrailerLocationNotification','','',0,0,'','','','','',1,0,'','','')

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
	
	SELECT  
		trc_trailer1 as [Trailer],
		trc_number as [Tractor],
		trc_gps_date as [GPS Date],-- as [Message Sent Date],
	    trc_gps_desc as [Location Description],
		trc_gps_latitude as Latitude, 
		trc_gps_longitude as Longitude
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
		AND IsNull(trc_gps_date, '19000101') > DateAdd(yy,-10,GetDate())
		AND IsNull(trc_trailer1, '') > ''

		SELECT 	
		[Trailer],
		'Trailer Loaded Status' = dbo.fnc_TMWRN_TrailerLoadedStatus([Trailer], default),
		'Last Trailer Commodity' = dbo.fnc_TMWRN_TrailerCommodityList([Trailer], default, default, default),
		[Tractor],
		[GPS Date],
	    [Location Description]
		INTO #TempResults
		FROM #TempResultsStep1
		WHERE IsNull(dbo.fnc_AirMilesBetweenLatLongSeconds (Latitude, @OnlyLocationLatitudeInDegrees*3600, Longitude, @OnlyLocationLongitudeInDegrees*3600),9999)   <= @MinThreshold

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
GRANT EXECUTE ON  [dbo].[WatchDog_TrailerLocationNotification] TO [public]
GO
