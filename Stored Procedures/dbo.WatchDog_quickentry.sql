SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE Proc [dbo].[WatchDog_quickentry] 
(

	--@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalOrderFollowUp',
	@WatchName varchar(255)='TRlQuickEntry',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
    @MinThreshold float = 1,
	@MinsBack int=-20
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables


   --declare @fechaini datetime
   --declare  @fechafin datetime
 
   --set @fechaini = DateAdd(dd,@DaysBack,GetDate())
  -- set @fechafin = GetDate()


	-- Initialize Temp Table
	


CREATE TABLE #QuickEntry(
		Remolque	VARCHAR(15),
        CreadoPor   VARCHAR(15),
        FechaCreacion datetime,
        )


   INSERT INTO #QuickEntry

 
    SELECT     
      Remolque =  trl_number, 
      CreadoPor =  trl_updatedby, 
      FechaCreacion = trl_createdate
    FROM         dbo.trailerprofile
      where trl_quickentry = 'Y'
      AND dateDiff(mi,trl_createdate,GetDate())>= @MinThreshold
	  AND DateDiff(mi,trl_createdate,getdate())<= -@MinsBack

 --desplegamos la consulta    
 select *
 into   	#TempResults
 from #QuickEntry
order by FechaCreacion asc


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
