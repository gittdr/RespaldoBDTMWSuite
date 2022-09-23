SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_CashReceipts]
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
		@UseGLPostedDate varchar(1) = 'N'
		)
		
AS


-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Cliente,2:Cobros


--debug


if exists (select * from sysobjects where name = 'Metric_TempCashReceipts')
	drop table Metric_TempCashReceipts



SET @RevType1= ',' + RTrim(ISNULL(@RevType1,'')) + ','
SET @RevType2= ',' + RTrim(ISNULL(@RevType2,'')) + ','
SET @RevType3= ',' + RTrim(ISNULL(@RevType3,'')) + ','
SET @RevType4= ',' + RTrim(ISNULL(@RevType4,'')) + ','
SET @BillToID=  ',' + RTrim(ISNULL(@BillToID,'')) + ','
	
/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'CashPosted',
		@nActive = 1,	-- 1=active, 0=inactive.
		@nSort = 601, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 2,
		@nPlusDeltaIsGood = 1,
		@nCumulative = 1,
		@sCaption = 'Cash posted',
		@sCaptionFull = 'Daily cash receipts posted in Great Plains',
		@sProcedureName = 'Metric_CashReceipts',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',
		@sCategory = '@@NOCATEGORY'

	</METRIC-INSERT-SQL>
*/

	-- NOTE 1: This might be inaccurate to run as backfill because history may be purged
	
--Local Variable Declaration
	DECLARE @GPPrefix VARCHAR(255)
	DECLARE @SQL VARCHAR(8000)
	DECLARE @PeriodEndDate DATETIME

	SET NOCOUNT ON

	SELECT @GPPrefix = dbo.fnc_TMWRN_GreatPlainsConnectionInfo(@Company)

		
--Temporary Table Creation
	CREATE TABLE Metric_TempCashReceipts
	(
 [Customer ID] char(15), 
 [Post Date] datetime,
 [Invoice Number] char(21),
 [CreditDebitType] int,
 [Cash Amount] money
        )



/*
the following SQL is built dynamicly so that it can be concatenated to the Great Plains server and 
database name.
INSERT INTO Metric_TempCashReceipts
Select  
	CustNmbr as 'Customer ID' ,
	PostDate as 'Post Date',
	DocNumbr as 'Invoice Number',
	RMDTYPAL as 'CreditDebitType',
	'Cash Amount' = IsNull(convert(money,ISNULL(ORTRXAMT,0)),0.00)
from    RM20101 R
where   R.RMDTYPAL IN (9) 
	And
        (@BILLTO  = ',,' OR CHARINDEX(',' + RTrim(CustNmbr) + ',', @BILLTO ) > 0) 
	And

	PostDate BETWEEN @DateStart AND @DateEnd
union
Select  
	CustNmbr as 'Customer ID' ,
	PostDate as 'Post Date',
	DocNumbr as 'Invoice Number',
	RMDTYPAL as 'CreditDebitType',
	'Cash Amount' = IsNull(convert(money,ISNULL(ORTRXAMT,0)),0.00)
from    RM30101 R 
where   R.RMDTYPAL IN (9) 
        And
        (@BILLTO  = ',,' OR CHARINDEX(',' + RTrim(CustNmbr) + ',', @BILLTO ) > 0) 
	And
	PostDate BETWEEN @DateStart AND @DateEnd
*/


SET @SQL = 'INSERT INTO Metric_TempCashReceipts Select CustNmbr as ''Customer ID'','
If @UseGLPostedDate = 'Y'
	SET @SQL = @SQL + 'GLPostDt'
ELSE
	SET @SQL = @SQL + 'PostDate'
SET @SQL = @SQL + 	' as ''Post Date'',DocNumbr as ''Invoice Number'',RMDTYPAL as ''CreditDebitType'',''Cash Amount'' = IsNull(convert(money,ISNULL(ORTRXAMT,0)),0.00) from '
SET @SQL = @SQL + @GPPrefix + 'dbo.RM20101 R where  R.VOIDSTTS = 0  and  R.RMDTYPAL IN (9) And ('''
SET @SQL = @SQL + @BillToID + ''' = '',,'' OR CHARINDEX('','' + RTrim(CustNmbr) + '','', '''
SET @SQL = @SQL + @BillToID + ''' ) > 0) And '
If @UseGLPostedDate = 'Y'
	SET @SQL = @SQL + 'GLPostDt'
ELSE
	SET @SQL = @SQL + 'PostDate'
SET @SQL = @SQL + ' >= ''' + CONVERT(VARCHAR(16), @DateStart, 121) + ''' AND '
If @UseGLPostedDate = 'Y'
	SET @SQL = @SQL + 'GLPostDt'
Else
	SET @SQL = @SQL + 'PostDate'
SET @SQL = @SQL + ' < '''  + CONVERT(VARCHAR(16), @DateEnd, 121) + ''' Union Select CustNmbr as ''Customer ID'',PostDate as ''Post Date'',DocNumbr as ''Invoice Number'',RMDTYPAL as ''CreditDebitType'',''Cash Amount'' = IsNull(convert(money,ISNULL(ORTRXAMT,0)),0.00) from '
SET @SQL = @SQL + @GPPrefix + 'dbo.RM30101 R where   R.RMDTYPAL IN (9) And ('''
SET @SQL = @SQL + @BillToID + ''' = '',,'' OR CHARINDEX('','' + RTrim(CustNmbr) + '','', '''
SET @SQL = @SQL + @BillToID + ''' ) > 0) And '
If @UseGLPostedDate = 'Y'
	SET @SQL = @SQL + 'GLPostDt'
Else
	SET @SQL = @SQL + 'PostDate'
SET @SQL = @SQL + ' >= ''' + CONVERT(VARCHAR(16), @DateStart, 121) + ''' AND '
If @UseGLPostedDate = 'Y'
	SET @SQL = @SQL + 'GLPostDt'
Else
	SET @SQL = @SQL + 'PostDate'
SET @SQL = @SQL + ' < ''' + CONVERT(VARCHAR(16), @DateEnd, 121) + ''''
--select @sql
	EXEC (@SQL)
	SELECT Metric_TempCashReceipts.*,
	       ivh_revtype1 AS RevType1,
	       ivh_revtype2 AS RevType2,
	       ivh_revtype3 AS RevType3,
	       ivh_revtype4 AS RevType4
	
	INTO   #TempReceipts       
	FROM   Metric_TempCashReceipts Left Join InvoiceHeader (NOLOCK) On [Invoice Number] = InvoiceHeader.ivh_invoicenumber
	       
	WHERE  (@RevType1 =',,' or CHARINDEX(',' + ivh_revtype1 + ',', @RevType1) >0)
       	  	AND 
	       (@RevType2 =',,' or CHARINDEX(',' + ivh_revtype2 + ',', @RevType2) >0)
       	        AND 
	       (@RevType3 =',,' or CHARINDEX(',' + ivh_revtype3 + ',', @RevType3) >0)
       	        AND 
           (@RevType4 =',,' or CHARINDEX(',' + ivh_revtype4 + ',', @RevType4) >0)


		SET @ThisCount = IsNull((Select  Sum([Cash Amount])  FROM  #TempReceipts ),0)
		
		SET @ThisTotal = 1
		SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

		EXEC Helper_sp_Metric_LogMetricResult 'Metric_CashReceipts', @Result, @ThisCount, @ThisTotal, @DateStart, @DateEnd, @UseMetricParms, @ShowDetail			
	

IF @ShowDetail = 1
 BEGIN
		SELECT  [Customer ID] as Cliente, 
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum([Cash Amount]),2) as CantidadCobro 
        FROM #TempReceipts  
        group by [Customer ID] 
        order by sum([Cash Amount]) DESC
END

IF @ShowDetail = 2
 BEGIN
		SELECT  [Customer ID] as Cliente, 
        [Post Date] as FechaCobro,
        [Invoice Number] as NumCobro,
        '$' + dbo.fnc_TMWRN_FormatNumbers([Cash Amount],2) as CantidadCobro FROM #TempReceipts  
END

	SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[Metric_CashReceipts] TO [public]
GO
