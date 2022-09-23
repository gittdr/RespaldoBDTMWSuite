SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

 CREATE Proc [dbo].[WatchDog_vence_Expirations_JR] 
(

    @Umbralasignacion float = 10,
	@TempTableName varchar(255)='##WatchDogExpirationDriver',
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
	

 
            create table #ExpDrivers (operador varchar(13) ,nombre varchar(45),codigo varchar(6),expiracion varchar(20)
            ,dias int,FechaVenc  datetime,descripcion varchar(100))
            
            create table #Todisplay (
             operador varchar(13)
            ,nombre varchar(45)
            ,codigo varchar(6)
            ,expiracion varchar(20)
            ,dias int
            ,FechaVenc  datetime
            ,descripcion varchar(100))


Begin
Insert into #ExpDrivers
     
		SELECT 	exp_id AS [Operador ID],
				mpp_lastfirst,
       			exp_code AS [Expiration Code],
       			[Expiration] = 	(
									SELECT labelfile.name 
									FROM labelfile (NOLOCK) 
									WHERE labelfile.abbr = exp_code 
										AND labeldefinition = exp_idtype + 'Exp'
								),
       			DATEDIFF(DAY,GETDATE(),exp_expirationdate) AS [Days Out],
       			exp_expirationdate AS [Expiration Date],
				exp_description as [Description]
		FROM   	Expiration (NOLOCK) 
				LEFT JOIN manpowerprofile (NOLOCK) ON exp_id = mpp_id
		WHERE  	exp_code in  ('LIC','EXMED')
      			AND ((exp_completed = 'N' AND DateDiff(day,GetDate(),exp_expirationdate) <= 7))
				and mpp_status <> 'OUT'
		ORDER BY exp_expirationdate ASC



---Insertamos los datos en la tabla para desplejarlos
insert into #Todisplay 
	
	Select operador 
		,nombre 
		,codigo 
		,expiracion
        ,dias
		,FechaVenc
		,descripcion
		from #ExpDrivers
           
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
