SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Metric_ConvoyTmailErrores] (
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

       

)
AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Tipo de Error,2:Tipo Error Sucursal,3:Proyecto,4:Operador,5:Detalle,6 :Detalle Sucursal,7:SinClasificar,8:ErroresTI

	--INICIALIZACION DE PARAMETROS PROPIOS DE LA METRICA.
      --Set  @Soloalmacenlista = ',' + ISNULL(@Soloalmacenlista,'') + ','
	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #ERRORS
    (
	 driver varchar(20),
	 flota varchar(50),
	 proyecto varchar(20),
	 division varchar(20),
	 SN varchar(12),
	 FechaEnviado datetime,
	 Asunto varchar(max),
	 TipoMensaje varchar(200),
	 Descripcion text,
	 Error varchar(200)
	  )

	  CREATE TABLE #SUCURSALES
	  (
	  orden varchar(10),
	  Sucursal varchar(10),
	  Error varchar(200)

	  )

	  CREATE TABLE #MSG
    (cuenta int )

	--Mensajes con Errores

	insert into #ERRORS

	 SELECT 
	 (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ) as DriverID, 
	 
	 (select name from labelfile where labeldefinition = 'fleet' 
	 and abbr = (select mpp_fleet from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) as flota,

	 ((select mpp_type3 from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) as proyecto,
	 ((select mpp_type4 from manpowerprofile (nolock) where mpp_id = (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ))) as division,
	 t.sn, t.dtsent, t.Subject,
     replace(replace(substring(subject,CHARINDEX('*',subject,1),(CHARINDEX('-',subject,1))),'*',''),'-','') as TipoMsg,
     description as error,
      case when Description like  '%remolque%' then 'Error en remolque' 
      when Description like  '%Trailer not on file or assigned to that move%' then 'Error en remolque'
	  when Description like  '%Change of trailer not permitted or missing Primary Trailer%' then 'Error en remolque'
      when description like '%uses a value of the wrong type%'  then 'ConversionSPTMW'
	  when description like '%El recurso ingresado esta en uso en otra orden%' then 'El recurso esta en uso en otra orden'
	   when description like '%The equipment is already in use%' then 'El recurso esta en uso en otra orden'
	  when description like '%The equipment is in use on another trip%' then 'El recurso esta en uso en otra orden'
	  when description like '%Earlier activity for the move has not yet been completed%'  then 'Actividad previa para el movimiento no completada'
	  when description like '%Later stop is already completed%' then 'Stop posterior ya completado'
	  when description like '%That Trip Segment is already started%' then 'Viaje ya iniciado'
	  when description like '%Applicable order number not found%' then 'Numero de orden invalido'
	  when description like '%Specified date/time is later than expected%' then 'Citas caducas por mas de 72 hrs'
	  when description like '%Specified date/time is earlier than expected%' then 'Citas caducas por menos de 72 hrs'
	  when description like '%Departure date/time is later than expected%' then 'Citas caducas por mas de 72 hrs'
	  when description like '%Arrival or Departure date/time is earlier than expected%' then 'Citas caducas por menos de 72 hrs'
	  when description like  '%Tractor not found or not assigned/dispatched to that move%' then 'Tractor no encontrado o asignado a la orden'
	  when description like  '%Operador no existente o no asignado a la orden%' then 'Operador no encontradoo o no asignado a la orden'
	  when description like  '%or that tractor not assigned to it%' then 'Tractor no asignado a la orden, cambio de tractor de operador'
	  when description like  '%Driver not found or not assigned to that move%' then 'Operador no asignado a la orden, cambio de tractor de operador'
	  when Description like '%SQL Server%' then 'Error SQL'
	  when Description like '%Parse%' then 'Error Parseo SQL'
	  when Description like '%Unrecognized unit of measure%' then 'Unidad de medida no reconocida'
	  when Description like '%There is other incomplete activity in progress on that move%' then 'Actividad previa para el movimiento no completada'
	  else 'No clasificado'

	  end as errorcategoria
	FROM tblMessages t (NOLOCK)
 		INNER JOIN tblMsgProperties (NOLOCK) ON t.SN = tblMsgProperties.MsgSN  
		join tblErrorData ON ErrListID= Value
 	WHERE  
 	tblMsgProperties.PropSN = 6 
	and subject like '%**%'
	and source like '%PSXact.clsPSXact: VB%'
	and subject <> '** ENVIAR CABECER DE CARGA **'
	and dtsent between @DateStart and @DateEnd
	and  (Select DispSysDriverID from tbldrivers (nolock) where sn = t.FromDrvSN ) is not null
	order by sn desc
	
	

	IF (@division = 'TODAS' and @Proyecto = 'TODOS')
	begin
	---mensajes totales
	insert into #MSG
	 select count(*) from tblMessages where DTSent between @DateStart and @DateEnd
	end


   IF (@division <> 'TODAS' and @Proyecto = 'TODOS')
	begin
	---mensajes totales
	insert into #MSG
	 select count(*) from tblMessages where DTSent between @DateStart and @DateEnd
	 and FromDrvSN in (select SN from tbldrivers (nolock) where DispSysDriverID  in (select mpp_id from manpowerprofile (nolock) where mpp_type4 = @Division))

	 delete #ERRORS where division <> @Division

	end
	

	IF (@Proyecto <> 'TODOS')
	begin
	---mensajes totales
	insert into #MSG
	 select count(*) from tblMessages where DTSent between @DateStart and @DateEnd
	 and FromDrvSN in (select SN from tbldrivers (nolock) where DispSysDriverID  in (select mpp_id from manpowerprofile (nolock) where mpp_type3 = @PRoyecto))

	  delete #ERRORS where proyecto <> @Proyecto
	end


	
	---CALCULO DE ERRORES POR SUCURSALES

	Insert into #Sucursales

         select   replace(replace( substring(Asunto,charindex('#',Asunto),8),' ',''),'#','') as Orden,
		 isnull((select ord_revtype2 from orderheader where ord_hdrnumber =  replace(replace( substring(Asunto,charindex('#',Asunto),8),' ',''),'#','')),'N/A') as Sucurusal,
	
		 Error
	       from #ERRORS
	     where replace(replace( substring(Asunto,charindex('#',Asunto),8),' ',''),'#','') not in  ('CLAVE','-CLA','unaCL','una')
		 and isnull((select ord_revtype3 from orderheader where ord_hdrnumber =  replace(replace( substring(Asunto,charindex('#',Asunto),8),' ',''),'#','')),'N/A') = 'BAJ'


	delete #ERRORS where driver is null


-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    SELECT @ThisCount = case when  (Select count(*)  from  #ERRORS) = 0   then 0
	else  
	 (Select  cast(count(*)  as float) from  #ERRORS )   / (Select cast(cuenta as float) from #MSG)
	end


    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount  /  cast(@ThisTotal as float) END


--Detalle a Nivel de Unidades  revisadas por dia


--Tipo de error

IF (@ShowDetail=1) 
	BEGIN

		select Error, count(*) as Ocurrencias from #ERRORS
		group by Error
		order by ocurrencias desc
	
		
		
	END


	---TIPO ERORR POR SUCUSAL 

	   IF (@ShowDetail=2) 
	   BEGIN 
		   select  Sucursal,Error, count(*) as Ocurrencias 
		   from #SUCURSALES
		   group by Sucursal, Error

		   order by sucursal
	   END


	

--ERRORES POR PROYECTO


IF (@ShowDetail=3) 
	BEGIN

		select (select name from labelfile where labeldefinition = 'drvtype3' and abbr = proyecto) as Proyecto, Error, count(*) as Ocurrencias from #ERRORS
		group by proyecto,Error
		order by proyecto, ocurrencias desc
	
		

END


 --ORDENES POR OPERADOR

	IF (@ShowDetail=4) 
	BEGIN
		
			select (select name from labelfile where labeldefinition = 'drvtype3' and abbr = proyecto) as Proyecto, driver as Operador, Error, count(*) as Ocurrencias from #ERRORS
		group by proyecto, driver, Error
		order by proyecto,driver,ocurrencias desc
	
		
	END

	--DETALLE


	IF (@ShowDetail=5) 
	BEGIN
		select * from #ERRORS
	END


	---DETALLE POR SUCURSAL

		IF (@ShowDetail=6) 
		BEGIN
           select * from #SUCURSALES
		   order by sucursal

		END



	--SIN CLASIFICAR


		IF (@ShowDetail=7) 
	BEGIN
		select * from #ERRORS
		where error = 'No clasificado'
	END


	--ERRORES TI


			IF (@ShowDetail=8) 
	BEGIN
		select * from #ERRORS
		where error in ('ConversionSPTMW','Error SQL')
	END


	

	
GO
