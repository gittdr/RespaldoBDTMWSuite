SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_TMRDia] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int

	--PARAMETROS PROPIOS DE LA METRICA
    --@Soloalmacenlista  varchar(20)  = 'QRO'     --MEX,QRO
     
      --@noproyecto varchar(255) = ''
       

)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Revisadas


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #TMRD
    (Unidad varchar(50),
     TotalLlantas int,
     FechaUltRev datetime,
     TipoUnidad varchar(500),
     Proyecto varchar(200),
     Dias int )

 

	--Cargamos la tabla temporal con los datos de la consulta 


      INSERT INTO #TMRD

      select 
      UNIDAD = REPLACE(id_unidad,'TCU',''),
      total_llantas,
      FEcha,
     tipounidad =(SELECT  isnull(tdrsilt.dbo.mtto_tipos_unidades.descripcion,'')         
           FROM tdrsilt.dbo.mtto_unidades,              tdrsilt.dbo.mtto_marcas_unidades,               tdrsilt.dbo.mtto_tipos_unidades     
           WHERE ( CAST(tdrsilt.dbo.mtto_unidades.id_marca_unidad AS VARCHAR) = CAST(tdrsilt.dbo.mtto_marcas_unidades.id_marca_unidad AS VARCHAR) ) and         
          ( CAST(tdrsilt.dbo.mtto_unidades.id_tipo_unidad AS VARCHAR) = CAST(tdrsilt.dbo.mtto_tipos_unidades.id_tipo_unidad AS VARCHAR) )   and  CAST(tdrsilt.dbo.mtto_unidades.id_unidad AS VARCHAR) =  cast(tdrsilt.dbo.REporte_Llantas_TMR.id_unidad AS VARCHAR) ),
      P,
      [días] 
      from tdrsilt.dbo.REporte_Llantas_TMR
      where 
           fecha >= @DateStart
	  AND 
      fecha < @DateEnd



-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = (Select count(*)  from #TMRD)


    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel de Unidades  revisadas por dia


IF (@ShowDetail=1) 
	BEGIN
		Select 
      Unidad,
      TipoUnidad,
       Proyecto,
        TotalLlantas,
       FechaUltRev
       ,Dias
          from #TMRD 
        order by  cast(unidad as int) desc
      
	END

GO
