SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

 CREATE Proc [dbo].[WatchDog_ordenes_AVERID_JR] 
(

    @Umbralasignacion float = 10,
	@TempTableName varchar(255)='##WatchDogOrdenesAverid',
	@WatchName varchar(255)='Expira',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
    @FiltroNombre varchar(50) = '',
	@ColumnMode varchar (50) ='Selected'
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables

	-- Initialize Temp Table
 
            create table #Todisplay (
             ord_hdrnumber int, ord_status varchar(6),ord_refnum varchar(30), ord_tractor varchar(8), ord_trailer varchar(13),ord_originpoint varchar(8), ord_destpoint varchar(8), 
			IniciaCarga datetime, FinCarga datetime, IniciaDescarga datetime, FinDescarga datetime, HrsDescarga int, HrsTransito Int)


Begin
Insert into #Todisplay
	select ord_hdrnumber, ord_status,ord_refnum, ord_tractor, ord_trailer,ord_originpoint, ord_destpoint, 
	(select stp_arrivaldate  from stops where stp_number = (select min(stp_number) from stops where ord_hdrnumber = orderheader.ord_hdrnumber and stp_event = 'LLD')) as IniciaCarga,
	(select stp_departuredate from stops where stp_number = (select min(stp_number) from stops where ord_hdrnumber = orderheader.ord_hdrnumber and stp_event = 'LLD')) as FinCarga,
	(select stp_arrivaldate from stops where stp_number = (select max(stp_number) from stops where ord_hdrnumber = orderheader.ord_hdrnumber and stp_event = 'LUL')) as IniciaDescarga,
	(select stp_departuredate from stops where stp_number = (select max(stp_number) from stops where ord_hdrnumber = orderheader.ord_hdrnumber and stp_event = 'LUL')) as FinDescarga,
	DATEDIFF(hh,(select stp_arrivaldate from stops where stp_number = (select max(stp_number) from stops where ord_hdrnumber = orderheader.ord_hdrnumber and stp_event = 'LUL')), (select stp_departuredate from stops where stp_number = (select max(stp_number) from stops where ord_hdrnumber = orderheader.ord_hdrnumber and stp_event = 'LUL'))) as HrsDescarga,
	DateDiff(hh,(select stp_departuredate from stops where stp_number = (select min(stp_number) from stops where ord_hdrnumber = orderheader.ord_hdrnumber and stp_event = 'LLD')),(select stp_arrivaldate from stops where stp_number = (select max(stp_number) from stops where ord_hdrnumber = orderheader.ord_hdrnumber and stp_event = 'LUL'))) as HrsTransito
	from orderheader where ord_billto = 'AVERYD' and ord_status in ( 'CMP','STD') and ord_bookdate >= '2019-03-01'



---Insertamos los datos en la tabla para desplejarlos

--mostramos el resultado final de la tabla #todisplay

			select * 
			into 
			#TempResultsa
			from #Todisplay 

	--Commits the results to be used in the wrapper
	If @ColumnNamesOnly = 1 or @ExecuteDirectly = 1
	Begin
		Set @SQL = 'Select * from #TempResultsa'
	End
	Else
	Begin
		Set @COLSQL = ''
		Exec WatchDogColumnNames @WatchName=@WatchName,@ColumnMode=@ColumnMode,@SQLForWatchDog=1,@SELECTCOLSQL = @COLSQL OUTPUT
		Set @SQL = 'Select identity(int,1,1) as RowID ' + @COLSQL + ' into ' + @TempTableName + ' from #TempResultsa'
	End

	Exec (@SQL)
	Set NoCount Off
 end

GO
