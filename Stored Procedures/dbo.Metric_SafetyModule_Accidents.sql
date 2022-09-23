SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_SafetyModule_Accidents] 
(
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,
	@MetricCode varchar(255)= 'SafetyModuleAccidents',
	@Terminal varchar(255) = '',
	@OnlyDrvType1List varchar(255)='',
	@OnlyDrvType2List varchar(255)='',
	@OnlyDrvType3List varchar(255)='',
	@OnlyDrvType4List varchar(255)='',
	@OnlyDrvTeamleaderList varchar(255)='',
	@OnlyDrvFleetList varchar(255)='',
	@OnlyDrvDivision varchar(255)='',
	@OnlyDrvDomicile varchar(255)='',
	@OnlyDrvTerminal varchar(255)=''
)
AS

	SET NOCOUNT ON  -- PTS46367

SELECT @Terminal = ',' + LTRIM(RTRIM(ISNULL(@Terminal, ''))) + ','
SELECT @OnlyDrvType1List = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvType1List, ''))) + ','
SELECT @OnlyDrvType2List = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvType2List, ''))) + ','
SELECT @OnlyDrvType3List = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvType3List, ''))) + ','
SELECT @OnlyDrvType4List = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvType4List, ''))) + ','
SELECT @OnlyDrvTeamleaderList = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvTeamleaderList, ''))) + ','
SELECT @OnlyDrvFleetList = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvFleetList, ''))) + ','
SELECT @OnlyDrvDivision = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvDivision, ''))) + ','
SELECT @OnlyDrvDomicile = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvDomicile, ''))) + ','
SELECT @OnlyDrvTerminal = ',' + LTRIM(RTRIM(ISNULL(@OnlyDrvTerminal, ''))) + ','


/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'SafetyModuleAccidents',
		@nActive = 1,	-- 1=active, 0=inactive.
		@nSort = 106, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'CURR',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = 'Revenue / Truck',
		@sCaptionFull = 'Revenue productivity per truck dispatched',
		@sProcedureName = 'Metric_SafetyModuleAccidents',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = 'Dispatch'

	</METRIC-INSERT-SQL>
*/

/*	To test this:
	DECLARE	@Result decimal(20, 5), @ThisCount decimal(20, 5), @ThisTotal decimal(20, 5), @DateStart datetime, @DateEnd datetime, @UseMetricParms int, @ShowDetail int
	EXEC Metric_RevPerTrc @Result OUTPUT, @ThisCount OUTPUT, @ThisTotal OUTPUT, '3/3/2002', '3/4/2002', 1, 1
*/
 
	Select  acd_Driver1 as [Driver1 ID] ,
			mpp_lastfirst as [Driver Name],
			srp_EventDate as [Event Date],
			acd_tractor as [Tractor],
			safetyreport.srp_terminal as [Terminal],
			acd_AccidentType1 as [Accident Type1],
			cast(srp_description as char(255)) as [Description],
			acd_DOTRecordable as [DOT Recordable],
			acd_AccdntPreventability as [Accident Preventable]
 	into    #TempAccidents
	From    Accident (NOLOCK),SafetyReport (NOLOCK), manpowerprofile (NOLOCK)
	Where   srp_eventdate >= @DateStart and srp_eventdate < @DateEnd
		And Accident.srp_id = SafetyReport.srp_id
		AND acd_driver1 = mpp_id
		And (@OnlyDrvType1List = ',,' OR CHARINDEX(',' + RTRIM( mpp_type1 ) + ',', @OnlyDrvType1List) > 0)
		And (@OnlyDrvType2List = ',,' OR CHARINDEX(',' + RTRIM( mpp_type2 ) + ',', @OnlyDrvType2List) > 0)
		And (@OnlyDrvType3List = ',,' OR CHARINDEX(',' + RTRIM( mpp_type3 ) + ',', @OnlyDrvType3List) > 0)
		And (@OnlyDrvType4List = ',,' OR CHARINDEX(',' + RTRIM( mpp_type4 ) + ',', @OnlyDrvType4List) > 0)
		And (@OnlyDrvTeamleaderList = ',,' OR CHARINDEX(',' + RTRIM( mpp_teamleader ) + ',', @OnlyDrvTeamleaderList) > 0)
		And (@OnlyDrvFleetList = ',,' OR CHARINDEX(',' + RTRIM( mpp_fleet ) + ',', @OnlyDrvFleetList) > 0)
		And (@OnlyDrvDivision = ',,' OR CHARINDEX(',' + RTRIM( mpp_division ) + ',', @OnlyDrvDivision) > 0)
		And (@OnlyDrvDomicile = ',,' OR CHARINDEX(',' + RTRIM( mpp_domicile ) + ',', @OnlyDrvDomicile) > 0)
		And (@OnlyDrvTerminal = ',,' OR CHARINDEX(',' + RTRIM( mpp_terminal ) + ',', @OnlyDrvTerminal) > 0)

	Select @ThisCount = Count(*)
	From   #TempAccidents
	
	SELECT @ThisTotal = CASE WHEN DATEDIFF(day, @DateStart, @DateEnd) = 0 THEN 1 ELSE DATEDIFF(day, @DateStart, @DateEnd) END
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END
 
	IF (@ShowDetail=1)
	BEGIN
		Select *
		From   #TempAccidents 							
	End
	
GO
GRANT EXECUTE ON  [dbo].[Metric_SafetyModule_Accidents] TO [public]
GO
