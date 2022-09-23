SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_TMR] (
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
-- DETAILOPTIONS=1:Proyecto,2:PorRevisar,3:Revisadas


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #TMR
    (Unidad varchar(50),
     TotalLlantas int,
     FechaUltRev datetime,
     TipoUni int,
     TipoUnidad varchar(500),
     Proyecto varchar(200),
     Dias int )

 

	--Cargamos la tabla temporal con los datos de la consulta 


      INSERT INTO #TMR

     select id_unidad,
     total_llantas,
     FEcha,
     Tipouni = 
        (SELECT    isnull(tdrsilt.dbo.mtto_unidades.tipo_unidad,'')        
        FROM tdrsilt.dbo.mtto_unidades   
        WHERE  tdrsilt.dbo.mtto_unidades.id_unidad =  tdrsilt.dbo.REporte_Llantas_TMR.id_unidad ),
     TipoUnidad = 
     (SELECT    
     isnull(tdrsilt.dbo.mtto_tipos_unidades.descripcion,'')         
      FROM tdrsilt.dbo.mtto_unidades,              tdrsilt.dbo.mtto_marcas_unidades,               tdrsilt.dbo.mtto_tipos_unidades     
     WHERE ( tdrsilt.dbo.mtto_unidades.id_marca_unidad = tdrsilt.dbo.mtto_marcas_unidades.id_marca_unidad ) and         
    ( tdrsilt.dbo.mtto_unidades.id_tipo_unidad = tdrsilt.dbo.mtto_tipos_unidades.id_tipo_unidad )   and tdrsilt.dbo.mtto_unidades.id_unidad =  tdrsilt.dbo.REporte_Llantas_TMR.id_unidad ),
      P,
     [días]
      from tdrsilt.dbo.REporte_Llantas_TMR
     where  [días] >= 0
    
		 

-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = (Select avg(Dias) from #TMR)


    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel de Unidades  por revisar


IF (@ShowDetail=2) 
	BEGIN
		Select 
        Unidad,
        TipoUnidad,
        Proyecto,
        TotalLlantas,
        FechaUltRev,
        Dias
          from #TMR 
        where dias > 30
        order by dias desc
      
	END


--Detalle a Nivel de Unidades  revisadas


IF (@ShowDetail=3) 
	BEGIN
		Select 
        Unidad,
        Proyecto,
        TipoUnidad,
        TotalLlantas,
        FechaUltRev,
        Dias
          from #TMR 
        where dias < 30
        order by dias desc
      
	END


--Detalle a Nivel de proyecto  revisadas


IF (@ShowDetail=1) 
	BEGIN
		Select 
      
        Proyecto,
        TotalLlantas = sum(totalllantas),
        DiasPromedio = avg(Dias),
        Trac= (select avg(dias) from #TMR tmd where TipoUni = 1 and #TMR.Proyecto = tmd.Proyecto),
        Rem = (select avg(dias) from #TMR tme where TipoUni = 2 and #TMR.Proyecto = tme.Proyecto),
        Dolly = (select avg(dias) from #TMR tmdo where TipoUni = 6 and #TMR.Proyecto = tmdo.Proyecto),
        Ther = (select avg(dias) from #TMR tmdt where TipoUni = 4 and #TMR.Proyecto = tmdt.Proyecto),
        Pipa =(select avg(dias) from #TMR tmpi where TipoUni = 3 and #TMR.Proyecto = tmpi.Proyecto)

          from #TMR 
   
        group by proyecto
        order by avg(dias) desc
      
	END


GO
