SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE Proc [dbo].[WatchDog_ZeroRatedCommodity]
(
	@MinThreshold float = 100,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalZeroRatedCommodity',
	@WatchName varchar(255) = 'ZeroRatedCommodity',
	@ThresholdFieldName varchar(255) = 'ZeroRatedCommodity',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@ThresholdType varchar(255) = 'ZeroRatedCommodity', --Choices:Dollars,PercentofRevenue
	@RevType1 varchar(140)='',
	@RevType2 varchar(140)='',
	@RevType3 varchar(140)='',
	@RevType4 varchar(140)='',
	@OnlyCommodity varchar(140)='',
	@ExcludeCommodity varchar(140)='',
	@OrderStatus varchar(255)='STD'
)

As

set nocount on

/*
Procedure Name:    WatchDog_ZeroRatedCommodity
Author/CreateDate: Lori Brickley / 5-19-2005
Purpose: 	   

*/



/*
if not exists (select WatchName from WatchDogItem where WatchName = 'ZeroRatedCommodity')
INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
 VALUES ('ZeroRatedCommodity','12/30/1899','12/30/1899','WatchDog_ZeroRatedCommodity','','',0,0,'','','','','',1,0,'','','')
*/

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

Set @RevType1= ',' + RTrim(ISNULL(@RevType1,'')) + ','
Set @RevType2= ',' + RTrim(ISNULL(@RevType2,'')) + ','
Set @RevType3= ',' + RTrim(ISNULL(@RevType3,'')) + ','
Set @RevType4= ',' + RTrim(ISNULL(@RevType4,'')) + ','
Set @OrderStatus= ',' + RTrim(ISNULL(@OrderStatus,'')) + ','
Set @OnlyCommodity= ',' + RTrim(ISNULL(@OnlyCommodity,'')) + ','
Set @ExcludeCommodity= ',' + RTrim(ISNULL(@ExcludeCommodity,'')) + ','



SELECT DISTINCT 
	stops.ord_hdrnumber,
	freightdetail.cmd_code as [Commodity Code],
	orderheader.ord_startdate,
	orderheader.ord_status,
	fgt_quantity,fgt_ratingunit
INTO #TempResults
FROM freightdetail (NOLOCK)
	JOIN stops (NOLOCK) ON freightdetail.stp_number = stops.stp_number
	JOIN orderheader (NOLOCK) ON orderheader.ord_hdrnumber = stops.ord_hdrnumber
WHERE fgt_quantity=0 
	AND fgt_ratingunit <>'UNK'
	AND orderheader.last_updatedate > Dateadd(mi,@MinsBack,GetDate())	
	AND (@OrderStatus =',,' OR CHARINDEX(',' + orderheader.ord_status + ',', @OrderStatus) >0)	
	AND (@OnlyCommodity =',,' OR CHARINDEX(',' + freightdetail.cmd_code + ',', @OnlyCommodity) >0)
	AND (@ExcludeCommodity =',,' OR CHARINDEX(',' + orderheader.cmd_code + ',', @ExcludeCommodity) =0)		
ORDER BY stops.ord_hdrnumber



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
