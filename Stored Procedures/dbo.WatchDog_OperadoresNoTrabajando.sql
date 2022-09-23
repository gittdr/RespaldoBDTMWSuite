SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_OperadoresNoTrabajando] 
(

    @NumeratorOnlyDrvFleetList varchar(255) = '',
	@TempTableName varchar(255)='##Operadores no trabajando',
	@WatchName varchar(255)='OperadoresNoTrabajando',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected'
)
						
As

Set NoCount On



EXEC Resnow_UpdateTripletsAssets

--Declaración de Variables.
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)

Declare @NumeratorList Table (lgh_Driver varchar(15), lgh_startdate datetime,lgh_enddate datetime, ord_hdrnumber varchar(10))
Declare @NumeratorRes Table (driv varchar(15))
Declare @DenominatorRes Table (driv varchar(15))
Declare @DenominatorList Table (lgh_Driver varchar(15))
Declare @Fecha datetime

   

----INICIALIZAR TABLA TEMPORAL CON VALORES DE LA CONSULTA--------------------------------------------------------------------------------------------------------


     set @Fecha = getdate()
     Set @NumeratorOnlyDrvFleetList= ',' + ISNULL(@NumeratorOnlyDrvFleetList,'') + ','

-----INSERTAMOS EN EL NUMERADOR LOS IDS DE LOS OPERADORES QUE ESTAN TRABAJANDO---------------------------------------------------------------------------------------------------------

	Insert into @NumeratorList (lgh_Driver,lgh_startdate,lgh_enddate, ord_hdrnumber)
			select distinct RNT.lgh_Driver1, (RNT.lgh_startdate),(RNT.lgh_enddate),(RNT.ord_hdrnumber)
			from ResNow_Triplets RNT (NOLOCK) inner join Legheader L on RNT.lgh_number = L.lgh_number
				inner join orderheader (NOLOCK) on RNT.ord_hdrnumber = orderheader.ord_hdrnumber
				inner join ResNow_DriverCache_Final TCF (NOLOCK) on RNT.lgh_Driver1 = TCF.Driver_id
            where
            --day(@dateStart) between  day(RNT.lgh_startdate) and day(RNT.lgh_enddate)
            --and month(@dateStart) between  month(RNT.lgh_startdate) and month(RNT.lgh_enddate)
            --and year(@dateStart) between  year(RNT.lgh_startdate) and year(RNT.lgh_enddate)			
            @Fecha between RNT.lgh_startdate and (DATEADD(ms, -2, DATEADD(dd, 1, DATEDIFF(dd, 0,RNT.lgh_enddate))))
           -- @dateend between RNT.lgh_startdate and RNT.lgh_enddate
			AND RNT.lgh_Driver1 <> 'UNKNOWN'
			AND RNT.lgh_startdate >= TCF.Driver_DateStart AND RNT.lgh_startdate < TCF.Driver_DateEnd
            AND (@NumeratorOnlyDrvFleetList =',,' OR CHARINDEX(',' + (select mpp_fleet from manpowerprofile where mpp_id = driver_id) + ',', @NumeratorOnlyDrvFleetList) > 0) 
		

-----OBTENEMOS EN EL DENOMINADOR LA LISTA DE LOS IDS DE LOS OPERADORES DISPONIBLES QUE PUEDEN TRABAJAR-----------------------------------------------------------------------------------------------------------


			Insert into @DenominatorList (lgh_Driver)
			Select Driver
			from dbo.fnc_TMWRN_DriverCount3 
				(
					'CURRENT','',''
					,'',''
					,'',''
					,'',@NumeratorOnlyDrvFleetList,''
					,'',''
					,'',''
					,'',''
					,'',''
					,'',''
					,'',''
					,'',@Fecha
				)


----ELIMINAMOS LOS REGISTROS REPETIDOS POR VARIOS LEGS Y LOS INSERTAMOS EN LA NUEVA TABLA--------------------------------------------------------------------------------------------------------------

      Insert into @NumeratorRes (driv)
      (Select distinct(lgh_driver) from @NumeratorList)


      Insert into @DenominatorRes (driv)
      (Select distinct(lgh_driver) from @DenominatorList)

----DESPLEGAMOS EL RESULTADO DE NUESTRA CONSULTA--------------------------------------------------------------------------------------------------------------------

Select
            Operador = lgh_Driver,
            NombreOperador = (select mpp_firstname + ' ' + mpp_lastname from manpowerprofile where mpp_id = lgh_Driver),
            Status = case when (select datediff(hh,max(lgh_startdate),getdate()) from ResNow_Triplets  (NOLOCK) where ResNow_Triplets.lgh_Driver1 = t.lgh_Driver)>= 0 then
            'Horas Inactivo: ' else  'Por iniciar leg en:' end, 
            Horas  = case when (select datediff(hh,max(lgh_startdate),getdate()) from ResNow_Triplets  (NOLOCK) where ResNow_Triplets.lgh_Driver1 = t.lgh_Driver)< 1 then
           (select datediff(hh,max(lgh_startdate),getdate()) from ResNow_Triplets  (NOLOCK) where ResNow_Triplets.lgh_Driver1 = t.lgh_Driver) * -1 else (select datediff(hh,max(lgh_startdate),getdate()) from ResNow_Triplets  (NOLOCK) where ResNow_Triplets.lgh_driver1 = t.lgh_driver) end    ,
            Flota = (select name from labelfile where labelfile.labeldefinition = 'Fleet' and abbr = (select mpp_fleet from manpowerprofile  where lgh_driver = manpowerprofile.mpp_id)),
            Division = (select mpp_type4 from manpowerprofile where lgh_driver = manpowerprofile.mpp_id),
            Tractor = replace((select mpp_tractornumber from manpowerprofile where lgh_driver = manpowerprofile.mpp_id),'UNKNOWN','SIN TRC.'),
            RegionActual = (select rgh_name from regionheader where rgh_id =( select mpp_prior_region1  from manpowerprofile  where lgh_driver = manpowerprofile.mpp_id))

            into  	#TempResults

			From @DenominatorList t where lgh_driver not in (Select lgh_driver From @NumeratorList) 
            and (select datediff(hh,max(lgh_startdate),getdate()) from ResNow_Triplets  (NOLOCK) where ResNow_Triplets.lgh_Driver1 = t.lgh_Driver)>= 0  
            Order by (select datediff(hh,max(lgh_startdate),getdate()) from ResNow_Triplets  (NOLOCK) where ResNow_Triplets.lgh_Driver1 = t.lgh_Driver) desc


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
