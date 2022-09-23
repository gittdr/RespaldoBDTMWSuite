SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Metric_CuentaOrdMantt] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int

	--PARAMETROS PROPIOS DE LA METRICA
	--@tipomant  varchar(20)  = 'TODOS',     --  TODOS,EXTERNO
      --@division Varchar(255) = 'TODOS',  --     CLIENTE,PATIOS
      --@noproyecto varchar(255) = ''
       

)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Taller,2:Proyecto,3:TipoUnidad,4:TipoMantt,5:RazonMantt,6:Autorizo,7:Orden


  --SET @division= ',' + ISNULL(@division,'') + ',' 
   --SET @noproyecto = ',' + ISNULL(@noproyecto,'') + ','

	--Metric Initialization
	/* NOTE: This SQL is used by MetricProcessing to automatically generate an new metric item in a category called NewItems.
	<METRIC-INSERT-SQL>

	EXEC MetricInitializeItem
		@sMetricCode = 'Estancias',
		@nActive = 0,	-- 1=active, 0=inactive.
		@nSort = 109, 	-- Used to determine the sort order that updates should be run.
		@sFormatText = '',	-- Typically 'PCT' or blank ('').
		@nNumDigitsAfterDecimal = 0,
		@nPlusDeltaIsGood = 0,
		@nCumulative = 0,
		@sCaption = 'Estancias',
		@sCaptionFull = 'Estancias',
		@sProcedureName = 'Metric_Estancias',
		-- @sDetailFilename	= '',	
		-- @sThresholdAlertEmailAddress = '',  
		-- @nThresholdAlertValue = 0, 
		-- @sThresholdOperator = '',
		@sCachedDetailYN = '',
		@nCacheRefreshAgeMaxMinutes = 0,
		@sShowDetailByDefaultYN = 'N', -- Typically 'N'
		@sRefreshHistoryYN = '',	-- Typically 'N'
		@sCategory = '@@NOCATEGORY'
		-- @nGoalDay = NULL, 
		-- @nGoalWeek = NULL, 
		-- @nGoalMonth = NULL, 
		-- @nGoalQuarter = NULL, 
		-- @nGoalYear = NULL,
		-- @sGradingScaleCode = NULL,  -- NULL means default to MetricCode
		-- @sGradeA = .90,
		-- @sGradeB = .80,
		-- @sGradeC = .70,
		-- @sGradeD = .60

	</METRIC-INSERT-SQL>
	*/

	--INICIALIZACION DE PARAMETROS ESTANDAR.
   -- Set @TIPOESTANCIAS = ISNULL(@TIPOESTANCIAS,'')
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #OrdenesM ( Orden varchar(10),Unidad varchar(15), Taller varchar(4), Proyecto varchar(25), TipoUnidad Varchar(255),TipoMantenimiento varchar (20),
    RazonMantt varchar(255), Autorizo varchar(255),  Costo_Mano_obra money, Costo_Taller_Externo Money, Costo_Refacciones Money, KM INT)


	-- Carga de la tabla temporal con los datos obtenidos de la consulta de la vista mtto_prueba_cierre
	

      INSERT INTO #OrdenesM
	
      Select id_orden as Orden, id_unidad as Unidad, terminal as Taller, Depto as Proyecto, Tipo as TipoUnidad, mtto as TipoMantenimiento,
      descripcion as RazonMantt, Expr1 as Autorizo, Costo_mano_obra, Costo_Taller_Externo, Costo_Refacciones, KM  from tdrsilt.dbo.Mtto_prueba_cierre 
      WHERE fecha_cierre >= @DateStart AND fecha_cierre < @DateEnd

	  
	SELECT @ThisCount = CONVERT(decimal(20, 5), SUM(Costo_Mano_Obra+ Costo_Taller_Externo + Costo_Refacciones)) FROM #OrdenesM

    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel del Taller que ejecuto la orden 

	IF (@ShowDetail=1)
	BEGIN
		Select  Taller,'$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by Taller 
	END

--Detalle a Nivel del proyecto de la Orden
    
	IF (@ShowDetail=2)
	BEGIN
		Select Proyecto,'$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by Proyecto 
	END

--Detalle a Nivel del tipo de Unidad Reparada en la Orden

   	IF (@ShowDetail=3)
	BEGIN
		Select TipoUnidad,'$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by TipoUnidad
	END

--Detalle a Nivel del tipo de Mantenimiento ejecutado en la orden 

       	IF (@ShowDetail=4)
	BEGIN
		Select TipoMantenimiento,'$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by TipoMantenimiento
	END

--Detalle a Nivel de la Rázon de Mantenimiento de la Orden

          	IF (@ShowDetail=5)
	BEGIN
		Select RazonMantt,'$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by RazonMantt
	END
 
--Detalle a Nivel de persona que autorizo la Orden
 
        IF (@ShowDetail=6)
	BEGIN
		Select Autorizo,'$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by Autorizo
	END

---Detalle General a Nivel de Orden

   	IF (@ShowDetail=7)
	BEGIN
		Select  Orden, Unidad,Taller,Proyecto,TipoUnidad,TipoMantenimiento,RazonMantt,Autorizo,
         '$' + dbo.fnc_TMWRN_FormatNumbers(Costo_Taller_externo,2) as CostoTallerExt,
         '$' + dbo.fnc_TMWRN_FormatNumbers(Costo_Refacciones,2) as CostoRefacciones, 
         '$' + dbo.fnc_TMWRN_FormatNumbers((Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
	END

  
GO
