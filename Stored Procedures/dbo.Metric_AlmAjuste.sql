SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[Metric_AlmAjuste] (
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
    @Soloalmacenlista  varchar(20)  = 'QRO',     --MEX,QRO
    @modo varchar(20) = 'NORM'         ---NORM,ABS
     
      --@noproyecto varchar(255) = ''
       

)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Mexico,2:Queretaro,3:Todo


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      Set  @Soloalmacenlista = ',' + ISNULL( replace(  replace(@Soloalmacenlista,'QRO','32') ,'MEX','11')   ,'') + ','


	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #Ajustes (Almacen int,vale int, Anterior float, Nueva float, fecha datetime, Poliza varchar(250), item varchar(255), total money)

	-- Carga de la tabla temporal en el  caso  de que el numerador sea salidas de almacen
	

      INSERT INTO #Ajustes


       
  SELECT   
         Almacen = id_almacen 
        ,Vale = id_Vale
       ,Anterior = cantidad_Anterior
       ,Nueva = cantidad_nueva
       ,fecha = fecha
       ,Poliza = isnull(no_poliza,'')
       ,Item = item
       ,total = [$ total]

 FROM tdrsilt.dbo.Reporte_Ajustes


    WHERE  
            ( fecha >= @DateStart ) AND  
            ( fecha <= @DateEnd )  AND  
          (@Soloalmacenlista  =',,' or CHARINDEX(',' + cast( id_almacen as varchar) + ',', @Soloalmacenlista ) > 0)  and
         ( ( 'S' = 'N' ) OR ( 'S' = 'S') )    



 

-- Asignar valores a variable de numerador, denominador y resultado de la metrica

     IF @modo = 'ABS'
      BEGIN
      SELECT @ThisCount = (Select sum(abs(total)) from #Ajustes)
     END
    else
     BEGIN
      SELECT @ThisCount = (Select sum(total) from #Ajustes)
     END
 

    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel de  Insumo

	IF (@ShowDetail=1) 
	BEGIN
	   Select 
        case Almacen when 11 then 'MEX' when 32 then 'QRO' else cast(Almacen as varchar) end
        ,Vale
       ,Anterior
       ,Nueva
       ,fecha
       ,Poliza
       ,Item
       ,Total = '$' + dbo.fnc_TMWRN_FormatNumbers(total,2) 
 
         from #Ajustes
        where almacen = 11
      
	END



	IF (@ShowDetail=2) 
	BEGIN
	    Select 
        case Almacen when 11 then 'MEX' when 32 then 'QRO' else cast(Almacen as varchar) end
        ,Vale
       ,Anterior
       ,Nueva
       ,fecha
       ,Poliza
       ,Item
       ,Total = '$' + dbo.fnc_TMWRN_FormatNumbers(total,2) 
 
         from #Ajustes
        where almacen = 32
      
	END

	IF (@ShowDetail=3) 
	BEGIN
		Select 
        case Almacen when 11 then 'MEX' when 32 then 'QRO' else cast(Almacen as varchar) end
        ,Vale
       ,Anterior
       ,Nueva
       ,fecha
       ,Poliza
       ,Item
       ,Total = '$' + dbo.fnc_TMWRN_FormatNumbers(total,2) 
 
         from #Ajustes
      
	END

GO
