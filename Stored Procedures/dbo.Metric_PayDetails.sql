SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



--EXEC [Metric_Estancias] 1,1,1,'20121212 00:00:01','20121212 01:31:00 pm', 1, 1, @tipoestancias='CLIENTES'
CREATE PROCEDURE [dbo].[Metric_PayDetails] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int,

	--PARAMETROS PROPIOS DE LA METRICA
	
     @Numerador varchar(50) = 'CUENTA',    --     CUENTA,CANTIDAD   
     @Modo varchar(50) = 'DIESEL' ,         --     DIESEL,MANT
     @Flota varchar(200) =  'TODAS',        --     TODAS O NUMERO DE FLOTA
     @PayItemCodeList varchar(255)         --     COMCOM, COMREP, CREF


)
AS
	SET NOCOUNT ON  -- PTS46367


-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Flota,2:Unidad,3:Operador,4:CreadoPor,5:Movimiento,6:Tipo,7:Vale/Docto



	--INICIALIZACION DE PARAMETROS ESTANDAR.
   -- Set  @PayItemCodeList  = ISNULL(@TIPOESTANCIAS,'')
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
      Set  @PayItemCodeList = ',' + ISNULL( @PayItemCodeList,'') + ','


	-- Create Temp Table
	CREATE TABLE #PayDetails (Movimiento varchar(12),Fecha datetime, Unidades float, Unidades2 float,
                              Cantidad float, CreadoPor varchar(255),Operador varchar(255), 
                              Unidad varchar (20), Flota varchar (255), Abbr varchar(30), 
                              Descripcion varchar(255), tipo varchar(30))




 SET @Flota = ',' + ISNULL(@Flota,'') + ','


	-- Initialize Temp Table

IF @modo = 'DIESEL' and @PayItemCodeList like '%CREF%'

    BEGIN

    insert into #PayDetails	

      select 
      Movimiento = no_movimiento,
      Fecha = (select ftk_created_on from fuelticket  where ftk_ticket_number  = no_vale),
      Unidades = (select ftk_liters from fuelticket  where ftk_ticket_number  = no_vale),
      Unidades2 =  horas ,
      Cantidad =   (select ftk_cost from fuelticket  where ftk_ticket_number  = no_vale),
      CreadoPor = 
         (select max(nombre) from tdrsilt.dbo.seguridad_usuarios where id_usuario =
        (select max(ftk_created_by) from fuelticket where fuelticket.mov_number  =no_movimiento and ftk_created_by 
         in (select id_usuario from tdrsilt.dbo.seguridad_usuarios))),

      Operador = (id_operador),
      Unidad =  (id_remolque),
      Flota = (Select  max(name)  from  labelfile  where abbr  = (Select max(trl_fleet) from trailerprofile where trl_number = ((id_remolque)) ) and labeldefinition = 'Fleet'),
      Abbr = (Select max(trc_fleet) from tractorprofile where trc_number = ((id_unidad)) ) ,
      Descripcion = no_vale ,
      tipo = 'Diesel Refrigerado'
      from vale_diesel_horas
      where
      (select ftk_created_on from fuelticket  where ftk_ticket_number  = no_vale) >= @DateStart
	  AND 
      (select ftk_created_on from fuelticket  where ftk_ticket_number  = no_vale) < @DateEnd
  END


ELSE IF @modo = 'HORAS' and @PayItemCodeList like '%CREF%'
    
   BEGIN

    insert into #PayDetails	

      select 
      Movimiento = no_movimiento,
      Fecha = (select ftk_created_on from fuelticket  where ftk_ticket_number  = no_vale),
      Unidades = ((select ftk_liters from fuelticket  where ftk_ticket_number  = no_vale)),
      Unidades2 =  horas ,
     ---invertir unidades y unidades 2 para el cambio
      Cantidad =   (select ftk_cost from fuelticket  where ftk_ticket_number  = no_vale),
      CreadoPor = 
         (select max(nombre) from tdrsilt.dbo.seguridad_usuarios where id_usuario =
        (select max(ftk_created_by) from fuelticket where fuelticket.mov_number  =no_movimiento and ftk_created_by 
         in (select id_usuario from tdrsilt.dbo.seguridad_usuarios))),

      Operador = (id_operador),
      Unidad =  (id_remolque),
      Flota = (Select  max(name)  from  labelfile  where abbr  = (Select max(trl_fleet) from trailerprofile where trl_number = ((id_remolque)) ) and labeldefinition = 'Fleet'),
      Abbr = (Select max(trc_fleet) from tractorprofile where trc_number = ((id_unidad)) ) ,
      Descripcion = no_vale ,
      tipo = 'Diesel Refrigerado'
      from vale_diesel_horas
      where
      (select ftk_created_on from fuelticket  where ftk_ticket_number  = no_vale) >= @DateStart
	  AND 
      (select ftk_created_on from fuelticket  where ftk_ticket_number  = no_vale) < @DateEnd
  END



ELSE IF @modo = 'DIESEL' 

 BEGIN

  insert into #PayDetails	

      select 
      Movimiento = mov_number,
      Fecha = pyd_transdate,
      Unidades = pyd_quantity ,
      Unidades2 =  pyd_quantity,
      Cantidad =  pyd_amount ,
      CreadoPor = 
         (select max(nombre) from tdrsilt.dbo.seguridad_usuarios where id_usuario =
        (select max(ftk_created_by) from fuelticket where fuelticket.mov_number  = paydetail.mov_number and ftk_created_by 
         in (select id_usuario from tdrsilt.dbo.seguridad_usuarios))),
      Operador = (select mpp_firstname +' ' + mpp_lastname from manpowerprofile where mpp_id = (select max(lgh_driver1) from legheader where legheader.mov_number = paydetail.mov_number)),
      Unidad =  (select max(lgh_tractor) from legheader where legheader.mov_number = paydetail.mov_number),
      Flota = (Select  max(name)  from  labelfile  where abbr  = (Select max(trc_fleet) from tractorprofile where trc_number = ((select max(lgh_tractor) from legheader where legheader.mov_number = paydetail.mov_number)) ) and labeldefinition = 'Fleet'),
      Abbr = (Select max(trc_fleet) from tractorprofile where trc_number = ((select max(lgh_tractor) from legheader where legheader.mov_number = paydetail.mov_number)) ) ,
   Descripcion = 
   substring(
    STUFF((SELECT ', ' +  cast(ftk_ticket_number as varchar) 
    FROM fuelticket 
    WHERE fuelticket.mov_number = paydetail.mov_number and ftk_updated_by is NULL and ftk_canceled_on is null 
    and  pyd_currencydate = ftk_created_on FOR XML PATH('')), 1, 1, ''),1,100),
   

      tipo = ( select pyt_description from paytype where paytype.pyt_itemcode = paydetail.pyt_itemcode)
      from paydetail 
      where
      pyd_transdate >= @DateStart
	  AND 
      pyd_transdate < @DateEnd
      and   ( @PayItemCodeList  =',,' or CHARINDEX(',' + pyt_itemcode  + ',', @PayItemCodeList ) > 0)
      and pyd_amount <> 0
END


IF @modo = 'MANT'
 BEGIN

    insert into #PayDetails	

      select 
      Movimiento = mov_number,
      Fecha = pyd_transdate,
      Unidades = pyd_quantity ,
      Unidades2 =  pyd_quantity,
      Cantidad =  pyd_amount ,
      CreadoPor = 
      (select usr_fname + ' '+ usr_lname from dbo.ttsusers where ttsusers.usr_userid = paydetail.Pyd_createdby),
      Operador = (select mpp_firstname +' ' + mpp_lastname from manpowerprofile where mpp_id = (select max(lgh_driver1) from legheader where legheader.mov_number = paydetail.mov_number)),
      Unidad =  (select max(lgh_tractor) from legheader where legheader.mov_number = paydetail.mov_number),
      Flota = (Select  max(name)  from  labelfile  where abbr  = (Select max(trc_fleet) from tractorprofile where trc_number = ((select max(lgh_tractor) from legheader where legheader.mov_number = paydetail.mov_number)) ) and labeldefinition = 'Fleet'),
      Abbr = (Select max(trc_fleet) from tractorprofile where trc_number = ((select max(lgh_tractor) from legheader where legheader.mov_number = paydetail.mov_number)) ) , 
      Descripcion =  pyd_description,
      tipo = ( select pyt_description from paytype where paytype.pyt_itemcode = paydetail.pyt_itemcode)
      from paydetail 
      where
      pyd_transdate >= @DateStart
	  AND 
      pyd_transdate < @DateEnd
      and   ( @PayItemCodeList  =',,' or CHARINDEX(',' + pyt_itemcode  + ',', @PayItemCodeList ) > 0)
  END


  --ELIMINAMOS LAS FLOTAS QUE NO OCUPAMOS

  if @Flota <> ',TODAS,'
       BEGIN
          delete #PayDetails  where (@Flota =',,' or CHARINDEX(',' + IsNull(Abbr,'') + ',', @Flota) = 0)   
       END


 
  --CALCULO DEL VALOR DE LA METRICA
   
   -- Si el numerador es cuenta	
	IF @numerador = 'RENDREF'
     BEGIN
       SELECT @ThisCount = (Select (Sum(Unidades2))  FROM  #PayDetails)
     END
 

   -- Si el numerador es cuenta	
 IF @numerador = 'CUENTA'
     BEGIN
       SELECT @ThisCount = (Select Sum(Unidades) FROM  #PayDetails)
     END



  -- Si el numerador es cantidad
	IF @numerador = 'CANTIDAD'
     BEGIN
       SELECT @ThisCount = (Select SUM(Cantidad) FROM  #PayDetails)
     END

	IF @numerador = 'RENDREF'
     BEGIN
       SELECT @ThisTotal = (Select (Sum(Unidades))  FROM  #PayDetails)
     END
    ELSE
     BEGIN
       SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END
    END

	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END

--**** MODO DIESEL *****************************************

 --VISTA DESDE FLOTA MODO DIESEL
  IF (@ShowDetail=1) and @Modo = 'DIESEL'
		BEGIN
		Select Flota, 
        count(movimiento) as CuentaComp,
        dbo.fnc_TMWRN_FormatNumbers(sum (unidades),2) as litros, 
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum(cantidad),2) as cantidad
		From #PayDetails
        group by Flota
        order by cast(sum(cantidad)as int) desc

	END
 --VISTA DESDE UNIDAD	MODO DIESEL
  	IF (@ShowDetail=2) and @Modo = 'DIESEL'
		BEGIN
		Select Unidad, 
        Flota,
        count(movimiento) as CuentaComp,
        dbo.fnc_TMWRN_FormatNumbers(sum (unidades),2) as litros, 
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum(cantidad),2) as cantidad
		From #PayDetails
        group by Flota, Unidad 
        order by Flota desc, cast(sum(cantidad)as int) desc
	END

 --VISTA DESDE OPERADOR	MODO DIESEL
    	IF (@ShowDetail=3) and @Modo = 'DIESEL'
	BEGIN
		Select operador, 
        Flota,
        count(movimiento) as CuentaComp,
        dbo.fnc_TMWRN_FormatNumbers(sum (unidades),2) as litros, 
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum(cantidad),2) as cantidad
		From #PayDetails
        group by operador,flota
        order by cast(sum(cantidad)as int) desc
	END


 --VISTA DESDE CREADOR POR MODO DIESEL
    	IF (@ShowDetail=4) and @Modo = 'DIESEL'
	BEGIN
		Select CreadoPor, 
        count(movimiento) as CuentaComp,
        dbo.fnc_TMWRN_FormatNumbers(sum (unidades),2) as litros, 
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum(cantidad),2) as cantidad
		From #PayDetails
        group by CreadoPor
        order by cast(sum(cantidad)as int) desc
	END



 --VISTA DESDE MOVIMIENTO MODO DIESEL
  	IF (@ShowDetail=5)  and @Modo = 'DIESEL'
	BEGIN
		Select Movimiento,
        Fecha, 
        dbo.fnc_TMWRN_FormatNumbers((unidades),2) as litros, 
        '$' + dbo.fnc_TMWRN_FormatNumbers((cantidad),2) as cantidad,
        CreadoPor,
        Operador,
        Unidad
		From #PayDetails
        order by cast((cantidad)as int) desc
	END

 --VISTA DESDE TIPO POR MODO  DIESEL
    	IF (@ShowDetail=6) and @Modo = 'DIESEL'
	BEGIN
		Select Tipo, 
        count(movimiento) as Cuenta, 
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum(cantidad),2) as cantidad
		From #PayDetails
        group by TIPO
        order by cast(sum(cantidad)as int) desc
	END


 --VISTA DESDE VALE POR MODO  DIESEL
      	IF (@ShowDetail=7)  and @Modo = 'DIESEL'
	BEGIN
		Select Descripcion as Vales,
        Movimiento,
        Fecha, 
        dbo.fnc_TMWRN_FormatNumbers((unidades),2) as litros, 
        '$' + dbo.fnc_TMWRN_FormatNumbers((cantidad),2) as cantidad,
        CreadoPor,
        Operador,
        Unidad
		From #PayDetails
        order by cast((cantidad)as int) desc
	END




--**** MODO HORAS *****************************************

 --VISTA DESDE FLOTA MODO DIESELHORAS
  IF (@ShowDetail=1) and @Modo = 'HORAS'
		BEGIN
		Select Flota, 
        count(movimiento) as CuentaComp,
        dbo.fnc_TMWRN_FormatNumbers(sum (unidades2),2) as horas,
        dbo.fnc_TMWRN_FormatNumbers(sum (unidades),2) as litros, 
        dbo.fnc_TMWRN_FormatNumbers((sum (unidades2)/sum(unidades)),2) as horasxlitro,
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum(cantidad),2) as cantidad
		From #PayDetails
        group by Flota
        order by cast(sum(cantidad)as int) desc

	END
 --VISTA DESDE UNIDAD	MODO DIESELHORAS
  	IF (@ShowDetail=2) and @Modo = 'HORAS'
		BEGIN
		Select Unidad, 
        Flota,
        count(movimiento) as CuentaComp,
        dbo.fnc_TMWRN_FormatNumbers(sum (unidades2),2) as horas,
        dbo.fnc_TMWRN_FormatNumbers(sum (unidades),2) as litros, 
        dbo.fnc_TMWRN_FormatNumbers((sum (unidades2)/sum(unidades)),2) as horasxlitro,
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum(cantidad),2) as cantidad
		From #PayDetails
        group by Flota, Unidad 
        order by Flota desc, cast(sum(cantidad)as int) desc
	END

 --VISTA DESDE OPERADOR	MODO DIESELHORAS
    	IF (@ShowDetail=3) and @Modo = 'HORAS'
	BEGIN
		Select operador, 
        Flota,
        count(movimiento) as CuentaComp,
        dbo.fnc_TMWRN_FormatNumbers(sum (unidades2),2) as horas,
        dbo.fnc_TMWRN_FormatNumbers(sum (unidades),2) as litros, 
        dbo.fnc_TMWRN_FormatNumbers((sum (unidades2)/sum(unidades)),2) as horasxlitro,
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum(cantidad),2) as cantidad
		From #PayDetails
        group by operador,flota
        order by cast(sum(cantidad)as int) desc
	END


 --VISTA DESDE CREADOR POR  MODO DIESELHORAS
    	IF (@ShowDetail=4) and @Modo = 'HORAS'
	BEGIN
		Select CreadoPor, 
        count(movimiento) as CuentaComp,
        dbo.fnc_TMWRN_FormatNumbers(sum (unidades2),2) as horas,
        dbo.fnc_TMWRN_FormatNumbers(sum (unidades),2) as litros, 
        dbo.fnc_TMWRN_FormatNumbers((sum (unidades2)/sum(unidades)),2) as horasxlitro,
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum(cantidad),2) as cantidad
		From #PayDetails
        group by CreadoPor
        order by cast(sum(cantidad)as int) desc
	END



 --VISTA DESDE MOVIMIENTO MODO DIESELHORAS
  	IF (@ShowDetail=5)  and @Modo = 'HORAS'
	BEGIN
		Select Movimiento,
        Fecha, 
        dbo.fnc_TMWRN_FormatNumbers(sum (unidades2),2) as horas,
        dbo.fnc_TMWRN_FormatNumbers(sum (unidades),2) as litros, 
        dbo.fnc_TMWRN_FormatNumbers((sum (unidades2)/sum(unidades)),2) as horasxlitro, 
        '$' + dbo.fnc_TMWRN_FormatNumbers((cantidad),2) as cantidad,
        CreadoPor,
        Operador,
        Unidad
		From #PayDetails
        order by cast((cantidad)as int) desc
	END

 --VISTA DESDE TIPO POR MODO DIESELHORAS
    	IF (@ShowDetail=6) and @Modo = 'HORAS'
	BEGIN
		Select Tipo, 
        count(movimiento) as Cuenta, 
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum(cantidad),2) as cantidad
		From #PayDetails
        group by TIPO
        order by cast(sum(cantidad)as int) desc
	END

 --VISTA DESDE VALE POR MODO DIESELHORAS
      	IF (@ShowDetail=7)  and @Modo = 'HORAS'
	BEGIN
		Select Descripcion as Vales,
        Fecha, 
        dbo.fnc_TMWRN_FormatNumbers( (unidades2),2) as horas,
        dbo.fnc_TMWRN_FormatNumbers((unidades),2) as litros, 
        dbo.fnc_TMWRN_FormatNumbers(((unidades2)/(unidades)),2) as horasxlitro,
        '$' + dbo.fnc_TMWRN_FormatNumbers((cantidad),2) as cantidad,
        CreadoPor,
        Operador,
        Unidad
		From #PayDetails
       -- group by Descripcion, Fecha, CreadoPor,Operador,Unidad
        order by cast((cantidad)as int) desc
	END



--**** MODO MANT *****************************************

 --VISTA DESDE FLOTA MODO MANT
  IF (@ShowDetail=1) and @Modo = 'MANT'
		BEGIN
		Select Flota, 
        count(movimiento) as CuentaComp, 
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum(cantidad),2) as cantidad
		From #PayDetails
        group by Flota
         order by cast(sum(cantidad)as int) desc
	END
 --VISTA DESDE UNIDAD	MODO  MANT
  	IF (@ShowDetail=2) and @Modo = 'MANT'
		BEGIN
		Select Unidad, 
        count(movimiento) as Cuenta, 
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum(cantidad),2) as cantidad
		From #PayDetails
        group by Unidad
        order by cast(sum(cantidad)as int) desc
	END

 --VISTA DESDE OPERADOR	MODO  MANT
    	IF (@ShowDetail=3) and @Modo = 'MANT'
	BEGIN
		Select operador, 
        count(movimiento) as Cuenta,
       '$' + dbo.fnc_TMWRN_FormatNumbers(sum(cantidad),2) as cantidad
		From #PayDetails
       group by Operador
        order by cast(sum(cantidad)as int) desc
	END

 --VISTA DESDE CREADOR POR MODO  MANT
    	IF (@ShowDetail=4) and @Modo = 'MANT'
	BEGIN
		Select CreadoPor, 
        count(movimiento) as Cuenta, 
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum(cantidad),2) as cantidad
		From #PayDetails
        group by CreadoPor
        order by cast(sum(cantidad)as int) desc
	END



 --VISTA DESDE MOVIMIENTO MODO  MANT
  	IF (@ShowDetail=5)  and @Modo = 'MANT'
	BEGIN
		Select Movimiento,
        Fecha, 
        '$' + dbo.fnc_TMWRN_FormatNumbers((cantidad),2) as cantidad,
        Tipo,
        Descripcion ,
        CreadoPor,
        Operador,
        Unidad
		From #PayDetails
        order by  cast(cantidad as int) desc
      
	END

 --VISTA DESDE TIPO POR MODO  MANT
    	IF (@ShowDetail=6) and @Modo = 'MANT'
	BEGIN
		Select Tipo, 
        count(movimiento) as Cuenta, 
        '$' + dbo.fnc_TMWRN_FormatNumbers(sum(cantidad),2) as cantidad
		From #PayDetails
        group by TIPO
        order by sum(cantidad) desc
	END
GO
