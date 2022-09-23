SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_NewDrivers] 
(	
	@MinThreshold float = 100,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalNewDrivers',
	@WatchName varchar(255) = 'NewDrivers',
	@ThresholdFieldName varchar(255) = 'NewDrivers',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	--Additional/Optional Parameters
	@OnlyDrvType1 varchar(140)='',
	@OnlyDrvType2 varchar(140)='',
	@OnlyDrvType3 varchar(140)='',
	@OnlyDrvType4 varchar(140)='',
	@ExcludeDrvType1 varchar(255)='',
	@ExcludeDrvType2 varchar(255)='',
	@ExcludeDrvType3 varchar(255)='',
	@ExcludeDrvType4 varchar(255)=''
)

As

Set NoCount On

/*
Procedure Name:    WatchDog_NewDrivers
Author/CreateDate: Lori Brickley / 4-13-2005
Purpose: 	    Returns drivers entered into
				file maintenance in the last x minutes

Revision History:
*/


/*
if not exists (select WatchName from WatchDogItem where WatchName = 'NewDrivers')
INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
 VALUES ('NewDrivers','12/30/1899','12/30/1899','WatchDog_NewDrivers','','',0,0,'','','','','',1,0,'','','')

*/

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

Set @OnlyDrvType1= ',' + RTrim(ISNULL(@OnlyDrvType1,'')) + ','
Set @OnlyDrvType2= ',' + RTrim(ISNULL(@OnlyDrvType2,'')) + ','
Set @OnlyDrvType3= ',' + RTrim(ISNULL(@OnlyDrvType3,'')) + ','
Set @OnlyDrvType4= ',' + RTrim(ISNULL(@OnlyDrvType4,'')) + ','

Set @ExcludeDrvType1= ',' + RTrim(ISNULL(@ExcludeDrvType1,'')) + ','
Set @ExcludeDrvType2= ',' + RTrim(ISNULL(@ExcludeDrvType2,'')) + ','
Set @ExcludeDrvType3= ',' + RTrim(ISNULL(@ExcludeDrvType3,'')) + ','
Set @ExcludeDrvType4= ',' + RTrim(ISNULL(@ExcludeDrvType4,'')) + ','


select 	mpp_id as [Driver ID],
       	mpp_firstname as [First Name],
		mpp_lastname as [Last Name],
       	mpp_updatedby as [Updated By],
       	mpp_createdate as [Date Created],
       	mpp_type1 as [DrvType1],
       	mpp_type2 as [DrvType2],
       	mpp_type3 as [DrvType3],
       	mpp_type4 as [DrvType4]
into   #TempResults	
From   manpowerprofile (NOLOCK)
where  mpp_createdate >= DateAdd(mi,@MinsBack,GetDate())
       And (@OnlyDrvType1 =',,' or CHARINDEX(',' + mpp_type1 + ',', @OnlyDrvType1) >0)
       AND (@OnlyDrvType2 =',,' or CHARINDEX(',' + mpp_type2 + ',', @OnlyDrvType2) >0)
       AND (@OnlyDrvType3 =',,' or CHARINDEX(',' + mpp_type3 + ',', @OnlyDrvType3) >0)
       AND (@OnlyDrvType4 =',,' or CHARINDEX(',' + mpp_type4 + ',', @OnlyDrvType4) >0)
       And (@ExcludeDrvType1 = ',,' OR Not (CHARINDEX(',' + IsNull(mpp_type1,'') + ',', @ExcludeDrvType1) > 0)) 
       And (@ExcludeDrvType2 = ',,' OR Not (CHARINDEX(',' + IsNull(mpp_type2,'') + ',', @ExcludeDrvType2) > 0)) 
       And (@ExcludeDrvType3 = ',,' OR Not (CHARINDEX(',' + IsNull(mpp_type3,'') + ',', @ExcludeDrvType3) > 0)) 
       And (@ExcludeDrvType4 = ',,' OR Not (CHARINDEX(',' + IsNull(mpp_type4,'') + ',', @ExcludeDrvType4) > 0)) 
       		
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
