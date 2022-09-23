SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Metric_AverageDaysToPayVendor]
--Standard Parameters
		(		
		@Result decimal(20, 5) OUTPUT, 
		@ThisCount decimal(20, 5) OUTPUT, 
		@ThisTotal decimal(20, 5) OUTPUT, 
		@DateStart datetime, 
		@DateEnd datetime, 
		@UseMetricParms int, 
		@ShowDetail int,
--Additional/Optional Parameters
		@Company varchar(255) = '',
		@VendorID varchar(255) = '',
		@VendorClass varchar(255) = '',
		@PeriodBeginDate datetime = NULL,
		@RollingYearYN char(1) = 'N',
		@RollingMonthYN char(1) = 'N'
		)
		
AS

--Metric Initialization
	
/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'AverageDaysToPayVendor',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 601, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'Average Days To Pay Vendor',
		@sCaptionFull = 'Average Days To Pay Vendor',
		@sProcedureName = 'Metric_AverageDaysToPayVendor',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',
		@sCategory = '@@NOCATEGORY'

	</METRIC-INSERT-SQL>
*/

	-- NOTE 1: This might be inaccurate to run as backfill because history may be purged, and driver/truck assignments change.
	-- NOTE 2: Make a shell procedure on TMWSuite server/database that calls equivalent procedure on TotalMail server/database.

--Local Variable Declaration
	DECLARE @GPPrefix VARCHAR(255)
	DECLARE @SQL VARCHAR(8000)
	Declare @PeriodEndDate DATETIME

	SET NOCOUNT ON

--Variable Initialization
	SELECT @GPPrefix = dbo.fnc_TMWRN_GreatPlainsConnectionInfo(@Company)

	IF @PeriodBeginDate IS NULL 
	BEGIN
		IF @RollingYearYN = 'Y'
		BEGIN
			SET @PeriodBeginDate = DateAdd(yy, -1, @DateStart)
		END
		ELSE
		BEGIN
			SET @PeriodBeginDate = CAST(DATEPART(yyyy,GETDATE()) as varchar(4)) + '0101'
		END

		IF @RollingMonthYN = 'Y'
		BEGIN
			SET @PeriodBeginDate = DateAdd(mm, -1, @DateStart)
		END

	END

	


	SET @PeriodEndDate   = @DateEnd



		
--Temporary Table Creation
	CREATE TABLE #TempGPPay
	(	[Vendor ID] CHAR(15), 
 		[Doc Date] DATETIME,
 		[Doc Number] CHAR(21),
 		[DocType] INT,
 		[Pay Amount] MONEY,
 		[LastPaymentAppliedDate] DATETIME,
 		[Days To Pay] INT
	)


	SELECT @SQL = 'EXEC ' + @GPPrefix + 'dbo.Metric_AverageDaysToPayVendor_GP ''' + CONVERT(VARCHAR(10), @PeriodBeginDate, 101) + ''', ''' + CONVERT(VARCHAR(10), @DateEnd, 101) + '''' + ',' + cast(IsNull(@UseMetricParms,0) as varchar(1)) + ',' + cast(IsNull(@ShowDetail,0) as varchar(1)) + ',' + '''' + @VendorID + '''' + ',' + '''' + @VendorClass + '''' + ',' + '''' +  CONVERT(VARCHAR(10), @PeriodBeginDate, 101) +  '''' + ',' +  '''' + CONVERT(VARCHAR(10), @PeriodEndDate, 101) +  ''''
	
	INSERT INTO #TempGPPay
	EXEC (@SQL)

	SELECT #TempGPPay.*
    INTO   #TempPay      
	FROM   #TempGPPay

	IF @ShowDetail = 0 
	BEGIN
		SELECT 	@ThisCount = Sum([Days To Pay]), 
        		@ThisTotal = Count(*)
		FROM    #TempPay
        	
		SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

		EXEC Helper_sp_Metric_LogMetricResult 'Metric_AverageDaysToPayVendor', @Result, @ThisCount, @ThisTotal, @DateStart, @DateEnd, @UseMetricParms, @ShowDetail			
	
	END
	ELSE
	BEGIN
		SELECT * FROM #TempPay 
	END

	SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[Metric_AverageDaysToPayVendor] TO [public]
GO
