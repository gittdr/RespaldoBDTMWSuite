SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

  Create Proc [dbo].[WatchDog_Bloqueos_Abastecimiento_JR] 
(

    @Umbralasignacion float = 10,
	@TempTableName varchar(255)='##WatchDogBloqueosAbastecimientoJR',
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
				proyecto varchar(20),
				recurso  varchar(13),
				operador varchar(80),
				unidad   varchar(13),
				nomcodigo varchar(20),
				descripcion  varchar(100),
				faltandias int,
				iniciabloquedo datetime,
				finbloqueo datetime,
				notarjeta varchar(50))


Begin
Insert into #Todisplay
	 SELECT
		(select name from labelfile where labeldefinition = 'DrvType3' and abbr = (select mpp_type3 from manpowerprofile where mpp_id = exp_id)) as proyecto,
		exp_id as Recurso,
		((select mpp_firstname + ' ' + mpp_lastname from manpowerprofile where mpp_id = exp_id)) as operador,
		 mpp_tractornumber as unidad,
		(select name from labelfile where labeldefinition = 'DrvExp' and abbr =exp_code) as NomCodigo,
		exp_Description,
		datediff(dd,getdate(),exp_expirationdate) as FaltanDias,
		exp_expirationdate,
		exp_compldate,
		'' as notarjeta
		from expiration , manpowerprofile 
		where exp_idtype  = 'DRV' and exp_completed = 'N'
		and exp_code in ('CAPA','SICT','PER','FALTA','VACT','OUT')
		and (datediff(mm,exp_expirationdate,getdate()) = 0 or datediff(mm,exp_expirationdate,getdate()) = -1)
		and exp_id = mpp_id and mpp_tractornumber <> 'UNKNOWN'
	union
	SELECT
		(select name from labelfile where labeldefinition = 'TrcType3' and abbr = (select trc_type3 from tractorprofile where trc_number = exp_id)) as proyecto,
		exp_id as Recurso,
		((select mpp_id+' '+ mpp_firstname + ' ' + mpp_lastname from manpowerprofile where mpp_tractornumber = exp_id)) as operador,
		exp_id as Unidad,
			(select name from  labelfile where labeldefinition = 'TrcExp' and abbr =exp_code) as NomCodigo,
		exp_Description,
		datediff(dd,getdate(),exp_expirationdate) as FaltanDias,
		exp_expirationdate,
		exp_compldate,
		'' as notarjeta
		from expiration 
		where exp_idtype  = 'TRC' and exp_completed = 'N'
		and exp_code in ('INSHOP','VAC')
		and (datediff(mm,exp_expirationdate,getdate()) = 0 or datediff(mm,exp_expirationdate,getdate()) = -1)
		order by 2 desc



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
