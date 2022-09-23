SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_OrderRatingDiscrepancy] 
(
	@MinThreshold float = 1.25,
	@MinsBack int=-20,
	@TempTableName varchar(255) = '##WatchDogGlobalOrderRatingDiscrepency',
	@WatchName varchar(255) = 'OrderRatingDiscrepency',
	@ThresholdFieldName varchar(255) = 'OrderRatingDiscrepency',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@RevType1 varchar(140)='',
	@RevType2 varchar(140)='',
	@RevType3 varchar(140)='',
	@RevType4 varchar(140)='',
	@ExcludeBillToOtherType1 varchar(255)='',
	@ExcludeBillToID varchar(255)='',
	@ExcludeUpdatedBy varchar(255)=''
)
 
As
 
	set nocount on
	 
	/*
	Procedure Name:    WatchDog_OrderRatingDiscrepancy
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
	Set @ExcludeBillToOtherType1 = ',' + RTrim(ISNULL(@ExcludeBillToOtherType1,'')) + ','
	Set @ExcludeBillToID = ',' + RTrim(ISNULL(@ExcludeBillToID,'')) + ','
	Set @ExcludeUpdatedBy = ',' + RTrim(ISNULL(@ExcludeUpdatedBy,'')) + ','
	 
	Select ord_number as [Order #],
		ord_billto as [Bill To ID],
		[Bill To] = (select cmp_name from company (NOLOCK) where cmp_id = ord_billto), 
		cast(IsNull(ord_totalcharge,0) as decimal(15,2)) as [Total Charge],
		cast(IsNull(ord_charge,0) as decimal(15,2)) as [Line Haul],
		cast(IsNull(ord_accessorial_chrg,0) as decimal(15,2)) as [Accessorial],
		tar_number as [Tariff Number],
		IsNull((select tar_rate from tariffheader th (NOLOCK) where th.tar_number = orderheader.tar_number),0) as [Tariff Rate],
		(select cht_rateunit from tariffheader th (NOLOCK) where th.tar_number = orderheader.tar_number) as [Tariff Rate Unit],
		ord_rate as [Order Rate],
		ord_rateunit as [Order Rate Unit],
		ord_invoicestatus as [Invoice Status],
		ord_bookdate as [Book Date],
	    ord_bookedby as [Booked By], 
	    ord_revtype1 as RevType1, 
        ord_revtype2 as RevType2, 
        ord_revtype3 as RevType3, 
        ord_revtype4 as RevType4 
	into   #TempResults
	From   orderheader (NOLOCK) Left Join Company (NOLOCK) On Company.cmp_id = orderheader.ord_billto
	Where  ord_bookdate >= DateAdd(mi,@MinsBack,GetDate()) 
		And (
				IsNull(tar_number,0) = 0 
				OR 
				IsNull(ord_rate_type,0)=1 
				OR 
				(	ord_rate <> IsNull((select tar_rate from tariffheader th (NOLOCK) where th.tar_number = orderheader.tar_number),0) 
					And 
					ord_rate <> IsNull((select tar_totlh_mincharge from tariffheader th (NOLOCK) where th.tar_number = orderheader.tar_number),0)
				)
			)
		And IsNull(tar_number,0) Not In (select tar_number from tariffrowcolumn (NOLOCK) where IsNull(orderheader.ord_rate_type,0) <> 1 )
		And not exists (select ord_hdrnumber from invoiceheader (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber) 
		And ord_status <> 'CAN'
		And ord_invoicestatus <> 'XIN'
		And (@RevType1 =',,' or CHARINDEX(',' + ord_revtype1 + ',', @RevType1) >0)
		AND (@RevType2 =',,' or CHARINDEX(',' + ord_revtype2 + ',', @RevType2) >0)
		AND (@RevType3 =',,' or CHARINDEX(',' + ord_revtype3 + ',', @RevType3) >0)
		AND (@RevType4 =',,' or CHARINDEX(',' + ord_revtype4 + ',', @RevType4) >0)
		AND (@ExcludeBillToOtherType1 = ',,' OR Not (CHARINDEX(',' + cmp_othertype1 + ',', @ExcludeBillToOtherType1) > 0))      
		AND (@ExcludeBillToID = ',,' OR Not (CHARINDEX(',' + ord_billto + ',', @ExcludeBillToID) > 0))          
		AND (@ExcludeUpdatedBy = ',,' OR Not (CHARINDEX(',' + last_updateby + ',', @ExcludeUpdatedBy) > 0))      
	order by mov_number,ord_hdrnumber 
	
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
	 
	set nocount off
	 
GO
GRANT EXECUTE ON  [dbo].[WatchDog_OrderRatingDiscrepancy] TO [public]
GO
