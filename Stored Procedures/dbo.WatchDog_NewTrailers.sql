SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_NewTrailers] 
(	
	@MinThreshold float = 100,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalNewTrailers',
	@WatchName varchar(255) = 'NewTrailers',
	@ThresholdFieldName varchar(255) = 'NewTrailers',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	--Additional/Optional Parameters
	@OnlyTrlType1 varchar(140)='',
	@OnlyTrlType2 varchar(140)='',
	@OnlyTrlType3 varchar(140)='',
	@OnlyTrlType4 varchar(140)=''	
)

As

Set NoCount On

/*
Procedure Name:    WatchDog_NewTrailers
Author/CreateDate: Lori Brickley / 5-6-2005
Purpose: 	    Returns trailers entered into
				file maintenance in the last x minutes

Revision History:
*/


/*
if not exists (select WatchName from WatchDogItem where WatchName = 'NewTrailers')
INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
 VALUES ('NewTrailers','12/30/1899','12/30/1899','WatchDog_NewTrailers','','',0,0,'','','','','',1,0,'','','')

*/

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

Set @OnlyTrlType1= ',' + RTrim(ISNULL(@OnlyTrlType1,'')) + ','
Set @OnlyTrlType2= ',' + RTrim(ISNULL(@OnlyTrlType2,'')) + ','
Set @OnlyTrlType3= ',' + RTrim(ISNULL(@OnlyTrlType3,'')) + ','
Set @OnlyTrlType4= ',' + RTrim(ISNULL(@OnlyTrlType4,'')) + ','

select 	Trl_number as [Tractor ID],
       	Trl_updatedby as [Updated By],
       	Trl_createdate as [Date Created],
       	Trl_type1 as [TrlType1],
       	Trl_type2 as [TrlType2],
       	Trl_type3 as [TrlType3],
       	Trl_type4 as [TrlType4],
		trl_licnum as [License Number],
		trl_year as [Year],
		trl_make as [Make],
		trl_ilt_scac as [ILT Scac],
		Trl_number as [Trailer ID]

into   #TempResults	
From   trailerprofile (NOLOCK)
where  Trl_createdate >= DateAdd(mi,@MinsBack,GetDate())
       And (@OnlyTrlType1 =',,' or CHARINDEX(',' + Trl_type1 + ',', @OnlyTrlType1) >0)
       AND (@OnlyTrlType2 =',,' or CHARINDEX(',' + Trl_type2 + ',', @OnlyTrlType2) >0)
       AND (@OnlyTrlType3 =',,' or CHARINDEX(',' + Trl_type3 + ',', @OnlyTrlType3) >0)
       AND (@OnlyTrlType4 =',,' or CHARINDEX(',' + Trl_type4 + ',', @OnlyTrlType4) >0)
       		
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
