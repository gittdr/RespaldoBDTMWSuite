SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Metric_OffNetworkFuel2]

	(
		--Standard Metric Parameters	
		@Result decimal(20, 5) OUTPUT, --Value of the metric for the time frame passed
		@ThisCount decimal(20, 5) OUTPUT, --Numerator of the daily metric calculation
		@ThisTotal decimal(20, 5) OUTPUT, --Denominator of the daily metric calculation
		@DateStart datetime, --Start Date of metric calculation time frame
		@DateEnd datetime, --End Date of metric calculation time frame
		@UseMetricParms int, --Use Metric Parms Flag
		@ShowDetail int, --Show Detail Flag
	
		--Additional/Optional Parameters
		@OnlyRevClass1List varchar(128) ='',
		@OnlyRevClass2List varchar(128) ='',
		@OnlyRevClass3List varchar(128) ='',
		@OnlyRevClass4List varchar(128) ='',
		@OnlyTeamLeaderList varchar(128) = '', -- Include only listed Team Leaders
		@OnlyMppClass1List varchar(128) = '',
		@OnlyMppClass2List varchar(128) = '',
		@OnlyMppClass3List varchar(128) = '',
		@OnlyMppClass4List varchar(128) = '',
		@OnlyTrcClass1List varchar(128) = '',
		@OnlyTrcClass2List varchar(128) = '',
		@OnlyTrcClass3List varchar(128) = '',
		@OnlyTrcClass4List varchar(128) = '',
		@ReturnAsPercentageYN char(1) = 'N',
		@OnlyCustomerList varchar(128) = '',
		@Mode varchar(50) = 'Count', -- OR Count, Gallons, Dollars, Price
		@Type varchar(128) = '', -- F=Focus, S=Select --OnNetwork Type List
		@OffNetworkDeterminedByTypeYN varchar(1)='N',
		@OffNetworkDeterminedByRebateAmountYN varchar(1)='N'
	)
AS

/*  Revision History
6/16/2008:	modified by adding new @Mode option (Price) and calculation code to support it

*/

	SET NOCOUNT ON
	
	-- Returns any of the following:
	-- Total/% Fuels
	-- Total/% Gallons 
	-- Total/% Dollars 
	
	
	--Metric Initialization
		/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
			<METRIC-INSERT-SQL>
	
			EXEC MetricInitializeItem
				@sMetricCode = 'OffNetworkFuel2',
				@nActive = 1,	-- 1=active, 0=inactive.
				@nSort = 705, 	-- Used to determine the sort order that updates should be run.
				@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
				@nNumDigitsAfterDecimal = 0,
				@nPlusDeltaIsGood = 0,
				@nCumulative = 0,
				@sCaption = 'Off Network Fuel',
				@sCaptionFull = 'Percent of total fuel Off Network',
				@sProcedureName = 'Metric_OffNetworkFuel2',
				@sCachedDetailYN = '',
				@nCacheRefreshAgeMaxMinutes = 0,
				@sShowDetailByDefaultYN = 'N', -- Typically 'N'
				@sRefreshHistoryYN = '',	-- Typically 'N'
				@sCategory = '@@NOCATEGORY'

			</METRIC-INSERT-SQL>
	
		*/

	--Standard Parameter Initialization
	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','

	SET @OnlyMppClass1List = ',' + ISNULL(@OnlyMppClass1List, '') + ','
	SET @OnlyMppClass2List = ',' + ISNULL(@OnlyMppClass2List, '') + ','
	SET @OnlyMppClass3List = ',' + ISNULL(@OnlyMppClass3List, '') + ','
	SET @OnlyMppClass4List = ',' + ISNULL(@OnlyMppClass4List, '') + ','
	SET @OnlyTeamLeaderList = ',' + ISNULL(@OnlyTeamLeaderList, '') + ','

	SET @OnlyTrcClass1List = ',' + ISNULL(@OnlyTrcClass1List, '') + ','
	SET @OnlyTrcClass2List = ',' + ISNULL(@OnlyTrcClass2List, '') + ','
	SET @OnlyTrcClass3List = ',' + ISNULL(@OnlyTrcClass3List, '') + ','
	SET @OnlyTrcClass4List = ',' + ISNULL(@OnlyTrcClass4List, '') + ','
	
	SET @OnlyCustomerList = ',' + ISNULL(@OnlyCustomerList, '') + ','
	SET @Type = ',' + ISNULL(@Type, '') + ','

	--Standard Declaration of Local Metric Variables
	DECLARE @Count AS INT
	DECLARE @CountTotal AS INT
	DECLARE @Gallons AS FLOAT
	DECLARE @GallonsTotal AS FLOAT
	DECLARE @Dollars AS MONEY
	DECLARE @DollarsTotal AS MONEY

	--Create Temp Table
	SELECT 	@Count = Count(vTTSTMW_FuelBill.[Tractor Gallons]),
			@Gallons = Sum(Isnull(vTTSTMW_FuelBill.[Tractor Gallons],0)), 
			@Dollars = Sum(Isnull(vTTSTMW_FuelBill.[Total Due],0))
	FROM vTTSTMW_FuelBill (nolock) join manpowerprofile m (nolock) on vTTSTMW_FuelBill.[Employee Number] = m.mpp_id
		left join orderheader o (NOLOCK) on vTTSTMW_FuelBill.[Trip Number] = o.mov_number
	WHERE vTTSTMW_FuelBill.[Transaction Date] >= @DateStart AND vTTSTMW_FuelBill.[Transaction Date] < @DateEnd
		AND (
				(@OffNetworkDeterminedByRebateAmountYN = 'Y' AND [Rebate Amount] = 0)
				OR
				@OffNetworkDeterminedByRebateAmountYN = 'N'
			)
		AND (	
				(@OffNetworkDeterminedByTypeYN = 'Y' AND (@Type =',,' or CHARINDEX(',' + RTRIM( vTTSTMW_FuelBill.[Focus or Select] ) + ',', @Type) >0))
				OR
				@OffNetworkDeterminedByTypeYN ='N'
			)
		AND (@OnlyCustomerList =',,' or CHARINDEX(',' + RTRIM( vTTSTMW_FuelBill.[Customer ID] ) + ',', @OnlyCustomerList) >0)
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( o.ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( o.ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( o.ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( o.ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
		AND (@OnlyMppClass1List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type1 ) + ',', @OnlyMppClass1List) >0)
		AND (@OnlyMppClass2List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type2 ) + ',', @OnlyMppClass2List) >0)
		AND (@OnlyMppClass3List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type3 ) + ',', @OnlyMppClass3List) >0)
		AND (@OnlyMppClass4List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type4 ) + ',', @OnlyMppClass4List) >0)
		AND (@OnlyTeamLeaderList= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
		AND (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trctype1 ) + ',', @OnlyTrcClass1List) >0)
		AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trctype2 ) + ',', @OnlyTrcClass2list) >0)
		AND (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trctype3 ) + ',', @OnlyTrcClass3List) >0)
		AND (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trctype4 ) + ',', @OnlyTrcClass4List) >0)	
	

	SELECT 	@CountTotal = Count(vTTSTMW_FuelBill.[Tractor Gallons]),
			@GallonsTotal = Sum(Isnull(vTTSTMW_FuelBill.[Tractor Gallons],0)), 
			@DollarsTotal = Sum(Isnull(vTTSTMW_FuelBill.[Total Due],0))
	FROM vTTSTMW_FuelBill (nolock) join manpowerprofile m (nolock) on vTTSTMW_FuelBill.[Employee Number] = m.mpp_id
		left join orderheader o (NOLOCK) on vTTSTMW_FuelBill.[Trip Number] = o.mov_number
	WHERE vTTSTMW_FuelBill.[Transaction Date] >= @DateStart AND vTTSTMW_FuelBill.[Transaction Date] < @DateEnd
		AND (@OnlyCustomerList =',,' or CHARINDEX(',' + RTRIM( vTTSTMW_FuelBill.[Customer ID] ) + ',', @OnlyCustomerList) >0)
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( o.ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( o.ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( o.ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( o.ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
		AND (@OnlyMppClass1List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type1 ) + ',', @OnlyMppClass1List) >0)
		AND (@OnlyMppClass2List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type2 ) + ',', @OnlyMppClass2List) >0)
		AND (@OnlyMppClass3List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type3 ) + ',', @OnlyMppClass3List) >0)
		AND (@OnlyMppClass4List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type4 ) + ',', @OnlyMppClass4List) >0)
		AND (@OnlyTeamLeaderList= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
		AND (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trctype1 ) + ',', @OnlyTrcClass1List) >0)
		AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trctype2 ) + ',', @OnlyTrcClass2list) >0)
		AND (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trctype3 ) + ',', @OnlyTrcClass3List) >0)
		AND (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trctype4 ) + ',', @OnlyTrcClass4List) >0)	
	
	If @ReturnAsPercentageYN = 'Y'
		BEGIN
			If @Mode = 'Count'	
				BEGIN
					Set @ThisCount = @Count
					Set @ThisTotal = @CountTotal
				END
			Else If @Mode = 'Gallons'
				BEGIN
					Set @ThisCount = @Gallons
					Set @ThisTotal = @GallonsTotal
				END
			Else If @Mode = 'Dollars'
				BEGIN
					Set @ThisCount = @Dollars
					Set @ThisTotal = @DollarsTotal
				END
			Else If @Mode = 'Price'
				BEGIN
					If @Type = 'S'
						Begin
							Set @ThisCount = @Dollars
							Set @ThisTotal = @Gallons
						End
					Else
						Begin
							Set @ThisCount = @DollarsTotal
							Set @ThisTotal = @GallonsTotal
						End
				END
		END
	ELSE --Not a Percentage
		BEGIN
			SELECT @ThisTotal = CASE WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) 
									THEN 1 ELSE DATEDIFF(day, @DateStart, @DateEnd) END
			--Set the Numerator	
			If @Mode = 'Count'
				Begin
					IF @Type = 'S'
						SET @ThisCount = @Count
					ELSE
						Set @ThisCount = @CountTotal
				End
			Else If @Mode = 'Gallons'
				Begin
					IF @Type = 'S'
						SET @ThisCount = @Gallons
					Else
						Set @ThisCount = @GallonsTotal
				End
			Else If @Mode = 'Dollars'
				Begin
					IF @Type = 'S'
						SET @ThisCount = @Dollars
					ELSE
						Set @ThisCount = @DollarsTotal
				End
			Else If @Mode = 'Price'
				Begin
					IF @Type = 'S'
						Begin	
							SET @ThisCount = @Dollars
							Set @ThisTotal = @Gallons
						End
					ELSE
						Begin	
							Set @ThisCount = @DollarsTotal
							Set @ThisTotal = @GallonsTotal
						End
				End
		END

	--Set the Result
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END
	
	--Show Detail
	If @ShowDetail=1
	BEGIN
		IF @OffNetworkDeterminedByTypeYN ='Y'
		BEGIN
			SELECT 	vTTSTMW_FuelBill.[Transaction Date], 
					vTTSTMW_FuelBill.[Employee Number], 
					vTTSTMW_FuelBill.[Truck Stop Name], 
					vTTSTMW_FuelBill.[Truck Stop City Name], 
					vTTSTMW_FuelBill.[Truck Stop State], 
					vTTSTMW_FuelBill.[Focus or Select], 
					vTTSTMW_FuelBill.[Tractor Cost Per Gallon], 
					vTTSTMW_FuelBill.[Tractor Gallons], 
					vTTSTMW_FuelBill.[Fee Fuel Oil Products],  
					vTTSTMW_FuelBill.[Total Due],
					case CHARINDEX(',' + RTRIM( vTTSTMW_FuelBill.[Focus or Select] ) + ',', @Type) when 1 then 'InNetwork' else 'OutOfNetwork' end as NetworkStatus
			FROM vTTSTMW_FuelBill (nolock) join manpowerprofile m (nolock) on vTTSTMW_FuelBill.[Employee Number] = m.mpp_id
				left join orderheader o (NOLOCK) on vTTSTMW_FuelBill.[Trip Number] = o.mov_number
			WHERE vTTSTMW_FuelBill.[Transaction Date] >= @DateStart AND vTTSTMW_FuelBill.[Transaction Date] < @DateEnd
				AND (@OnlyCustomerList =',,' or CHARINDEX(',' + RTRIM( vTTSTMW_FuelBill.[Customer ID] ) + ',', @OnlyCustomerList) >0)
				AND vTTSTMW_FuelBill.[Tractor Gallons] > 0
				AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( o.ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
				AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( o.ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
				AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( o.ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
				AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( o.ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
				AND (@OnlyMppClass1List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type1 ) + ',', @OnlyMppClass1List) >0)
				AND (@OnlyMppClass2List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type2 ) + ',', @OnlyMppClass2List) >0)
				AND (@OnlyMppClass3List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type3 ) + ',', @OnlyMppClass3List) >0)
				AND (@OnlyMppClass4List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type4 ) + ',', @OnlyMppClass4List) >0)
				AND (@OnlyTeamLeaderList= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
				AND (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trctype1 ) + ',', @OnlyTrcClass1List) >0)
				AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trctype2 ) + ',', @OnlyTrcClass2list) >0)
				AND (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trctype3 ) + ',', @OnlyTrcClass3List) >0)
				AND (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trctype4 ) + ',', @OnlyTrcClass4List) >0)
			ORDER BY vTTSTMW_FuelBill.[Employee Number],vTTSTMW_FuelBill.[Transaction Date]
		END
		ELSE
		BEGIN
			SELECT 	vTTSTMW_FuelBill.[Transaction Date], 
					vTTSTMW_FuelBill.[Employee Number], 
					vTTSTMW_FuelBill.[Truck Stop Name], 
					vTTSTMW_FuelBill.[Truck Stop City Name], 
					vTTSTMW_FuelBill.[Truck Stop State], 
					vTTSTMW_FuelBill.[Focus or Select], 
					vTTSTMW_FuelBill.[Tractor Cost Per Gallon], 
					vTTSTMW_FuelBill.[Tractor Gallons],
					vTTSTMW_FuelBill.[Fee Fuel Oil Products], 
					vTTSTMW_FuelBill.[Total Due],
					vTTSTMW_FuelBill.[Rebate Amount],
					case when [Rebate Amount]=0 then 'OutOfNetwork' else 'InNetwork' end as NetworkStatus
			FROM vTTSTMW_FuelBill (nolock) join manpowerprofile m (nolock) on vTTSTMW_FuelBill.[Employee Number] = m.mpp_id
				left join orderheader o (NOLOCK) on vTTSTMW_FuelBill.[Trip Number] = o.mov_number
			WHERE vTTSTMW_FuelBill.[Transaction Date] >= @DateStart AND vTTSTMW_FuelBill.[Transaction Date] < @DateEnd
				AND (@OnlyCustomerList =',,' or CHARINDEX(',' + RTRIM( vTTSTMW_FuelBill.[Customer ID] ) + ',', @OnlyCustomerList) >0)
				AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( o.ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
				AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( o.ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
				AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( o.ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
				AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( o.ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
				AND (@OnlyMppClass1List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type1 ) + ',', @OnlyMppClass1List) >0)
				AND (@OnlyMppClass2List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type2 ) + ',', @OnlyMppClass2List) >0)
				AND (@OnlyMppClass3List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type3 ) + ',', @OnlyMppClass3List) >0)
				AND (@OnlyMppClass4List= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_type4 ) + ',', @OnlyMppClass4List) >0)
				AND (@OnlyTeamLeaderList= ',,'  or CHARINDEX(',' + RTRIM( m.mpp_teamleader ) + ',', @OnlyTeamLeaderList) >0)
				AND (@OnlyTrcClass1List =',,' or CHARINDEX(',' + RTRIM( trctype1 ) + ',', @OnlyTrcClass1List) >0)
				AND (@OnlyTrcClass2List =',,' or CHARINDEX(',' + RTRIM( trctype2 ) + ',', @OnlyTrcClass2list) >0)
				AND (@OnlyTrcClass3List =',,' or CHARINDEX(',' + RTRIM( trctype3 ) + ',', @OnlyTrcClass3List) >0)
				AND (@OnlyTrcClass4List =',,' or CHARINDEX(',' + RTRIM( trctype4 ) + ',', @OnlyTrcClass4List) >0)	
		ORDER BY vTTSTMW_FuelBill.[Employee Number],vTTSTMW_FuelBill.[Transaction Date]

		END
	END

	SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[Metric_OffNetworkFuel2] TO [public]
GO
