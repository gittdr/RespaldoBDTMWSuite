SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_NewNotes] 
(
	@MinThreshold float = 100,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalNewNotes',
	@WatchName varchar(255) = 'NewNotes',
	@ThresholdFieldName varchar(255) = 'NewNotes',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
	@TableList varchar(255) = '',
	@NoteType varchar(255) = ''
)

As

	Set NoCount On

	/*
	Procedure Name:    WatchDog_NewNotes
	Author/CreateDate: Lori Brickley / 1-4-2006
	Purpose: 	    Returns notes which have been updated/written
					in the last x minutes.

	Revision History:
	*/

	/*
	if not exists (select WatchName from WatchDogItem where WatchName = 'NewNotes')
	INSERT INTO watchdogitem (WatchName, BeginDate, EndDate, SqlStatement, Operator, EmailAddress, BeginDateMinusDays, EndDatePlusDays, DateField, QueryType, ProcName, NumericOrText, MinsBackToRun, HTMLTemplateFlag, ActiveFlag, DefaultCurrency, CurrencyDateType, Description)
	 VALUES ('NewNotes','12/30/1899','12/30/1899','WatchDog_NewNotes','','',0,0,'','','','','',1,0,'','','')
	*/
	--Reserved/Mandatory WatchDog Variables
	Declare @SQL varchar(8000)
	Declare @COLSQL varchar(4000)
	--Reserved/Mandatory WatchDog Variables

	Set @TableList= ',' + RTrim(ISNULL(@TableList,'')) + ','
	Set @NoteType= ',' + RTrim(ISNULL(@NoteType,'')) + ','
	
	select	not_number as [ID],
			not_text as [Text],
			not_type as [Type],
			not_urgent as [Urgent],
			ntb_table as [Table],
			nre_tablekey as [Table Key],
			last_updatedby as [Updated By],
			last_updatedatetime as [Date Updated]
	into   #TempResults	
	From   Notes (NOLOCK)
	where  last_updatedatetime >= DateAdd(mi,@MinsBack,GetDate())
		And (@TableList =',,' or CHARINDEX(',' + ntb_table + ',', @TableList) >0)
		AND (@NoteType =',,' or CHARINDEX(',' + not_type + ',', @NoteType) >0)
	   
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
