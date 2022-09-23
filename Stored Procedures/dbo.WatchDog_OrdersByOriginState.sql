SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_OrdersByOriginState] 
(
	@MinThreshold float = 1,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalOrdersByOriginState',
	@WatchName varchar(255)='WatchOrdersByOriginState',
	@ThresholdFieldName varchar(255) = 'OrdersByOriginState',
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
	@BillTo varchar(140)='',
	@OriginState varchar(255)='',
	@OrderStatus varchar(140)='PLN,AVL,STD,DSP,CMP'
)
						
As

	Set NoCount On

	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	Set @RevType1= ',' + ISNULL(@RevType1,'') + ','
	Set @RevType2= ',' + ISNULL(@RevType2,'') + ','
	Set @RevType3= ',' + ISNULL(@RevType3,'') + ','
	Set @RevType4= ',' + ISNULL(@RevType4,'') + ','
	Set @BillTo= ',' + ISNULL(@BillTo,'') + ','
	Set @Shipper= ',' + ISNULL(@Shipper,'') + ','
	Set @Consignee= ',' + ISNULL(@Consignee,'') + ','
	Set @OrderedBy= ',' + ISNULL(@OrderedBy,'') + ','
	Set @OrderStatus= ',' + ISNULL(@OrderStatus,'') + ','
	Set @OriginState= ',' + ISNULL(@OriginState,'') + ','	

	--Create SQL and return results into #TempResults
	Select  @billto as [BillTo],
			@Shipper as [Shipper],
			@Consignee as [Consignee],
			@OrderedBy as [OrderedBy],
			ord_originstate as [Origin State],
			Count(*) as [Volume]
	INTO   #TempResults
	FROM   orderheader (NOLOCK)
	Where (@RevType1 =',,' or CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
		AND (@RevType2 =',,' or CHARINDEX(',' + ord_revtype2 + ',', @RevType2) >0)
	    AND (@RevType3 =',,' or CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
	    AND (@RevType4 =',,' or CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
	    And (@OrderStatus =',,' or CHARINDEX(',' + ord_status + ',', @OrderStatus) >0)
	    And (@BillTo =',,' or CHARINDEX(',' + ord_billto + ',', @BillTo) >0)
	    And (@Shipper =',,' or CHARINDEX(',' + ord_shipper + ',', @Shipper) >0)       
	    And (@Consignee =',,' or CHARINDEX(',' + ord_consignee + ',', @Consignee) >0)       
	    And (@OrderedBy =',,' or CHARINDEX(',' + ord_company + ',', @OrderedBy) >0)  
	    And (@OrderStatus =',,' or CHARINDEX(',' + ord_status + ',', @OrderStatus) >0) 
	    And (@OriginState =',,' or CHARINDEX(',' + ord_originstate + ',', @OriginState) >0)      
	    And ord_startdate >= DateAdd(mi,@MinsBack,GetDate())
	GROUP BY ord_originstate
	Order by ord_originstate
			
	      
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
