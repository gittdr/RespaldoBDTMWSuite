SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Emilio Olvera
-- Create date: 09/01/2012
-- Description:	 Actualiza Goles de ResultsNow
-- =============================================

--exec ResNowActualizaGolesWeekDay

CREATE PROCEDURE  [dbo].[ResNowActualizaGolesWeekDay]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;




--creamos tabla como varibles para ingresar la consulta

DECLARE @goaltemp  table
(year  varchar(5),
 week int,
 metriccode varchar(500),
 [valorgoal] [decimal](20, 5),
 [ingresado] [int] )


--insertamos en la tabla como variables la consulta que cumpla con la semana actual 
--y no se encuentre ya ingresado 
insert into @goaltemp 
 select  year,week,metriccode,valorgoal,ingresado
  from MetricGoalDateWeek where week = DATEPART( wk, GETDATE() ) or  week = (DATEPART( wk, GETDATE() ) -1)  -- and ingresado <> 1

--select * from @goaltemp


--Declaramos la variable que almacenara el nombre de la metrica a hacer update
DECLARE @goalmetriccode varchar(500)
DECLARE @goalvalorgoal [decimal](20, 5)
DECLARE @semana int

--Declaramos el cursor
DECLARE Goal_Cursor CURSOR
 FOR select metriccode,valorgoal, week from @goaltemp
 OPEN Goal_Cursor
 

--Agregamos los valores del nombre de la metrica y valordelgoal a las variables
 fetch next from Goal_Cursor
 into @goalmetriccode, @goalvalorgoal, @semana
 while @@fetch_Status = 0

 begin


-- Si la semana  es la actual usaremos el valor de goal para actualizar los días
 if @semana = (DATEPART( wk, GETDATE() ))
  BEGIN

		--Si el valor del goal es mayor a 100 quiere decir que se trata de una cantidad acumulada
		--por lo tanto los dias se dividen entre 6


		if @goalvalorgoal > 100
		begin
 			UPDATE MetricItem SET  GoalDay = (@goalvalorgoal/6)  WHERE MetricCode = @goalmetriccode
		end

		--Si el valor del goal es menor a 1 quiere decir que se trata de un %porcentaje 
		--por lo tanto el dia no se divide
        --Si el valor del goal se encuetra entre 1 y 100 quiere decir que se trata de un valor promedio no acumulado como precio x km
		--por lo tanto el dias no se divide

		else if @goalvalorgoal between 0 and 100
		 begin
            UPDATE MetricItem SET  GoalDay = (@goalvalorgoal)  WHERE MetricCode = @goalmetriccode 
        end
		
   END

-- Si la semana  es la actual menos 1 usaremos el valor de goal para actualizar las semanas
	 ELSE if @semana = (DATEPART( wk, GETDATE() )-1)
	  BEGIN

 				UPDATE MetricItem SET  GoalWeek = (@goalvalorgoal)  WHERE MetricCode = @goalmetriccode
	  END

	 --avanzamos el cursor
	 fetch next from Goal_Cursor
	 into @goalmetriccode, @goalvalorgoal, @semana
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


END
GO
