SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Metric_ConvoyOrdenesCerradas] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	--PARAMETROS PROPIOS DE LA METRICA
    @Division  varchar(20)  = 'TODAS',     --ABI,DED,ESP
	@Proyecto varchar(20) = 'TODOS'

     
      --@noproyecto varchar(255) = ''
       

)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:TotailMailVsUsuario,2:Proyecto,3:Operador,4:Detalle


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #COCT
    (Segmento varchar(12),
	 FechaCierre datetime,
	 Proyecto varchar(12),
	 Division varchar(12),
	 Operador varchar(200),
	 IdOperador varchar(20),
	 Updateby varchar(10)
	  )

	



	--Cargamos la tabla temporal con los datos de la consulta 


	 --ORDENES DEL DIA ACTUALIZADAS POR TOTALMAIL

      INSERT INTO #COCT

	  select 
	  lgh_number,
	  stp_departuredate,
	  '' as Proyecto,
		 '' as Division,
		 '' as Operador,
		 '' as IdOperador,
		 'TMAIL' as Updatedby
	  from stops a where 
	  stp_mfh_sequence = (select max(stp_mfh_sequence) from stops b (nolock) where a.lgh_number = b.lgh_number)
	  and lgh_number in (select lgh_number from legheader (nolock) where lgh_outstatus = 'CMP' and lgh_enddate between @DateStart and @DateEnd)
	  and stp_departuredate between @DateStart and @DateEnd
	  and stp_tmstatus = 'OK'


	
	    --SE AGREGAN DATOS PROYECTO,OPERADOR y ID OPERADOR

	  update  #COCT set 
	   proyecto =  (select (select mpp_type3 from manpowerprofile where mpp_id = lgh_driver1) from legheader (nolock) where lgh_number= segmento),
	   Division = (select (select mpp_type4 from manpowerprofile where mpp_id = lgh_Driver1) from legheader (nolock) where lgh_number= segmento),
	   operador = (select (select mpp_firstname + ' ' + mpp_lastname from manpowerprofile where mpp_id = lgh_Driver1) from legheader (nolock) where lgh_number= segmento),
	   IdOperador = (select  lgh_driver1 from legheader (nolock) where  lgh_number= segmento)


	  --ORDENES DEL DIA NO ACTUALIZADAS POR TOTALMAIL

	  INSERT INTO #COCT

	   select 
	      lgh_number as segmento,
		  lgh_enddate as FechaCierre,
		  (select mpp_type3 from manpowerprofile where mpp_id = lgh_driver1) as Proyecto,
		  (select mpp_type4 from manpowerprofile where mpp_id = lgh_driver1) as Division,
		  (select (select mpp_firstname + ' ' + mpp_lastname from manpowerprofile where mpp_id = lgh_driver1)) as Operador,
		  lgh_driver1 as IdOperador,
		  'TMWUSER' as Updatedby
       from legheader (nolock) 
	   where lgh_enddate between @DateStart and @DateEnd
	   and lgh_outstatus = 'CMP'
	   and lgh_number not in (select Segmento from #COCT)
	


	   delete #COCT where IdOperador in ('UNKNOWN','PEPE')


	   if (@Division <> 'TODAS') 
	    BEGIN
	      delete  #COCT where Division <> @Division
		END

		if (@Proyecto <> 'TODOS') 
		 delete #COCT where Proyecto <> @Proyecto



-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = case when  (Select count(*)  from  #COCT) = 0   then 0
	else  
	 (Select cast(count(*) as float) from  #COCT where Updateby = 'TMAIL')  / (Select cast(count(*) as float) from  #COCT)
	end


    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount  /  cast(@ThisTotal as float) END


--Detalle a Nivel de Unidades  revisadas por dia


--ORDENES TOTALMAIL VS USUARIO

IF (@ShowDetail=1) 
	BEGIN

		SELECT (SELECT Count(*) from #COCT where Updateby = 'TMAIL') as TotalMail,
		(SELECT Count(*) from #COCT  where Updateby = 'TMWUSER') as Usuarios
	
		
		
	END

	

--ORDENES POR PROYECTO


IF (@ShowDetail=2) 
	BEGIN

		Select 
		 (select name from labelfile where abbr = a.Proyecto and labeldefinition = 'Drvtype3') as Proyecto,
		 (select count(*)  from #COCT r where r.Proyecto =a.Proyecto and Updateby = 'TMWUSER' )  as SegmentosTMW,
		 (select count(*) from #COCT r where r.Proyecto = a.Proyecto and Updateby = 'TMAIL' ) as SegmentosConvoy,
		 dbo.fnc_TMWRN_FormatNumbers((cast((select count(*) from #COCT r where r.Proyecto = a.Proyecto and Updateby = 'TMAIL' ) as float) / cast((count(*)) as float (2)) )* 100,0)
		 + '%' as Porcentaje

          from #COCT a
		  group by proyecto
		  order by 	 cast((select count(*) from #COCT r where r.Proyecto = a.Proyecto and Updateby = 'TMAIL') as float) / cast((count(*) ) as float (2))  desc


END


 --ORDENES POR OPERADOR

	IF (@ShowDetail=3) 
	BEGIN
		

		  Select 
		  (select name from labelfile where abbr = a.Proyecto and labeldefinition = 'Drvtype3') as Proyecto,
		 a.IdOperador,
		 a.Operador,
		 (select count(*)  from #COCT r where r.IdOperador =a.IdOperador and Updateby = 'TMWUSER' )  as SegmentosTMW,
		 (select count(*) from #COCT r where r.IdOperador = a.IdOperador and Updateby = 'TMAIL' ) as SegmentosConvoy,
		 dbo.fnc_TMWRN_FormatNumbers((cast((select count(*) from #COCT r where r.IdOperador = a.IdOperador and Updateby = 'TMAIL' ) as float) / cast((count(*)) as float (2)) )* 100,0)
		 + '%' as Porcentaje

          from #COCT a
		  group by proyecto,a.IdOperador,a.Operador
		  order by 	Proyecto, cast((select count(*) from #COCT r where r.IdOperador = a.IdOperador and Updateby = 'TMAIL') as float) / cast((count(*) ) as float (2))  desc




	END


	IF (@ShowDetail=4) 
	BEGIN
		Select 
		(Select ord_hdrnumber from legheader (nolock) where segmento = lgh_number) as Orden,
      * 
          from #COCT
		  order by Proyecto,IdOperador
		  
	END


	
GO
