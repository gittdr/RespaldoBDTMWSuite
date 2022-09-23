SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



 
CREATE Proc [dbo].[WatchDog_MissingFuelSurcharge] 
(
	@MinThreshold float = 0,
	@MinsBack int=-20,
	@TempTableName varchar(255) = '##WatchDogGlobalMissingFuelSurcharge',
	@WatchName varchar(255)='MissingFuelSurcharge',
	@ThresholdFieldName varchar(255) = 'NA',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar(50) = 'Selected',
    @RevType1 varchar(255)='',
    @RevType2 varchar(255)='',
    @RevType3 varchar(255)='',
    @RevType4 varchar(255)='',
    @OrderStatus varchar(140)='PLN,STD,CMP',
 	@ExcludeBillToID varchar(255)='',
	@OriginState varchar(255)='',
	@DestState varchar(255)='',
	@BookedBy varchar(255)='',
	@OnlyInvoiceStatus varchar(255)='',
	@InvoicedOnlyYN varchar(1) = 'N'
)      
 
As
 
	Set NoCount On
	 
	 
	/*
	Procedure Name:    WatchDog_MissingFuelSurcharge
	Author/CreateDate: Brent Keeton / 6-15-2004
	Purpose:    Returns orders with no fuel surcharge assuming that charge type for fuel surcharge
				is of form 'FUEL%' or charge type description includes 'FUEL'
	Revision History:
6/5/2008:	alert fails to properly classify trips with fuel surcharge between zero and $0.99; corrected
			by implementing @MinThreshold to allow client to specify limit below which to report

	*/
	 
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	Set @RevType1= ',' + ISNULL(@RevType1,'') + ','
	Set @RevType2= ',' + ISNULL(@RevType2,'') + ','
	Set @RevType3= ',' + ISNULL(@RevType3,'') + ','
	Set @RevType4= ',' + ISNULL(@RevType4,'') + ','
	Set @OrderStatus= ',' + ISNULL(@OrderStatus,'') + ','
	Set @ExcludeBillToID =  ',' + ISNULL(@ExcludeBillToID,'') + ','
	Set @OriginState =  ',' + ISNULL(@OriginState,'') + ','
	Set @DestState =  ',' + ISNULL(@DestState,'') + ',' 
	Set @BookedBy =  ',' + ISNULL(@BookedBy,'') + ','  
	set @OnlyInvoiceStatus =  ',' + ISNULL(@OnlyInvoiceStatus,'') + ','  
	 
	SELECT ord_number as [Order #],
		ord_revtype1 as RevType1,
		ord_revtype2 as RevType2,
		ord_revtype3 as RevType3,
		ord_revtype4 as RevType4,
		last_updatedate as [Last Updated Date],
		ord_status as [Order Status],
		ord_consignee as [Consignee],
		ord_billto as [Bill To ID],
		ord_originstate as [Origin State],
		ord_deststate as [Dest State]
	INTO   #TempResults
	FROM   orderheader (NOLOCK)
	WHERE	last_updatedate >= DateAdd(mi,@MinsBack,GetDate())
		And ord_invoicestatus <> 'XIN'
		And (@RevType1 =',,' or CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
		AND (@RevType2 =',,' or CHARINDEX(',' + ord_revtype2+ ',', @RevType2) >0)
		AND (@RevType3 =',,' or CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
		AND (@RevType4 =',,' or CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
		And (@OrderStatus =',,' or CHARINDEX(',' + ord_status + ',', @OrderStatus) >0)
		And (@BookedBy =',,' or CHARINDEX(',' + ord_bookedby + ',', @BookedBy) >0)
		And (@ExcludeBillToID = ',,' OR Not (CHARINDEX(',' + ord_billto + ',', @ExcludeBillToID) > 0)) 
	--	sum all charge types like 'FUEL%' or that have 'FUEL' in the description; if <= ZERO, include the trip
	--  modified 6/5/2008 by adding @MinThreshold parameter value to the comparison
		And IsNull((	SELECT IsNull(sum(ivd_charge),0.00)
						FROM  invoicedetail (NOLOCK), 
							chargetype (NOLOCK)
						WHERE invoicedetail.ord_hdrnumber = orderheader.ord_hdrnumber
							And invoicedetail.cht_itemcode=chargetype.cht_itemcode
							AND (
									Upper(chargetype.cht_itemcode) like 'FUEL%'
									OR
									CharIndex('FUEL', cht_description)>0
								)
							and ivd_charge is Not Null
				),0) <= @MinThreshold
		AND (
				(@InvoicedOnlyYN = 'N') 
			OR 
				(Exists (	SELECT ivh_hdrnumber
							FROM invoiceheader (NOLOCK)
							WHERE invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber
								And (@OnlyInvoiceStatus =',,' or CHARINDEX(',' + ivh_invoicestatus + ',', @OnlyInvoiceStatus) >0) 
						)
				)
			)
		And (@OriginState=',,' or CHARINDEX(',' + ord_originstate + ',', @OriginState) >0)
		And (@DestState=',,' or CHARINDEX(',' + ord_deststate + ',', @DestState) >0)
	 
	 
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
GRANT EXECUTE ON  [dbo].[WatchDog_MissingFuelSurcharge] TO [public]
GO
