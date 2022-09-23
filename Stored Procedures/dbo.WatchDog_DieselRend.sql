SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Proc [dbo].[WatchDog_DieselRend] 
(

    @MinThreshold float = 1,
	@MinsBack int=-20,
	@TempTableName varchar(255)='##WatchDogGlobalOrderFollowUp',
	@WatchName varchar(255)='DieselRend',
	@ThresholdFieldName varchar(255) = '',
	@ColumnNamesOnly bit = 0,
	@ExecuteDirectly bit = 0,
	@ColumnMode varchar (50) ='Selected',
    @UmbralRendimiento float
)
						
As

Set NoCount On

--Reserved/Mandatory WatchDog Variables
Declare @SQL varchar(8000)
Declare @COLSQL varchar(4000)
--Reserved/Mandatory WatchDog Variables


   declare @fechaini datetime
   declare  @fechafin datetime
 
   set @fechaini = DateAdd(mi,@MinsBack,GetDate())
   set @fechafin = DateAdd(mi,@MinThreshold,GetDate()) 


	-- Initialize Temp Table
	


CREATE TABLE #DifRend(
		Movimiento	Integer,
		Litros		decimal(10,2),
		KMS			decimal (10,2),
		Unidad		VARCHAR(50),
		Proyecto	VARCHAR(5),
		NomProy		VARCHAR(20),
		Flota		VARCHAR(20),
		Abbr		Varchar(20),
        Ejes       int,
        Motor      varchar(20),
        RendCarg  float,
        RendVacio float,
        )


   INSERT INTO #DifRend


  
    exec sp_ValesVsKms  @FechaIni, @FechaFin



  
   --insertamos el valor del rendimiento real del movimiento para informacion y si es cargado o vacio
   update #DifRend set Motor = dbo.fnc_TMWRN_FormatNumbers(cast(round((KMS/Litros),2) as varchar),2)
   update #DifRend set Nomproy  = ( select case  when    ( select max(lgh_tot_weight) from legheader where legheader.mov_number = #DifRend.movimiento ) > 0 then 'Cargado' else 'Vacio' end)

   --borar los movimientos cargados que cumplen el rendimiento de cargados
   delete #DifRend where  Nomproy = 'Cargado'
    and Round((Round(((KMS)/(Litros)),2) +   @UmbralRendimiento),2)  >=  RendCarg 

  
   --borar los movimientos cargados que cumplen el rendimiento de cargados
      delete #DifRend where  Nomproy = 'Vacio'
    and Round((Round(((KMS)/(Litros)),2) +    @UmbralRendimiento),2) >=  RendVacio

 --desplegamos la consulta    
 select Unidad,
 Operador = (select mpp_firstname +' ' + mpp_lastname from manpowerprofile where mpp_id = (select lgh_driver1 from legheader where legheader.mov_number = #DifRend.Movimiento)) , 
 Flota,
 Movimiento,
 NomProy as Tipo, 
 Litros,
 KMS,
 Motor as Rendimiento,
 case NomProy when 'Cargado' then RendCarg else  RendVacio end as RendEsperado,
 dbo.fnc_TMWRN_FormatNumbers(case NomProy when 'Cargado' then RendCarg - cast(Motor as float) else  RendVacio - cast(Motor as float)  end,2) as DifRend
 into   	#TempResults
 from #DifRend
 order by DifRend desc





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
