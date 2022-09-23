SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_CustomerAverageDaysToPay]
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
		@RollingYearYN char(1) = 'N',
		@RollingMonthYN char(1) = 'N'
		)
		
AS

SET @RevType1= ',' + RTrim(ISNULL(@RevType1,'')) + ','
SET @RevType2= ',' + RTrim(ISNULL(@RevType2,'')) + ','
SET @RevType3= ',' + RTrim(ISNULL(@RevType3,'')) + ','
SET @RevType4= ',' + RTrim(ISNULL(@RevType4,'')) + ','
SET @BillToID= ',' + RTRIM(ISNULL(@BillToID,'')) + ','    



	DECLARE @SQL VARCHAR(8000)
	DECLARE @PeriodEndDate DATETIME

	SET NOCOUNT ON

	
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
		IF @RollingMonthYN = 'Y'
		BEGIN
			SET @PeriodBeginDate = DateAdd(mm, -1, @DateStart)
		END
	END

	
	SET @PeriodEndDate   = @DateEnd

	--END

	--SET @PeriodEndDate = GETDATE()

If Exists (SELECT * FROM sysobjects where name = 'Metric_TempGPInvoices')
   drop table Metric_TempGPInvoices

--Temporary Table Creation
	CREATE TABLE Metric_TempGPInvoices
	(
 		[Customer ID] char(15), 
 		[Doc Date] datetime,
 		[Invoice Number] char(21),
 		[CreditDebitType] int,
 		[Invoice Amount] money,
 		[Open Invoice Amount] money,
 		[Prior Invoice Number] char(15),
 		[LastPaymentAppliedDate] datetime,
 		[Days To Pay] int
	)


Create Index idxInvoiceNumber On Metric_TempGPInvoices([Invoice Number])
Create Index idxInvoiceAmount On Metric_TempGPInvoices([Invoice Amount])
Create Index idxPriorInvoiceNumber On Metric_TempGPInvoices([Prior Invoice Number])



SET @SQL = 'INSERT INTO Metric_TempGPInvoices ([Customer ID],[Doc Date],[Invoice Number],[CreditDebitType],[Invoice Amount],[Open Invoice Amount],[LastPaymentAppliedDate])'
SET @SQL = @SQL + 'Select CustNmbr as ''Customer ID'',DocDate as ''Doc Date'',DocNumbr as ''Invoice Number'',RMDTYPAL as ''CreditDebitType'',''Invoice Amount'' = IsNull(convert(money,ISNULL(ORTRXAMT,0)),0.00),'
SET @SQL = @SQL + '''Open Invoice Amount'' = IsNull(convert(money,ISNULL(CURTRXAM,0)),0.00), ''LastPaymentAppliedDate'' = IsNull((Select max(APFRDCDT)	FROM ' + ' [172.24.16.113].TDR.dbo.RM20201 RP where RP.APTODCNM=R.DocNumbr), ''19000101'') from '
SET @SQL = @SQL + '[172.24.16.113].TDR.dbo.RM20101 R where   R.RMDTYPAL IN (1,3,7) And ('''
SET @SQL = @SQL + @BillToID + ''' = '',,'' OR CHARINDEX('','' + RTrim(CustNmbr) + '','', '''
SET @SQL = @SQL + @BillToID + ''' ) > 0) And IsNull(CURTRXAM,0) = 0 And PostDate BETWEEN '''
SET @SQL = @SQL + CONVERT(VARCHAR(10), @PeriodBeginDate, 101) + ''' AND '''
SET @SQL = @SQL + CONVERT(VARCHAR(10), @PeriodEndDate, 101) + ''' Union Select CustNmbr as ''Customer ID'',DocDate as ''Doc Date'',DocNumbr as ''Invoice Number'',RMDTYPAL as ''CreditDebitType'',''Invoice Amount'' = IsNull(convert(money,ISNULL(ORTRXAMT,0)),0.00),'
SET @SQL = @SQL + '''Open Invoice Amount'' = IsNull(convert(money,ISNULL(CURTRXAM,0)),0.00), ''LastPaymentAppliedDate'' = IsNull((Select max(APFRDCDT)	FROM ' + '[172.24.16.113].TDR.dbo.RM30201 RP where RP.APTODCNM=R.DocNumbr),''19000101'') from '
SET @SQL = @SQL +  '[172.24.16.113].TDR.dbo.RM30101 R where   R.RMDTYPAL IN (1,3,7) And ('''
SET @SQL = @SQL + @BillToID + ''' = '',,'' OR CHARINDEX('','' + RTrim(CustNmbr) + '','', '''
SET @SQL = @SQL + @BillToID + ''' ) > 0) And PostDate BETWEEN '''
SET @SQL = @SQL + CONVERT(VARCHAR(10), @PeriodBeginDate, 101) + ''' AND '''
SET @SQL = @SQL + CONVERT(VARCHAR(10), @PeriodEndDate, 101) + ''''

--SET ANSI_WARNINGS OFF this doesn't work for EL Hollingsworth
	EXEC (@SQL)
SET ANSI_WARNINGS ON

	Update Metric_TempGPInvoices Set [Days To Pay] =  datediff(day,[Doc Date],[LastPaymentAppliedDate])
	Where LastPaymentAppliedDate > '19000101'

	

	SELECT Metric_TempGPInvoices.*,
	       ivh_billdate AS [Bill Date],
	       ivh_revtype1 AS RevType1,
	       ivh_revtype2 AS RevType2,
	       ivh_revtype3 AS RevType3,
	       ivh_revtype4 AS RevType4
	                                                                            
	INTO   #TempInvoices       
	FROM   Metric_TempGPInvoices Left Join InvoiceHeader (NOLOCK) On [Invoice Number] = InvoiceHeader.ivh_invoicenumber
	       
	WHERE  (@RevType1 =',,' or CHARINDEX(',' + ivh_revtype1 + ',', @RevType1) >0)
       	  	AND (@RevType2 =',,' or CHARINDEX(',' + ivh_revtype2 + ',', @RevType2) >0)
       	    AND (@RevType3 =',,' or CHARINDEX(',' + ivh_revtype3 + ',', @RevType3) >0)
       	    AND (@RevType4 =',,' or CHARINDEX(',' + ivh_revtype4 + ',', @RevType4) >0)
	    AND LastPaymentAppliedDate > '19000101' 
--quitar los documentos que la fecha de pago es menor a la fecha del docto.
and [LastPaymentAppliedDate] > [Doc Date]

--Show Detail
	IF @ShowDetail = 0 
	BEGIN
		SELECT 	@ThisCount = Sum([Days To Pay]), 
        	   	@ThisTotal = Count(*)
		FROM	#TempInvoices
        	
		SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

		EXEC Helper_sp_Metric_LogMetricResult 'Metric_CustomerAverageDaysToPay', @Result, @ThisCount, @ThisTotal, @DateStart, @DateEnd, @UseMetricParms, @ShowDetail			
	
	END
	ELSE
	BEGIN
	select 'No data to show' as Message
	END

	



	SET NOCOUNT OFF

GO
