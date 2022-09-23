SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_ElectOrdPct] (
	@Result decimal(20, 5) OUTPUT, @ThisCount decimal(20, 5) OUTPUT, @ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, @DateEnd datetime, @UseMetricParms int, @ShowDetail int,
	@ListofBookByIDsThatIndicateImported varchar(255) = '',
	@OnlyRevClass1List varchar(128) ='',
	@OnlyRevClass2List varchar(128) ='',
	@OnlyRevClass3List varchar(128) ='',
	@OnlyRevClass4List varchar(128) =''

)
AS 

/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'ElectOrdPct',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 405, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 0,
		@sCaption = '% Electronic Orders',
		@sCaptionFull = 'Percentage of the total orders that are received via edi, web, or integrations',
		@sProcedureName = 'Metric_ElectOrdPct',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = '@@NOCATEGORY'

	</METRIC-INSERT-SQL>
*/
	SET NOCOUNT ON  -- PTS46367

	-- Electronic Order count- dm 2/25/03  -- Count of orders booked today electronically

	Set @OnlyRevClass1List= ',' + ISNULL(@OnlyRevClass1List,'') + ','
	Set @OnlyRevClass2List= ',' + ISNULL(@OnlyRevClass2List,'') + ','
	Set @OnlyRevClass3List= ',' + ISNULL(@OnlyRevClass3List,'') + ','
	Set @OnlyRevClass4List= ',' + ISNULL(@OnlyRevClass4List,'') + ','

	
	DECLARE @ImportedCountTemp int
	DECLARE @ImportedCount int,	@EDIOrderCount int, @CopiedOrderOrSchedulerCount int
	
	SELECT @ListofBookByIDsThatIndicateImported = ',' + ISNULL(@ListofBookByIDsThatIndicateImported, '') + ','
	
	-- Assume any order with a bookby id not in the TTSUSER list is imported
	SELECT @ImportedCountTemp =	COUNT(*)
		FROM orderheader WITH (NOLOCK)
		WHERE ord_bookdate >= @DateStart AND ord_bookdate < @DateEnd
			AND ord_status IN ('AVL','DSP','STD', 'CMP','PND')
			AND	NOT EXISTS (SELECT * FROM ttsusers WITH (NOLOCK) WHERE usr_userid = ord_bookedby)
			AND	(CHARINDEX(',' + RTRIM( ord_bookedby ) + ',', @ListofBookByIDsThatIndicateImported) = 0) -- Counted below 		
			AND (CHARINDEX('Electronic Data Interchange', Ord_remark) = 0) -- EDI COUNTED BELOW
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)


	
	-- Add in any orders with specific ID in User defined list of user id that indicate imported
	SELECT @ImportedCount = COUNT(*)
		FROM Orderheader WITH (NOLOCK), TTSUsers WITH (NOLOCK)
		WHERE ord_bookdate >= @DateStart AND ord_bookdate < @DateEnd
			AND ord_status IN ('AVL','DSP','STD', 'CMP','PND')
			AND	(CHARINDEX(',' + RTRIM( ord_bookedby ) + ',', @ListofBookByIDsThatIndicateImported) > 0) 
			AND	usr_userid = ord_bookedby
			AND	(CHARINDEX('Electronic Data Interchange', Ord_remark) = 0)  -- EDI COUNTED BELOW
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)

	
	SELECT @ImportedCount = @ImportedCount + @ImportedCountTemp
	
	-- Check EDI comment and count
	SELECT @EDIOrderCount = COUNT(*)
		FROM orderheader WITH (NOLOCK)
		WHERE ord_bookdate >= @DateStart AND ord_bookdate < @DateEnd
			AND ord_status IN ('AVL','DSP','STD', 'CMP','PND')
			AND	(CHARINDEX('Electronic Data Interchange', Ord_remark) > 0)
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)


	-- Find copied/scheduler loads-- make sure it hasn't been counted already 
	SELECT @CopiedOrderOrSchedulerCount = COUNT(*)
		FROM orderheader WITH (NOLOCK), TTSUSERS WITH (NOLOCK)
		WHERE ord_bookdate >= @DateStart AND ord_bookdate < @DateEnd
			AND ord_status IN ('AVL','DSP','STD', 'CMP','PND')
			AND	ord_fromorder IS NOT NULL 
			AND ord_fromorder > ''
			AND	(CHARINDEX('Electronic Data Interchange', Ord_remark) = 0) -- Counted above
			AND	(CHARINDEX(',' + RTRIM( ord_bookedby ) + ',', @ListofBookByIDsThatIndicateImported) = 0)-- Counted above
			AND usr_userid = ord_bookedby
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)


	SELECT @ThisCount = @EDIOrderCount	+ @CopiedOrderOrSchedulerCount

	-- Check EDI comment and count
	SELECT @ThisTotal = COUNT(*)
		FROM orderheader WITH (NOLOCK)
		WHERE ord_bookdate >= @DateStart AND ord_bookdate < @DateEnd
			AND ord_status IN ('AVL','DSP','STD', 'CMP','PND')
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

	IF (@ShowDetail=1)
	BEGIN
		Select 
			ord_number,
			ord_bookedby,
			IsEdi= (
				CASE WHEN
					(CHARINDEX('Electronic Data Interchange', Ord_remark) = 0)
					THEN 'No'
				Else 'Yes'
				END
				),
			BookedByIsInList= (
				CASE WHEN
					(CHARINDEX(',' + RTRIM( ord_bookedby ) + ',', @ListofBookByIDsThatIndicateImported) > 0)
				THEN 'Yes'
				ELSE 'No'
				END
				),
			IsBookedByNonTMWUser = (
				CASE WHEN
					NOT EXISTS (SELECT * FROM ttsusers WITH (NOLOCK) WHERE usr_userid = ord_bookedby)
				THEN 'Yes'
				ELSE 'No'
				END
				),
			ord_shipper ShipperID,
			Ord_consignee ConsigneeID,
			Ord_bookdate BookDate,
			@ListofBookByIDsThatIndicateImported ListofBookByIDsThatIndicateImported				
		From Orderheader (NOLOCK)
		where			
			 ord_bookdate >= @DateStart AND ord_bookdate < @DateEnd
			AND ord_status IN ('AVL','DSP','STD', 'CMP','PND')
		AND (@OnlyRevClass1List =',,' or CHARINDEX(',' + RTRIM( ord_revtype1 ) + ',', @OnlyRevClass1List) >0)
		AND (@OnlyRevClass2List =',,' or CHARINDEX(',' + RTRIM( ord_revtype2 ) + ',', @OnlyRevClass2list) >0)
		AND (@OnlyRevClass3List =',,' or CHARINDEX(',' + RTRIM( ord_revtype3 ) + ',', @OnlyRevClass3List) >0)
		AND (@OnlyRevClass4List =',,' or CHARINDEX(',' + RTRIM( ord_revtype4 ) + ',', @OnlyRevClass4List) >0)
	end
GO
GRANT EXECUTE ON  [dbo].[Metric_ElectOrdPct] TO [public]
GO
