SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

 CREATE Proc [dbo].[WatchDog_Paydetail_SinOrden_JR] 
(

    @Umbralasignacion float = 10,
	@TempTableName varchar(255)='##WatchDogPaydetailSinOrdenJR',
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
 
            create table #DetalleDePago (
			idOperador Varchar(13),
			fecha Date,
			creadopor Varchar(20),
			codigo	Varchar(6),
			descripcion Varchar(75),
			monto money,
			estatus varchar(3))
            
            create table #Todisplay (
            idOperador Varchar(13),
			fecha Date,
			creadopor Varchar(20),
			codigo	Varchar(6),
			descripcion Varchar(75),
			monto money,
			estatus varchar(3))


Begin
Insert into #DetalleDePago
     
select asgn_id, pyd_createdon, pyd_createdby, pyt_itemcode,pyd_description, pyd_amount,pyd_status from paydetail where asgn_type = 'DRV' and pyd_createdon > '01-01-2018' and ord_hdrnumber is null
and pyt_itemcode not in ('ispt', 'compat', 'infona','IMSS','FONACOT','MN+','MN-','POMCE','FONAC','ALIMEN',
'AGUINA','BCAPAC','BDIESE','BONO','BPOMCE','CARRIE','CEMS','COMOPM','COMPEN','COMTAX','COMTEL','COMTRA',
'DEDPEN','DEDPRE','DESDIE','FALTAS','INFOAM','INGROP','LAVA','IVA2','LIQUI','PAINST','PATMTY','PRESTA','PRIMAV','PXDIST','UNIFOR','VAC')
Order By 2



---Insertamos los datos en la tabla para desplejarlos
insert into #Todisplay 
	
	Select idOperador 
		,fecha 
		,creadopor 
		,codigo
        ,descripcion
		,monto
		,estatus
		from #DetalleDePago
           
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
