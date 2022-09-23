SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****
Autor: Emolvera
Fecha creacion: 26/11/2015
metrica que calcula el numero de mantenimientos correctivos desde la BD de SILT
*****/

CREATE  PROCEDURE [dbo].[Metric_MttoCorrectivo] (
	--PARAMETROS ESTANDAR PARA EL CALCULO DE LA METRICA
	@Result decimal(20, 5) OUTPUT, 
	@ThisCount decimal(20, 5) OUTPUT, 
	@ThisTotal decimal(20, 5) OUTPUT, 
	@DateStart datetime, 
	@DateEnd datetime, 
	@UseMetricParms int, 
	@ShowDetail int



)

AS
	SET NOCOUNT ON  

-- Don't touch the following line. It allows for choices in drill down
-- DETAILOPTIONS=1:Proyecto,2:Unidad,3:Operador,4:TipoEquipo,5:Sucursal





	--Set @DIVISION= ',' + ISNULL(@DIVISION,'') + ','
	--Set @NOPROYECTO= ',' + ISNULL(@NOPROYECTO,'') + ','


	-- Creación de la tabla temporal

	CREATE TABLE #MttoCor (Fechainicio datetime,Total float,Unidad varchar(30), Terminal varchar(20), Descripcion varchar(250), Depto varchar(20), id_orden varchar(20), fechacierre datetime , tipo varchar(255), Operador varchar(20))

	-- Carga de la tabla temporal en el  caso  de que el numerador sea salidas de almacen
	

      INSERT INTO #MttoCor


       
            SELECT  tdrsilt.dbo.mtto_orden.fecha_inicio,
				   tdrsilt.dbo.mtto_orden.costo_taller_externo +  tdrsilt.dbo.mtto_orden.costo_refacciones AS Total, 
				    tdrsilt.dbo.mtto_orden.id_unidad,   tdrsilt.dbo.personal_personal.terminal,  
                  tdrsilt.dbo.mtto_razon_reparacion.descripcion,   tdrsilt.dbo.general_departamentos.descripcion AS Depto,   tdrsilt.dbo.mtto_orden.id_orden,
				   tdrsilt.dbo.mtto_orden.fecha_cierre,   tdrsilt.dbo.mtto_tipos_unidades.descripcion AS Tipo,
				  Operador = isnull((select trc_driver from tmwsuite.dbo.tractorprofile (nolock) where trc_number =  tdrsilt.dbo.mtto_orden.id_unidad),'')
				
				 
                  
FROM     tdrsilt.dbo.mtto_orden  (nolock) INNER JOIN
                   tdrsilt.dbo.mtto_unidades (nolock) ON   tdrsilt.dbo.mtto_orden.id_unidad =  tdrsilt.dbo.mtto_unidades.id_unidad INNER JOIN
                   tdrsilt.dbo.general_departamentos(nolock) ON  tdrsilt.dbo.mtto_unidades.id_area =  tdrsilt.dbo.general_departamentos.id_area AND 
                   tdrsilt.dbo.mtto_unidades.id_depto  =  tdrsilt.dbo.general_departamentos.id_depto INNER JOIN
                   tdrsilt.dbo.personal_personal (nolock) ON  tdrsilt.dbo.mtto_orden.id_superviso_entrada =  tdrsilt.dbo.personal_personal.id_personal INNER JOIN
                   tdrsilt.dbo.mtto_razon_reparacion (nolock) ON  tdrsilt.dbo.mtto_orden.id_razon =  tdrsilt.dbo.mtto_razon_reparacion.id_razon INNER JOIN
                   tdrsilt.dbo.mtto_servicios  (nolock) ON  tdrsilt.dbo.mtto_orden.id_servicio =  tdrsilt.dbo.mtto_servicios.id_servicio INNER JOIN
                   tdrsilt.dbo.mtto_tipos_unidades  (nolock) ON  tdrsilt.dbo.mtto_unidades.id_tipo_unidad =  tdrsilt.dbo.mtto_tipos_unidades.id_tipo_unidad
WHERE  ( tdrsilt.dbo.mtto_orden.estado <> 'N') AND ( tdrsilt.dbo.mtto_unidades.id_tipo_unidad <> 17) AND ( tdrsilt.dbo.mtto_orden.fecha_inicio > CONVERT(DATETIME, '2013-01-01 00:00:00', 102))
and   tdrsilt.dbo.mtto_razon_reparacion.mtto = 'Correctivo' and  tdrsilt.dbo.mtto_orden.estado = 'C'
and  (tdrsilt.dbo.mtto_orden.fecha_inicio >= @DateStart ) and  (tdrsilt.dbo.mtto_orden.fecha_inicio <= @DateEnd) 
    


 
-- Asignar valores a variable de numerador, denominador y resultado de la metrica

    
      SELECT @ThisCount = (Select count(*) from #MttoCor)


    SELECT @ThisTotal = CASE  WHEN CONVERT(VARCHAR(10), @DateStart, 121) = CONVERT(VARCHAR(10), @DateEnd, 121) THEN 1  ELSE DATEDIFF(day, @DateStart, @DateEnd) END


	SELECT @Result = CASE ISNULL(@ThisTotal, 0) WHEN 0 THEN NULL ELSE @ThisCount / @ThisTotal END


--Detalle a Nivel de Proyecto

	IF (@ShowDetail=1) 
	BEGIN
	   select Depto,Tipo,  count(*) as Cantidad, '$' + dbo.fnc_TMWRN_FormatNumbers((sum(Total) ),2) as Monto  from #MttoCor
		group by Depto, Tipo
		order by count(*) desc
	END


--Detalle a Nivel de Unidad


	IF (@ShowDetail=2) 
	BEGIN
	    select Unidad,    count(*) as Cantidad, '$' + dbo.fnc_TMWRN_FormatNumbers((sum(Total) ),2) as Monto   from #MttoCor
		group by Unidad
		order by count(*) desc
	END


--Detalle a Nivel de Operador

	IF (@ShowDetail=3) 
	BEGIN
		  select Operador as OperadorID, (select mpp_firstname + ' ' + mpp_lastname from manpowerprofile (nolock) where mpp_id = Operador) as NombreOperador, count(*) as Cantidad, '$' + dbo.fnc_TMWRN_FormatNumbers((sum(Total) ),2) as Monto   from #MttoCor
		group by Operador
		order by count(*) desc
	END

--Detalle a Nivel de Tipo

	IF (@ShowDetail=4) 
	BEGIN
		  select Tipo,    count(*) as Cantidad, '$' + dbo.fnc_TMWRN_FormatNumbers((sum(Total) ),2) as Monto   from #MttoCor
		group by Tipo
		order by count(*) desc
	END


	--Detalle a Nivel de Sucursal

	IF (@ShowDetail=5) 
	BEGIN
		  select Terminal,    count(*) as Cantidad, '$' + dbo.fnc_TMWRN_FormatNumbers((sum(Total) ),2) as Monto   from #MttoCor
		group by Terminal
		order by count(*) desc
	END


GO
