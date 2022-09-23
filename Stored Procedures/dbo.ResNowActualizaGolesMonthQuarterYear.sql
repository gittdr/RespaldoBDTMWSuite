SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Emilio Olvera
-- Create date: 09/01/2012
-- Description:	 Actualiza Goles de ResultsNow
-- =============================================

--exec ResNowActualizaGolesMonthQuarterYear

CREATE PROCEDURE  [dbo].[ResNowActualizaGolesMonthQuarterYear]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


--creamos tabla como varibles para ingresar la consulta

DECLARE @goaltempm  table
(year  varchar(5),
 [month] int,
 metriccode varchar(500),
 [valorgoal] [decimal](20, 5),
 [ingresado] [int] )


--insertamos en la tabla como variables la consulta que cumpla con la semana actual 
--y no se encuentre ya ingresado 
insert into @goaltempm 
 select  year,[month],metriccode,valorgoal,ingresado
  from MetricGoalDateMonth where  [month] = (month(getdate()) -1)  or [month] = 0 -- and ingresado <> 1

--select * from @goaltempm


--Declaramos la variable que almacenara el nombre de la metrica a hacer update
DECLARE @goalmetriccode varchar(500)
DECLARE @goalvalorgoal [decimal](20, 5)
DECLARE @mes int

--Declaramos el cursor
DECLARE Goal_Cursor CURSOR
 FOR select metriccode,valorgoal, [month] from @goaltempm
 OPEN Goal_Cursor
 

--Agregamos los valores del nombre de la metrica y valordelgoal a las variables
 fetch next from Goal_Cursor
 into @goalmetriccode, @goalvalorgoal, @mes
 while @@fetch_Status = 0

 begin

-- Si el mes  es el actual menos 1 usaremos el valor de goal para actualizar el mes
 IF @mes = (month(getdate())-1)
  BEGIN
 			UPDATE MetricItem SET  Goalmonth = (@goalvalorgoal)  WHERE MetricCode = @goalmetriccode
  END

-- Si el mes  es  0 usaremos el valor de goal por 12meses para actualizar  el año y el año Fiscal. y por 3 meses para el quarter
 ELSE if @mes = 0
  BEGIN
 			UPDATE MetricItem SET  GoalQuarter = (@goalvalorgoal*3)  WHERE MetricCode = @goalmetriccode
            UPDATE MetricItem SET  GoalYear = (@goalvalorgoal*12)  WHERE MetricCode = @goalmetriccode
            UPDATE MetricItem SET  GoalFiscalYear = (@goalvalorgoal*12)  WHERE MetricCode = @goalmetriccode
  END

 --avanzamos el cursor
 fetch next from Goal_Cursor
 into @goalmetriccode, @goalvalorgoal, @mes
 end

 --cerramos y dealocamos el cursor
 close Goal_Cursor
 deallocate Goal_Cursor


--Hacemos update en las tabla de los goles para marcar
--como actualizadas esas metricas

update MetricGoalDateweek set ingresado = 1
where week = DATEPART( wk, GETDATE() )

--acutalizamos las posiciones decimales de las metricas que las tienen en NULL
	update  MetricItem set    GoalNumDigitsAfterDecimal = 0    
WHERE     (GoalNumDigitsAfterDecimal IS NULL)


--Crear el mes 0
/*insert into  MetricGoalDateMonth

SELECT      year, 0, metriccode, valorgoal/1.15, ingresado
FROM         MetricGoalDateMonth
WHERE    (month = 12)
*/

END
GO
