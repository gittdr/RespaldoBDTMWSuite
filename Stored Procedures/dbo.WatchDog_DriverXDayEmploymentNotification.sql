SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_DriverXDayEmploymentNotification] 
(
	@MinThreshold float = -1,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalDriverXDayEmploymentNotification',
	@WatchName varchar(255) = 'DriverXDayEmploymentNotification',
	@ThresholdFieldName varchar(255) = 'Days',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@OnlyDrvType1 varchar(50)='',
	@OnlyDrvType2 varchar(50)='',
	@OnlyDrvType3 varchar(50)='',
	@OnlyDrvType4 varchar(50)='',
	@NotificationDays int = 7 
)

As

Set NoCount On

/*
Procedure Name:    WatchDog_DriverXDayEmploymentNotification
Author/CreateDate: Lori Brickley / 5-6-2005
Purpose: 	    Returns Drivers who are at x Days of Employment
				notifies x minutes in advance
Revision History:
*/

/*
if not exists (select WatchName from WatchDogItem where WatchName = 'DriverXDayEmploymentNotification')
INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
 VALUES ('DriverXDayEmploymentNotification','12/30/1899','12/30/1899','WatchDog_DriverXDayEmploymentNotification','','',0,0,'','','','','',1,0,'','','')
*/

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

SET @OnlyDrvType1= ',' + ISNULL(@OnlyDrvType1,'') + ','
SET @OnlyDrvType2= ',' + ISNULL(@OnlyDrvType2,'') + ','
SET @OnlyDrvType3= ',' + ISNULL(@OnlyDrvType3,'') + ','
SET @OnlyDrvType4= ',' + ISNULL(@OnlyDrvType4,'') + ','

select 	mpp_id as [Driver ID],
		mpp_firstname as [First Name],
		mpp_lastname as [Last Name],
		mpp_hiredate as [Hire Date]
		--cast(cast(month(mpp_hiredate) as varchar(2))+ '/' + cast(day(mpp_hiredate) as varchar(2))+ '/' + cast(year(getdate()) as varchar(4)) as datetime) as [Anniversary Date],
		--datediff(yyyy,mpp_hiredate,cast(cast(month(mpp_hiredate) as varchar(2))+ '/' + cast(day(mpp_hiredate) as varchar(2))+ '/' + cast(year(getdate()) as varchar(4)) as datetime)) as [Upcoming Anniversary Year]
into #TempResults
from manpowerprofile (NOLOCK)
WHERE 	mpp_terminationdt>getdate()
	AND (@OnlyDrvType1 =',,' or CHARINDEX(',' + mpp_type1 + ',', @OnlyDrvType1) >0)
	AND (@OnlyDrvType2 =',,' or CHARINDEX(',' + mpp_type2 + ',', @OnlyDrvType2) >0)
	AND	(@OnlyDrvType3 =',,' or CHARINDEX(',' + mpp_type3 + ',', @OnlyDrvType3) >0)
	AND	(@OnlyDrvType4 =',,' or CHARINDEX(',' + mpp_type4 + ',', @OnlyDrvType4) >0)
	AND	dateadd(day, @MinThreshold, mpp_hiredate) >= getdate()
	AND dateadd(day, @MinThreshold, mpp_hiredate) <= dateadd(day,@NotificationDays,getdate())
		
order by mpp_hiredate

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
