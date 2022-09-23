SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
Autor: Emilio Olvera Yanez
Rev: 8 junio 2015.
ver 3.0

metrica que calcula remolques disponibles por patio.

en la version 3.0 se incluyo se pueda utilizar como parametro la sucursal
a la cual pertenece la compañaia en la que va a quedar disponible el remolque.

*/

CREATE  PROCEDURE [dbo].[Metric_RemolquesPatio] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,
    
  

	--PARAMETROS PROPIOS DE LA METRICA

       
        @SoloCuentaInactivos  varchar(1) = 'N',			-- S o N
		@OmitirdiasVentana    int = 6 ,                -- VENTANA DE DIAS A OMITIR ENTRE EL -NUMERO Y EL +NUMERO
        @ConsiderarTemporales  varchar(1) = 'S',	    -- S o N
        @TipoRemolque varchar (70) = 'TODOS',            --TODOS,TNQ,THO,VOL,DLL,PLT,CHS,CRF,CSC,CAME
		@Sucursales varchar(100) = 'TODOS',		         -- QRO,MEX,GUD,MTE,LAD,UNK
		@Patios varchar(100) = 'TODOS'		         		-- ID DE LOS PATIOS QUE SE QUIEREN MEDIR O TODOS
       

)

AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Remolques,2:Tipo,3:Capacidad,4:Temporales,5:Region


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Sucursales = ',' + ISNULL(@Patios,'') + ','
	  Set  @Patios = ',' + ISNULL(@Patios,'') + ','
      Set  @TipoRemolque = ',' + ISNULL(@TipoRemolque,'') + ','



	-- Creación de la tabla temporal

	CREATE TABLE #RemPatios (
      Remolque varchar (20),
      Fecha datetime,
      Dias int,
      CapturaRapida varchar(3),
      Patio varchar(20),
      Region varchar(20),
      TrailerStatus varchar(6),
      Capacidad varchar(10),
      Tipo varchar(20), 
      Proyecto varchar (20),
      temporal varchar (2) )


	--Cargamos la tabla temporal con los datos de la consulta de la tabla de accidente_costo_Gasto


    

IF @Patios = ',TODOS,' and @Sucursales = 'TODOS'
 BEGIN

  INSERT INTO #RemPatios  

     SELECT   
        Remolque = trl_number, 
        Fecha = trl_avail_date, 
        Dias = DATEDIFF(dd, trl_avail_date, GETDATE()),
        CapturaRapida =  trl_quickentry,
        Patio = trl_avail_cmp_id,
        Region =   (select rgh_name from regionheader where rgh_id =(select cmp_region1 from company  where cmp_ID =  trl_avail_cmp_id)),
        TrailerStatus=  trl_status,
        Capacidad=trl_type2,
        Tipo=trl_type1,
        Proyecto= trl_type3,
        Temporal = trl_quickentry

        FROM    dbo.trailerprofile
        WHERE     (trl_status not in ('OUT')) 

END

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ELSE  IF @Patios = ',TODOS,' and @Sucursales  <>  'TODOS'


 --Validaciones para que inserte los datos pertenecientes a la sucursal en base a sus regiones que le pertenecen

 BEGIN

  if @Sucursales = 'LAD'
   begin
   INSERT INTO #RemPatios
    
        SELECT 
        Remolque = trl_number, 
        Fecha = trl_avail_date, 
        Dias = DATEDIFF(dd, trl_avail_date, GETDATE()),
        CapturaRapida =  trl_quickentry,
        Patio = trl_avail_cmp_id,
         Region =   (select rgh_name from regionheader where rgh_id =(select cmp_region1 from company  where cmp_ID =  trl_avail_cmp_id)),
        TrailerStatus=  trl_status,
        Capacidad=trl_type2,
        Tipo=trl_type1,
        Proyecto= trl_type3,
        Temporal = trl_quickentry 

        FROM    dbo.trailerprofile
        WHERE     (trl_status not in ('OUT')) 
		AND 
	    ((select  cmp_region1 from company where cmp_id =trl_avail_cmp_id) in ('NV'))
       end
	 
 if @Sucursales = 'GUD'
   begin
   INSERT INTO #RemPatios
    
        SELECT 
        Remolque = trl_number, 
        Fecha = trl_avail_date, 
        Dias = DATEDIFF(dd, trl_avail_date, GETDATE()),
        CapturaRapida =  trl_quickentry,
        Patio = trl_avail_cmp_id,
         Region =   (select rgh_name from regionheader where rgh_id =(select cmp_region1 from company  where cmp_ID =  trl_avail_cmp_id)),
        TrailerStatus=  trl_status,
        Capacidad=trl_type2,
        Tipo=trl_type1,
        Proyecto= trl_type3,
        Temporal = trl_quickentry 

        FROM    dbo.trailerprofile
        WHERE     (trl_status not in ('OUT')) 
		AND 
	    ((select  cmp_region1 from company where cmp_id =trl_avail_cmp_id) in ('GD','CU'))
       end
	 
	   
 if @Sucursales = 'MEX'
   begin
   INSERT INTO #RemPatios
   
     SELECT 
        Remolque = trl_number, 
        Fecha = trl_avail_date, 
        Dias = DATEDIFF(dd, trl_avail_date, GETDATE()),
        CapturaRapida =  trl_quickentry,
        Patio = trl_avail_cmp_id,
         Region =   (select rgh_name from regionheader where rgh_id =(select cmp_region1 from company  where cmp_ID =  trl_avail_cmp_id)),
        TrailerStatus=  trl_status,
        Capacidad=trl_type2,
        Tipo=trl_type1,
        Proyecto= trl_type3,
        Temporal = trl_quickentry 

        FROM    dbo.trailerprofile
        WHERE     (trl_status not in ('OUT')) 
		AND 
	    ((select  cmp_region1 from company where cmp_id =trl_avail_cmp_id)  in ('MA','MX','PB','VH'))
       end

 if @Sucursales = 'MTE'
    begin
   INSERT INTO #RemPatios
   
        SELECT 
        Remolque = trl_number, 
        Fecha = trl_avail_date, 
        Dias = DATEDIFF(dd, trl_avail_date, GETDATE()),
        CapturaRapida =  trl_quickentry,
        Patio = trl_avail_cmp_id,
         Region =   (select rgh_name from regionheader where rgh_id =(select cmp_region1 from company  where cmp_ID =  trl_avail_cmp_id)),
        TrailerStatus=  trl_status,
        Capacidad=trl_type2,
        Tipo=trl_type1,
        Proyecto= trl_type3,
        Temporal = trl_quickentry 

        FROM    dbo.trailerprofile
        WHERE     (trl_status not in ('OUT')) 
		AND 
	    ((select  cmp_region1 from company where cmp_id =trl_avail_cmp_id)  in ('MT','CH','TJ'))
       end

else if @Sucursales = 'QRO'
  
    begin

	   INSERT INTO #RemPatios
   
        SELECT 
        Remolque = trl_number, 
        Fecha = trl_avail_date, 
        Dias = DATEDIFF(dd, trl_avail_date, GETDATE()),
        CapturaRapida =  trl_quickentry,
        Patio = trl_avail_cmp_id,
         Region =   (select rgh_name from regionheader where rgh_id =(select cmp_region1 from company  where cmp_ID =  trl_avail_cmp_id)),
        TrailerStatus=  trl_status,
        Capacidad=trl_type2,
        Tipo=trl_type1,
        Proyecto= trl_type3,
        Temporal = trl_quickentry 

        FROM    dbo.trailerprofile
        WHERE     (trl_status not in ('OUT')) 
		AND 
	    ((select  cmp_region1 from company where cmp_id =trl_avail_cmp_id)  in ('QR'))
       end
	   	

END
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




        --Filtrado de fechas-----------
        --como se presentara la medida como una foto de la cantidad de remolques en los patios no consideremos ventanas de tiempo sino el total, la metrica no actualizara el pasado.
 

       --si  solo cuenta inactivos es igual a 'S' entonces borramos los que son menores a @DiasConsiderarInactivo
        IF    @SoloCuentaInactivos = 'S'
         BEGIN
         delete from #RemPatios where dias < ( @OmitirdiasVentana) and dias > ( @OmitirdiasVentana*-1)
        END


   --si  no se consideran los temporales los eliminamos
        IF    @ConsiderarTemporales  = 'N'
         BEGIN
         delete from #RemPatios where temporal = 'Y'
        END

  --Si se parametriza por tipo de remolque eliminamos todos los remolques que no sean del tipo 
        IF  @TipoRemolque <> ',TODOS,'
         BEGIN
         delete from #RemPatios where (@TipoRemolque =',,' or CHARINDEX(',' + tipo + ',', @TipoRemolque) <= 0)
        END

   delete  from #RemPatios where REMOLQUE = 'UNKNOWN'
   
-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = (Select count(Remolque) from #Rempatios)

    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


-----Despliegue del detalle del resultado de la metrica----------------------------------------------------------------------------------------------------------------

--Detalle a Nivel de Remolque
	IF (@ShowDetail=1 and @SoloCuentaInactivos = 'S') 
	BEGIN
		Select 
               Remolque,
               Region,
               Patio,
               Fecha,
               Dias,
               RemolquesTemporales = case CapturaRapida when 'N' then 'NO TEMPORALES' else 'TEMPORALES' end,
               TrailerStatus,
               Capacidad,
               Tipo = (select name from labelfile where labeldefinition  = 'TrlType1'  and abbr = Tipo)

		From  #Rempatios
        order by dias desc
 
	END
   ELSE IF (@ShowDetail=1 and @SoloCuentaInactivos = 'N') 
    	BEGIN
		Select Remolque,
               Fecha,
               Dias,
               RemolquesTemporales = case CapturaRapida when 'N' then 'NO TEMPORALES' else 'TEMPORALES' end,
               TrailerStatus,
               Capacidad,
               Tipo = (select name from labelfile where labeldefinition  = 'TrlType1'  and abbr = Tipo)

		From  #Rempatios
        order by dias desc
 
	END
 

--Detalle a Nivel de Tipo
	IF (@ShowDetail=2 and @SoloCuentaInactivos = 'S')  
	BEGIN
		Select 
               Patio,
               Tipo = (select name from labelfile where labeldefinition  = 'TrlType1'  and abbr = Tipo),
               Cantidad = count (Remolque)

		From  #Rempatios
        group by Patio,Tipo
        order by Tipo, Cantidad desc

	END
	ELSE IF (@ShowDetail=2 and @SoloCuentaInactivos = 'N') 
	BEGIN
		Select 
               Tipo = (select name from labelfile where labeldefinition  = 'TrlType1'  and abbr = Tipo),
               Cantidad = count (Remolque)

		From  #Rempatios
        group by Tipo
        order by Tipo, Cantidad desc

	END


--detale a nivel de Capacidad


 IF (@ShowDetail=3 and @SoloCuentaInactivos = 'S') 
	BEGIN
		Select 
               Patio,
               Capacidad,
               Cantidad = count (Remolque)

		From  #Rempatios
        group by  PAtio,Capacidad
       order by Capacidad, Cantidad desc

	END
 ELSE IF (@ShowDetail=3 and @SoloCuentaInactivos = 'N') 
	BEGIN
		Select 
               Capacidad,
               Cantidad = count (Remolque)

		From  #Rempatios
        group by  Capacidad
        order by Capacidad, Cantidad desc

	END


--detalle a nivel de Temporales.

 IF (@ShowDetail=4 and @SoloCuentaInactivos = 'S') 
	BEGIN
		Select 
               Patio,
               RemolquesTemporales = case CapturaRapida when 'N' then 'NO TEMPORALES' else 'TEMPORALES' end,
               Cantidad = count (Remolque)

		From  #Rempatios
        group by Patio,CapturaRapida
        order by CapturaRapida, Cantidad desc
	END


 ELSE IF (@ShowDetail=4 and @SoloCuentaInactivos = 'N') 
	BEGIN
		Select 
               RemolquesTemporales = case CapturaRapida when 'N' then 'NO TEMPORALES' else 'TEMPORALES' end,
               Cantidad = count (Remolque)

		From  #Rempatios
        group by CapturaRapida
        order by CapturaRapida, Cantidad desc
	END


--detalle a nivel de Regiones.

 IF (@ShowDetail=5 and @SoloCuentaInactivos = 'S') 
	BEGIN
		Select 
               Region,
               Cantidad = count (Remolque)

		From  #Rempatios
        group by Region
        order by Cantidad desc
	END


 ELSE IF (@ShowDetail=5 and @SoloCuentaInactivos = 'N') 
	BEGIN
		Select 
               Region,
               Cantidad = count (Remolque)

		From  #Rempatios
        group by Region
        order by Cantidad desc
	END


GO
