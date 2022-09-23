SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Metric_LlantasCostoKm] (
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
-- DETAILOPTIONS=1:Llantas,2:Marca,3:Medida,4:Causa


	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


------------------ Creación de la tabla temporal

	CREATE TABLE #Costokm
    (economico varchar (200),
     marca varchar (200),
     tipo varchar(200),
     kms int,
     precio float,
     medida varchar(500),
     costokm float,
     renovados int,
     ponchaduras int,
     causa varchar(500), 
     fecha datetime)

-------------------Creacion tabla alterna subconsultas

	CREATE TABLE #PCostokm
    (peconomico varchar (200),
     pmarca varchar (200),
     ptipo varchar(200),
     pkms int,
     pprecio float,
     pmedida varchar(500),
     pcostokm float,
     prenovados int,
     pponchaduras int,
     pcausa varchar(500), 
     fecha datetime)

 

---------------------Cargamos la tabla temporal con los datos de la consulta 


      INSERT INTO #CostoKm

      select 
      ECONOMICO = no_economico
      , MARCA = (select max(nombre) from tdrsilt.dbo.llantas_marcas where tdrsilt.dbo.llantas_marcas.id_marca = tdrsilt.dbo.llantas.id_marca)
      ,TIPO = (select max(nombre) from tdrsilt.dbo.llantas_tipos where tdrsilt.dbo.llantas_tipos.id_tipo = tdrsilt.dbo.llantas.id_tipo)
      ,KMS = kms_acumulados
      ,PRECIO = (precio_llanta + costos_acumulados)
      ,MEDIDA = medida
      ,COSTOKM = ((precio_llanta + costos_acumulados)/ replace(isnull(kms_acumulados,1),0,1))
      ,RENOVADOS = renovados
      ,PONCHADURAS = ponchaduras
      ,CAUSA = (select max(descripcion) from tdrsilt.dbo.llantas_mont_desmont  where id_causa = (select max(id_causa) from tdrsilt.dbo.llantas_mvtos  where  destino = 'D' and fecha between @datestart and @dateend and tdrsilt.dbo.llantas.no_economico = tdrsilt.dbo.llantas_mvtos.no_economico ))
      ,FECHA = (select max(fecha) from tdrsilt.dbo.llantas_mvtos  where  destino = 'D' and fecha between @datestart and @dateend and tdrsilt.dbo.llantas.no_economico = tdrsilt.dbo.llantas_mvtos.no_economico )
      from tdrsilt.dbo.llantas 
     ----que la llanta este en descho
      where no_economico in ( select no_economico from tdrsilt.dbo.llantas_mvtos  where destino = 'D' and fecha between @datestart and @dateend )

--------------------Cargamos la tabla alterna temporal con los datos de la consulta  para la subconsulta


      INSERT INTO #PCostoKm

      select 
      PECONOMICO = no_economico
      ,PMARCA = (select max(nombre) from tdrsilt.dbo.llantas_marcas where tdrsilt.dbo.llantas_marcas.id_marca = tdrsilt.dbo.llantas.id_marca)
      ,PTIPO = (select max(nombre) from tdrsilt.dbo.llantas_tipos where tdrsilt.dbo.llantas_tipos.id_tipo = tdrsilt.dbo.llantas.id_tipo)
      ,PKMS = kms_acumulados
      ,PPRECIO = (precio_llanta + costos_acumulados)
      ,PMEDIDA = medida
      ,PCOSTOKM = ((precio_llanta + costos_acumulados)/ replace(isnull(kms_acumulados,1),0,1))
      ,PRENOVADOS = renovados
      ,PPONCHADURAS = ponchaduras
      ,PCAUSA = (select max(descripcion) from tdrsilt.dbo.llantas_mont_desmont  where id_causa = (select max(id_causa) from tdrsilt.dbo.llantas_mvtos  where  destino = 'D' and fecha between @datestart and @dateend and tdrsilt.dbo.llantas.no_economico = tdrsilt.dbo.llantas_mvtos.no_economico ))
      ,PFECHA = (select max(fecha) from tdrsilt.dbo.llantas_mvtos  where  destino = 'D' and fecha between @datestart and @dateend and tdrsilt.dbo.llantas.no_economico = tdrsilt.dbo.llantas_mvtos.no_economico )
      from tdrsilt.dbo.llantas 
     ----que la llanta este en descho
      --where no_economico in ( select no_economico from tdrsilt.dbo.llantas_mvtos  where destino = 'D' and fecha between @datestart and @dateend)
      where no_economico in ( select no_economico from tdrsilt.dbo.llantas_mvtos  where destino = 'D' and fecha between @datestart and @dateend )



-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = (Select sum(kms)  from #CostoKm)
    SELECT @Thistotal = (Select count(Economico)  from #CostoKm)

    --SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE  DATEDIFF(day, @DateStart, @DateEnd) 
    --END
--en metricas que el resultado sea un promedio siempre hacer en thiscount la suma y en thistotal la cuenta del economico

	
	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @Thistotal END



--Detalle a Nivel de

----------LLANTAS---------------------------------------------------------------------------------------------------------------------

IF (@ShowDetail=1) 
  BEGIN	
   select Economico,Fecha,Marca,Tipo,Medida,ponchaduras as Talachas, Renovados, dbo.fnc_TMWRN_FormatNumbers(Kms,2) as kms , '$' + dbo.fnc_TMWRN_FormatNumbers(Precio,2) as Precio , '$' + dbo.fnc_TMWRN_FormatNumbers(Costokm,5) as CostoXkm
          from #CostoKm

        order by  fecha desc, costokm desc
      
	END

----------MARCA---------------------------------------------------------------------------------------------------------------------

IF (@ShowDetail=2) 
  BEGIN	
   select Marca, 
   count(economico) as Llantas, 
   (select avg(pponchaduras) from #PCostoKm where marca = pmarca ) as PromTalachas,
   (select avg(prenovados)  from #PCostoKm where marca = pmarca ) as PromRenovados, 
    '$' + dbo.fnc_TMWRN_FormatNumbers(avg(Costokm),5) as CostoXkm,
     dbo.fnc_TMWRN_FormatNumbers(avg(Kms),2) as kms
          from #CostoKm
          group by Marca
        order by  avg(kms) desc
      
	END

----------MEDIDA---------------------------------------------------------------------------------------------------------------------

IF (@ShowDetail=3) 
  BEGIN	
   select Medida,
   count(economico) as Llantas,
   (select avg(pponchaduras) from #PCostoKm where marca = pmarca ) as PromTalachas,
   (select avg(prenovados)  from #PCostoKm where marca = pmarca ) as PromRenovados, 
   '$' + dbo.fnc_TMWRN_FormatNumbers(avg(Costokm),5) as CostoXkm,
   dbo.fnc_TMWRN_FormatNumbers(avg(Kms),2) as kms
          from #CostoKm
          group by Medida,marca
        order by  avg(Costokm) desc
	END

----------CAUSA---------------------------------------------------------------------------------------------------------------------

IF (@ShowDetail=4) 
  BEGIN	
   select Causa,
   count(economico) as Llantas,
   (select avg(pponchaduras) from #PCostoKm where marca = pmarca ) as PromTalachas,
   (select avg(prenovados)  from #PCostoKm where marca = pmarca ) as PromRenovados, 
   '$' + dbo.fnc_TMWRN_FormatNumbers(avg(Costokm),5) as CostoXkm,
   dbo.fnc_TMWRN_FormatNumbers(avg(Kms),2) as kms
          from #CostoKm
          group by causa,marca
        order by  avg(Costokm) desc
	END


GO
