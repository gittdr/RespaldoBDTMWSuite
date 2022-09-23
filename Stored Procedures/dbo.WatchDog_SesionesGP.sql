SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_SesionesGP] 
(

	--@DaysBack int=-20,
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


   --declare @fechaini datetime
   --declare  @fechafin datetime
 
   --set @fechaini = DateAdd(dd,@DaysBack,GetDate())
  -- set @fechafin = GetDate()


	-- Initialize Temp Table
	


CREATE TABLE #USGP(
		Usuario	VARCHAR(200),
        Fecha datetime,
        Hora VARCHAR(22)
        )


   INSERT INTO #USGP

     SELECT  
      Usuario = (select USERNAME from [172.24.16.113].DYNAMICS.dbo.SY01400 B where B.USERID = A.USERID ) ,
      Fecha = A.LOGINDAT,
      Hora = substring(cast(A.LOGINTIM as varchar),13,20) 
      from [172.24.16.113].DYNAMICS.dbo.Activity A


 --desplegamos la consulta    
 select *
 into   	#TempResults
 from #USGP
order by Hora asc


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
