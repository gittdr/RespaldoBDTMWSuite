SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

 CREATE Proc [dbo].[WatchDog_TrcInactivos] 
(

    @Umbralasignacion float = 1,
	@TempTableName varchar(255)='##WatchDogGlobalOrderFollowUp',
	@WatchName varchar(255)='PayDetails',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
    @SoloFlotaLista varchar(255)
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables


Set @SoloFlotaLista= ',' + ISNULL(@SoloFlotaLista,'') + ','


	-- Initialize Temp Table
	

 
            create table #TrcInact (Tractor varchar(8), ultfecha datetime)

			Insert into #TrcInact

			select  lgh_tractor, max(lgh_startdate)  from legheader  
			group by lgh_tractor 

			delete from #trcInact where Tractor in  (select trc_number from tractorprofile where trc_fleet = '17') 
			delete from #trcInact where  Tractor in (Select exp_id  FROM expiration WITH (NOLOCK) WHERE exp_idtype='TRC'  and exp_code = 'OUT')
			delete from #trcInact where  Tractor is NULL or  Tractor in ('010','UNKNOWN','232016') 
		    delete from #TrcInact where datediff(d,UltFecha,getdate()) <= @Umbralasignacion


		select  

            Tractor,
            DiasInactivo = datediff(d,Ultfecha,getdate()),
            UltimaAsignacion = ultfecha,
            Flota = (select name from labelfile where labelfile.labeldefinition = 'Fleet' and abbr = (select trc_fleet from tractorprofile where tractorprofile.trc_number = Tractor)),
            Division = (select trc_type4 from tractorprofile where Tractor = tractorprofile.trc_number),
            Operador = replace((select trc_driver from tractorprofile where Tractor = tractorprofile.trc_number),'UNKNOWN','SIN OP.'),
            RegionActual = (select rgh_name from regionheader where rgh_id =( select trc_prior_region1  from  tractorprofile where trc_number = Tractor)),
            Ubicacion = (select trc_gps_desc from tractorprofile where Tractor = tractorprofile.trc_number),
            Estatus = isnull(( select name from labelfile where labeldefinition = 'TrcExp' and abbr = (select  exp_code from expiration where exp_id = Tractor and exp_Completed = 'N' 
            and exp_idtype = 'TRC' and  exp_key = (select max(exp_key) from expiration where exp_id = Tractor and exp_Completed = 'N'))),'Disponible')
            into   	#TempResults
		    from #TrcInact
            where  ( @SoloFlotaLista  =',,' or CHARINDEX(',' + (select name from labelfile where labelfile.labeldefinition = 'Fleet' and abbr = (select trc_fleet from tractorprofile where tractorprofile.trc_number = Tractor)) + ',', @SoloFlotaLista ) > 0)
            order by Flota,DiasInactivo desc ,Tractor 


 


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
