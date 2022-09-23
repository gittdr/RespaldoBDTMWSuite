SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Metric_PayDetailsTarifa] (
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
-- DETAILOPTIONS=1:AutoVsManual,2:Proyecto,3:Operador,4:PayDetail,5:DetalleManual


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #COCT
    (Orden varchar(12),
	 Fecha datetime,
	 Proyecto varchar(12),
	 Operador varchar(200),
	 IdOperador varchar(20),
	 Item varchar(40),
	 Descripcion varchar(250),
	 Tarifa float,
	 Cantidad float,
	 IDTarifa varchar(10),
	 Tipo varchar(10)
	  )

	--Cargamos la tabla temporal con los datos de la consulta 


	 --PAYDETAILS

      INSERT INTO #COCT

	  select 
	  ord_hdrnumber as Orden,
	  pyd_transdate as Fecha,
	  '',
	  '',
	  '',
	  pyt_itemcode,
	  pyd_description,
	  pyd_rate,
	  pyd_amount,
	  tar_tarriffnumber,
	  case tar_tarriffnumber when null then 'Manual'  when '' then 'Manual' else 'Auto' end as Tipo   from PayDetail
	  where  pyd_transdate  between @DateStart and @DateEnd
	  and pyt_itemcode not in  ('TDDE','COMTAL')



	    --SE AGREGAN DATOS PROYECTO,OPERADOR y ID OPERADOR

	  update  #COCT set 
	   proyecto =  (select (select name from labelfile where labeldefinition = 'revtype3' and abbr=ord_revtype3) from orderheader (nolock) where ord_hdrnumber = orden),
	   operador = (select (select mpp_firstname + ' ' + mpp_lastname from manpowerprofile where mpp_id = ord_driver1) from orderheader (nolock) where ord_hdrnumber = orden),
	   IdOperador = (select  ord_driver1 from orderheader (nolock) where ord_hdrnumber = orden)


	


-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = case when  (Select count(*)  from  #COCT) = 0   then 0
	else  
	 (Select cast(count(*) as float) from  #COCT where Tipo = 'Auto')  / (Select cast(count(*)  as float) from  #COCT) 
	end


    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount  /  cast(@ThisTotal as float) END


--Detalle a Nivel de Unidades  revisadas por dia


--PAydetail Auto VS Manual

IF (@ShowDetail=1) 
	BEGIN

		SELECT (SELECT Count(*) from #COCT where Tipo= 'Auto') as Auto,
		(SELECT Count(*) from #COCT  where Tipo = 'Manual') as Manual
	
		
		
	END

	

--PAY DETAILS POR PROYECTO


IF (@ShowDetail=2) 
	BEGIN

		Select 
		 a.Proyecto,
		 (select count(*)  from #COCT r where r.Proyecto =a.Proyecto and Tipo = 'Manual' )  as Manual,
		 (select count(*) from #COCT r where r.Proyecto = a.Proyecto and Tipo = 'Auto' ) as Auto,
		 dbo.fnc_TMWRN_FormatNumbers((cast((select count(*) from #COCT r where r.Proyecto = a.Proyecto and Tipo= 'AUTO' ) as float) / cast((count(*)) as float (2)) )* 100,0)
		 + '%' as Porcentaje

          from #COCT a
		  where a.Proyecto <> ''
		  group by proyecto
		  order by 	 cast((select count(*) from #COCT r where r.Proyecto = a.Proyecto and Tipo = 'Auto') as float) / cast((count(*) ) as float (2))  desc, Auto


END


 --PAY DETAILS  POR OPERADOR

	IF (@ShowDetail=3) 
	BEGIN
		

		  Select 
		 a.Proyecto,
		 a.IdOperador,
		 a.Operador,
		  (select count(*)  from #COCT r where r.Proyecto =a.Proyecto and Tipo = 'Manual' and a.IdOperador = r.IdOperador )  as Manual,
		 (select count(*) from #COCT r where r.Proyecto = a.Proyecto and Tipo = 'Auto' and a.IdOperador = r.IdOperador ) as Auto,
		 dbo.fnc_TMWRN_FormatNumbers((cast((select count(*) from #COCT r where  r.Proyecto =a.Proyecto and r.IdOperador = a.IdOperador and Tipo = 'Auto' ) as float) / cast((count(*)) as float (2)) )* 100,0)
		 + '%' as Porcentaje

          from #COCT a
		  where a.Proyecto <> ''
		  group by proyecto,a.IdOperador,a.Operador
		  order by 	Proyecto, cast((select count(*) from #COCT r where r.IdOperador = a.IdOperador and tipo = 'Auto') as float) / cast((count(*) ) as float (2))  desc




	END





	 --PAY DETAILS POR TIPO PAYDETAIL

	IF (@ShowDetail=4) 
	BEGIN
		

		  Select 
		 a.Item,
		(select pyt_description from paytype where pyt_itemcode = a.Item) as Descripcion,
		  (select count(*)  from #COCT r where r.item = a.item and Tipo = 'Manual' )  as Manual,
		 (select count(*) from #COCT r where r.item = a.item and Tipo = 'Auto' ) as Auto,
		 dbo.fnc_TMWRN_FormatNumbers((cast((select count(*) from #COCT r where r.item = a.item and Tipo = 'Auto' ) as float) / cast((count(*)) as float (2)) )* 100,0)
		 + '%' as Porcentaje

          from #COCT a
		  group by item
		  order by  cast((select count(*) from #COCT r where r.item = a.item and tipo = 'Auto') as float) / cast((count(*) ) as float (2))  desc, auto desc




	END

	--DETALLE


	IF (@ShowDetail=5) 
	BEGIN
		Select 
          * 
          from #COCT
		  where Tipo = 'Manual'
		  order by Proyecto,IdOperador
		  
	END

GO
