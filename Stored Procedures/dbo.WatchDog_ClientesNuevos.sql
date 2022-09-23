SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

 CREATE Proc [dbo].[WatchDog_ClientesNuevos] 
(

    @Umbralasignacion float = 10,
	@TempTableName varchar(255)='##WatchDogOrdenesWorkCycleJR',
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
	

 
            create table #OrdenesWC (ID_EMPRESA varchar(50) , NOMBRE_COMPANIA varchar(500), ESTATUS VARCHAR(20), NOMBRE varchar(500), CORREO varchar(70), TIPO_DE_CONTACTO varchar(12),TELEFONO varchar(50), CELULAR varchar(30),fechaRegistro varchar(50))
            
            create table #Todisplay (ID_EMPRESA varchar(50) , NOMBRE_COMPANIA varchar(500), ESTATUS VARCHAR(20), NOMBRE varchar(500), CORREO varchar(70), TIPO_DE_CONTACTO varchar(12),TELEFONO varchar(50), CELULAR varchar(30),fechaRegistro varchar(50))


Begin
Insert into #OrdenesWC
--	select last_updatedate, ord_hdrnumber, ord_completiondate, tar_number,  tar_tarriffnumber, ord_company,  ord_totalcharge, 'PROCESADA'
 --from orderheader where last_updateby = 'ESTAT' and last_updatedate >= CONVERT(varchar, getdate(), 101) and ord_totalcharge > 0
 --union

 EXEC [dbo].[ClientesNuevos] 1




---Insertamos los datos en la tabla para desplejarlos
insert into #Todisplay 
	
	Select ID_EMPRESA , NOMBRE_COMPANIA , ESTATUS , NOMBRE , CORREO , TIPO_DE_CONTACTO ,TELEFONO , CELULAR ,fechaRegistro
		from #OrdenesWC
           
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
