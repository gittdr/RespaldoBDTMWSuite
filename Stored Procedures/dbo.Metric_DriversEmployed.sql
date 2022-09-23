SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_DriversEmployed] 
(
	--Standard Parameters
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,
	@MetricCode VARCHAR(255)='DriverHire',
	
	--Additional/Optional Parameters
	@OnlyDrvClass1List varchar(128) ='',
	@OnlyDrvClass2List varchar(128) ='',
	@OnlyDrvClass3List varchar(128) ='',
	@OnlyDrvClass4List varchar(128) ='',
	@OnlyDrvTerminalList varchar(255)='',
	@OnlyDrvTeamleaderList varchar(128) ='',
	@OnlyDrvFleetList varchar(128)='',
	@OnlyDrvDivisionList varchar(128)='',
	@OnlyDrvDomicileList varchar(128)='',
	@OnlyDrvCompanyList varchar(128)='',
	@OnlyDrvStatusList varchar(128)='',
	@Mode varchar(30) = 'Active' -- Expiration
	
)
AS

	--Standard Metric Initialization
	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item.
	<METRIC-INSERT-SQL>
metricrun 'DriversEmployed',@showdetail=1
	EXEC MetricInitializeItem
		@sMetricCode = 'DriversEmployed',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 105, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 1,
		@sCaption = 'Drivers Employed',
		@sCaptionFull = 'Drivers Employed',
		@sProcedureName = 'Metric_DriversEmployed',
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
	Set @OnlyDrvTeamleaderList = ',' + ISNULL(@OnlyDrvTeamleaderList,'') + ','
	Set @OnlyDrvFleetList = ',' + ISNULL(@OnlyDrvFleetList,'') + ','
	Set @OnlyDrvDivisionList = ',' + ISNULL(@OnlyDrvDivisionList,'') + ','
	Set @OnlyDrvDomicileList = ',' + ISNULL(@OnlyDrvDomicileList,'') + ','
	Set @OnlyDrvCompanyList = ',' + ISNULL(@OnlyDrvCompanyList,'') + ','
	Set @OnlyDrvTerminalList = ',' + ISNULL(@OnlyDrvTerminalList,'') + ','
	Set @OnlyDrvStatusList = ',' + ISNULL(@OnlyDrvStatusList,'') + ','
	
	
	SELECT  @ThisCount =  dbo.fnc_TMWRN_DriverCount(DEFAULT, @Mode, @DateStart, @DateEnd, @OnlyDrvFleetList, @OnlyDrvDivisionList, @OnlyDrvDomicileList, @OnlyDrvCompanyList, @OnlyDrvTerminalList, @OnlyDrvStatusList, default, default, default, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, default,default,default,default,DEFAULT, DEFAULT, DEFAULT, DEFAULT)

	SELECT	@ThisTotal = CASE WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) 
									THEN 1 ELSE DATEDIFF(day, @DateStart, @DateEnd) END
			
	--Standard Result Calculation
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 
	
	--Show Detail
	IF (@ShowDetail = 1)
	BEGIN
		SELECT mpp_terminal as Terminal,
		       mpp_id as DriverID,
		       mpp_lastfirst as DriverName,
		       mpp_terminationdt as [Termination Date],
		       mpp_hiredate as [Hire Date]
		FROM   manpowerprofile (NOLOCK) 
		WHERE   dbo.fnc_TMWRN_DriverCount(DEFAULT, @Mode, @DateStart, @DateEnd, @OnlyDrvFleetList, @OnlyDrvDivisionList, @OnlyDrvDomicileList, @OnlyDrvCompanyList, @OnlyDrvTerminalList, @OnlyDrvStatusList, default, default, default, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, default,default,default,default,DEFAULT, DEFAULT, DEFAULT, mpp_id) >= 1
	END
	
GO
GRANT EXECUTE ON  [dbo].[Metric_DriversEmployed] TO [public]
GO
