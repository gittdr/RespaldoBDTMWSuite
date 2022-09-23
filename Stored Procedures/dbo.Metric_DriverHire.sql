SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_DriverHire] 
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
	@ExcludeDrvTerminalList varchar(255)='',
	@OnlyDrvTeamleaderList varchar(128) ='',
	@OnlyDrvFleetList varchar(128)='',
	@OnlyDrvDivisionList varchar(128)='',
	@OnlyDrvDomicileList varchar(128)='',
	@OnlyDrvCompanyList varchar(128)='',
	@OnlyDrvStatusList varchar(128)='',
	@ExcludeDrvStatusList varchar(128)=''
)
AS

	--Standard Metric Initialization
	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'DriverHire',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 105, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 1,
		@sCaption = 'Order booked',
		@sCaptionFull = 'Orders booked (cumulative)',
		@sProcedureName = 'Metric_DriverHire',
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
	Set @ExcludeDrvTerminalList = ',' + ISNULL(@ExcludeDrvTerminalList,'') + ','
	Set @OnlyDrvStatusList = ',' + ISNULL(@OnlyDrvStatusList,'') + ','
	Set @ExcludeDrvStatusList = ',' + ISNULL(@ExcludeDrvStatusList,'') + ','
	
	SELECT  @ThisCount =	(
								SELECT Count(*)		      
								FROM   manpowerprofile (NOLOCK) 
								WHERE  mpp_hiredate >= @DateStart AND mpp_hiredate < @DateEnd
									AND (@OnlyDrvClass1List =',,' or CHARINDEX(',' + RTRIM( mpp_type1 ) + ',', @OnlyDrvClass1List) >0)
									AND (@OnlyDrvClass2List =',,' or CHARINDEX(',' + RTRIM( mpp_type2 ) + ',', @OnlyDrvClass2list) >0)
									AND (@OnlyDrvClass3List =',,' or CHARINDEX(',' + RTRIM( mpp_type3 ) + ',', @OnlyDrvClass3List) >0)
									AND (@OnlyDrvClass4List =',,' or CHARINDEX(',' + RTRIM( mpp_type4 ) + ',', @OnlyDrvClass4List) >0)
									AND (@OnlyDrvTerminalList =',,' or CHARINDEX(',' + RTRIM( mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
									AND (@ExcludeDrvTerminalList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_terminal ) + ',', @ExcludeDrvTerminalList) >0)
									AND (@OnlyDrvTeamleaderList =',,' or CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @OnlyDrvTeamleaderList) >0)
									AND (@OnlyDrvFleetList =',,' or CHARINDEX(',' + RTRIM( mpp_fleet ) + ',', @OnlyDrvFleetList) >0)
									AND (@OnlyDrvDivisionList =',,' or CHARINDEX(',' + RTRIM( mpp_division ) + ',', @OnlyDrvDivisionList) >0)
									AND (@OnlyDrvDomicileList =',,' or CHARINDEX(',' + RTRIM( mpp_domicile ) + ',', @OnlyDrvDomicileList) >0)
									AND (@OnlyDrvCompanyList =',,' or CHARINDEX(',' + RTRIM( mpp_company ) + ',', @OnlyDrvCompanyList) >0)
									AND (@OnlyDrvStatusList =',,' or CHARINDEX(',' + RTRIM( mpp_status ) + ',', @OnlyDrvStatusList) >0)
									AND (@ExcludeDrvStatusList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_status ) + ',', @ExcludeDrvStatusList) =0)
							),
			@ThisTotal = CASE WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) 
									THEN 1 ELSE DATEDIFF(day, @DateStart, @DateEnd) END
			
	--Standard Result Calculation
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END 
	
	--Show Detail
	IF (@ShowDetail = 1)
	BEGIN
		SELECT mpp_terminal as Terminal,
		       mpp_id as DriverID,
		       mpp_lastfirst as Nombre,
		       mpp_terminationdt as [Fecha Terminacion],
		       mpp_hiredate as [Fecha Contratacion]				           
		FROM   manpowerprofile (NOLOCK) 
		WHERE  mpp_hiredate >= @DateStart AND mpp_hiredate < @DateEnd
		    AND (@OnlyDrvClass1List =',,' or CHARINDEX(',' + RTRIM( mpp_type1 ) + ',', @OnlyDrvClass1List) >0)
		    AND (@OnlyDrvClass2List =',,' or CHARINDEX(',' + RTRIM( mpp_type2 ) + ',', @OnlyDrvClass2list) >0)
		    AND (@OnlyDrvClass3List =',,' or CHARINDEX(',' + RTRIM( mpp_type3 ) + ',', @OnlyDrvClass3List) >0)
		    AND (@OnlyDrvClass4List =',,' or CHARINDEX(',' + RTRIM( mpp_type4 ) + ',', @OnlyDrvClass4List) >0)
		    AND (@OnlyDrvTerminalList =',,' or CHARINDEX(',' + RTRIM( mpp_terminal ) + ',', @OnlyDrvTerminalList) >0)
			AND (@ExcludeDrvTerminalList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_terminal ) + ',', @ExcludeDrvTerminalList) >0)
		    AND (@OnlyDrvTeamleaderList =',,' or CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @OnlyDrvTeamleaderList) >0)
			AND (@OnlyDrvFleetList =',,' or CHARINDEX(',' + RTRIM( mpp_fleet ) + ',', @OnlyDrvFleetList) >0)
			AND (@OnlyDrvDivisionList =',,' or CHARINDEX(',' + RTRIM( mpp_division ) + ',', @OnlyDrvDivisionList) >0)
			AND (@OnlyDrvDomicileList =',,' or CHARINDEX(',' + RTRIM( mpp_domicile ) + ',', @OnlyDrvDomicileList) >0)
			AND (@OnlyDrvCompanyList =',,' or CHARINDEX(',' + RTRIM( mpp_company ) + ',', @OnlyDrvCompanyList) >0)
			AND (@OnlyDrvStatusList =',,' or CHARINDEX(',' + RTRIM( mpp_status ) + ',', @OnlyDrvStatusList) >0)
			AND (@ExcludeDrvStatusList =',,' or NOT CHARINDEX(',' + RTRIM( mpp_status ) + ',', @ExcludeDrvStatusList) =0)

	END
	
GO
GRANT EXECUTE ON  [dbo].[Metric_DriverHire] TO [public]
GO
