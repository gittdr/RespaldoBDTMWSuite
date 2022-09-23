SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_CreditLimit] 
(
	@MinThreshold float = 100,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalCreditLimit',
	@WatchName varchar(255) = 'CreditLimit',
	@ThresholdFieldName varchar(255) = 'Dollars',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@OnlyCustomerID varchar(255) = '',
	@DeductCurrentOrderRevenueYN varchar(1) = 'N',
	@Mode varchar(10) = 'Percent' 	
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

SET @OnlyCustomerID= ',' + ISNULL(@OnlyCustomerID,'') + ','

Exec WatchDogPopulateSessionIDParamaters 'Revenue',@WatchName 

select 	cmp_id,
	cmp_name,
	cmp_contact,
	cmp_primaryphone,
	cmp_primaryphoneext,
	convert(money, 0.00) AS OrderRevenue,
        convert(money, 0.00) AS CreditAvailableAfterCurrentOrders,
       	cmp_creditlimit AS [Credit Limit],
       	cmp_creditavail as [Credit Available],
	    cmp_creditavail_update
into   	#TempResults	
From   	company (NOLOCK)
WHERE 	(@OnlyCustomerID =',,' or CHARINDEX(',' + cmp_id + ',', @OnlyCustomerID) >0)
	AND cmp_creditavail is not null
	AND cmp_creditlimit >0
    AND cmp_billto = 'Y'


SELECT 	ord_billto, 
		SUM(ISNULL(dbo.fnc_TMWRN_Revenue('Order',DEFAULT,DEFAULT,DEFAULT,ord_hdrnumber,DEFAULT,DEFAULT,'','','','','','','','',''),0)) AS Revenue
INTO 	#TempResultsStep2
FROM 	OrderHeader (NOLOCK) Join #TempResults on cmp_id=ord_billto
where  	ord_status NOT IN ('CAN','CMP')
       	And (@OnlyCustomerID =',,' or CHARINDEX(',' + ord_billto + ',', @OnlyCustomerID) >0)
		AND ord_startdate >cmp_creditavail_update
group by ord_billto

Update #TempResults
SET OrderRevenue = Revenue
FROM #TempResultsStep2, #TempResults
WHERE ord_billto = cmp_id

IF @DeductCurrentOrderRevenueYN = 'Y'
BEGIN
	Update #TempResults
	SET CreditAvailableAfterCurrentOrders = ([Credit Available] - OrderRevenue)
	FROM #TempResults
END
ELSE
BEGIN
Update #TempResults
	SET CreditAvailableAfterCurrentOrders = ([Credit Available])
	FROM #TempResults
END

If @Mode = 'Percent'
	BEGIN
		IF @DeductCurrentOrderRevenueYN = 'Y'
			DELETE From #TempResults WHERE CreditAvailableAfterCurrentOrders > (@MinThreshold * [Credit Limit])
		ELSE
			DELETE From #TempResults WHERE [Credit Available] > (@MinThreshold * [Credit Limit])
	END
	ELSE
	BEGIN
		IF @DeductCurrentOrderRevenueYN = 'Y'
			DELETE From #TempResults WHERE CreditAvailableAfterCurrentOrders > @MinThreshold
		ELSE
			DELETE From #TempResults WHERE [Credit Available] > @MinThreshold
	END
       
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
