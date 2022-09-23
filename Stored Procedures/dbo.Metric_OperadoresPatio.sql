SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*
Autor: Emilio Olvera Yanez
Rev: 18 junio 2015.
ver 3.0

metrica que calcula operadores disponibles por patio.

en la version 3.0 se incluyo se pueda utilizar como parametro la sucursal
a la cual pertenece la compañaia en la que va a quedar disponible el remolque.

*/

CREATE  PROCEDURE [dbo].[Metric_OperadoresPatio] (
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
		@Sucursales varchar(100) = 'TODOS',		         -- QRO,MEX,GUD,MTE,LAD,UNK
		@Patios varchar(100) = 'TODOS'		         		-- ID DE LOS PATIOS QUE SE QUIEREN MEDIR O TODOS
       

)

AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Operadores


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Sucursales = ',' + ISNULL(@Patios,'') + ','
	  Set  @Patios = ',' + ISNULL(@Patios,'') + ','



	-- Creación de la tabla temporal

	CREATE TABLE #OpPatios (
      Operador varchar (20),
      Fecha datetime,
      Dias int,
      Patio varchar(20),
      Region varchar(20),
      DriverStatus varchar(6),
      Proyecto varchar (20) )


	--Cargamos la tabla temporal con los datos de la consulta de la tabla de accidente_costo_Gasto


    

IF @Patios = ',TODOS,' and @Sucursales = 'TODOS'
 BEGIN

  INSERT INTO #OpPatios  

     SELECT   
        Operador = mpp_id, 
        Fecha = mpp_avl_date, 
        Dias = DATEDIFF(dd, mpp_avl_date, GETDATE()),
        Patio = mpp_avl_cmp_id,
        Region =   (select rgh_name from regionheader where rgh_id =(select cmp_region1 from company  where cmp_ID =  mpp_avl_cmp_id)),
        DriverStatus=  mpp_status,
        Proyecto= mpp_type3


        FROM    dbo.manpowerprofile
        WHERE     (mpp_status not in ('OUT','BAJAA')) 
			and DATEDIFF(dd, mpp_avl_date, GETDATE()) >0 
			and mpp_id not in ('PEPE', 'TDRTD')
		

END

 ELSE  IF @Patios = ',TODOS,' and @Sucursales  <>  'TODOS'


 BEGIN

    
  INSERT INTO #OpPatios  

        SELECT   
        Operador = mpp_id, 
        Fecha = mpp_avl_date, 
        Dias = DATEDIFF(dd, mpp_avl_date, GETDATE()),
        Patio = mpp_avl_cmp_id,
        Region =   (select rgh_name from regionheader where rgh_id =(select cmp_region1 from company  where cmp_ID =  mpp_avl_cmp_id)),
        DriverStatus=  mpp_status,
        Proyecto= mpp_type3


        FROM    dbo.manpowerprofile
        WHERE     (mpp_status not in ('OUT','BAJAA'))  
		AND (select cmp_revtype2 from company where cmp_id =mpp_avl_cmp_id)  = @Sucursales
		and mpp_id not in ('PEPE', 'TDRTD')
		and DATEDIFF(dd, mpp_avl_date, GETDATE()) >0 
		
		END


        --Filtrado de fechas-----------
        --como se presentara la medida como una foto de la cantidad de remolques en los patios no consideremos ventanas de tiempo sino el total, la metrica no actualizara el pasado.
 

       --si  solo cuenta inactivos es igual a 'S' entonces borramos los que son menores a @DiasConsiderarInactivo
        IF    @SoloCuentaInactivos = 'S'
         BEGIN
         delete from #OpPatios where dias < ( @OmitirdiasVentana) and dias > ( @OmitirdiasVentana*-1)
        END


  
   
-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = (Select count(Operador) from #Oppatios)

    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


-----Despliegue del detalle del resultado de la metrica----------------------------------------------------------------------------------------------------------------

--Detalle a Nivel de Remolque
	IF (@ShowDetail=1 and @SoloCuentaInactivos = 'S') 
	BEGIN
		Select 
              *
			  ,(select mpp_tractornumber from manpowerprofile where mpp_id = Operador) as Tractror
			  ,(select cmp_revtype2 from company where cmp_id = Operador)  as Sucursal

		From  #Oppatios
        order by dias desc --(select cmp_revtype2 from company where cmp_id = Operador), dias desc
 
	END
 

GO
