SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_DuplicateOrder]
(
	@MinThreshold float = 1,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalOrderConfirmation',
	@WatchName varchar(255)='WatchLargeMTMoves',
	@ThresholdFieldName varchar(255) = 'Order Confirmation',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@RevType1 varchar(140)='',
    @RevType2 varchar(140)='',
    @RevType3 varchar(140)='',
	@RevType4 varchar(140)='',
	@Shipper varchar(140)='',
	@Consignee varchar(140)='',
	@OrderedBy varchar(140)='',
	@BillTo varchar(140)=''
)
			
As

Set NoCount On

/*
Procedure Name:    WatchDog_DuplicateOrder
Author/CreateDate: Lori Brickley / 01-20-2005
Purpose: 	   Returns orders updated in the last x minutes 
				which are duplicates based on
				Bill To, Shipper, Consignee, and Start Date.
Revision History:  
*/

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

--Standard Parameter Initialization
Set @RevType1= ',' + ISNULL(@RevType1,'') + ','
Set @RevType2= ',' + ISNULL(@RevType2,'') + ','
Set @RevType3= ',' + ISNULL(@RevType3,'') + ','
Set @RevType4= ',' + ISNULL(@RevType4,'') + ','
Set @Shipper= ',' + ISNULL(@Shipper,'') + ','
Set @Consignee= ',' + ISNULL(@Consignee,'') + ','
Set @BillTo= ',' + ISNULL(@BillTo,'') + ','

--Create SQL and return results into #TempResults
Select ord_billto as [Customer ID],
       cmpbillto.cmp_name as Customer,
       ord_shipper as [Shipper ID],
       cmpshipper.cmp_name as [Shipper],
       ord_consignee as [Consignee ID],
       cmpconsignee.cmp_name as [Consignee],
	   ord_startdate as [Order Start],
	   count(ord_startdate) as [Count]
into   #TempResultsStep1
From   orderheader (NOLOCK) 
	   Left Join company  cmpshipper (NOLOCK)  On ord_shipper = cmpshipper.cmp_id
	   Left Join company cmpconsignee (NOLOCK)  On ord_billto = cmpconsignee.cmp_id
	   Left Join company cmpbillto (NOLOCK) On ord_billto = cmpbillto.cmp_id
Where  (@RevType1 =',,' or CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
       AND (@RevType2 =',,' or CHARINDEX(',' + ord_revtype2 + ',', @RevType2) >0)
       AND (@RevType3 =',,' or CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
       AND (@RevType4 =',,' or CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
       And (@BillTo =',,' or CHARINDEX(',' + ord_billto + ',', @BillTo) >0)
       And (@Shipper =',,' or CHARINDEX(',' + ord_shipper + ',', @Shipper) >0)       
       And (@Consignee =',,' or CHARINDEX(',' + ord_consignee + ',', @Consignee) >0)       
       And last_updatedate >= DateAdd(mi,@MinsBack,GetDate())
	   And ord_status <> 'CAN'
group by ord_billto, cmpbillto.cmp_name, ord_shipper, cmpshipper.cmp_name,
       ord_consignee, cmpconsignee.cmp_name, ord_startdate


SELECT 	[Customer ID],
       	Customer,
       	[Shipper ID],
       	[Shipper],
       	[Consignee ID],
       	[Consignee],
	   	[Order Start],
		ord_hdrnumber as [Order],
		ord_bookedby as [Booked By],
		ord_status as [Status]
into #TempResults
FROM #TempResultsStep1 
	JOIN orderheader (NOLOCK) ON [Customer ID] = ord_billto 
		AND [Shipper ID] = ord_shipper 
		AND [Consignee ID] = ord_consignee
		AND [Order Start] = ord_startdate
WHERE count > 1

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
GRANT EXECUTE ON  [dbo].[WatchDog_DuplicateOrder] TO [public]
GO
