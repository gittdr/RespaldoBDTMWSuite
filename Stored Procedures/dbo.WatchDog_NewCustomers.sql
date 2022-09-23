SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_NewCustomers] 
(
	@MinThreshold float = 100,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalNewCustomers',
	@WatchName varchar(255) = 'NewCustomers',
	@ThresholdFieldName varchar(255) = 'NewCustomers',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@RevType1 varchar(140)='',
	@RevType2 varchar(140)='',
	@RevType3 varchar(140)='',
	@RevType4 varchar(140)='',
	@CustomerType varchar(140)='BillTo', --BillTo, Shipper, Consingee
	@CustomerID varchar(140)=''
)

As

	Set NoCount On

	/*
	Procedure Name:    WatchDog_NewCustomers
	Author/CreateDate: Brent Keeton / 6-15-2004
	Purpose: 	    

	Revision History:
	*/


	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	Set @RevType1= ',' + RTrim(ISNULL(@RevType1,'')) + ','
	Set @RevType2= ',' + RTrim(ISNULL(@RevType2,'')) + ','
	Set @RevType3= ',' + RTrim(ISNULL(@RevType3,'')) + ','
	Set @RevType4= ',' + RTrim(ISNULL(@RevType4,'')) + ','
	Set @CustomerID= ',' + RTrim(ISNULL(@CustomerID,'')) + ','


	select	cmp_id as [Customer ID],
			cmp_name as [Customer Name],
			cmp_updatedby as [Updated By],
			cmp_createdate as [Date Created],
			cmp_revtype1 as [RevType1],
			cmp_revtype2 as [RevType2],
			cmp_revtype3 as [RevType3],
			cmp_revtype4 as [RevType4],
			CASE 
					WHEN @CustomerType like '%BillTo%' and cmp_billto = 'Y'
						Then 'Y'
					WHEN @CustomerType like '%Shipper%' and cmp_shipper = 'Y'
						Then 'Y'
					WHEN @CustomerType like '%Consingee%' and cmp_consingee = 'Y'
						Then 'Y'
					ELSE
						'N'
			END AS NewCustomer
	into   #TempResults	
	From   company (NOLOCK)
	where  cmp_createdate >= DateAdd(mi,@MinsBack,GetDate())
		And (@RevType1 =',,' or CHARINDEX(',' + cmp_revtype1 + ',', @RevType1) >0)
		AND (@RevType2 =',,' or CHARINDEX(',' + cmp_revtype2 + ',', @RevType2) >0)
		AND (@RevType3 =',,' or CHARINDEX(',' + cmp_revtype3 + ',', @RevType3) >0)
		AND (@RevType4 =',,' or CHARINDEX(',' + cmp_revtype4 + ',', @RevType4) >0)
	       		
	   
	DELETE FROM #TempResults where NewCustomer = 'N'

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
