SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Metric_DiasCorralon] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
    @Modo varchar (20),                         --UACUM,UVIVAS,ULIBE,DACUM,DVIVAS,DLIBE
	@ShowDetail int


     


)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down




	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #DiasCorralon(
	        Tractor varchar(10),Ingreso datetime,Salida datetime, DiasCorralon int, Descripcion varchar(500), Completada varchar(1), FechaCompletada datetime)
	

--Cargamos la tabla temporal con los datos de la consulta de la tabla de litigios

      INSERT INTO #DiasCorralon

   Select 
            Tractor = exp_id,
            Ingreso = exp_expirationdate ,
            Salida = exp_compldate,
            DiasCorralon = case when  exp_completed = 'Y' then datediff(d,exp_expirationdate,exp_compldate) else  datediff(d,exp_expirationdate,getdate()) end, 
            Descripcion = exp_description,
            Completada = exp_completed,
            FechaCompletada = exp_compldate
    
		         FROM expiration WITH (NOLOCK) 
		         WHERE exp_idtype='TRC' 
		         and exp_code in ('LEG') 
              

-------------------------CALCULO DEL NUMERADOR------------------------------------------------------------------------------------------------------------------

--CUENTA DE  TODAS LAS UNIDADES QUE HAN ESTADO EN EL CORRALON EN EL AÑO
If @modo = 'UACUM'
   BEGIN   
     SELECT @ThisCount =  (Select  count(tractor)  from #DiasCorralon where completada <> 'Y') +  (Select count(tractor) from #DiasCorralon where completada = 'Y' and year(FechaCompletada) = year(@dateStart) )
   END
--CUENTA DE UNIDADES AUN EN CORRALON
ELSE IF @modo = 'UVIVAS'
   BEGIN
     SELECT @ThisCount = (Select  count(tractor)  from #DiasCorralon where completada <> 'Y')
   END
--CUENTA DE UNIDADES LIBERADAS EN EL AÑO
ELSE IF @modo = 'ULIBE'
   BEGIN
      SELECT @ThisCount = (Select count(tractor) from #DiasCorralon where completada = 'Y' and year(FechaCompletada) = year(@dateStart) )
   END

------------********************METRICAS EN DIAS******************************************************************************************


--DIAS TRANSCURRIDOS EN CORRALON DE TODAS LAS UNIDADES ACUMULADAS EL AÑO 
ELSE IF @modo = 'DACUM'
   BEGIN
    SELECT @ThisCount =  ((Select AVG(DiasCorralon) from #DiasCorralon where completada <> 'Y') +  (Select AVG(diasCorralon) from #DiasCorralon where completada = 'Y' and year(FechaCompletada) = year(@dateStart) )) / 2
   END
--DIAS TRANSCURRIDOS EN CORRALON DE LAS UNIDADES AUN EN CORRALON
ELSE IF @modo = 'DVIVAS'
   BEGIN
    SELECT @ThisCount = (Select AVG(DiasCorralon) from #DiasCorralon where completada <> 'Y')
   END
--DIAS TRANSCURRIDOS EN CORRALON DE LAS UNIDADES LIBERADAS EN EL AÑO
ELSE IF @modo = 'DLIBE'
   BEGIN
     SELECT @ThisCount = (Select AVG(diasCorralon) from #DiasCorralon where completada = 'Y' and year(FechaCompletada) = year(@dateStart) )
   END

-------------------------CALCULO DEL DENOMINADOR------------------------------------------------------------------------------------------------------------------



    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


	IF (@ShowDetail=1)  and @modo  in ('UACUM','DACUM')

	BEGIN
	   (Select Tractor,Ingreso,Salida = 'En corralon', DiasCorralon,Descripcion  from #DiasCorralon where completada <> 'Y')
         UNION
       (Select Tractor,Ingreso,Salida = cast(Salida as varchar) ,DiasCorralon,Descripcion from #DiasCorralon where completada = 'Y'  and year(FechaCompletada) = year(@dateStart))
  
    order by DiasCorralon desc
            
	END
  
  else if (@ShowDetail=1)  and @modo  in ('UVIVAS','DVIVAS')

	BEGIN
		Select  Tractor,Ingreso,DiasCorralon,Descripcion
        from #DiasCorralon
        where completada <> 'Y'
  
        order by DiasCorralon desc
      
	END
 
  else if (@ShowDetail=1)  and @modo  in ('ULIBE','DLIBE')

	BEGIN
		Select  Tractor,Ingreso,Salida,DiasCorralon,Descripcion
        from #DiasCorralon
        where completada = 'Y'
        and year(FechaCompletada) = year(@dateStart)
  
        order by DiasCorralon desc
      
	END
GO
