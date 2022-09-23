SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  Proc [dbo].[WatchDog_Ordenesproblemassgc] 
(

	--@DaysBack int=-20,
	@TempTableName varchar(255)='##WatchDogFailSGC',
	@WatchName varchar(255)='FailSGC',
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
     --set @diasumbral = 1

	-- Initialize Temp Table
	

declare @tempo table (driver varchar(100),orden varchar(200),leg varchar(200), fecha datetime,  status varchar(4), tipo varchar(100))

/*
insert into @tempo 

select  (select mpp_id+ ' | ' + isnull(mpp_firstname,'') +' '+ isnull(mpp_lastname,'')from manpowerprofile (nolock) where mpp_id = lgh_driver1) as driver,
 ord_hdrnumber,lgh_number, lgh_Startdate,
(select stp_status from tmwsuite..stops (nolock) where stops.lgh_number = legheader.lgh_number and stp_mfh_sequence = 
 (select max(stp_mfh_sequence) from tmwsuite..stops (nolock) where stops.lgh_number = legheader.lgh_number)) as ultstopstatus,
'Leg abierto con stops cerrados'
from tmwsuite..legheader where lgh_outstatus = 'STD'

delete from @tempo where status = 'OPN'
*/
--------------------------------------------------------------------------------------------------------------------------------------------------------

insert into @tempo 

select 
 (select mpp_id+ ' | ' +isnull(mpp_firstname,'') +' '+ isnull(mpp_lastname,'') from manpowerprofile (nolock) where mpp_id =
(select lgh_driver1 from legheader (nolock) where legheader.lgh_number = stops.lgh_number)) as driver,
ord_hdrnumber,lgh_number, stp_arrivaldate, 'CMP',
'leg cerrado con stops abiertos' from stops (nolock) where stp_status = 'OPN' and lgh_number in (select lgh_number from legheader (nolock) where lgh_outstatus = 'CMP')

-------------------------------------------------------------------------------------------------------------------------------------------------------

insert into @tempo 

select 
 mpp_id+ ' | ' + isnull(mpp_firstname,'') +' '+ isnull(mpp_lastname,'') as driver,
  (STUFF((select  ', ' + cast(ord_hdrnumber as varchar(12))  from legheader  where lgh_outstatus  = 'STD' and lgh_driver1 = mpp_id FOR XML PATH('')) , 1, 1, '')),
   (STUFF((select  ', ' + cast(lgh_number as varchar(12))  from legheader  where lgh_outstatus  = 'STD' and lgh_driver1 = mpp_id FOR XML PATH('')) , 1, 1, '')),
 getdate(),'STD',
 '---------'+ cast((select count(*) from legheader where lgh_outstatus  = 'STD' and lgh_driver1 = mpp_id) as varchar(3)) + ' viajes iniciados---------'  as ordenesabiertas
from manpowerprofile 
where mpp_status <> 'OUT' and mpp_id <> 'UNKNOWN' and
(select count(*) from legheader where lgh_outstatus  = 'STD' and lgh_driver1 = mpp_id) > 1 


select * into  #TempResults from @tempo 
order by driver

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
