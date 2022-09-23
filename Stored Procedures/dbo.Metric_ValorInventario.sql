SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Metric_ValorInventario] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	--PARAMETROS PROPIOS DE LA METRICA
	--@numerador Varchar(255) = 'IN',  --     IN,OUT
    @Soloalmacenlista  varchar(20)  = 'QRO'     --MEX,QRO,VER
     
      --@noproyecto varchar(255) = ''
       

)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Insumo,2:Familia,3:SubFamilia


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #ValorInventario( Familia varchar(255),SubFamilia varchar(255),NoParte varchar(20),Insumo varchar(255),Estado Varchar(2), Existencia float , UltCompra float, CostoPromedio float, TotalUltCompra float, TotalPromedio float, TP  int) 
   
	-- Carga de la tabla temporal 
   insert into #ValorInventario	

   select 
	Familia =  isnull((SELECT   (descripcion)  FROM  tdrsilt.dbo.general_familias WHERE tdrsilt.dbo.inventario_almacen.id_familia =  tdrsilt.dbo.general_familias.id_familia and  tdrsilt.dbo.inventario_almacen.id_articulo =  tdrsilt.dbo.general_familias.id_articulo),'N/A'),
	SubFamilia =  isnull((SELECT   (descripcion)  FROM  tdrsilt.dbo.general_subfamilias WHERE tdrsilt.dbo.inventario_almacen.id_subfamilia =  tdrsilt.dbo.general_subfamilias.id_subfamilia and  tdrsilt.dbo.inventario_almacen.id_articulo =  tdrsilt.dbo.general_subfamilias.id_articulo and tdrsilt.dbo.inventario_almacen.id_familia =  tdrsilt.dbo.general_subfamilias.id_familia),'N/A'),
    id_insumo,
	Insumo = (SELECT     descripcion  FROM  tdrsilt.dbo.compras_insumos WHERE tdrsilt.dbo.inventario_almacen .id_insumo = tdrsilt.dbo.compras_insumos.id_insumo),
	Estado_insumo,
	Existencia = cantidad_insumo,
	UltCompra = costo_ultima_compra,
	CostoPromedio = precio,
	TotalUltCompra = cantidad_insumo * costo_ultima_compra,
	TotalPromedio =  cantidad_insumo * precio,
    TP =  cantidad_insumo * precio
	from  tdrsilt.dbo.inventario_almacen 
    where  (@Soloalmacenlista   =',,' or CHARINDEX(',' + replace(replace(replace(replace(id_almacen,11,'MEX'),32,'QRO'),15,'VER'),45,'TULT') + ',', @Soloalmacenlista) > 0) and
    cantidad_insumo > 0 and  ( consignacion = 0 ) AND  (id_area = 1) 



-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = (Select sum(TotalPromedio) from #ValorInventario)

    SELECT @ThisTotal =  1
    --CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel de  Insumo

	IF (@ShowDetail=1) 
	BEGIN
		Select Familia,subfamilia,NoParte,Insumo,Estado,
         dbo.fnc_TMWRN_FormatNumbers( (Existencia),2) as Existencias,
         '$' + dbo.fnc_TMWRN_FormatNumbers((UltCompra),2) as UltimaCompra,
         '$' + dbo.fnc_TMWRN_FormatNumbers((CostoPromedio),2) as UltimaCompra,
         '$' + dbo.fnc_TMWRN_FormatNumbers((TotalUltCompra),2) as TotalUltCompra,
          '$' + dbo.fnc_TMWRN_FormatNumbers((TotalPromedio),2) as TotalPromedio
		From  #ValorInventario
       order by TP desc
	END


--Detalle a Nivel de la familia Insumo

   	IF (@ShowDetail=2) 
	BEGIN
		Select  Familia, 
        dbo.fnc_TMWRN_FormatNumbers( sum(Existencia),2) as Existencias,
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum(TotalPromedio),2) as TotalPromedio
		From  #ValorInventario
        group by familia
        order by sum(TotalPromedio) DESC
	END


	--Detalle a Nivel de la Subfamilia Insumo

   	IF (@ShowDetail=3) 
	BEGIN
		Select  Familia,SubFamilia, 
        dbo.fnc_TMWRN_FormatNumbers( sum(Existencia),2) as Existencias,
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum(TotalPromedio),2) as TotalPromedio
		From  #ValorInventario
        group by Familia,Subfamilia
        order by sum(TotalPromedio) desc
	END


	


	


	
GO
