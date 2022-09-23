SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[kmstotalespordia_poraño_JR] 
--prueba de ejecucion 
-- exec kmstotalespordia_poraño_JR

--variables que recibira el sp como parametros con su tipo de dato
--(@fechaini datetime, @fechafin datetime)

--sintaxis como obligatoria y el count off para no alojar memoria
as --inicio codigo del sp
	SET NOCOUNT ON

	--creamos la tabla temporal seguida de sus tipos de datos de cada columna
	CREATE TABLE  #temp (billto varchar(8), movimiento varchar(12), totalkmsmov int, tkmsfuelt int, Diferencia int, Fecha datetime, Unidad Varchar(8), Operador varchar(8))

	--insertamos los valores del select en la tabla temporal
	insert into #temp
	select ord_billto,
	  mov_number,0, 0, 0, 0,'U','O'
    from orderheader
    where   ord_bookdate between 
	(select DATEADD (day, -415, getdate())) and (select getdate()) -- se añadio para generar reporte diario
		and ord_status not in ('MST', 'CAN')
		UNION
	select 'Vacio',mov_number,0,0,0,0,'U','O'  from legheader 
	where ord_hdrnumber = 0 and lgh_startdate between (select DATEADD (day, -415, getdate())) and (select getdate()) 

    ----updateamos el valor del total de kms de movimiento
    -- update #temp set totalkmsmov =  (select sum(stp_lgh_mileage) from stops where stops.mov_number = movimiento)

    ----updateamos el valor de total de kms de vales tomando solo los numeros de orden mas altos
    --update #temp set tkmsfuelt = (select sum(isnull(fcl_miles,0)) from fuelticket_calclog where fuelticket_calclog.mov_number = movimiento and orden in (SELECT TOP 1 WITH TIES orden FROM fuelticket_calclog where fuelticket_calclog.mov_number = movimiento ORDER BY orden DESC))
  
    --updateamos el valor del total de kms de movimiento
     update #temp set totalkmsmov =  (select sum(stp_lgh_mileage) from stops, legheader where stops.mov_number = movimiento and stops.lgh_number = legheader.lgh_number and legheader.lgh_carrier = 'UNKNOWN')

    --updateamos el valor de total de kms de vales tomando solo los numeros de orden mas altos
    update #temp set tkmsfuelt = (select isnull(sum(fcl_miles),0) from fuelticket_calclog where fuelticket_calclog.fcl_mpg > 0.00 and fuelticket_calclog.mov_number = movimiento and orden in (SELECT TOP 1 WITH TIES orden FROM fuelticket_calclog where fuelticket_calclog.mov_number = movimiento ORDER BY orden DESC))
  




	--updateamos el valor de la diferencia de kms e igualamos valores para aquellos campos nulos
	update #temp set tkmsfuelt = totalkmsmov where tkmsfuelt is null
    update #temp set Diferencia = (tkmsfuelt-totalkmsmov)

	--updateamos el campo fecha
	update #temp set Fecha = (select top(1) ord_bookdate from orderheader where mov_number = movimiento)

	-- Actualizamos la unidad
	update #temp set unidad = (select top(1) ord_tractor from orderheader where mov_number = movimiento)
	-- Actualizamos el operador
    update #temp set operador = (select top(1) ord_driver1 from orderheader where mov_number = movimiento)

	--hacemos la consulta final de la tabla temporal
	select billto,movimiento, totalkmsmov, tkmsfuelt, Diferencia, Fecha, unidad, operador from #temp --where Abs(Diferencia) > 5 order by Diferencia

	--no olvidar darle drop para sacarla de memoria
	drop table #temp



GO
