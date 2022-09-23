SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[SP_ObtenerPeriodoSemana_JR] @Año AS INT, @Semana AS INT
, @fechadom as datetime out, @fechasab as datetime Out
AS
/***************************** ENCABEZADO ************************************
************************************************** ****************************
** NOMBRE: SP_ObtenerPeriodoSemana **
** DESCRIPCION: Retorna el periodo en fecha al que corresponde el numero de **
** semana segun el anio **
** CREADOR:Eddy_Neo **
********************* REGISTRO DE MODIFICACIONES *****************************
************************************************** ****************************
Fecha Descripcion
-----------------------------------------------------------------------------
2008.Oct.17 Creación de la función.. SP
************************************************** ***************************/
BEGIN
DECLARE @PeriodoDescripcion AS VARCHAR(100)
DECLARE @SemenaFecha AS DATETIME
-- DECLARE @fechadom AS DATETIME
-- DECLARE @fechasab AS DATETIME


Select @SemenaFecha = CONVERT(DATETIME, CAST(@Año AS VARCHAR(4))+'-01-01')

IF(DATENAME(dw, @SemenaFecha) = 'Sunday')
	BEGIN 
		SELECT @fechadom = convert(datetime,CONVERT(VARCHAR(100), (DATEADD(d, -7, DATEADD(ww, @Semana, @SemenaFecha))), 103),103)
		Select @fechasab = convert(datetime,CONVERT(VARCHAR(100), (DATEADD(d, -1, DATEADD(ww, @Semana, @SemenaFecha))), 103),103)
	END

IF(DATENAME(dw, @SemenaFecha) = 'Monday')
BEGIN 
SELECT @fechadom = Convert(Datetime,CONVERT(VARCHAR(100), (DATEADD(d, -8, DATEADD(ww, @Semana, @SemenaFecha))), 103),103) 
Select @fechasab = Convert(Datetime,CONVERT(VARCHAR(100), (DATEADD(d, -2, DATEADD(ww, @Semana, @SemenaFecha))), 103),103)
END
IF(DATENAME(dw, @SemenaFecha) = 'Tuesday')
BEGIN 
SELECT @fechadom = Convert(Datetime, CONVERT(VARCHAR(100), (DATEADD(d, -9, DATEADD(ww, @Semana, @SemenaFecha))), 103),103) 
Select @fechasab = Convert(Datetime, CONVERT(VARCHAR(100), (DATEADD(d, -3, DATEADD(ww, @Semana, @SemenaFecha))), 103),103)
END
IF(DATENAME(dw, @SemenaFecha) = 'Wednesday')
BEGIN 
SELECT @fechadom = Convert(Datetime, CONVERT(VARCHAR(100), (DATEADD(d, -10, DATEADD(ww, @Semana, @SemenaFecha))), 103),103) 
Select @fechasab = Convert(Datetime, CONVERT(VARCHAR(100), (DATEADD(d, -4, DATEADD(ww, @Semana, @SemenaFecha))), 103),103)
END
IF(DATENAME(dw, @SemenaFecha) = 'Thursday')
BEGIN 
SELECT @fechadom = Convert(Datetime, CONVERT(VARCHAR(100), (DATEADD(d, -11, DATEADD(ww, @Semana, @SemenaFecha))), 103),103) 
Select @fechasab = Convert(Datetime, CONVERT(VARCHAR(100), (DATEADD(d, -5, DATEADD(ww, @Semana, @SemenaFecha))), 103),103)
END
IF(DATENAME(dw, @SemenaFecha) = 'Friday')
BEGIN 
SELECT @fechadom = Convert(Datetime, CONVERT(VARCHAR(100), (DATEADD(d, -12, DATEADD(ww, @Semana, @SemenaFecha))), 103),103) 
Select @fechasab = Convert(Datetime, CONVERT(VARCHAR(100), (DATEADD(d, -6, DATEADD(ww, @Semana, @SemenaFecha))), 103),103)
END
IF(DATENAME(dw, @SemenaFecha) = 'Saturday')
BEGIN 
SELECT @fechadom = Convert(Datetime, CONVERT(VARCHAR(100), (DATEADD(d, -13, DATEADD(ww, @Semana, @SemenaFecha))), 103),103) 
Select @fechasab = Convert(Datetime, CONVERT(VARCHAR(100), (DATEADD(d, -7, DATEADD(ww, @Semana, @SemenaFecha))), 103),103)
END

--Select @fechadom
--Select @fechasab

--Print convert(varchar(30),@fechadom)
--Print convert(varchar(30),@fechasab)

END
GO
