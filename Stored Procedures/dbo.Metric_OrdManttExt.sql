SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Metric_OrdManttExt] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	--PARAMETROS PROPIOS DE LA METRICA
	   @taller  varchar(20)  = 'TODOS'     -- 'TODOS,MEX,QRO'
      --@division Varchar(255) = 'TODOS',  --     CLIENTE,PATIOS
      --@noproyecto varchar(255) = ''
       

)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Proveedor,2:Proyecto,3:Autorizo,4:Orden


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

	CREATE TABLE #OrdenesM ( Orden varchar(10),FechaCierre datetime, Unidad varchar(15), Proveedor varchar(255), 
     Autorizo varchar(255), Proyecto varchar(255), Especificacion varchar(255), Factura  varchar(20), FechaFactura datetime,
     Costo_Taller_Externo Money, Costo_Insumos Money, Subtotal Money, TotalIVAinc Money, MontoTotal Money)


	-- Carga de la tabla temporal con los datos obtenidos de la consulta de la vista mtto_prueba_cierre
	

      INSERT INTO #OrdenesM
	
      select  id_orden,
	 (select (fecha_cierre) from tdrsilt.dbo.mtto_orden where tdrsilt.dbo.mtto_orden.id_orden =  tdrsilt.dbo.inventario_bienes_ser.id_orden) as fecha_cierre ,
     (select max(id_unidad) from tdrsilt.dbo.mtto_orden where tdrsilt.dbo.mtto_orden.id_orden =  tdrsilt.dbo.inventario_bienes_ser.id_orden) as unidad ,
     (Select (nombre) from tdrsilt.dbo.compras_proveedor where tdrsilt.dbo.compras_proveedor.id_proveedor =  tdrsilt.dbo.inventario_bienes_ser.id_proveedor) as proveedor,
     (select (nombre) from tdrsilt.dbo.personal_personal where   tdrsilt.dbo.personal_personal.id_personal= tdrsilt.dbo.inventario_bienes_ser.id_autorizo) as autorizo,
     (select descripcion from tdrsilt.dbo.general_departamentos where id_depto =(select (id_depto) from  tdrsilt.dbo.mtto_unidades where tdrsilt.dbo.mtto_unidades.id_unidad  = (select max(id_unidad) from tdrsilt.dbo.mtto_orden where tdrsilt.dbo.mtto_orden.id_orden =  tdrsilt.dbo.inventario_bienes_ser.id_orden))) as proyecto,
     especificacion, factura, fecha_factura,

     (select sum(costo_mano_obra) from   tdrsilt.dbo.inventario_bienes_ser_d  where tdrsilt.dbo.inventario_bienes_ser_d.id_vale = tdrsilt.dbo.inventario_bienes_ser.id_vale) as costo_mo_ext,
     (select sum(costo_insumos) from   tdrsilt.dbo.inventario_bienes_ser_d  where tdrsilt.dbo.inventario_bienes_ser_d.id_vale  = tdrsilt.dbo.inventario_bienes_ser.id_vale) as costo_insumos_ext,

     ((select sum(costo_mano_obra) from   tdrsilt.dbo.inventario_bienes_ser_d  where tdrsilt.dbo.inventario_bienes_ser_d.id_vale = tdrsilt.dbo.inventario_bienes_ser.id_vale) +
     (select sum(costo_insumos) from   tdrsilt.dbo.inventario_bienes_ser_d  where tdrsilt.dbo.inventario_bienes_ser_d.id_vale  = tdrsilt.dbo.inventario_bienes_ser.id_vale)) as subtotal,


     ((select sum(costo_mano_obra) from   tdrsilt.dbo.inventario_bienes_ser_d  where tdrsilt.dbo.inventario_bienes_ser_d.id_vale = tdrsilt.dbo.inventario_bienes_ser.id_vale) +
     (select sum(costo_insumos) from   tdrsilt.dbo.inventario_bienes_ser_d  where tdrsilt.dbo.inventario_bienes_ser_d.id_vale  = tdrsilt.dbo.inventario_bienes_ser.id_vale)) * 1.16  as totalivainc,
     monto_total

     from tdrsilt.dbo.inventario_bienes_ser
     WHERE  (select (fecha_cierre) from tdrsilt.dbo.mtto_orden where tdrsilt.dbo.mtto_orden.id_orden =  tdrsilt.dbo.inventario_bienes_ser.id_orden) >= @DateStart 
     AND 
    (select (fecha_cierre) from tdrsilt.dbo.mtto_orden where tdrsilt.dbo.mtto_orden.id_orden =  tdrsilt.dbo.inventario_bienes_ser.id_orden) < @DateEnd 
    AND status not in (2,1)
     AND 
    (select (estado) from tdrsilt.dbo.mtto_orden where tdrsilt.dbo.mtto_orden.id_orden =  tdrsilt.dbo.inventario_bienes_ser.id_orden) <> 'N'


   if @Taller =('MEX')
     BEGIN
     delete  #OrdenesM where autorizo in (select (nombre) from tdrsilt.dbo.personal_personal where terminal <> 'MEX') 
     END

   if @Taller =('QRO')
     BEGIN
     delete  #OrdenesM where autorizo in (select (nombre) from tdrsilt.dbo.personal_personal where terminal <> 'QRO') 
     END
    

	  
	SELECT @ThisCount = CONVERT(decimal(20, 5), SUM(MontoTotal)) FROM #OrdenesM

    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel de proveedor de la orden 

   IF (@ShowDetail=1)
	BEGIN
		Select  proveedor, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo),2)   as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Insumos),2) as CostoInsumos, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Subtotal),2)   as  Subtotal,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(TotalIVAinc),2) as TotalIVAinc, 
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(MontoTotal),2) as MontoTotal
		From #OrdenesM
        group by proveedor
        order by sum(MontoTotal) desc
	END

--Detalle a nivel de proyecto de la orden

 IF (@ShowDetail=2)
	BEGIN
		Select  proyecto, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo),2)  as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Insumos),2) as CostoInsumos, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Subtotal),2)   as  Subtotal,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(TotalIVAinc),2) as TotalIVAinc, 
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(MontoTotal),2) as MontoTotal
		From #OrdenesM
        group by proyecto
        order by sum(MontoTotal) desc
	END


--Detalle a Nivel de persona que autorizo la Orden
 
        IF (@ShowDetail=3)
	BEGIN
        Select  autorizo,
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo),2)   as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Insumos),2) as CostoInsumos, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Subtotal),2)  as  Subtotal,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(TotalIVAinc),2) as TotalIVAinc, 
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(MontoTotal),2) as MontoTotal
		From #OrdenesM
        group by Autorizo
        order by sum(MontoTotal) desc
	END

---Detalle General a Nivel de Orden

   	IF (@ShowDetail=4)
	BEGIN
		Select  Orden,Autorizo,Proveedor,Unidad,Proyecto, Especificacion, Factura, FEchaFactura, FechaCierre,
       '$' + dbo.fnc_TMWRN_FormatNumbers(( Costo_Taller_externo),2)   as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers((Costo_Insumos),2) as CostoInsumos, 
       '$' + dbo.fnc_TMWRN_FormatNumbers((Subtotal),2)   as  Subtotal,
       '$' + dbo.fnc_TMWRN_FormatNumbers((TotalIVAinc),2) as TotalIVAinc, 
       '$' + dbo.fnc_TMWRN_FormatNumbers((MontoTotal),2) as MontoTotal
		From #OrdenesM
       order by MontoTotal desc, autorizo,proveedor,unidad
	END

---Detalle General a Nivel Mexico

   	IF (@ShowDetail=5 )
	BEGIN
		Select  proveedor, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo),2)   as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Insumos),2) as CostoInsumos, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Subtotal),2)   as  Subtotal,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(TotalIVAinc),2) as TotalIVAinc, 
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(MontoTotal),2) as MontoTotal
		From #OrdenesM
        where autorizo in  (select (nombre) from tdrsilt.dbo.personal_personal where terminal = 'MEX') 
        group by proveedor
        order by sum(MontoTotal) desc
	END

---Detalle General a Nivel Queretaro
   	IF (@ShowDetail=6)
	BEGIN
	Select  proveedor, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum( Costo_Taller_externo),2)   as CostoTallerExt,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(Costo_Insumos),2) as CostoInsumos, 
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum(Subtotal),2)   as  Subtotal,
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(TotalIVAinc),2) as TotalIVAinc, 
       '$' + dbo.fnc_TMWRN_FormatNumbers( sum(MontoTotal),2) as MontoTotal
		From #OrdenesM
              where autorizo in (select (nombre) from tdrsilt.dbo.personal_personal where terminal = 'QRO') 
        group by proveedor
        order by sum(MontoTotal) desc
      
	END


GO
