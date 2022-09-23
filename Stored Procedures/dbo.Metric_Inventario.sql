SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Metric_Inventario] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	--PARAMETROS PROPIOS DE LA METRICA
	@numerador Varchar(255) = 'IN',  --     IN,OUT
    @Soloalmacenlista  varchar(20)  = 'QRO'     --MEX,QRO
     
      --@noproyecto varchar(255) = ''
       

)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Insumo


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      Set  @Soloalmacenlista = ',' + ISNULL( replace(  replace(@Soloalmacenlista,'QRO','32') ,'MEX','11')   ,'') + ','


	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #Inventario(Vale varchar (50),Orden varchar(20), NoParte varchar(50),Insumo varchar(500), Fecha datetime, Cantidad float , PrecioUnitario float, PrecioTotal float, Almacen  Varchar(10), Autorizo varchar(500), 
    Recibio varchar(500), Unidad varchar(40), Proyecto varchar (100), Actividad varchar (500), PT int)

	-- Carga de la tabla temporal en el  caso  de que el numerador sea salidas de almacen
	
    IF @numerador = 'OUT'
   
     BEGIN

       

      INSERT INTO #Inventario

     select
    
        vale= id_vale,
        orden= ( SELECT (id_orden) FROM tdrsilt.dbo.inventario_salidas_dir WHERE tdrsilt.dbo.inventario_salidas_dir.id_vale = tdrsilt.dbo.inventario_salidas_dir_d.id_vale
		AND tdrsilt.dbo.inventario_salidas_dir.id_almacen= tdrsilt.dbo.inventario_salidas_dir_d.id_almacen),
        NoParte = id_insumo,
		Insumo =(SELECT     descripcion  FROM tdrsilt.dbo.compras_insumos WHERE tdrsilt.dbo.inventario_salidas_dir_d.id_insumo = tdrsilt.dbo.compras_insumos.id_insumo),
		Fecha = ( SELECT (fecha) FROM tdrsilt.dbo.inventario_salidas_dir WHERE tdrsilt.dbo.inventario_salidas_dir.id_vale = tdrsilt.dbo.inventario_salidas_dir_d.id_vale
		AND tdrsilt.dbo.inventario_salidas_dir.id_almacen= tdrsilt.dbo.inventario_salidas_dir_d.id_almacen),
		Cantidad = cantidad_insumo - cantidad_devuelta,
		PrecioUnitario = precio_unitario,
        PrecioTotal = (cantidad_insumo - cantidad_devuelta ) *  precio_unitario,
        Almacen = (select terminal from tdrsilt.dbo.personal_personal where (select id_autorizo from tdrsilt.dbo.inventario_salidas_dir  where 
		tdrsilt.dbo.inventario_salidas_dir.id_vale = tdrsilt.dbo.inventario_salidas_dir_d.id_vale AND tdrsilt.dbo.inventario_salidas_dir.id_almacen= tdrsilt.dbo.inventario_salidas_dir_d.id_almacen ) = tdrsilt.dbo.personal_personal.id_personal),
		Autorizo = (SELECT (nom_autorizo) from tdrsilt.dbo.inventario_salidas_dir  where tdrsilt.dbo.inventario_salidas_dir.id_vale = tdrsilt.dbo.inventario_salidas_dir_d.id_vale 
		AND tdrsilt.dbo.inventario_salidas_dir.id_almacen= tdrsilt.dbo.inventario_salidas_dir_d.id_almacen),
		Recibio = (SELECT (nom_recibio) from tdrsilt.dbo.inventario_salidas_dir  where tdrsilt.dbo.inventario_salidas_dir.id_vale = tdrsilt.dbo.inventario_salidas_dir_d.id_vale 
		AND tdrsilt.dbo.inventario_salidas_dir.id_almacen= tdrsilt.dbo.inventario_salidas_dir_d.id_almacen),
		Unidad = (SELECT (id_unidad) from tdrsilt.dbo.inventario_salidas_dir  where tdrsilt.dbo.inventario_salidas_dir.id_vale = tdrsilt.dbo.inventario_salidas_dir_d.id_vale 
		AND tdrsilt.dbo.inventario_salidas_dir.id_almacen= tdrsilt.dbo.inventario_salidas_dir_d.id_almacen),
		Proyecto = (Select descripcion from tdrsilt.dbo.general_departamentos where tdrsilt.dbo.general_departamentos.id_depto = (SELECT (id_depto_destino) from tdrsilt.dbo.inventario_salidas_dir  where tdrsilt.dbo.inventario_salidas_dir.id_vale = tdrsilt.dbo.inventario_salidas_dir_d.id_vale 
		AND tdrsilt.dbo.inventario_salidas_dir.id_almacen= tdrsilt.dbo.inventario_salidas_dir_d.id_almacen)),
        Actividad = (Select nombre from tdrsilt.dbo.mtto_actividad where tdrsilt.dbo.mtto_actividad.id_actividad = tdrsilt.dbo.inventario_salidas_dir_d.id_actividad),
        PT =  (cantidad_insumo - cantidad_devuelta ) *  precio_unitario
		 
       from tdrsilt.dbo.inventario_salidas_dir_d


      WHERE  (@Soloalmacenlista  =',,' or CHARINDEX(',' + cast(id_almacen as varchar) + ',', @Soloalmacenlista ) > 0)  
      AND  ( SELECT (fecha) FROM tdrsilt.dbo.inventario_salidas_dir WHERE tdrsilt.dbo.inventario_salidas_dir.id_vale = tdrsilt.dbo.inventario_salidas_dir_d.id_vale
	  AND tdrsilt.dbo.inventario_salidas_dir.id_almacen= tdrsilt.dbo.inventario_salidas_dir_d.id_almacen) >= @DateStart AND ( SELECT (fecha) FROM tdrsilt.dbo.inventario_salidas_dir WHERE tdrsilt.dbo.inventario_salidas_dir.id_vale = tdrsilt.dbo.inventario_salidas_dir_d.id_vale
	  AND tdrsilt.dbo.inventario_salidas_dir.id_almacen= tdrsilt.dbo.inventario_salidas_dir_d.id_almacen)< @DateEnd   
      AND (id_area = 1 ) 

    END


   IF @numerador = 'IN'
   
     BEGIN

       

      INSERT INTO #Inventario


       
  SELECT   
          
         Vale = tdrsilt.dbo.compras_orden_detalle.renglonorden,   
         Orden = tdrsilt.dbo.compras_orden_detalle.id_orden_compra,
         NoParte= tdrsilt.dbo.compras_orden_detalle.id_insumo,   
         Insumo = tdrsilt.dbo.compras_insumos.descripcion +'|'+  tdrsilt.dbo.compras_orden_detalle.estado_insumo ,   
         Fecha =  tdrsilt.dbo.compras_orden_detalle.fecha_entrega,
         Cantidad = tdrsilt.dbo.compras_orden_detalle.cantidad_recibida,
         Precio_Unitario = tdrsilt.dbo.compras_orden_detalle.precioalmacen,
         Precio_Total = tdrsilt.dbo.compras_orden_detalle.precioalmacen * replace((tdrsilt.dbo.compras_orden_detalle.cantidad_recibida),0,1),
         Almacen ='',
         Autorizo = tdrsilt.dbo.compras_proveedor.nombre,
         Recibio = ( select nombre from tdrsilt.dbo.personal_personal where id_personal =(select max(id_recibio) from tdrsilt.dbo.inventario_recepcion where tdrsilt.dbo.inventario_recepcion.id_orden_compra =  tdrsilt.dbo.compras_orden_detalle.id_orden_compra)),
         Unidad = '',
         Proyecto = '',
         Actividad = '',
         PT =   tdrsilt.dbo.compras_orden_detalle.precioalmacen * replace((tdrsilt.dbo.compras_orden_detalle.cantidad_recibida),0,1)

    FROM tdrsilt.dbo.compras_orden, tdrsilt.dbo.compras_orden_detalle,  tdrsilt.dbo.compras_insumos,tdrsilt.dbo.compras_proveedor,tdrsilt.dbo.general_area
    
    WHERE   ( tdrsilt.dbo.compras_orden.id_area_orden = tdrsilt.dbo.compras_orden_detalle.id_area_orden ) and
            ( tdrsilt.dbo.compras_orden.id_orden_compra = tdrsilt.dbo.compras_orden_detalle.id_orden_compra ) and
			( tdrsilt.dbo.compras_orden_detalle.id_insumo = tdrsilt.dbo.compras_insumos.id_insumo ) and
			( tdrsilt.dbo.compras_orden.id_proveedor = tdrsilt.dbo.compras_proveedor.id_proveedor ) and
			( tdrsilt.dbo.compras_orden.id_area_orden = tdrsilt.dbo.general_area.id_area ) and
			( tdrsilt.dbo.compras_orden.id_area_orden = 1 ) AND  
            ( tdrsilt.dbo.compras_orden.id_orden_compra  in  
            (select id_orden_compra from tdrsilt.dbo.inventario_recepcion where
            ( tdrsilt.dbo.inventario_recepcion.id_area = tdrsilt.dbo.general_area.id_area ) and       
            ( tdrsilt.dbo.inventario_recepcion.id_area = 1 ) and        (@Soloalmacenlista  =',,' or CHARINDEX(',' + cast( tdrsilt.dbo.compras_orden_detalle.id_almacen as varchar) + ',', @Soloalmacenlista ) > 0)
            AND  ( tdrsilt.dbo.inventario_recepcion.fecha >= @DateStart ) AND  
            ( tdrsilt.dbo.inventario_recepcion.fecha <= @DateEnd ) )) AND  
         ( tdrsilt.dbo.compras_orden_detalle.id_areaalmacen = 1 ) AND  
          (@Soloalmacenlista  =',,' or CHARINDEX(',' + cast( tdrsilt.dbo.compras_orden_detalle.id_almacen as varchar) + ',', @Soloalmacenlista ) > 0)  and
         ( ( 'S' = 'N' ) OR ( 'S' = 'S') )    


    END

 

-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = (Select sum(PrecioTotal) from #Inventario)

    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel de  Insumo

	IF (@ShowDetail=1) and @numerador = 'IN'
	BEGIN
		Select Orden as OrdenCompra,NoParte,Insumo, Fecha as Fecha, dbo.fnc_TMWRN_FormatNumbers((Cantidad),2) as Cantidad,
       '$' + dbo.fnc_TMWRN_FormatNumbers((PrecioUnitario),2) as PrecioUnitario, 
       '$' + dbo.fnc_TMWRN_FormatNumbers((PrecioTotal),2) as PrecioTotal, 
        Proveedor = Autorizo,Recibio
		From  #Inventario
        Order by orden DESC ,PT DESC
    
      
	END


	IF (@ShowDetail=1) and @numerador = 'OUT'
	BEGIN
      -- select * from #inventario
		Select Vale,Orden,NoParte,Insumo,Fecha, dbo.fnc_TMWRN_FormatNumbers((Cantidad),2) as Cantidad,
       '$' + dbo.fnc_TMWRN_FormatNumbers ((PrecioUnitario),2) as PrecioUnitario, 
       '$' + dbo.fnc_TMWRN_FormatNumbers((PrecioTotal),2) as PrecioTotal, 
        Proveedor = Autorizo ,Recibio,Proyecto,Unidad,Actividad
		From  #Inventario
       
        order by orden DESC ,PT  DESC
	END

  

GO
