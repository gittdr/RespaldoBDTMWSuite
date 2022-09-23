SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Metric_OrdMantt] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	--PARAMETROS PROPIOS DE LA METRICA
	@numerador Varchar(255) = 'COSTO',  --     COSTO,ABIERTAS,CERRADAS,LIBERADAS,CERRADAS, DIASTALLER, DIASCIERRE
    @Solotallerlista  varchar(20)  = 'QRO'     --MEX,QRO
     
      --@noproyecto varchar(255) = ''
       

)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Taller,2:Proyecto,3:TipoUnidad,4:TipoMantt,5:RazonMantt,6:Autorizo,7:Orden,8:Unidad


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
      Set  @Solotallerlista = ',' + ISNULL(@Solotallerlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #OrdenesM ( Orden varchar(255),Unidad varchar(255), Taller varchar(255), Proyecto varchar(255), TipoUnidad Varchar(255),TipoMantenimiento varchar (255),
    RazonMantt varchar(255), Autorizo varchar(255),  Costo_Mano_obra money, Costo_Taller_Externo Money, Costo_Refacciones Money, KM INT, Estado varchar (10),
    fechainicio datetime, fechacierre datetime, fechaliberacion datetime, dif float, fechacuenta datetime, pt int)


	-- Carga de la tabla temporal con los datos obtenidos de la consulta de la vista mtto_prueba_cierre
	
    IF @numerador = 'COSTO'
   
     BEGIN

      INSERT INTO #OrdenesM
	
      Select id_orden as Orden, id_unidad as Unidad, terminal as Taller, Depto as Proyecto, Tipo as TipoUnidad, mtto as TipoMantenimiento,
      descripcion as RazonMantt, Expr1 as Autorizo, Costo_mano_obra, Costo_Taller_Externo, Costo_Refacciones, KM, Estado,fecha_inicio, fecha_cierre, 
	  fecha_liberacion,0, fecha_cierre, Costo_Taller_externo+ costo_Refacciones as pt 
	  from tdrsilt.dbo.Mtto_prueba_cierre
      WHERE fecha_cierre >= @DateStart AND fecha_cierre < @DateEnd  
     AND (@Solotallerlista  =',,' or CHARINDEX(',' + Terminal + ',', @Solotallerlista ) > 0) 

       SELECT @ThisCount = CONVERT(decimal(20, 5), SUM(Costo_Mano_Obra+ Costo_Taller_Externo + Costo_Refacciones)) FROM #OrdenesM

    END

  ELSE  IF @numerador = 'ABIERTAS'

   BEGIN
  
      INSERT INTO #OrdenesM

      Select id_orden as Orden, id_unidad as Unidad, terminal as Taller, Depto as Proyecto, Tipo as TipoUnidad, mtto as TipoMantenimiento,
      descripcion as RazonMantt, Expr1 as Autorizo, Costo_mano_obra, Costo_Taller_Externo, Costo_Refacciones, KM, Estado, fecha_inicio, fecha_cierre, fecha_liberacion,0 , fecha_inicio, 0 
	   from tdrsilt.dbo.Mtto_prueba_cierre
      WHERE  (@Solotallerlista  =',,' or CHARINDEX(',' + Terminal + ',', @Solotallerlista ) > 0)  and  fecha_inicio >= @DateStart AND fecha_inicio < @DateEnd  


       SELECT @ThisCount = COUNT(ORDEN) FROM #OrdenesM 
   END

  ELSE  IF @numerador = 'CERRADAS'

   BEGIN
  
      INSERT INTO #OrdenesM

      Select id_orden as Orden, id_unidad as Unidad, terminal as Taller, Depto as Proyecto, Tipo as TipoUnidad, mtto as TipoMantenimiento,
      descripcion as RazonMantt, Expr1 as Autorizo, Costo_mano_obra, Costo_Taller_Externo, Costo_Refacciones, KM, Estado, fecha_inicio, fecha_cierre, fecha_liberacion,0, fecha_cierre, 0   
	  from tdrsilt.dbo.Mtto_prueba_cierre
      WHERE  (@Solotallerlista  =',,' or CHARINDEX(',' + Terminal + ',', @Solotallerlista ) > 0) and  fecha_cierre >= @DateStart AND fecha_cierre < @DateEnd  
       SELECT @ThisCount = COUNT(ORDEN) FROM #OrdenesM 

   END


    ELSE  IF @numerador = 'LIBERADAS'

   BEGIN
  
      INSERT INTO #OrdenesM

      Select id_orden as Orden, id_unidad as Unidad, terminal as Taller, Depto as Proyecto, Tipo as TipoUnidad, mtto as TipoMantenimiento,
      descripcion as RazonMantt, Expr1 as Autorizo, Costo_mano_obra, Costo_Taller_Externo, Costo_Refacciones, KM, Estado, fecha_inicio, fecha_cierre, fecha_liberacion,0, fecha_liberacion, 0   
	  from tdrsilt.dbo.Mtto_prueba_cierre
      WHERE  (@Solotallerlista  =',,' or CHARINDEX(',' + Terminal + ',', @Solotallerlista ) > 0) and  fecha_liberacion >= @DateStart AND fecha_liberacion < @DateEnd  
       SELECT @ThisCount = COUNT(ORDEN) FROM #OrdenesM 

   END


  ELSE  IF @numerador = 'DIASTALLER'

   BEGIN
  
      INSERT INTO #OrdenesM

      Select id_orden as Orden, id_unidad as Unidad, terminal as Taller, Depto as Proyecto, Tipo as TipoUnidad, mtto as TipoMantenimiento,
      descripcion as RazonMantt, Expr1 as Autorizo, Costo_mano_obra, Costo_Taller_Externo, Costo_Refacciones, KM, Estado, fecha_inicio, fecha_cierre, fecha_liberacion, (DATEDIFF(hh,fecha_inicio, fecha_liberacion)), fecha_liberacion, 0 
	    from tdrsilt.dbo.Mtto_prueba_cierre
      WHERE  (@Solotallerlista  =',,' or CHARINDEX(',' + Terminal + ',', @Solotallerlista ) > 0) and estado  in ('C')and fecha_cierre >= @DateStart AND fecha_cierre < @DateEnd  and fecha_liberacion is not null
  

          SELECT @ThisCount = AVG(dif)  FROM #OrdenesM 

   END

  ELSE  IF @numerador = 'DIASCIERRE'

   BEGIN
  
      INSERT INTO #OrdenesM

      Select id_orden as Orden, id_unidad as Unidad, terminal as Taller, Depto as Proyecto, Tipo as TipoUnidad, mtto as TipoMantenimiento,
      descripcion as RazonMantt, Expr1 as Autorizo, Costo_mano_obra, Costo_Taller_Externo, Costo_Refacciones, KM, Estado, fecha_inicio, fecha_cierre, fecha_liberacion, (DATEDIFF(hh,fecha_liberacion,fecha_cierre)), fecha_cierre, 0 
	   from tdrsilt.dbo.Mtto_prueba_cierre
      WHERE  (@Solotallerlista  =',,' or CHARINDEX(',' + Terminal + ',', @Solotallerlista ) > 0) and estado  in ('C') and fecha_cierre >= @DateStart AND fecha_cierre < @DateEnd  

          SELECT @ThisCount = AVG(dif) FROM #OrdenesM 

   END




    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel del Taller que ejecuto la orden 

	IF (@ShowDetail=1) and @numerador in ('COSTO','ABIERTAS','CERRADAS','LIBERADAS') 
	BEGIN
		Select  Taller,count(orden) as CuentaOrdenes, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by Taller 
        order by sum( Costo_Taller_externo+ costo_Refacciones) DESC 
	END

    IF (@ShowDetail=1) and @numerador = 'DIASTALLER'
	BEGIN
		Select   Taller,dbo.fnc_TMWRN_FormatNumbers( avg(dif),2) as horasTaller, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by   Taller
        order by avg(dif) DESC
	END

 IF (@ShowDetail=1)  and @numerador = 'DIASCIERRE'
	BEGIN
		Select  Taller, dbo.fnc_TMWRN_FormatNumbers( avg(dif),2) as HorasCierre, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by   Taller
        order by avg(dif) DESC
	END

   
--Detalle a Nivel del proyecto de la Orden
    
	IF (@ShowDetail=2)and @numerador in ('COSTO','ABIERTAS','CERRADAS','LIBERADAS') 
	BEGIN
		Select Proyecto,count(orden) as CuentaOrdenes, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by Proyecto 
        order by sum( Costo_Taller_externo+ costo_Refacciones) DESC 
	END


 IF (@ShowDetail=2) and @numerador = 'DIASTALLER'
	BEGIN
		Select  Proyecto, dbo.fnc_TMWRN_FormatNumbers( avg(dif),2) as HorasTaller, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by  Proyecto
        order by avg(dif) DESC
	END

 IF (@ShowDetail=2)  and @numerador = 'DIASCIERRE'
	BEGIN
		Select  Proyecto, dbo.fnc_TMWRN_FormatNumbers( avg(dif),2) as HorasCierre, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by  Proyecto
        order by avg(dif) DESC
	END






--Detalle a Nivel del tipo de Unidad Reparada en la Orden

 IF (@ShowDetail=3)and @numerador in ('COSTO','ABIERTAS','CERRADAS','LIBERADAS') 
	BEGIN
		Select TipoUnidad, count(orden) as CuentaOrdenes,'$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by TipoUnidad
        order by sum( Costo_Taller_externo+ costo_Refacciones) DESC 
	END

 IF (@ShowDetail=3) and @numerador = 'DIASTALLER'
	BEGIN
		Select TipoUnidad, dbo.fnc_TMWRN_FormatNumbers( avg(dif),2) as HorasTaller, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by TipoUnidad
        order by avg(dif) DESC
	END

 IF (@ShowDetail=3)  and @numerador = 'DIASCIERRE'
	BEGIN
		Select TipoUnidad, dbo.fnc_TMWRN_FormatNumbers( avg(dif),2) as HorasCierre, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by TipoUnidad
        order by avg(dif) DESC
	END





--Detalle a Nivel del tipo de Mantenimiento ejecutado en la orden 

  IF (@ShowDetail=4 and @numerador in ('COSTO','ABIERTAS','CERRADAS','LIBERADAS') )
	BEGIN
		Select TipoMantenimiento,count(orden) as CuentaOrdenes, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by TipoMantenimiento
        order by sum( Costo_Taller_externo+ costo_Refacciones) DESC 
	END


 IF (@ShowDetail=4) and @numerador = 'DIASTALLER'
	BEGIN
		Select TipoMantenimiento, dbo.fnc_TMWRN_FormatNumbers( avg(dif ),2)as HorasTaller, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by TipoMantenimiento
        order by avg(dif) DESC
	END

 IF (@ShowDetail=4)  and @numerador = 'DIASCIERRE'
	BEGIN
		Select TipoMantenimiento, dbo.fnc_TMWRN_FormatNumbers( avg(dif),2) as HorasCierre, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by TipoMantenimiento
        order by avg(dif) DESC
	END

  
--Detalle a Nivel de la Rázon de Mantenimiento de la Orden

  IF (@ShowDetail=5)  and @numerador in ('COSTO','ABIERTAS','CERRADAS','LIBERADAS') 
	BEGIN
		Select RazonMantt,count(orden) as CuentaOrdenes, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by RazonMantt
        order by sum( Costo_Taller_externo+ costo_Refacciones) DESC 
	END

  IF (@ShowDetail=5) and @numerador = 'DIASTALLER'
	BEGIN
		Select RazonMantt, dbo.fnc_TMWRN_FormatNumbers( avg(dif),2) as HorasTaller, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by RazonMantt
        order by avg(dif) DESC
	END

 IF (@ShowDetail=5)  and @numerador = 'DIASCIERRE'
	BEGIN
		Select RazonMantt, dbo.fnc_TMWRN_FormatNumbers( avg(dif),2) as HorasCierre, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by RazonMantt
        order by avg(dif) DESC
	END

  

 
--Detalle a Nivel de persona que autorizo la Orden
 
   IF (@ShowDetail=6) and @numerador in ('COSTO','ABIERTAS','CERRADAS','LIBERADAS') 
	BEGIN
		Select Autorizo,count(orden) as CuentaOrdenes, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by Autorizo
        order by sum( Costo_Taller_externo+ costo_Refacciones) DESC 
	END

  IF (@ShowDetail=6) and @numerador = 'DIASTALLER'
	BEGIN
		Select Autorizo, dbo.fnc_TMWRN_FormatNumbers( avg(dif),2) as HorasTaller, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by Autorizo
        order by avg(dif) DESC
	END

  IF (@ShowDetail=6)  and @numerador = 'DIASCIERRE'
	BEGIN
		Select Autorizo, dbo.fnc_TMWRN_FormatNumbers( avg(dif),2) as HorasCierre, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by Autorizo
        order by avg(dif) DESC
	END



---Detalle General a Nivel de Orden

   IF (@ShowDetail=7) and @numerador in ('COSTO','ABIERTAS','CERRADAS','LIBERADAS') 
	BEGIN
		Select  Orden, fechacuenta as FechaCuenta,Taller,Proyecto,Unidad,TipoUnidad,TipoMantenimiento,RazonMantt,Autorizo, 
         '$' + dbo.fnc_TMWRN_FormatNumbers(Costo_Taller_externo,2) as CostoTallerExt,
         '$' + dbo.fnc_TMWRN_FormatNumbers(Costo_Refacciones,2) as CostoRefacciones, 
         '$' + dbo.fnc_TMWRN_FormatNumbers((Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
    order by (Costo_Taller_externo+ costo_Refacciones) DESC
	END

  IF (@ShowDetail=7) and @numerador = 'DIASTALLER'
	BEGIN
		Select  Orden, dif as HorasTaller,fechainicio as FechInicio, fechaliberacion as FechaLiberacion, Taller,Proyecto,Unidad,TipoUnidad,TipoMantenimiento,RazonMantt,Autorizo, 
         '$' + dbo.fnc_TMWRN_FormatNumbers(Costo_Taller_externo,2) as CostoTallerExt,
         '$' + dbo.fnc_TMWRN_FormatNumbers(Costo_Refacciones,2) as CostoRefacciones, 
         '$' + dbo.fnc_TMWRN_FormatNumbers((Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        order by dif desc
	END

  IF (@ShowDetail=7) and @numerador = 'DIASCIERRE'
	BEGIN
		Select  Orden, dif as HorasCierre,fechacierre as FechaCierre, fechaliberacion as FechaLiberacion,Taller,Proyecto,Unidad,TipoUnidad,TipoMantenimiento,RazonMantt,Autorizo, 
         '$' + dbo.fnc_TMWRN_FormatNumbers(Costo_Taller_externo,2) as CostoTallerExt,
         '$' + dbo.fnc_TMWRN_FormatNumbers(Costo_Refacciones,2) as CostoRefacciones, 
         '$' + dbo.fnc_TMWRN_FormatNumbers((Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        order by dif desc
	END



--Detalle a Nivel de unidad

  IF (@ShowDetail=8)  and @numerador in ('COSTO','ABIERTAS','CERRADAS','LIBERADAS') 
	BEGIN
		Select Unidad,TipoUnidad,count(orden) as CuentaOrdenes,  '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by Unidad,TipoUnidad
        order by sum( Costo_Taller_externo+ costo_Refacciones) DESC  ,TipoUnidad desc
	END

  IF (@ShowDetail=8) and @numerador = 'DIASTALLER'
	BEGIN
		Select Unidad, dbo.fnc_TMWRN_FormatNumbers( avg(dif),2) as HorasTaller, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by Unidad
        order by avg(dif) desc 
	END

 IF (@ShowDetail=8)  and @numerador = 'DIASCIERRE'
	BEGIN
		Select Unidad, dbo.fnc_TMWRN_FormatNumbers( avg(dif),2) as HorasCierre, '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Costo_Taller_externo),2) as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Refacciones),2) as CostoRefacciones, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo+ costo_Refacciones),2)   as CostoTotal
		From #OrdenesM
        group by Unidad
        order by avg(dif) desc 
	END

  

 
GO
