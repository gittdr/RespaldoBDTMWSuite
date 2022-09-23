SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_CFDIcancel] 
(

	@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalOrderFollowUp',
	@WatchName varchar(255)='CFDIcancel',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected'
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables


   declare @fechaini datetime
   declare  @fechafin datetime
 
   set @fechaini = DateAdd(dd,@DaysBack,GetDate())
   set @fechafin = GetDate()


	-- Initialize Temp Table
	


CREATE TABLE #CFDIcancel(
		master	VARCHAR(50),
		invoice	VARCHAR(50),
		serie		VARCHAR(20),
		receptor		VARCHAR(50),
		total	float,
        moneda varchar(20),
        folio varchar(20),
        hechapor varchar(20),
        fhemision datetime,
        )


   INSERT INTO #CFDIcancel


     SELECT     nmaster AS master, invoice, serie, idreceptor, total, moneda, bandera, hechapor, fhemision
     FROM         VISTA_fe_generadas
     WHERE     (rutapdf = 'CANCELADA')
     and fhemision between  @fechaini and @fechafin




 --desplegamos la consulta    
 select *
 into   	#TempResults
 from #CFDIcancel
order by fhemision DESC



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
