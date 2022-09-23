SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--watchdogprocessing 'aragingsummary'

Create Procedure [dbo].[WatchDog_ARAgingSummary] 
(
	@MinThreshold float = 0,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalOutstandingReceivables',
	@WatchName varchar(255) = 'OutstandingReceivables',
	@ThresholdFieldName varchar(255) = 'Days Open',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@PercentofTotal float  = 0,
	@RevType1 varchar(255)='',
	@RevType2 varchar(255)='',
	@RevType3 varchar(255)='',
	@RevType4 varchar(255)='',
	@BillToID varchar(255)=''
)

As

	Set NoCount On

	/*
	Procedure Name:    WatchDog_ARAgingSummary 
	Author/CreateDate: Brent Keeton / 8-25-2004
	Purpose: 	   
Notes: This alert requires a SQL job to activate the stored Procedure daily - TMWRN_OutstandingReceivablesProcessing_GP 
	Revision History:
	5/20/2008  Fixed bug in aging allocations; was double allocating if EXACTLY 60 or 90 days old Steve Pembridge
	*/


	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	Declare @CompareDate datetime
	Set @CompareDate = GetDate()
--	for debugging
--	Set @CompareDate = '2007-12-07'


	Set @RevType1= ',' + RTrim(ISNULL(@RevType1,'')) + ','
	Set @RevType2= ',' + RTrim(ISNULL(@RevType2,'')) + ','
	Set @RevType3= ',' + RTrim(ISNULL(@RevType3,'')) + ','
	Set @RevType4= ',' + RTrim(ISNULL(@RevType4,'')) + ','
	Set @BillToID= ',' + RTrim(ISNULL(@BillToID,'')) + ','

	SELECT	ord_number as [Order #],
			InvoiceHeader.ivh_invoicenumber as [Invoice Number],
			InvoiceHeader.ivh_totalcharge as [Invoice Amount],
			AmountReceived as [Amount Received],
			mov_number as [Move #],
			ivh_shipper as [Shipper ID],
			(select cty_name from city (NOLOCK) Where cty_code = ivh_origincity) as [Origin City],
			ivh_consignee as [Consignee ID],
			(select cty_name from city (NOLOCK) Where cty_code = ivh_destcity) as [Destination City],
			(select cmp_name from company (NOLOCK) Where cmp_id = ivh_billto) as [BillTo],
			ivh_billto as [BillTo ID],
			ivh_revtype1 as RevType1,
			ivh_revtype2 as RevType2,
			ivh_revtype3 as RevType3,
			ivh_revtype4 as RevType4,
			BatchDate as [Doc Date],
			OpenACCTInvoiceAmount as [Total Open Amount],
			LastPaymentAppliedDate as [Last Payment Date],
			Case When DateDiff(day,[BatchDate],@CompareDate) <= 30 Then
		       			IsNull([OpenACCTInvoiceAmount],0.00)
			End as [<= 30 Days],
			Case When DateDiff(day,[BatchDate],@CompareDate) > 30 and DateDiff(day,[BatchDate],@CompareDate) <= 60 Then
		       			IsNull([OpenACCTInvoiceAmount],0.00)
			End as [31 To 60 Days],
			Case When DateDiff(day,[BatchDate],@CompareDate) > 60 and DateDiff(day,[BatchDate],@CompareDate) <= 90 Then
						IsNull([OpenACCTInvoiceAmount],0)
			End as [61 To 90 Days],
			Case When DateDiff(day,[BatchDate],@CompareDate) > 90 Then
		       			IsNull([OpenACCTInvoiceAmount],0.00)
			End as [> 90 Days],
			DateDiff(day,[BatchDate],@CompareDate) as [Days Open]	 
	INTO   #TempReport
	FROM   ACCT_OutstandingReceivables (NOLOCK) 
		Left Join invoiceheader (NOLOCK) On ACCT_OutstandingReceivables.InvoiceNumber = InvoiceHeader.ivh_invoicenumber       
	WHERE (@RevType1 =',,' or CHARINDEX(',' + ivh_revtype1 + ',', @RevType1) >0)
		AND (@RevType2 =',,' or CHARINDEX(',' + ivh_revtype2 + ',', @RevType2) >0)
		AND (@RevType3 =',,' or CHARINDEX(',' + ivh_revtype3 + ',', @RevType3) >0)
		AND (@RevType4 =',,' or CHARINDEX(',' + ivh_revtype4 + ',', @RevType4) >0)
		AND (@BillToID=',,' or CHARINDEX(',' + ivh_billto + ',', @BillToID) >0)
		   
	SELECT	[BillTo ID],
			[BillTo],
			Sum(IsNull([<= 30 Days],0)) as [<= 30 Days],
			Case When Sum(IsNull([Total Open Amount],0.00)) = 0.00 Then
				0.00
	 		Else
	 			cast((Sum(IsNull([<= 30 Days],0.00)) / Sum(IsNull([Total Open Amount],0.00)) * 100) as decimal(10,2))
	 		End as [% <= 30 Days],
			Sum(IsNull([31 To 60 Days],0.00)) as [31 To 60 Days],
			Case When Sum(IsNull([Total Open Amount],0.00)) = 0.00 Then
				0.00
	 		Else
	 			cast((Sum(IsNull([31 To 60 Days],0.00)) / Sum(IsNull([Total Open Amount],0.00)) * 100) as decimal(10,2))
	 		End as [% 31 To 60 Days],
			Sum(IsNull([61 To 90 Days],0.00)) as [61 To 90 Days],
			Case When Sum(IsNull([Total Open Amount],0.00)) = 0.00 Then
				0.00
	 		Else
				cast((Sum(IsNull([61 To 90 Days],0.00)) / Sum(IsNull([Total Open Amount],0.00)) * 100) as decimal(10,2))
	 		End as [% 61 To 90 Days],
			Sum(IsNull([> 90 Days],0.00)) as [> 90 Days],	      
			Case When Sum(IsNull([Total Open Amount],0.00)) = 0.00 Then
				0.00
	 		Else
				cast((Sum(IsNull([> 90 Days],0.00)) / Sum(IsNull([Total Open Amount],0.00)) * 100) as decimal(10,2))
	 		End as [% > 90 Days],
	 		Sum(IsNull([Total Open Amount],0.00)) as [Total Open],
	 		cast((select sum(IsNull(a.[Total Open Amount],0.00)) from #TempReport a where a.[BillTo ID] = #TempReport.[BillTo ID] and a.[Days Open] >= @MinThreshold)/Sum(IsNull([Total Open Amount],0.00)) as decimal (10,2)) as [% >= X Days]
	INTO     #TempSummary
	FROM     #TempReport
	GROUP BY [BillTo ID],[BillTo]
	HAVING  Sum(IsNull([Total Open Amount],0.00)) > 0.00
		AND IsNull((select sum(IsNull(a.[Total Open Amount],0.00)) from #TempReport a where a.[BillTo ID] = #TempReport.[BillTo ID] and a.[Days Open] >= @MinThreshold),0.00)/Sum(IsNull([Total Open Amount],0.00)) >= @PercentofTotal
				
	SELECT TempSummary.*
	INTO   #TempResults
	FROM	(	Select   #TempSummary.*
				From     #TempSummary
				Where    [BillTo ID] In (select [BillTo ID] from #TempReport a where a.[BillTo ID] = #TempSummary.[BillTo ID] and [Days Open] >= @MinThreshold)

				Union

				select   '' as [BillTo ID],
						'Total' as  [BillTo],
						Sum(IsNull([<= 30 Days],0.00)) as [<= 30 Days],
						Case When Sum(IsNull([Total Open],0.00)) = 0.00 Then
							0
	 					Else
	 						cast((Sum(IsNull([<= 30 Days],0.00))/Sum(IsNull([Total Open],0.00)) * 100) as decimal(10,2))
	 					End as [% <= 30 Days],
						Sum(IsNull([31 To 60 Days],0.00)) as [31 To 60 Days],
						Case When Sum(IsNull([Total Open],0.00)) = 0.00 Then
							0
	 					Else
	 						cast((Sum(IsNull([31 To 60 Days],0.00))/Sum(IsNull([Total Open],0.00)) * 100) as decimal(10,2))
	 					End as [% 31 To 60 Days],
						Sum(IsNull([61 To 90 Days],0.00)) as [61 To 90 Days],
						Case When Sum(IsNull([Total Open],0.00)) = 0.00 Then
							0
	 					Else
							cast((Sum(IsNull([61 To 90 Days],0.00))/Sum(IsNull([Total Open],0.00)) * 100) as decimal(10,2))
	 					End as [% 61 To 90 Days],
						Sum(IsNull([> 90 Days],0.00)) as [> 90 Days],	      
						Case When Sum(IsNull([Total Open],0.00)) = 0.00 Then
							0
	 					Else
							cast((Sum(IsNull([> 90 Days],0.00))/Sum(IsNull([Total Open],0.00)) * 100) as decimal(10,2))
	 					End as [% > 90 Days],
	 					Sum(IsNull([Total Open],0.00)) as [Total Open],
	 					cast((select sum(IsNull(a.[Total Open Amount],0.00)) from #TempReport a where a.[Days Open] >= @MinThreshold)/Sum(IsNull([Total Open],0.00)) as decimal (10,2)) as [% >= X Days]

				From     #TempSummary

			) as TempSummary
	Order By [Total Open] ASC
	  
	 
	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResults'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResults'
	End

	Exec (@SQL)

	Set NoCount Off


GO
GRANT EXECUTE ON  [dbo].[WatchDog_ARAgingSummary] TO [public]
GO
