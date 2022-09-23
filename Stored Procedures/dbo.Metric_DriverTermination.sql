SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_DriverTermination] 
	(
		--Standard Parameters
		@Result decimal(20, 5) OUTPUT, 
		@ThisCount decimal(20, 5) OUTPUT, 
		@ThisTotal decimal(20, 5) OUTPUT, 
		@DateStart datetime, 
		@DateEnd datetime, 
		@UseMetricParms int, 
		@ShowDetail int,

		--Additional/Optional Parameters
		@OnlyDrvClass1List varchar(128) ='',
		@OnlyDrvClass2List varchar(128) ='',
		@OnlyDrvClass3List varchar(128) ='',
		@OnlyDrvClass4List varchar(128) ='',
		@OnlyDrvTerminalList varchar(255)='',
		@OnlyTeamLeaderList varchar(255)='',
		@UseDriverTotal char(1)='N',
		@OnlyDrvFleetList varchar(128)='',
		@OnlyDrvDivisionList varchar(128)='',
		@OnlyDrvDomicileList varchar(128)='',
		@OnlyDrvCompanyList varchar(128)='',
		@OnlyDrvStatusList varchar(255)= '',
		@ExcludeDrvFleetList varchar(255) = '',
		@ExcludeDrvDivisionList varchar(255) = '',
		@ExcludeDrvDomicileList varchar(255) = '',
		@ExcludeDrvCompanyList varchar(255) = '',
		@ExcludeDrvTerminalList varchar(255) = '',
		@ExcludeDrvStatusList varchar(255) = '',
		@ExcludeTeamLeaderList varchar(255)='',
		@ExcludeDriversWithinProbationaryPeriodYN varchar(1)='N',
		@ProbationaryPeriodDays int = 60
	)
AS

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	This example creates two metric based on one stored procedure. (The only difference is the cumulative flag.)
	Typically, only one MetricInitializeItem is necessary.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'DriverTermination',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 105, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 1,
		@sCaption = 'Driver Turnover',
		@sCaptionFull = 'Orders booked (cumulative)',
		@sProcedureName = 'Metric_DriverTermination',
		-- @sDetailFilename	= '',	
		-- @sThresholdAlertEmailAddress = '',  
		-- @nThresholdAlertValue = 0, 
		-- @sThresholdOperator = '',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = '@@NOCATEGORY'


	</METRIC-INSERT-SQL>

*/

	SET NOCOUNT ON

	Set @OnlyDrvClass1List= ',' + ISNULL(@OnlyDrvClass1List,'') + ','
	Set @OnlyDrvClass2List= ',' + ISNULL(@OnlyDrvClass2List,'') + ','
	Set @OnlyDrvClass3List= ',' + ISNULL(@OnlyDrvClass3List,'') + ','
	Set @OnlyDrvClass4List= ',' + ISNULL(@OnlyDrvClass4List,'') + ','
	Set @OnlyDrvTerminalList = ',' + ISNULL(@OnlyDrvTerminalList,'') + ','
	Set @OnlyTeamLeaderList = ',' + ISNULL(@OnlyTeamLeaderList,'') + ','
	Set @OnlyDrvFleetList = ',' + ISNULL(@OnlyDrvFleetList,'') + ','
	Set @OnlyDrvDivisionList = ',' + ISNULL(@OnlyDrvDivisionList,'') + ','	
	Set @OnlyDrvDomicileList = ',' + ISNULL(@OnlyDrvDomicileList,'') + ','
	Set @OnlyDrvCompanyList = ',' + ISNULL(@OnlyDrvCompanyList,'') + ','	
	SELECT @OnlyDrvStatusList = Case When Left(@OnlyDrvStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvStatusList, ''))) + ',' Else @OnlyDrvStatusList End

	
	SELECT @ExcludeDrvFleetList = Case When Left(@ExcludeDrvFleetList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvFleetList, ''))) + ',' Else @ExcludeDrvFleetList End
	SELECT @ExcludeDrvDivisionList = Case When Left(@ExcludeDrvDivisionList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvDivisionList, ''))) + ',' Else @ExcludeDrvDivisionList End
	SELECT @ExcludeDrvDomicileList = Case When Left(@ExcludeDrvDomicileList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvDomicileList, ''))) + ',' Else @ExcludeDrvDomicileList End
	SELECT @ExcludeDrvCompanyList = Case When Left(@ExcludeDrvCompanyList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvCompanyList, ''))) + ',' Else @ExcludeDrvCompanyList End
	SELECT @ExcludeDrvTerminalList = Case When Left(@ExcludeDrvTerminalList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvTerminalList, ''))) + ',' Else @ExcludeDrvTerminalList End
	SELECT @ExcludeDrvStatusList = Case When Left(@ExcludeDrvStatusList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeDrvStatusList, ''))) + ',' Else @ExcludeDrvStatusList End
	SELECT @ExcludeTeamLeaderList = Case When Left(@ExcludeTeamLeaderList,1) <> ',' Then ',' + LTRIM(RTRIM(ISNULL(@ExcludeTeamLeaderList, ''))) + ',' Else @ExcludeTeamLeaderList End

	SELECT  @ThisCount = (	
							SELECT COUNT(*) 
							FROM   manpowerprofile (NOLOCK) 
							WHERE  mpp_terminationdt >= @DateStart AND mpp_terminationdt < @DateEnd
									AND (
											(@ExcludeDriversWithinProbationaryPeriodYN = 'N')
											OR
											(
												@ExcludeDriversWithinProbationaryPeriodYN = 'Y'
												AND
												DATEDIFF(day,mpp_hiredate, mpp_terminationdt) > @ProbationaryPeriodDays
											)
										)
									AND (@OnlyDrvClass1List =',,' or CHARINDEX(',' + RTRIM( mpp_type1 ) + ',', @OnlyDrvClass1List) >0)
									AND (@OnlyDrvClass2List =',,' or CHARINDEX(',' + RTRIM( mpp_type2 ) + ',', @OnlyDrvClass2list) >0)
									AND (@OnlyDrvClass3List =',,' or CHARINDEX(',' + RTRIM( mpp_type3 ) + ',', @OnlyDrvClass3List) >0)
									AND (@OnlyDrvClass4List =',,' or CHARINDEX(',' + RTRIM( mpp_type4 ) + ',', @OnlyDrvClass4List) >0)
									AND (@OnlyDrvTerminalList =',,' or CHARINDEX(',' + RTRIM( mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
									AND (@OnlyTeamLeaderList =',,' or CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
									AND (@OnlyDrvFleetList =',,' or CHARINDEX(',' + RTRIM( mpp_fleet ) + ',', @OnlyDrvFleetList) >0)
									AND (@OnlyDrvDivisionList =',,' or CHARINDEX(',' + RTRIM( mpp_division ) + ',', @OnlyDrvDivisionList) >0)
									AND (@OnlyDrvDomicileList =',,' or CHARINDEX(',' + RTRIM( mpp_domicile ) + ',', @OnlyDrvDomicileList) >0)
									AND (@OnlyDrvCompanyList =',,' or CHARINDEX(',' + RTRIM( mpp_company ) + ',', @OnlyDrvCompanyList) >0)
									
									AND (@ExcludeDrvTerminalList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_terminal ) + ',', @ExcludeDrvTerminalList) >0)
									AND (@ExcludeTeamLeaderList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @ExcludeTeamLeaderList) >0)
									AND (@ExcludeDrvFleetList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_fleet ) + ',', @ExcludeDrvFleetList) >0)
									AND (@ExcludeDrvDivisionList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_division ) + ',', @ExcludeDrvDivisionList) >0)
									AND (@ExcludeDrvDomicileList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_domicile ) + ',', @ExcludeDrvDomicileList) >0)
									AND (@ExcludeDrvCompanyList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_company ) + ',', @ExcludeDrvCompanyList) >0)
									AND (@OnlyDrvStatusList =',,' or CHARINDEX(',' + RTRIM( mpp_status ) + ',', @OnlyDrvStatusList) >0)
									AND (@ExcludeDrvStatusList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_status ) + ',', @ExcludeDrvStatusList) >0)
									
						),
			@ThisTotal = DATEDIFF(day, @DateStart, @DateEnd)
			
	IF @ThisTotal = 0
		SET @ThisTotal = 1

	IF @UseDriverTotal <> 'N'
		Begin
			Select @ThisTotal =  dbo.fnc_TMWRN_DriverCount(default, 'Active', @DateStart, @DateEnd, default, default, default, default, @OnlyDrvTerminalList, default, default, default, default, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT)
		End
	
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 
	
	IF (@ShowDetail = 1)
	BEGIN
		SELECT 	mpp_teamleader as TeamLeader,
				mpp_terminal as Terminal,
		       	mpp_id as DriverID,
		       	mpp_lastfirst as DriverName,
		       	mpp_terminationdt as [Termination Date],
		       	mpp_hiredate as [Hire Date]				         
		FROM   	manpowerprofile (NOLOCK) 
		WHERE  	mpp_terminationdt >= @DateStart AND mpp_terminationdt < @DateEnd
			AND (
					(@ExcludeDriversWithinProbationaryPeriodYN = 'N')
					OR
					(
						@ExcludeDriversWithinProbationaryPeriodYN = 'Y'
						AND
						DATEDIFF(day,mpp_hiredate, mpp_terminationdt) > @ProbationaryPeriodDays
					)
				)
		    AND (@OnlyDrvClass1List =',,' or CHARINDEX(',' + RTRIM( mpp_type1 ) + ',', @OnlyDrvClass1List) >0)
			AND (@OnlyDrvClass2List =',,' or CHARINDEX(',' + RTRIM( mpp_type2 ) + ',', @OnlyDrvClass2list) >0)
			AND (@OnlyDrvClass3List =',,' or CHARINDEX(',' + RTRIM( mpp_type3 ) + ',', @OnlyDrvClass3List) >0)
			AND (@OnlyDrvClass4List =',,' or CHARINDEX(',' + RTRIM( mpp_type4 ) + ',', @OnlyDrvClass4List) >0)
			AND (@OnlyDrvTerminalList =',,' or CHARINDEX(',' + RTRIM( mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
			AND (@OnlyTeamLeaderList =',,' or CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
			AND (@OnlyDrvFleetList =',,' or CHARINDEX(',' + RTRIM( mpp_fleet ) + ',', @OnlyDrvFleetList) >0)
			AND (@OnlyDrvDivisionList =',,' or CHARINDEX(',' + RTRIM( mpp_division ) + ',', @OnlyDrvDivisionList) >0)
			AND (@OnlyDrvDomicileList =',,' or CHARINDEX(',' + RTRIM( mpp_domicile ) + ',', @OnlyDrvDomicileList) >0)
			AND (@OnlyDrvCompanyList =',,' or CHARINDEX(',' + RTRIM( mpp_company ) + ',', @OnlyDrvCompanyList) >0)
			
			AND (@ExcludeDrvTerminalList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_terminal ) + ',', @ExcludeDrvTerminalList) >0)
			AND (@ExcludeTeamLeaderList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @ExcludeTeamLeaderList) >0)
			AND (@ExcludeDrvFleetList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_fleet ) + ',', @ExcludeDrvFleetList) >0)
			AND (@ExcludeDrvDivisionList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_division ) + ',', @ExcludeDrvDivisionList) >0)
			AND (@ExcludeDrvDomicileList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_domicile ) + ',', @ExcludeDrvDomicileList) >0)
			AND (@ExcludeDrvCompanyList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_company ) + ',', @ExcludeDrvCompanyList) >0)
			AND (@OnlyDrvStatusList =',,' or CHARINDEX(',' + RTRIM( mpp_status ) + ',', @OnlyDrvStatusList) >0)
			AND (@ExcludeDrvStatusList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_status ) + ',', @ExcludeDrvStatusList) >0)
									
	END
	
GO
GRANT EXECUTE ON  [dbo].[Metric_DriverTermination] TO [public]
GO
