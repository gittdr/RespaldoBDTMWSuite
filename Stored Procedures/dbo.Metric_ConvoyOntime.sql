SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  PROCEDURE [dbo].[Metric_ConvoyOntime] (
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
-- DETAILOPTIONS=1:Proyecto,2:Operador,3:Detalle


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #COCT
    (Orden varchar(12),
	 leg varchar(21),
	 Fecha datetime,
	 Ontimes int,
	 Stops int,
	 Proyecto varchar(12),
	 Operador varchar(200),
	 IdOperador varchar(20)
	  )


   --LLENAMOS TABLA CON LAS ORDENES ACTUALIZADAS POR TOTALMAIL
	insert into #COCT
	
	select
	  ord_hdrnumber as Orden,
	  '',
	  '',
	  0,
	  0,
	  '',
	  '',
	  ''
	  from expedite_audit_tbl where activity  = 'OrderHeader update'
      and updated_by = 'totalmail' and update_note  = 'Status STD -> CMP'
	  and ord_hdrnumber <> 0
	  and updated_dt between @DateStart and @DateEnd
      group by ord_hdrnumber,activity


	 --HACEMOS UPDATE A LA TABLA TEMPORAL CON LOS DATOS FALTANTANTES DE ORDENES DEL DIA NO COHERENTES


	 update #COCT set leg = (select min(lgh_number) from legheader (nolock) where ord_hdrnumber = orden)
	 update #COCT set fecha = (select lgh_startdate from legheader (nolock) where lgh_number = leg) 

	 update #COCT set Ontimes = (select count(*) from stops (nolock) where stp_arrivaldate  between stp_schdtearliest and stp_schdtlatest and stops.lgh_number = leg and ord_hdrnumber <> 0)
	 update #COCT set Stops = (select count(*) from stops (nolock) where  stops.lgh_number = leg)

	 update #COCT set IdOperador = (select lgh_driver1 from legheader (nolock) where  lgh_number = leg )
	 update #COCT set Proyecto = (select name from labelfile where labeldefinition = 'revtype3' and abbr = (Select ord_revtype3 from orderheader (nolock) where ord_hdrnumber = orden))
	 update #COCT set Operador = ( select  mpp_firstname+' ' + mpp_lastname from manpowerprofile where mpp_id =  IDOperador)


-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = case when  (Select count(*)  from  #COCT  ) = 0   then 0
	else  
	 (Select cast(sum(Ontimes) as float) from  #COCT )  / (Select cast(sum(Stops) as float) from   #COCT)
	end


    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount  /  cast(@ThisTotal as float) END


--Detalle



	

--ORDENES POR PROYECTO


IF (@ShowDetail=1) 
	BEGIN

		Select 
		 a.Proyecto,
		 sum(Ontimes) as StopsOntime,
		 sum(Stops) as StopsTotales,
		 dbo.fnc_TMWRN_FormatNumbers((cast((sum(Ontimes) ) as float) / cast(sum(stops) as float (2)) )* 100,0)
		 + '%' as Ontime

          from #COCT a
		  group by proyecto
		  order by 	 sum(Ontimes)/sum(stops) desc


END


 --ORDENES POR OPERADOR

	IF (@ShowDetail=2) 
	BEGIN
		

		  Select 
		 a.Proyecto,
		 a.IdOperador,
		 a.Operador,
		 sum(Ontimes) as StopsOntime,
		 sum(Stops) as StopsTotales,
		 dbo.fnc_TMWRN_FormatNumbers((cast((sum(Ontimes) ) as float) / cast(sum(stops) as float (2)) )* 100,0)
		 + '%' as Ontime

          from #COCT a
		  group by proyecto,a.IdOperador,a.Operador
		  order by 	sum(Ontimes)/sum(stops) desc




	END


	IF (@ShowDetail=3) 
	BEGIN
		Select 
           * 
          from #COCT
		  order by Proyecto,IdOperador
		  
	END


	
GO
