SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_MonitorFieldChange] 
(
	@MinThreshold float = 100,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogMonitorFieldChange',
	@WatchName varchar(255) = 'MonitorFieldChange',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@OnlyFieldList varchar(255) = 'Teamleader' 	
)

As

Set NoCount On

/*
Procedure Name:    WatchDog_MonitorFieldChange
Author/CreateDate: Lori Brickley / 4-7-2005
Purpose: 	     Returns a history of changes made to
				 fields in a table.

				 Handles:  anything triggered to enter a record in the
							table WatchdogMonitorFieldChange
Revision History:
*/

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

SET @OnlyFieldList= ',' + ISNULL(@OnlyFieldList,'') + ','

select 	TableName, 
		Field, 
		PreviousValue,
		UpdatedValue,
		Identifier = IdentifierField + ': '+ IdentifierValue,
		Updated = UpdatedBy + ' - ' + cast(UpdatedOn as varchar(20))
into   	#TempResults	
From   	WatchdogMonitorFieldChange (NOLOCK)
WHERE 	(@OnlyFieldList =',,' or CHARINDEX(',' + Field + ',', @OnlyFieldList) >0)
	AND DATEDIFF(m,UpdatedOn,GETDATE()) > @MinsBack  OR UpdatedOn IS NULL
ORDER by UpdatedOn
       
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
