SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_AccidentsPerDay] (
	--Standard Metric Parameters
	@Result decimal(20, 5) OUTPUT, 		--Value of metric for the time frame passed
	@ThisCount decimal(20, 5) OUTPUT, 	--Numerator of the daily metric calculation
	@ThisTotal decimal(20, 5) OUTPUT, 	--Denominator of the daily metric calculation
	@DateStart datetime, 			--Start Date of metric calculation time frame
	@DateEnd datetime, 			--End Date of metric calculation time frame
	@UseMetricParms int, 			--Use Metric Parms Flag
	@ShowDetail int,				--Show Detail Flag

	--Additional/Optional Parameters
	@OnlyMppClass1List varchar(128) = '',
	@OnlyMppClass2List varchar(128) = '',
	@OnlyMppClass3List varchar(128) = '',
	@OnlyMppClass4List varchar(128) = '',
	@OnlyDrvCompany varchar(128)='',
	@OnlyDrvTerminal varchar(128)='',
	@OnlyDrvFleet varchar(128)='',
	@OnlyDrvDivision varchar(128)='',
	@Mode varchar(50) = 'PERDAY',            -- or 'PERMML' million miles
	@DebugMode varchar(50) = 0,
	@OnlyPreventableList varchar(128)=''
	)
	--

AS

--Metric Initialization
	--For use to automatically generate new metic item
		/* NOTE: This SQL is used by MetricProcessing to automatically generate 
			 an new metric item in a category called NewItems.

		<METRIC-INSERT-SQL>
	
		EXEC MetricInitializeItem
			@sMetricCode = 'AccidentsperMillionMiles',
			@nActive = 1,	-- 1=active, 0=inactive.
			@nSort = 100, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = '',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDecimal = 2,
			@nPlusDeltaIsGood = 0,
			@nCumulative = 0,
			@sCaption = 'Accidents per million miles',
			@sCaptionFull = 'Accidents per million miles',
			@sProcedureName = 'Metric_AccidentsPerDay',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = 'ProcessOnly'
			
		EXEC MetricInitializeItem
			@sMetricCode = 'AccidentsPerMillionMiles',
			@nActive = 1,	-- 1=active, 0=inactive.
			@nSort = 100, 	-- Used to determine the sort order that updates should be run.
			@sFormatText = '',	-- Typically 'PCT' or blank ('').
			@nNumDigitsAfterDecimal = 2,
			@nPlusDeltaIsGood = 0,
			@nCumulative = 0,
			@sCaption = 'Accidents Per Million Miles',
			@sCaptionFull = 'Accidents Per Million Miles',
			@sProcedureName = 'Metric_AccidentsPerDay',
			@sCachedDetailYN = '',
			@nCacheRefreshAgeMaxMinutes = 0,
			@sShowDetailByDefaultYN = 'N', -- Typically 'N'
			@sRefreshHistoryYN = '',	-- Typically 'N'
			@sCategory = '@@NoCategory'
	
		</METRIC-INSERT-SQL>
	
	*/
	--
--

	SET NOCOUNT ON

	SET @OnlyMppClass1List = ',' + ISNULL(@OnlyMppClass1List, '') + ','
	SET @OnlyMppClass2List = ',' + ISNULL(@OnlyMppClass2List, '') + ','
	SET @OnlyMppClass3List = ',' + ISNULL(@OnlyMppClass3List, '') + ','
	SET @OnlyMppClass4List = ',' + ISNULL(@OnlyMppClass4List, '') + ','
	SET @OnlyDrvCompany = ',' + ISNULL(@OnlyDrvCompany, '') + ','
	SET @OnlyDrvTerminal = ',' + ISNULL(@OnlyDrvTerminal, '') + ','
	SET @OnlyDrvFleet = ',' + ISNULL(@OnlyDrvFleet, '') + ','
	SET @OnlyDrvDivision = ',' + ISNULL(@OnlyDrvDivision, '') + ','
	SET @OnlyPreventableList = ',' + ISNULL(@OnlyPreventableList, '') + ','

	
	DECLARE @TotalMiles decimal(20,5)
	DECLARE @Impact decimal(20,2)

--Metric Calculation
	--Set Numerator (ThisCount) Equal to the count of all driver accidents
	--Based on Accident Date
	--Set the Denominator = 1 where @Mode = PerDay
	--Set the Denominator = Total Miles where @Mode = PerMML
-- 
	SELECT  @ThisCount = 	(SELECT COUNT(*) 
			      			FROM driveraccident (NOLOCK), manpowerprofile (NOLOCK)
			      			WHERE dra_accidentdate >= @DateStart AND dra_accidentdate < @DateEnd
								AND driveraccident.mpp_id = manpowerprofile.mpp_id
								AND (@OnlyMppClass1List= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_type1 ) + ',', @OnlyMppClass1List) >0)
								AND (@OnlyMppClass2List= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_type2 ) + ',', @OnlyMppClass2List) >0)
								AND (@OnlyMppClass3List= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_type3 ) + ',', @OnlyMppClass3List) >0)
								AND (@OnlyMppClass4List= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_type4 ) + ',', @OnlyMppClass4List) >0)
								AND (@OnlyDrvCompany= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_company ) + ',', @OnlyDrvCompany) >0)
								AND (@OnlyDrvTerminal= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_terminal ) + ',', @OnlyDrvTerminal) >0)
								AND (@OnlyDrvFleet= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_fleet ) + ',', @OnlyDrvFleet) >0)
								AND (@OnlyDrvDivision= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_division ) + ',', @OnlyDrvDivision) >0)
								AND (@OnlyPreventableList= ',,'  or CHARINDEX(',' + RTRIM( dra_preventable ) + ',', @OnlyPreventableList) >0)
								
								
								
			      			)

	IF @Mode = 'PERDAY'
		SELECT	@ThisTotal = CASE WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) 
									THEN 1 ELSE DATEDIFF(day, @DateStart, @DateEnd) END
	ELSE
	BEGIN
	  	Set @TotalMiles = (
							SELECT SUM(IsNull(dbo.fnc_TMWRN_Miles('Segment','Travel','Miles',l.mov_number,default,l.lgh_number,default,default,default,default,default),0)) as TotalMiles
							FROM Legheader L (NOLOCK),
								manpowerprofile m (NOLOCK)
							WHERE l.lgh_driver1= m.mpp_id
								AND lgh_enddate >= @DateStart AND lgh_enddate < @DateEnd
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
--


--Show Detail
	--MPP_id, Accident Date, File Number, Points, Description, Preventable, Code, Truck Number
	--Trailer Number, Cost, Location, City NMSTCT, Dispatcher, Reserve, Status
	--based on Accident Date
	IF (@ShowDetail = 1) 
	BEGIN
		IF @Mode = 'PERDAY'
		BEGIN
			SELECT driveraccident.mpp_id, dra_accidentdate, dra_filenumber, dra_points, 
				dra_description, dra_preventable, dra_code, trc_number, 
				trl_number, dra_cost, dra_location, cty_nmstct, dra_dispatcher,
				dra_reserve, dra_status
			FROM driveraccident (NOLOCK), manpowerprofile (NOLOCK)
			WHERE dra_accidentdate >= @DateStart AND dra_accidentdate < @DateEnd
				AND driveraccident.mpp_id = manpowerprofile.mpp_id
				AND (@OnlyMppClass1List= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_type1 ) + ',', @OnlyMppClass1List) >0)
				AND (@OnlyMppClass2List= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_type2 ) + ',', @OnlyMppClass2List) >0)
				AND (@OnlyMppClass3List= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_type3 ) + ',', @OnlyMppClass3List) >0)
				AND (@OnlyMppClass4List= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_type4 ) + ',', @OnlyMppClass4List) >0)
				AND (@OnlyDrvCompany= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_company ) + ',', @OnlyDrvCompany) >0)
				AND (@OnlyDrvTerminal= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_terminal ) + ',', @OnlyDrvTerminal) >0)
				AND (@OnlyDrvFleet= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_fleet ) + ',', @OnlyDrvFleet) >0)
				AND (@OnlyDrvDivision= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_division ) + ',', @OnlyDrvDivision) >0)
				AND (@OnlyPreventableList= ',,'  or CHARINDEX(',' + RTRIM( dra_preventable ) + ',', @OnlyPreventableList) >0)

		END
		ELSE
		BEGIN
			
			SELECT @TotalMiles as [Company Miles Driven], @Impact as [Statistical Impact of one accident],
				driveraccident.mpp_id, dra_accidentdate, dra_filenumber, dra_points, 
				dra_description, dra_preventable, dra_code, trc_number, 
				trl_number, dra_cost, dra_location, cty_nmstct, dra_dispatcher,
				dra_reserve, dra_status
			FROM driveraccident (NOLOCK), manpowerprofile (NOLOCK)
			WHERE dra_accidentdate >= @DateStart AND dra_accidentdate < @DateEnd
				AND driveraccident.mpp_id = manpowerprofile.mpp_id
				AND (@OnlyMppClass1List= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_type1 ) + ',', @OnlyMppClass1List) >0)
				AND (@OnlyMppClass2List= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_type2 ) + ',', @OnlyMppClass2List) >0)
				AND (@OnlyMppClass3List= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_type3 ) + ',', @OnlyMppClass3List) >0)
				AND (@OnlyMppClass4List= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_type4 ) + ',', @OnlyMppClass4List) >0)
				AND (@OnlyDrvCompany= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_company ) + ',', @OnlyDrvCompany) >0)
				AND (@OnlyDrvTerminal= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_terminal ) + ',', @OnlyDrvTerminal) >0)
				AND (@OnlyDrvFleet= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_fleet ) + ',', @OnlyDrvFleet) >0)
				AND (@OnlyDrvDivision= ',,'  or CHARINDEX(',' + RTRIM( manpowerprofile.mpp_division ) + ',', @OnlyDrvDivision) >0)
				AND (@OnlyPreventableList= ',,'  or CHARINDEX(',' + RTRIM( dra_preventable ) + ',', @OnlyPreventableList) >0)
		END
	END

--step note="Log Metric Result"

--/step

GO
GRANT EXECUTE ON  [dbo].[Metric_AccidentsPerDay] TO [public]
GO
