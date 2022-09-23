SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

 CREATE Proc [dbo].[WatchDog_ordenes_en_cero_JR] 
(

    @Umbralasignacion float = 10,
	@TempTableName varchar(255)='##WatchDogOrdenEnCero',
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
	

 
            create table #OrdenCero (Tipo varchar(10) ,Billto varchar(30),Orden integer, estatus varchar(20),Fecha datetime,Factura varchar(12),Proyecto varchar(20))
            
            create table #Todisplay (
             tipo varchar(10)
            ,Billto varchar(8)
            ,Orden integer
            ,estatus varchar(6)
            ,Fecha  datetime
            ,factura varchar(12)
			,Proyecto varchar(20))


Begin
Insert into #OrdenCero
	select 'ORDEN',ord_billto, ord_hdrnumber,ord_status,ord_startdate,'SIN FACTURA',(select name from labelfile where labeldefinition ='REVtype3' and abbr = ord_revtype3) from orderheader where ord_totalcharge = 0.00 and ord_bookdate > '01-01-2016'
		and ord_status not in ('CAN','MST','AVL') and ord_billto <> 'SAE'  and ord_invoicestatus not in ('PPD', 'XIN')
	union
		select 'FACTURA',ivh_billto, ord_hdrnumber, ivh_invoicestatus,ivh_billdate,ivh_invoicenumber, (select name from labelfile where labeldefinition ='REVtype3' and abbr = ivh_revtype3) from invoiceheader where ord_hdrnumber in (
		select ord_hdrnumber from orderheader where ord_totalcharge = 0.00 and ord_bookdate > '01-01-2016'
		and ord_status not in ('CAN','MST','AVL') and ord_billto <> 'SAE'  and ord_invoicestatus in ('PPD')
		) and ivh_invoicestatus <> 'XFR'



---Insertamos los datos en la tabla para desplejarlos
insert into #Todisplay 
	
	Select tipo 
		,billto 
		,orden 
		,estatus
		,Fecha
		,factura
		,Proyecto
		from #OrdenCero
           
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
