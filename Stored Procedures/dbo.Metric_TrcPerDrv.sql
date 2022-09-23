SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_TrcPerDrv] 
	(
		--Standard Parameters
		@Result DECIMAL(20, 5) OUTPUT, 
		@ThisCount DECIMAL(20, 5) OUTPUT, 
		@ThisTotal DECIMAL(20, 5) OUTPUT, 
		@DateStart DATETIME, 
		@DateEnd DATETIME, 
		@UseMetricParms INT, 
		@ShowDetail INT,
	
		--Additional/Optional Parameters 
		@ExcludeOutOfServiceTrucks CHAR(1) ='Y',
		@OnlyRevClass1List VARCHAR(128) ='',
		@OnlyRevClass2List VARCHAR(128) ='',
		@OnlyRevClass3List VARCHAR(128) ='',
		@OnlyRevClass4List VARCHAR(128) ='',
		@OnlyDrvTerminalList VARCHAR(128) ='',
		@OnlyDrvFleetList VARCHAR(128)='',
		@OnlyDrvDivisionList VARCHAR(128)='',
		@OnlyDrvDomicileList VARCHAR(128)='',
		@OnlyDrvCompanyList VARCHAR(128)='',
		@OnlyDrvStatusList VARCHAR(128)='',
		@ExcludeDrvFleetList VARCHAR(128)='',
		@ExcludeDrvDivisionList VARCHAR(128)='',
		@ExcludeDrvDomicileList VARCHAR(128)='',
		@ExcludeDrvCompanyList VARCHAR(128)='',
		@ExcludeDrvTerminalList VARCHAR(128)='',
		@OnlyMppType1List VARCHAR(128) ='',
		@OnlyMppType2List VARCHAR(128) ='',
		@OnlyMppType3List VARCHAR(128) ='',
		@OnlyMppType4List VARCHAR(128) ='',
		@OnlyTrcClass1List varchar(128) ='',
		@OnlyTrcClass2List varchar(128) ='',
		@OnlyTrcClass3List varchar(128) ='',
		@OnlyTrcClass4List varchar(128) ='',
		@OnlyTrcTerminal varchar(128) ='',
		@MetricCode VARCHAR(255)= 'TrcPerDrv',
	    @OnlyTeamLeaderList VARCHAR(255) = '', -- Used to include only selected Team Leaders
		@ExcludeTeamLeaderList VARCHAR(255)=''
	)
AS

	SET NOCOUNT ON  -- PTS46367

	--Populate DEFAULT currency and currency date types
        EXEC PopulateSessionIDParamatersInProc 'Revenue',@MetricCode  

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'TrcPerDrv',
		@nActive = 1,	-- 1=active, 0=inactive.
		@nSort = 106, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'CURR',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = 'Tractor / Driver',
		@sCaptionFull = 'Tractors per Driver',
		@sProcedureName = 'Metric_TrcPerDrv',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDEFAULTYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = 'Dispatch'


	insert INTO metricparameter (Heading,SubHeading,ParmName,ParmValue) Values ('Config','RevPerDrv2','RetainTotalForMetricYN','Y')

	</METRIC-INSERT-SQL>
*/

/*	To test this:
	DECLARE	@Result decimal(20, 5), @ThisCount decimal(20, 5), @ThisTotal decimal(20, 5), @DateStart datetime, @DateEnd datetime, @UseMetricParms int, @ShowDetail int
	EXEC Metric_RevPerTrc2 @Result OUTPUT, @ThisCount OUTPUT, @ThisTotal OUTPUT, '3/3/2002', '3/4/2002', 1, 1
*/

	SET @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	SET @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	SET @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	SET @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','

	SET @OnlyDrvStatusList= ',' + ISNULL(@OnlyDrvStatusList,'') + ',' 
	
	SET @OnlyMppType1List= ',' + ISNULL(@OnlyMppType1List,'') + ','
	SET @OnlyMppType2List= ',' + ISNULL(@OnlyMppType2List,'') + ','
	SET @OnlyMppType3List= ',' + ISNULL(@OnlyMppType3List,'') + ','
	SET @OnlyMppType4List= ',' + ISNULL(@OnlyMppType4List,'') + ','

	SET @OnlyDrvTerminalList= ',' + ISNULL(@OnlyDrvTerminalList,'') + ','
	SET @OnlyDrvFleetList= ',' + ISNULL(@OnlyDrvFleetList,'') + ',' 
	SET @OnlyDrvDivisionList= ',' + ISNULL(@OnlyDrvDivisionList,'') + ','
	SET @OnlyDrvDomicileList= ',' + ISNULL(@OnlyDrvDomicileList,'') + ','
	SET @OnlyDrvCompanyList= ',' + ISNULL(@OnlyDrvCompanyList,'') + ','  
	--SET @OnlyDrvFleetList= ',' + ISNULL(@OnlyDrvFleetList,'') + ','  
	
	SET @ExcludeDrvFleetList= ',' + ISNULL(@ExcludeDrvFleetList,'') + ',' 
	SET @ExcludeDrvDivisionList= ',' + ISNULL(@ExcludeDrvDivisionList,'') + ',' 
	SET @ExcludeDrvDomicileList= ',' + ISNULL(@ExcludeDrvDomicileList,'') + ','
	SET @ExcludeDrvCompanyList= ',' + ISNULL(@ExcludeDrvCompanyList,'') + ',' 
	SET @ExcludeDrvTerminalList= ',' + ISNULL(@ExcludeDrvTerminalList,'') + ','  
	 
	Set @OnlyTrcClass1List= ',' + ISNULL(@OnlyTrcClass1List,'') + ','
	Set @OnlyTrcClass2List= ',' + ISNULL(@OnlyTrcClass2List,'') + ','
	Set @OnlyTrcClass3List= ',' + ISNULL(@OnlyTrcClass3List,'') + ','
	Set @OnlyTrcClass4List= ',' + ISNULL(@OnlyTrcClass4List,'') + ','

	Set @OnlyTrcTerminal= ',' + ISNULL(@OnlyTrcTerminal,'') + ','

	SET @OnlyTeamLeaderList = ',' + ISNULL(@OnlyTeamLeaderList,'') + ','
	SET @ExcludeTeamLeaderList= ',' + ISNULL(@ExcludeTeamLeaderList,'') + ','

	Select @ThisCount = dbo.fnc_TMWRN_TractorCount(default,@OnlyTrcClass1List,@OnlyTrcClass2List,@OnlyTrcClass3List,@OnlyTrcClass4List,@OnlyTrcTerminal,'','','','',@ExcludeOutOfServiceTrucks,@OnlyMppType1List,@OnlyMppType2List,@OnlyMppType3List,@OnlyMppType4List,@OnlyRevClass1List,	@OnlyRevClass2List,	@OnlyRevClass3List,	@OnlyRevClass4List,@DateStart,@DateEnd,default,'N',@OnlyTeamLeaderList,default,default,default,default,default)

-- modified 3/19/08 to add mpptype parameters to function call
	Select @ThisTotal =  dbo.fnc_TMWRN_DriverCount(DEFAULT, 'active', @DateStart, @DateEnd, @OnlyDrvFleetList, @OnlyDrvDivisionList, @OnlyDrvDomicileList, @OnlyDrvCompanyList, @OnlyDrvTerminalList, @OnlyDrvStatusList, @ExcludeDrvFleetList, @ExcludeDrvDivisionList, @ExcludeDrvDomicileList, DEFAULT, DEFAULT, DEFAULT, @OnlyMppType1List, @OnlyMppType2List, @OnlyMppType3List, @OnlyMppType4List, @OnlyRevClass1List,@OnlyRevClass2List,@OnlyRevClass3List,@OnlyRevClass4List,DEFAULT, DEFAULT, DEFAULT, DEFAULT)

	
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END
GO
GRANT EXECUTE ON  [dbo].[Metric_TrcPerDrv] TO [public]
GO
