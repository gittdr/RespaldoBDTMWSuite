SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[Metric_ProdRemolques] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,
    
  

	--PARAMETROS PROPIOS DE LA METRICA

	 @ConsiderarTemporales varchar(1)= 'S',      --S O N	
     @Modo varchar(12) = ''		         		-- kms o ingreso

   
)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Remolques,2:Tipo,3:Capacidad,4:Flota,5:Cliente


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
    --Set  @Patios = ',' + ISNULL(@Patios,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #ProdRemolques (
      Remolque varchar (20),
      Kilometros int,
      Ingreso float,
      Orden varchar (10),
      Capacidad varchar (10),
      Tipo varchar (25),
      Flota varchar (30),
      Cliente varchar (20)
      
    )


	--Cargamos la tabla temporal con los datos de la consulta de la tabla de accidente_costo_Gasto

  

--insertamos los valores para los remolques primeros

INSERT INTO #ProdRemolques  

     select 
		Remolque = lgh_primary_trailer
		,Kilometros = lgh_miles
        -- en el caso de que se trate de un FULL Vamos a dividir el ingreso entre 2 debido a las 2 cajas
		,Ingreso =  case when lgh_primary_pup <> 'UNKNOWN'  then (lgh_ord_charge)/2 else lgh_ord_charge end
		,Orden = ord_hdrnumber
        ,Capacidad= ( select trl_type2 from trailerprofile where trl_id = lgh_primary_trailer)
        ,Tipo= ( select trl_type1 from trailerprofile where trl_id = lgh_primary_trailer)
        ,Flota = (select name from labelfile where labeldefinition = 'Fleet' and abbr =(select trl_fleet from trailerprofile where trl_id = lgh_primary_trailer))
        ,Cliente = ( select ord_billto from orderheader where orderheader.ord_hdrnumber  = legheader.ord_hdrnumber)

	from legheader
   where lgh_enddate > @DateStart AND lgh_startdate < @DateEnd
   and lgh_primary_trailer <> 'UNKNOWN'
   and ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_status = 'CMP')


--insertamos los remolques segundos en caso de un FULL

  INSERT INTO #ProdRemolques  

     select 
		Remolque = lgh_primary_pup 
		,Kilometros = lgh_miles
        --como se trata de una segunda caja Vamos a dividir el ingreso entre 2
		,Ingreso =  (lgh_ord_charge/2)
		,Orden = ord_hdrnumber
        ,Capacidad= ( select trl_type2 from trailerprofile where trl_id = lgh_primary_pup)
        ,Tipo= ( select trl_type1 from trailerprofile where trl_id = lgh_primary_pup)
        ,Flota = (select name from labelfile where labeldefinition = 'Fleet' and abbr =(select trl_fleet from trailerprofile where trl_id = lgh_primary_pup))
        ,Cliente = ( select ord_billto from orderheader where orderheader.ord_hdrnumber  = legheader.ord_hdrnumber)

	from legheader
   where lgh_enddate > @DateStart AND lgh_startdate < @DateEnd
   and lgh_primary_pup   <> 'UNKNOWN'
   and ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_status = 'CMP')



--borramos los registros de los remolques temporales si el parametro es no considerarlos

if @considerartemporales = 'N'
 BEGIN 
  delete from #ProdRemolques  where Remolque in (select trl_id from trailerprofile where trl_quickentry = 'Y')
 END

-- Asignar valores a variable de numerador, denominador y resultado de la metrica

If @modo = 'kms' 
 BEGIN

    SELECT @ThisCount = (Select avg(kilometros) from #ProdRemolques  )

    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END
 END

else if @modo = 'ingreso'
 BEGIN 
 
    SELECT @ThisCount = (Select avg(ingreso) from #ProdRemolques  )

    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END

 END

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


-----Despliegue del detalle del resultado de la metrica----------------------------------------------------------------------------------------------------------------

--Detalle a Nivel de Remolque
	IF (@ShowDetail=1) 
	BEGIN
		Select  
          Remolque
          ,Kms =  dbo.fnc_TMWRN_FormatNumbers(Kilometros,2)
          ,Ingresos = ('$' + dbo.fnc_TMWRN_FormatNumbers(Ingreso,2))
          ,Orden
          ,Flota

		From   #ProdRemolques
        order by Ingreso DESC
	END
   

--Detalle a Nivel de Tipo
		IF (@ShowDetail=2) 
	BEGIN
		Select  
           Tipo = (select name from labelfile where labeldefinition  = 'TrlType1'  and abbr = Tipo)
          ,Kms =  dbo.fnc_TMWRN_FormatNumbers(avg(Kilometros),2)
          ,Ingresos = ('$' + dbo.fnc_TMWRN_FormatNumbers(avg(Ingreso),2))

		From   #ProdRemolques
        group by Tipo
        order by avg(ingreso) desc
	END
   
--Detalle a Nivel de Capacidad
	IF (@ShowDetail=3) 
	BEGIN
		Select  
          Capacidad
          ,Kms =  dbo.fnc_TMWRN_FormatNumbers(avg(Kilometros),2)
          ,Ingresos = ('$' + dbo.fnc_TMWRN_FormatNumbers(avg(Ingreso),2))

		From   #ProdRemolques
        group by capacidad
        order by avg(ingreso) desc
	END
   


--Detalle a Nivel de Flota
	IF (@ShowDetail=4) 
	BEGIN
		Select  
          Flota
          ,Kms =  dbo.fnc_TMWRN_FormatNumbers(avg(Kilometros),2)
          ,Ingresos = ('$' + dbo.fnc_TMWRN_FormatNumbers(avg(Ingreso),2))

		From   #ProdRemolques
        group by Flota
       order by avg(ingreso) desc
	END
   
--Detalle a Nivel de Cliente
	IF (@ShowDetail=5) 
	BEGIN
		Select  
          Cliente
          ,Kms =  dbo.fnc_TMWRN_FormatNumbers(avg(Kilometros),2)
          ,Ingresos = ('$' + dbo.fnc_TMWRN_FormatNumbers(avg(Ingreso),2))

		From   #ProdRemolques
        group by Cliente
        order by avg(ingreso) desc
	END
   
GO
