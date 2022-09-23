SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_ExtremeInvoiceAmounts] 
(
	@MinThreshold float = 100,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalExtremeInvoiceAmounts',
	@WatchName varchar(255) = 'ExtremeInvoiceAmounts',
	@ThresholdFieldName varchar(255) = 'Charge',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@RevType1 varchar(140)='',
	@RevType2 varchar(140)='',
	@RevType3 varchar(140)='',
	@RevType4 varchar(140)='',
	@AmountType varchar(50)='Total',
	@InvoiceStatus varchar(255)='',
	@ThresholdDirection varchar(50)='Above'
)

As

	Set NoCount On

	/*
	Procedure Name:    WatchDog_ExtremeInvoiceAmounts
	Author/CreateDate: Brent Keeton / 6-15-2004
	Purpose: 	     To Return Extreme Invoice Amounts
				either below or above a certain threshold
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
	Set @InvoiceStatus= ',' + RTrim(ISNULL(@InvoiceStatus,'')) + ','

	Exec WatchDogPopulateSessionIDParamaters 'Revenue',@WatchName 

	select	ord_number as [Order #],
		mov_number as [Move #],
		ivh_invoicenumber as [Invoice #],
		ivh_shipper as [Shipper ID],
		(select cty_name from city (NOLOCK) Where cty_code = ivh_origincity) as [Origin City],
		ivh_consignee as [Consignee ID],
		(select cty_name from city (NOLOCK) Where cty_code = ivh_destcity) as [Destination City],
		(select cmp_name from company (NOLOCK) Where cmp_id = ivh_billto) as [BillTo],
		ivh_billto as [BillTo ID],
		Case @AmountType
			When 'Total' Then IsNull(dbo.fnc_TMWRN_Revenue('Invoice',default,default,default,default,default,ivh_hdrnumber,'','','','','','','','',''),0)
			When 'LineHaul' Then IsNull(dbo.fnc_TMWRN_Revenue('Invoice',default,default,default,default,default,ivh_hdrnumber,'','','','','','','','',''),0)
			When 'Accessorial' Then IsNull(dbo.fnc_TMWRN_Revenue('Invoice',default,default,default,default,default,ivh_hdrnumber,'','','','','','','','',''),0)
		End as Charge
	into   #TempResults	
	From   invoiceheader (NOLOCK)
	where  ivh_billdate >= DateAdd(mi,@MinsBack,GetDate())
		And ivh_invoicestatus <> 'CAN'
		And (@InvoiceStatus =',,' or CHARINDEX(',' + ivh_invoicestatus + ',', @InvoiceStatus) >0)
		AND (@RevType1 =',,' or CHARINDEX(',' + ivh_revtype1 + ',', @RevType1) >0)
		AND (@RevType2 =',,' or CHARINDEX(',' + ivh_revtype2 + ',', @RevType2) >0)
		AND (@RevType3 =',,' or CHARINDEX(',' + ivh_revtype3 + ',', @RevType3) >0)
		AND (@RevType4 =',,' or CHARINDEX(',' + ivh_revtype4 + ',', @RevType4) >0)
		AND (
				(@AmountType = 'Total' And @ThresholdDirection = 'Above' and ivh_totalcharge > @MinThreshold)
				Or
				(@AmountType = 'Total' And @ThresholdDirection = 'Below' and ivh_totalcharge < @MinThreshold)
				Or
				(@AmountType = 'LineHaul' And @ThresholdDirection = 'Above' and ivh_charge > @MinThreshold)  
				Or
				(@AmountType = 'LineHaul' And @ThresholdDirection = 'Below' and ivh_charge < @MinThreshold)    
				Or
				(@AmountType = 'Accessorial' And @ThresholdDirection = 'Above' and (ivh_totalcharge - ivh_charge) > @MinThreshold)  
				Or
				(@AmountType = 'Accessorial' And @ThresholdDirection = 'Below' and (ivh_totalcharge - ivh_charge) < @MinThreshold)    
			)  
	   
		  
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
