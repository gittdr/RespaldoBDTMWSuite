SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  Proc [dbo].[WatchDog_OrdenesPLNPast] 
(

	--@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogOrdenesPLNPast',
	@WatchName varchar(255)='OrdenesPLNPast',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',  
    @diasumbral int
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
     --set @diasumbral = 1

	-- Initialize Temp Table
	


CREATE TABLE #OrdPln(
       [Orden Planeada] varchar(20),
	   [Orden Iniciada] varchar(20),
       [Cliente] varchar(20),
       [Planeada por] VARCHAR(200),
       [Fecha Inicio] datetime,
       [Paydetails generados] VARCHAR(8000),
       [Cantidad Pay Details] float,
       [Vales generados] varchar(500),
       [Impreso por] varchar(500)
       
        )


   INSERT INTO #OrdPln


	select cast(o.ord_hdrnumber as varchar) as [Orden Planeada],
	isnull((select cast(max(b.ord_hdrnumber) as varchar) from orderheader b where ord_status = 'STD' and  ord_driver1 = (select ord_driver1 from orderheader where ord_hdrnumber = o.ord_hdrnumber)),0)  as [Orden Iniciada], 
	ord_billto as [Cliente],
	(select (usr_fname +' ' +usr_lname) from ttsusers where  usr_userid = ord_bookedby) as  [Planeada por],
	(select ord_startdate from orderheader where ord_hdrnumber = o.ord_hdrnumber) as [Fecha Inicio],
	 STUFF((select '-' + pyd_description  from paydetail where ord_hdrnumber =o.ord_hdrnumber FOR XML PATH('') ), 1, 1, '')  as [Paydetails generados],
	(select sum(pyd_amount)  from paydetail where ord_hdrnumber =o.ord_hdrnumber) as [Cantidad Pay Details],
     STUFF((select ',' + cast(ftk_ticket_number as varchar) from fuelticket where ord_hdrnumber = o.ord_hdrnumber FOR XML PATH('') ), 1, 1, '')  as [Vales generados],
     isnull(STUFF((select ',' + cast(ftk_printed_by as varchar) from fuelticket where ord_hdrnumber = o.ord_hdrnumber FOR XML PATH('') ), 1, 1, ''),'No impreso')  as [Impreso por]
	from orderheader o
	where ord_status = ('PLN')  and datediff(dd,ord_startdate,getdate())>= 1
	

 --desplegamos la consulta    
 select *
 into   	#TempResults
 from #OrdPln
order by [Fecha Inicio] asc


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
