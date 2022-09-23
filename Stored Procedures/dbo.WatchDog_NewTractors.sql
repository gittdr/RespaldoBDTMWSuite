SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_NewTractors] 
(	
	@MinThreshold float = 100,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalNewTractors',
	@WatchName varchar(255) = 'NewTractors',
	@ThresholdFieldName varchar(255) = 'NewTractors',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	--Additional/Optional Parameters
	@OnlyTrcType1 varchar(140)='',
	@OnlyTrcType2 varchar(140)='',
	@OnlyTrcType3 varchar(140)='',
	@OnlyTrcType4 varchar(140)=''	
)

As

Set NoCount On

/*
Procedure Name:    WatchDog_NewTractors
Author/CreateDate: Lori Brickley / 5-6-2005
Purpose: 	    Returns tractors entered into
				file maintenance in the last x minutes

Revision History:
*/


/*
if not exists (select WatchName from WatchDogItem where WatchName = 'NewTractors')
INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
 VALUES ('NewTractors','12/30/1899','12/30/1899','WatchDog_NewTractors','','',0,0,'','','','','',1,0,'','','')

*/

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

Set @OnlyTrcType1= ',' + RTrim(ISNULL(@OnlyTrcType1,'')) + ','
Set @OnlyTrcType2= ',' + RTrim(ISNULL(@OnlyTrcType2,'')) + ','
Set @OnlyTrcType3= ',' + RTrim(ISNULL(@OnlyTrcType3,'')) + ','
Set @OnlyTrcType4= ',' + RTrim(ISNULL(@OnlyTrcType4,'')) + ','

select 	trc_number as [Tractor ID],
       	trc_updatedby as [Updated By],
       	trc_createdate as [Date Created],
       	trc_type1 as [TrcType1],
       	trc_type2 as [TrcType2],
       	trc_type3 as [TrcType3],
       	trc_type4 as [TrcType4]
into   #TempResults	
From   tractorprofile (NOLOCK)
where  trc_createdate >= DateAdd(mi,@MinsBack,GetDate())
       And (@OnlyTrcType1 =',,' or CHARINDEX(',' + trc_type1 + ',', @OnlyTrcType1) >0)
       AND (@OnlyTrcType2 =',,' or CHARINDEX(',' + trc_type2 + ',', @OnlyTrcType2) >0)
       AND (@OnlyTrcType3 =',,' or CHARINDEX(',' + trc_type3 + ',', @OnlyTrcType3) >0)
       AND (@OnlyTrcType4 =',,' or CHARINDEX(',' + trc_type4 + ',', @OnlyTrcType4) >0)
       		
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
