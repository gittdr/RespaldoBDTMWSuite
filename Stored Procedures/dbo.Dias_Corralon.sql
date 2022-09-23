SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Dias_Corralon] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int

	--PARAMETROS PROPIOS DE LA METRICA
    --@Modo  varchar(20)  = 'RESUELTOS'                     --RESUELTOS,MONTOARREGLO
     
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

	CREATE TABLE #DiasCorralon(
	        Tractor varchar(10),Ingreso datetime,Salida datetime, DiasCorralon int, Descripcion varchar(500))
	--Cargamos la tabla temporal con los datos de la consulta de la tabla de litigios

      INSERT INTO #DiasCorralon

         
	Select 
            Tractor = exp_id,
            Ingreso = exp_creatdate ,
            Salida = exp_compldate,
            DiasCorralon = datediff(d,exp_creatdate,exp_compldate),
            Descripcion = exp_description
		         FROM tdrsilt.dbo.expiration WITH (NOLOCK) 
		         WHERE exp_idtype='TRC' 
		         and exp_code not in ('OUT','ICFM')   and
                 exp_description like '%Corral%n%'and exp_completed = 'Y' 

        --   where
	

        -- Validacion de fechas 
		 -- f_demanda  >= @DateStart  and
       --   f_demanda  < @DateEnd 

-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    
    SELECT @ThisCount = (Select avg(DiasCorralon) from #DiasCorralon )



    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END




	IF (@ShowDetail=1)  

	BEGIN
		Select *
        from #DiasCorralon
  
        order by DiasCorralon desc
      
	END

 
GO
