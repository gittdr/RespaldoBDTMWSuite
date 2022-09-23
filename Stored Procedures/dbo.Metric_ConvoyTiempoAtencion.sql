SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_ConvoyTiempoAtencion] (
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
-- DETAILOPTIONS=1:Usuario,2:Detalle


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #CTA
    (msgid int,
     dtsent datetime,
     dtoriginal datetime,
     encontestar int,
     msg varchar(max),
	 manda varchar(200),
	 destino varchar(200) )

	--Cargamos la tabla temporal con los datos de la consulta 


      INSERT INTO #CTA

		select 
		sn as msgid,
		dtsent,
		substring([dbo].[RTF2Text](Contents) , charindex('Sent',[dbo].[RTF2Text](Contents),0)+5, charindex('CDT,',[dbo].[RTF2Text](Contents),0) -charindex('Sent',[dbo].[RTF2Text](Contents),0)-5) as dtoriginal,
		datediff(mi,substring([dbo].[RTF2Text](Contents) , charindex('Sent',[dbo].[RTF2Text](Contents),0)+5, charindex('CDT,',[dbo].[RTF2Text](Contents),0) -charindex('Sent',[dbo].[RTF2Text](Contents),0)-5),dtsent) as encontestar,
		[dbo].[RTF2Text](Contents) as msg,
		fromname as manda,
		DeliverTo as destino
		 from tblMessages
		 where Contents like '%Sent:%' and Contents like '%CDT%'
		 and ToDrvSN is not null
		 and DeliverToType in (4,5,6)
		 and DTSent between @DateStart and @DateEnd
		 order by encontestar desc

		

-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = (Select avg(encontestar)  from #CTA)


    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel de Unidades  revisadas por dia


IF (@ShowDetail=1) 
	BEGIN
		
		Select manda as Usuario,
		avg(encontestar) as MinutosEnContestar
      
          from #CTA 
		  group by manda
		  order by MinutosEnContestar desc
   


	END


IF (@ShowDetail=2) 
	BEGIN
		Select 
      *
          from #CTA 
      
      
	END

GO
