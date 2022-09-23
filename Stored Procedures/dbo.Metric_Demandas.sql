SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Metric_Demandas] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	--PARAMETROS PROPIOS DE LA METRICA
    @Modo  varchar(20)  = 'RESUELTOS'                     --RESUELTOS,MONTOARREGLO,CUENTAASUNTOS,CUENTARESUELTOS
     
    --  @noproyecto varchar(255) = ''
       

)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Resueltos,2:EnCurso



	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #Demandas(
	        IdLitigio  int,
			 Expediente varchar(1000),  
			 Actor  varchar (1000),     
			 Demandado   varchar (1000),     
			 Causa    varchar(1000),       
			 FechaDemanda    datetime,      
			 FechaNotificacion datetime,    
			 Externo varchar(1000) ,   
			 Estatus    char,     
			 Audiencia    varchar(1000),       
			 FechaAudiencia datetime , 
			 Resolucion  varchar(1000) ,     
			 FechaResolucion  datetime,   
			 Observaciones varchar(1000), 
			 AudienciaAnt   varchar(1000) ,     
			 FechaAnterior  datetime ,   
			 MontoArreglo float ,          
			 Prestaciones varchar(1000),    
			 MontoPagare  float, 
			 FechaPAgare datetime ,    
			 Procesal   varchar(1000) ,     
			 FehaProcesal datetime )


	--Cargamos la tabla temporal con los datos de la consulta de la tabla de litigios

      INSERT INTO #Demandas

         

		 SELECT  
			 IdLitigio = id_litigio,
			 Expediente = expediente ,  
			 Actor = actor ,     
			 Demandado  =  demandado ,     
			 Causa =      causa ,       
			 FechaDemanda =    f_demanda ,      
			 FechaNotificacion = f_notificacion ,       
			 Externo =  externo ,   
			 Estatus =      estatus ,     
			 Audiencia =      audiencia ,       
			 FechaAudiencia = f_audiencia , 
			 Resolucion =   resolucion ,     
			 FechaResolucion =  f_resolucion ,   
			 Observaciones = observaciones , 
			 AudienciaAnt =   audiencia_ant ,     
			 FechaAnterior =  f_anterior ,   
			 MontoArreglo = monto_arreglo ,          
			 Prestaciones = prestaciones ,    
			 MontoPagare =  monto_pagare , 
			 FechaPAgare = fecha_pagare ,    
			 Procesal =    procesal ,     
			 FehaProcesal = f_procesal   
      

         FROM tdrsilt.dbo.legal_litigio     
    

        --   where
	

        -- Validacion de fechas 
		 -- f_demanda  >= @DateStart  and
       --   f_demanda  < @DateEnd 

-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    if @Modo In ('RESUELTOS','CUENTARESUELTOS')
     BEGIN
    SELECT @ThisCount = (Select count(Idlitigio) from #Demandas where estatus = 'C' )
     END
   else if @modo = 'MONTOARREGLO'
        BEGIN
    SELECT @ThisCount = (Select avg(MontoArreglo) from #Demandas where estatus = 'C' )
     END
  else if @modo = 'CUENTAASUNTOS'
        BEGIN
    SELECT @ThisCount =  (Select count(Idlitigio) from #Demandas )
     END
 


    if @Modo = 'RESUELTOS'
     BEGIN
    SELECT @ThisTotal = (Select count(Idlitigio) from #Demandas )
     END
   else if @modo IN ('MONTOARREGLO','CUENTARESUELTOS','CUENTAASUNTOS')
        BEGIN
    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END
     END


    


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel de  Estado

	IF (@ShowDetail=1)  
	BEGIN
		Select Expediente,
        FechaResolucion = (select f_resolucion from tdrsilt.dbo.legal_litigio     
        where idlitigio = ID_litigio) ,
        Resolucion = (select resolucion from tdrsilt.dbo.legal_litigio     
        where idlitigio = ID_litigio)  , 
        ACtor,Demandado, Causa, MontoArreglo =  '$' + dbo.fnc_TMWRN_FormatNumbers(MontoArreglo,2)
        from #demandas
        where estatus = 'C'
        order by  cast(MontoArreglo as int)  desc
      
	END

 IF (@ShowDetail=2)  

	BEGIN
		Select Expediente,FechaDemanda, ACtor,Demandado, Causa, MontoArreglo =  '$' + dbo.fnc_TMWRN_FormatNumbers(MontoArreglo,2)
        from #demandas
        where estatus = 'A'
        order by  cast(MontoArreglo as int)  desc
      
	END
GO
