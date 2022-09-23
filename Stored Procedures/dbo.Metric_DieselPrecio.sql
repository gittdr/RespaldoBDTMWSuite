SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Metric_DieselPrecio] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int


)
AS
	SET NOCOUNT ON  -- PTS46367

    --declare @difdate  int
    --declare @PDateStart datetime
	--declare @PDateEnd datetime 


	--INICIALIZACION DE PARAMETROS ESTANDAR.
    --inicializamos las variables de las  fechas con una semana antes para comparar


    




	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Precio



	-- Create Temp Table
	CREATE TABLE #PrecioDiesel(
		Fecha	    datetime,
		Precio		decimal(10,2))
		

	-- Initialize Temp Table
	

      INSERT INTO #PrecioDiesel
	
      SELECT     afp_date, afp_price
      FROM         averagefuelprice
      WHERE     (afp_description = 'DIESEL')
      and afp_Date  < @DateEnd 


	
	SELECT @ThisCount =  (Select Precio  FROM #PrecioDiesel where Fecha = (select max(afp_date) from   averagefuelprice  
    where afp_Date < @DateEnd ))

    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--PRECIOS DIESEL FECHA

	IF (@ShowDetail=1) 
	BEGIN
		Select 
        Fecha,
        Precio,
        PrecioIVA = PRecio * 1.16
   
       
   
        from #PrecioDiesel
        order by Fecha Desc
	END


GO
