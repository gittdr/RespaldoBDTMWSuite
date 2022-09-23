SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Metric_OutstandingPartialAmountsDue]
		(
		--Standard Parameters
		@Result decimal(20, 5) OUTPUT,  --Value of metric for the time frame passed 
		@ThisCount decimal(20, 5) OUTPUT, --Numerator of the daily metric calculation
		@ThisTotal decimal(20, 5) OUTPUT, --Denominator of the daily metric calculation
		@DateStart datetime, --Start date of metric calculation time frame 
		@DateEnd datetime, --End date of metric calculation time frame
		@UseMetricParms int, --Use metric parm flag
		@ShowDetail int, --Show detail flag
		
		--Additional/Optional Parameters
		@Company varchar(255) = '',
		@BillToID varchar(255) = '',
		@RevType1 varchar(255) = '', --ord_revtype1
		@RevType2 varchar(255) = '', --ord_revtype2
		@RevType3 varchar(255) = '', --ord_revtype3
		@RevType4 varchar(255) = '', --ord_revtype4
		@PeriodBeginDate datetime = NULL,
		@RollingYearYN char(1) = 'N'
		)
		
AS

SET @RevType1= ',' + RTrim(ISNULL(@RevType1,'')) + ','
SET @RevType2= ',' + RTrim(ISNULL(@RevType2,'')) + ','
SET @RevType3= ',' + RTrim(ISNULL(@RevType3,'')) + ','
SET @RevType4= ',' + RTrim(ISNULL(@RevType4,'')) + ','


	
/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'CustomerAverageDaysToPay',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 601, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = 'PCT',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'Customer Average Days To Pay',
		@sCaptionFull = 'Customer Average Days To Pay%',
		@sProcedureName = 'Metric_CustomerAverageDaysToPay',
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
	DECLARE @PeriodEndDate DATETIME

	SET NOCOUNT ON

	SELECT @GPPrefix = dbo.fnc_TMWRN_GreatPlainsConnectionInfo(@Company)

	IF @PeriodBeginDate IS NULL 
	BEGIN
		IF @RollingYearYN = 'Y'
		BEGIN
			SET @PeriodBeginDate = GETDATE() - 365
		END	
		ELSE
		BEGIN
			SET @PeriodBeginDate = CAST(DATEPART(yyyy,GETDATE()) AS VARCHAR(4)) + '0101'
		END
	END

	SET @PeriodEndDate = GETDATE()
		
--Temporary Table Creation
	CREATE TABLE #TempGPInvoices
	(
 		[Customer ID] char(15), 
 		[Bill Date] datetime,
 		[Invoice Number] char(21),
 		[CreditDebitType] int,
 		[Invoice Amount] money,
 		[Open Invoice Amount] money,
		[Partial Amount Still Due] money	
	)


	SELECT @SQL = 'EXEC ' + @GPPrefix + 'dbo.Metric_OutstandingPartialAmountsDue_GP ''' + CONVERT(VARCHAR(10), @PeriodBeginDate, 101) + ''', ''' + CONVERT(VARCHAR(10), @DateEnd, 101) + '''' + ',' + cast(IsNull(@UseMetricParms,0) as varchar(1)) + ',' + cast(IsNull(@ShowDetail,0) as varchar(1)) + ',' + '''' + @BillToID + '''' + ',' + '''' + CONVERT(VARCHAR(10), @PeriodBeginDate, 101) +  '''' + ',' +  '''' + CONVERT(VARCHAR(10), @PeriodEndDate, 101) +  ''''
	
	INSERT INTO #TempGPInvoices
	EXEC (@SQL)

	SELECT #TempGPInvoices.*,
	       --ivh_billdate AS [Bill Date],
	       ivh_revtype1 AS RevType1,
	       ivh_revtype2 AS RevType2,
	       ivh_revtype3 AS RevType3,
	       ivh_revtype4 AS RevType4
	
	INTO   #TempInvoices       
	FROM   #TempGPInvoices Left Join InvoiceHeader (NOLOCK) On [Invoice Number] = InvoiceHeader.ivh_invoicenumber
	       
	WHERE  (@RevType1 =',,' or CHARINDEX(',' + ivh_revtype1 + ',', @RevType1) >0)
       	  	AND 
	       (@RevType2 =',,' or CHARINDEX(',' + ivh_revtype2 + ',', @RevType2) >0)
       	        AND 
	       (@RevType3 =',,' or CHARINDEX(',' + ivh_revtype3 + ',', @RevType3) >0)
       	        AND 
               (@RevType4 =',,' or CHARINDEX(',' + ivh_revtype4 + ',', @RevType4) >0)

--Show Detail
	IF @ShowDetail = 0 
	BEGIN
		SET @ThisCount = IsNull((Select
					       Sum([Partial Amount Still Due])
				         FROM  #TempInvoices
        			        ),0)
		

		SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

		EXEC Helper_sp_Metric_LogMetricResult 'Metric_OutstandingPartialAmountsDue', @Result, @ThisCount, @ThisTotal, @DateStart, @DateEnd, @UseMetricParms, @ShowDetail			
	
	END
	ELSE
	BEGIN
		SELECT * FROM #TempInvoices  
	END

	



	SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[Metric_OutstandingPartialAmountsDue] TO [public]
GO
