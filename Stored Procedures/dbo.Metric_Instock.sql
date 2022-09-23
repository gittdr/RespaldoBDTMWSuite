SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Metric_Instock] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	--PARAMETROS PROPIOS DE LA METRICA
    @Soloalmacenlista  varchar(20)  = 'QRO'     --MEX,QRO
     
      --@noproyecto varchar(255) = ''
       

)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:InStock,2:OutStock


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #Stock (NoParte varchar(20), Insumo varchar(255), Estado varchar (2), Cantidadminima float, CantidadInsumo float, Puntaje  float)

	-- Carga de la tabla temporal en el  caso  de que el numerador sea salidas de almacen
	

       

      INSERT INTO #Stock

       SELECT    

        NoParte = id_insumo,
		Insumo =(SELECT     descripcion  FROM tdrsilt.dbo.compras_insumos WHERE  tdrsilt.dbo.inventario_almacen.id_insumo = tdrsilt.dbo.compras_insumos.id_insumo),
		Estado = estado_insumo,
		Cantidadminima = (cantidad_minima),
		Cantidadinsumo = (Cantidad_insumo),
		case when (Cantidad_insumo) - (cantidad_minima) >= 0 then 1 else 0 end as puntaje
		FROM         tdrsilt.dbo.inventario_almacen
		where reorden > 0 and  id_almacen in (11,32)
        and (@Soloalmacenlista   =',,' or CHARINDEX(',' + replace(replace(id_almacen,11,'MEX'),32,'QRO') + ',', @Soloalmacenlista  ) > 0)
   



-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = (Select sum(Puntaje) from #Stock)
    SELECT @ThisTotal =  (Select count(Insumo) from #Stock)
    --SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel de  Insumo inStock

	IF (@ShowDetail=1) 
	BEGIN
		Select NoParte, Insumo, Estado, Cantidadminima, Cantidadinsumo
		From  #Stock
        where cantidadinsumo >= cantidadminima
        order by cantidadinsumo DESC
      
	END

--Detalle a Nivel de  Insumo outStock


	IF (@ShowDetail=2) 
	BEGIN
		Select NoParte, Insumo, Estado, Cantidadminima, Cantidadinsumo
		From  #Stock
         where cantidadinsumo < cantidadminima
        order by cantidadminima DESC
	END
GO
