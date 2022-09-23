SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[Metric_SafetyModule_AccidentsPerMode] 
(
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,
	@MetricCode varchar(255)= 'SafetyModuleAccidentsPerMode',
	@Mode varchar(50) = 'PERDAY',            -- or 'PERMML' million miles
	@OnlyMppClass1List varchar(128) = '',
	@OnlyMppClass2List varchar(128) = '',
	@OnlyMppClass3List varchar(128) = '',
	@OnlyMppClass4List varchar(128) = '',
	@OnlyDrvCompany varchar(128)='',
	@OnlyDrvTerminal varchar(128)='',
	@OnlyDrvFleet varchar(128)='',
	@OnlyDrvDivision varchar(128)=''
)

AS
	SET NOCOUNT ON  -- PTS46367



/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'SafetyModuleAccidentsPerMode',
		@nActive = 1,	-- 1=active, 0=inactive.
		@nSort = 106, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = 'Accidents Per Day',
		@sCaptionFull = 'Accidents Per Day',
		@sProcedureName = 'Metric_SafetyModule_AccidentsPerMode',
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

	SET @OnlyMppClass1List = ',' + ISNULL(@OnlyMppClass1List, '') + ','
	SET @OnlyMppClass2List = ',' + ISNULL(@OnlyMppClass2List, '') + ','
	SET @OnlyMppClass3List = ',' + ISNULL(@OnlyMppClass3List, '') + ','
	SET @OnlyMppClass4List = ',' + ISNULL(@OnlyMppClass4List, '') + ','
	SET @OnlyDrvCompany = ',' + ISNULL(@OnlyDrvCompany, '') + ','
	SET @OnlyDrvTerminal = ',' + ISNULL(@OnlyDrvTerminal, '') + ','
	SET @OnlyDrvFleet = ',' + ISNULL(@OnlyDrvFleet, '') + ','
	SET @OnlyDrvDivision = ',' + ISNULL(@OnlyDrvDivision, '') + ','

	DECLARE @TotalMiles decimal(20,5)
	DECLARE @Impact decimal(20,2)

 
	Select  acd_Driver1 as [Driver1 ID] ,
			srp_EventDate as [Event Date],
			acd_tractor as [Tractor],
			safetyreport.srp_terminal as [Terminal],
			acd_AccidentType1 as [Accident Type1],
			CONVERT(varchar(4000), acd_description) as [Accident Description]
 	into    #TempAccidents
	From    Accident (NOLOCK) join SafetyReport (NOLOCK) on Accident.srp_id = SafetyReport.srp_id
			join ManpowerProfile (NOLOCK) on Accident.acd_driver1 = ManpowerProfile.mpp_id
	Where   srp_eventdate >= @DateStart and srp_eventdate < @DateEnd
			AND (@OnlyMppClass1List= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_type1 ) + ',', @OnlyMppClass1List) >0)
			AND (@OnlyMppClass2List= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_type2 ) + ',', @OnlyMppClass2List) >0)
			AND (@OnlyMppClass3List= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_type3 ) + ',', @OnlyMppClass3List) >0)
			AND (@OnlyMppClass4List= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_type4 ) + ',', @OnlyMppClass4List) >0)
			AND (@OnlyDrvCompany= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_company ) + ',', @OnlyDrvCompany) >0)
			AND (@OnlyDrvTerminal= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_terminal ) + ',', @OnlyDrvTerminal) >0)
			AND (@OnlyDrvFleet= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_fleet ) + ',', @OnlyDrvFleet) >0)
			AND (@OnlyDrvDivision= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_division ) + ',', @OnlyDrvDivision) >0)

-- get accident count
	Select @ThisCount = Count(*)
	From   #TempAccidents

	IF @Mode = 'PERDAY'
		SELECT	@ThisTotal = CASE WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) 
									THEN 1 ELSE DATEDIFF(day, @DateStart, @DateEnd) END
	ELSE
		BEGIN
	  		Set @TotalMiles = (
								SELECT SUM(IsNull(dbo.fnc_TMWRN_Miles('Segment','Travel','Miles',l.mov_number,default,l.lgh_number,default,default,default,default,default),0)) as TotalMiles
								FROM Legheader L (NOLOCK) join manpowerprofile m (NOLOCK) on l.lgh_driver1= m.mpp_id
								WHERE lgh_enddate >= @DateStart AND lgh_enddate < @DateEnd
									AND lgh_outstatus = 'CMP'
									AND (@OnlyMppClass1List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type1 ) + ',', @OnlyMppClass1List) >0)
									AND (@OnlyMppClass2List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type2 ) + ',', @OnlyMppClass2List) >0)
									AND (@OnlyMppClass3List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type3 ) + ',', @OnlyMppClass3List) >0)
									AND (@OnlyMppClass4List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type4 ) + ',', @OnlyMppClass4List) >0)
									AND (@OnlyDrvCompany= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_company ) + ',', @OnlyDrvCompany) >0)
									AND (@OnlyDrvTerminal= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_terminal ) + ',', @OnlyDrvTerminal) >0)
									AND (@OnlyDrvFleet= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_fleet ) + ',', @OnlyDrvFleet) >0)
									AND (@OnlyDrvDivision= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_division ) + ',', @OnlyDrvDivision) >0)
								)

			Set @ThisTotal =  @TotalMiles / 1000000
			If @TotalMiles = 0 
				Set @TotalMiles =  1
			SET @Impact = 1000000 / @TotalMiles
		END

--Standard Metric Result Calculation
	
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END
 
	IF (@ShowDetail=1)
	Begin
		IF @Mode = 'PERDAY'
			BEGIN
				Select *
				From   #TempAccidents 							
			END
		Else
			BEGIN
				Select @TotalMiles as [Company Miles Driven], @Impact as [Statistical Impact of one accident],*
				From   #TempAccidents 							
			END
	End
	
GO
GRANT EXECUTE ON  [dbo].[Metric_SafetyModule_AccidentsPerMode] TO [public]
GO
