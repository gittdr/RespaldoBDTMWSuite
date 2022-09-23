SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


--Ejecucion manual del sp para cargar goles en base a resultados de anios pasados
--exec resnow_actualizagolesresul


CREATE  PROC [dbo].[resnow_actualizagolesresul]

AS


declare @V_registros integer
declare @V_i integer
declare @metrica varchar(255)
declare @cumulativa integer
declare @inc float

declare @anio [decimal](20, 5)
declare @cuarto [decimal](20, 5)
declare @mes [decimal](20, 5)
declare @semana [decimal](20, 5)
declare @dia [decimal](20, 5)



select @inc  = 1

   	--Se obtiene el total de metricas que existen
		select @V_registros =  
        (select count(*) from  metricitem)
     
		--Se inicializa el contador en 0
		select @V_i = 0


          DECLARE Recorre_metricas CURSOR 
		  FOR  (select metricCode,Cumulative from metricitem )
		

		  OPEN Recorre_metricas 
		    FETCH NEXT FROM Recorre_metricas   INTO @metrica, @cumulativa
			WHILE (@@FETCH_STATUS = 0 and @V_i < @V_registros)
			   BEGIN -- del cursor 


           --Metricas acumulativas
           if @cumulativa = 1
             begin
                               --obtenemos los valores para actualizar la metrica

								--Resultados Anuales------------------------------------------
                                  select @anio = (select max(ThisYTD) from metricdetail where plainyear =  (year(getdate())-1)  and MetricCode = @metrica)
                                --Resultados Por Cuarto---------------------------------------
								  select @cuarto = (select max(ThisQTD) from metricdetail where plainyear = (year(getdate())-1) and PlainQuarter = datepart(qq,getdate()) and MetricCode = @metrica)
								--Resultados Mensuales---------------------------------------
								  select @mes = (select max(ThisMTD) from metricdetail where plainyear =   (year(getdate())-1)  and Plainmonth = month(getdate()) and MetricCode = @metrica)
							
                                --Resultados Semanales---------------------------------------
								  select @semana = (select max(ThisWTD) from metricdetail where plainyear = (year(getdate())-1) and Plainweek = datepart(ww, getdate()) and MetricCode = @metrica)
             end
          
            --Metricas no acumulativas
            else if @cumulativa = 0
             begin

                                --obtenemos los valores para actualizar la metrica

								--Resultados Anuales------------------------------------------
                                  select @anio = (select avg(ThisYTD) from metricdetail where plainyear =  (year(getdate())-1)  and MetricCode = @metrica)
                                --Resultados Por Cuarto---------------------------------------
								  select @cuarto = (select avg(ThisQTD) from metricdetail where plainyear = (year(getdate())-1) and PlainQuarter = datepart(qq,getdate()) and MetricCode = @metrica)
								--Resultados Mensuales---------------------------------------
								  select @mes = (select avg(ThisMTD) from metricdetail where plainyear =   (year(getdate())-1)  and Plainmonth = month(getdate()) and MetricCode = @metrica)
							
                                --Resultados Semanales---------------------------------------
								  select @semana = (select avg(ThisWTD) from metricdetail where plainyear = (year(getdate())-1) and Plainweek = datepart(ww, getdate()) and MetricCode = @metrica)

              end


                                --Resultados Diarios--------------------------------------
								  select @dia = (select avg(DailyValue) from metricdetail where plainyear = (year(getdate())-1)  and Plainweek = datepart(ww, getdate()) and MetricCode = @metrica)
                                
                                --Para cargar la primera semana del anio que aun pertenece al anio pasado
                                  /*
                                  cumulativa
                                  select @semana = (select max(ThisWTD) from metricdetail where  Plainyearweek = 201252  and MetricCode = @metrica)
                                  no cumulativa
                                   select @semana = (select avg(ThisWTD) from metricdetail where  Plainyearweek = 201252  and MetricCode = @metrica)
                                  select @dia = (select avg(DailyValue) from metricdetail where  Plainyearweek = 201252  and MetricCode = @metrica)
                                  update metricitem set goalday = @dia, goalweek = @semana   where metriccode = @metrica       
                                 */
                   
				                 if (@metrica  = 'Asset_RevenuePerDay' or @metrica  like 'Asset_RevenuePerDay@sucursal=%')
							          	 begin
								    declare @valor as decimal(20,5)
									declare @valorsemana  as decimal(20,5)
									declare @valormes  as decimal(20,5)
									declare @valoranio  as decimal(20,5)

									select DATEPART(week, getdate());

								    select @valor = (select valorgoal from MetricGoalDateDay where datediff(dd,getdate(),day) = 0 and metriccode = @metrica)
									select @valorsemana = (select sum(valorgoal) from MetricGoalDateDay where year(day) = year(getdate()) and  DATEPART(week, getdate()) = DATEPART(week,day) and metriccode = @metrica)
									select @valormes = (select sum(valorgoal) from MetricGoalDateDay where month(day) = month(getdate()) and metriccode = @metrica and year(day) = year(getdate()))
									select @valoranio = (select sum(valorgoal) from MetricGoalDateDay where year(day) = year(getdate()) and metriccode = @metrica)
									--select @valor = NULL
								 	update metricitem set goalday = @valor, goalweek = @valorsemana, goalmonth = @valormes , goalquarter = (@valoranio/4) , goalyear = @valoranio, goalfiscalyear = @valoranio where metriccode = @metrica
								 end

								else
						
								 	   begin
								--actualizamos los goles para la metrica
								update metricitem set goalday =  cast(isnull(@dia,0) as decimal (20,5)) , goalweek =  cast(isnull(@semana,0) as decimal(20,5)) , goalmonth =  cast(isnull(@mes,0) as decimal(20,5)), 
								goalquarter = cast(isnull(@cuarto,0) as decimal(20,5)) , goalyear = cast(isnull(@anio,0) as decimal(20,5)), goalfiscalyear = cast(isnull(@anio,0) as decimal(20,5))   where metriccode = @metrica
                                   end


								select @V_i = @V_i + 1

								FETCH NEXT FROM Recorre_metricas INTO @metrica, @cumulativa
						
				END -- del cursor
					    
		CLOSE Recorre_metricas
		DEALLOCATE Recorre_metricas











GO
