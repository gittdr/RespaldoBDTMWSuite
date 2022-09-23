SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_NewRecruits] 
(	
	@MinThreshold float = 100,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalNewRecruits',
	@WatchName varchar(255) = 'NewRecruits',
	@ThresholdFieldName varchar(255) = 'NewRecruits',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	--Additional/Optional Parameters
	@OnlyRecType1 varchar(140)='',
	@OnlyRecType2 varchar(140)='',
	@OnlyRecType3 varchar(140)='',
	@OnlyRecType4 varchar(140)='',
	@ExcludeRecType1 varchar(255)='',
	@ExcludeRecType2 varchar(255)='',
	@ExcludeRecType3 varchar(255)='',
	@ExcludeRecType4 varchar(255)=''
)

As

Set NoCount On

/*
Procedure Name:    WatchDog_NewRecruits
Author/CreateDate: Tricia Noble / 2011/1/6
Purpose: 	    Returns recruits entered into file maintenance recruiting module in the last x minutes
Revision History:
*/


/*
if not exists (select WatchName from WatchDogItem where WatchName = 'NewRecruits')
INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
 VALUES ('NewRecruits','12/30/1899','12/30/1899','WatchDog_NewRecruits','','',0,0,'','','','','',1,0,'','','')

*/

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

Set @OnlyRecType1= ',' + RTrim(ISNULL(@OnlyRecType1,'')) + ','
Set @OnlyRecType2= ',' + RTrim(ISNULL(@OnlyRecType2,'')) + ','
Set @OnlyRecType3= ',' + RTrim(ISNULL(@OnlyRecType3,'')) + ','
Set @OnlyRecType4= ',' + RTrim(ISNULL(@OnlyRecType4,'')) + ','

Set @ExcludeRecType1= ',' + RTrim(ISNULL(@ExcludeRecType1,'')) + ','
Set @ExcludeRecType2= ',' + RTrim(ISNULL(@ExcludeRecType2,'')) + ','
Set @ExcludeRecType3= ',' + RTrim(ISNULL(@ExcludeRecType3,'')) + ','
Set @ExcludeRecType4= ',' + RTrim(ISNULL(@ExcludeRecType4,'')) + ','


select 	rec_id+0 as [Driver ID],
       	Rec_firstname as [First Name],
		Rec_lastname as [Last Name],
       	Rec_createdby as [Updated By],
       	Rec_createdon as [Date Created],
       	Rec_type1 as [RecType1],
       	Rec_type2 as [RecType2],
       	Rec_type3 as [RecType3],
       	Rec_type4 as [RecType4]
into   #TempResults	
From   recruitheader (NOLOCK)
where  Rec_createdon >= DateAdd(mi,@MinsBack,GetDate())
       And (@OnlyRecType1 =',,' or CHARINDEX(',' + Rec_type1 + ',', @OnlyRecType1) >0)
       AND (@OnlyRecType2 =',,' or CHARINDEX(',' + Rec_type2 + ',', @OnlyRecType2) >0)
       AND (@OnlyRecType3 =',,' or CHARINDEX(',' + Rec_type3 + ',', @OnlyRecType3) >0)
       AND (@OnlyRecType4 =',,' or CHARINDEX(',' + Rec_type4 + ',', @OnlyRecType4) >0)
       And (@ExcludeRecType1 = ',,' OR Not (CHARINDEX(',' + IsNull(Rec_type1,'') + ',', @ExcludeRecType1) > 0)) 
       And (@ExcludeRecType2 = ',,' OR Not (CHARINDEX(',' + IsNull(Rec_type2,'') + ',', @ExcludeRecType2) > 0)) 
       And (@ExcludeRecType3 = ',,' OR Not (CHARINDEX(',' + IsNull(Rec_type3,'') + ',', @ExcludeRecType3) > 0)) 
       And (@ExcludeRecType4 = ',,' OR Not (CHARINDEX(',' + IsNull(Rec_type4,'') + ',', @ExcludeRecType4) > 0)) 
       		
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
