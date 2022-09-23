SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--EXEC [Metric_Estancias] 1,1,1,'20121212 00:00:01','20121212 01:31:00 pm', 1, 1, @tipoestancias='CLIENTES'
CREATE PROCEDURE [dbo].[Metric_Estancias] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	--PARAMETROS PROPIOS DE LA METRICA
	  @tipoestancias varchar(255)
      --@division Varchar(255) = 'TODOS',  --     CLIENTE,PATIOS
      --@noproyecto varchar(255) = ''
       

)
AS
	SET NOCOUNT ON  -- PTS46367

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:General,2:Patios/Clientes

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
    Set @TIPOESTANCIAS = ISNULL(@TIPOESTANCIAS,'')
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Create Temp Table
	CREATE TABLE #Estancias ( Fecha datetime, Patio varchar(50), Cliente varchar (255), Orden varchar(8),  Unidad varchar(8), Captura varchar (10), Descripcion varchar(255)  )


--select ([Pay Type Description]) from vista_estancias1


	-- Initialize Temp Table
	
if @tipoestancias = 'PATIOS'
  begin
 
      INSERT INTO #Estancias
	
    select   [pyd_createdon] as fecha ,Patio,ord_billto as Cliente,[Order Number] as Orden,[ord_tractor] as Unidad,[pyd_createdby] as Captura, Description as Decripcion from vista_Estancias1 with(NOLOCK)
      WHERE [pyd_createdon] >= @DateStart AND [pyd_createdon]  < @DateEnd 
      and [Pay Type Description] in  ('%Estancias en Patio', '%Estancias MTTO')
	
		



 END		

ELSE  if @tipoestancias = 'CLIENTES' -- Entonces es igual a 'CLIENTES'

 BEGIN	

    INSERT INTO #Estancias
	
      select   [pyd_createdon] as fecha , Patio,ord_billto as Cliente,[Order Number] as Orden,[ord_tractor] as Unidad,[pyd_createdby] as Captura, Description as Decripcion from vista_Estancias1 with(NOLOCK)
      WHERE [pyd_createdon]  >= @DateStart AND [pyd_createdon]  < @DateEnd
      and [Pay Type Description] in ('%Estancias Cte Carga', '%Estancias Cte Descarga')
	

 END

 ELSE  if @tipoestancias = 'TODAS' -- todas las estancias

 BEGIN	

    INSERT INTO #Estancias
	
      select    [pyd_createdon] as fecha , Patio,ord_billto as Cliente,[Order Number] as Orden,[ord_tractor] as Unidad,[pyd_createdby] as Captura, Description as Decripcion from vista_Estancias1 with(NOLOCK)
      WHERE [pyd_createdon] >= @DateStart AND [pyd_createdon]  < @DateEnd
     

 END


	
	SELECT @ThisCount = CONVERT(decimal(20, 5), COUNT(*)) FROM #Estancias

    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


------------------------------------------------------------------DETALLES

	IF (@ShowDetail=1) and @tipoestancias = 'PATIOS'
	BEGIN
		Select Fecha,Patio,Orden,Unidad,Captura,Descripcion
		From #Estancias
        order by Fecha
	END

  	IF (@ShowDetail=1) and @tipoestancias = 'CLIENTES'
	BEGIN
		Select Fecha, Patio, Cliente, Orden, Unidad, Captura, Descripcion
		From #Estancias
         order by Fecha
	END

--------------------------------------------------------------------CLIENTES/PATIOS


	IF (@ShowDetail=2) and @tipoestancias = 'PATIOS'
	BEGIN
		Select Patio,
        Orden = Count(Orden)
		From #Estancias
       group by Patio
        order by Count(Orden)
	END

  	IF (@ShowDetail=2) and @tipoestancias = 'CLIENTES'
	BEGIN
			Select Cliente,
        Orden = Count(Orden)
		From #Estancias
       group by Cliente
        order by Count(Orden)

	END
GO
