SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_Consumo_Diesel_semanal_JR] as 
/*
Identifica Ordenes de carriers con vales de combustible
exec sp_Consumo_Diesel_semanal_JR 

*/
Declare @consumossemanal table(
		ID_proyecto		varchar(8),
		Numero_semana	Integer,
		Litros			Integer,
		Kilometros		Integer)

Declare @T_ConsumosTotales Table
(Nombre_proyecto varchar(50),
Num_semana	integer,
total_kms		integer,
total_litros	integer)

declare	@V_nombreProyecto varchar(50),
		@V_nombre_proy	varchar(50),
		@V_Billto		varchar(15),
		@V_SemMax		integer,
		@V_i			Int = 1,
		@V_kms			Int,
		@V_lts			Int,
		@V_rend			float
BEGIN


-- Limpia la tabla Diesel_TablaSemanal_JR
delete Diesel_TablaSemanal_JR;

-- Consulta por semana los consumos 
	insert into @consumossemanal (ID_proyecto, Numero_semana, Litros, Kilometros)
	Select lgh_class3, Datepart(week,lgh_startdate) as semana, IsNull((select sum(isnull(ftk_liters,0)) from fuelticket where drv_id = lgh_driver1 and lgh_number = legheader.lgh_number and ftk_canceled_on is null ),0) as litros, lgh_miles
from legheader (nolock) where lgh_startdate > '2018-01-01' and lgh_class3 not in ('SAEO','UNK','NDIE') and lgh_outstatus = 'CMP' and lgh_tractor <> 'UNKNOWN'

-- Agrupa por semana los consumos de cada proyecto
Insert Into @T_ConsumosTotales(Nombre_proyecto, Num_semana, total_kms, total_litros)
select name as Proyecto, Numero_semana as No_Semana, sum(Kilometros) as Kms, sum(Litros) as Litros 
	from @consumossemanal, labelfile 
	where labeldefinition = 'RevType3'  and abbr =  ID_proyecto 
	group by name, Numero_semana order by 1,2; 

-- Inserta los nombres de los proyectos
Insert Into Diesel_TablaSemanal_JR(proyecto)
		SELECT Distinct(Nombre_proyecto)
		FROM @T_ConsumosTotales 

-- Obtiene el numero de semanas activas
select @V_SemMax = Max(Num_semana) From @T_ConsumosTotales

-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Proyectos_Cursor CURSOR FOR 
		SELECT proyecto
		FROM Diesel_TablaSemanal_JR 
	
		OPEN Proyectos_Cursor 
		FETCH NEXT FROM Proyectos_Cursor INTO @V_nombreProyecto
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor ordenes

			set @V_i = 1;
			Way:
				Begin
					select @V_kms = 0
					select @V_lts = 0
					Select @V_kms	= total_kms, @V_lts = total_litros From @T_ConsumosTotales Where Nombre_proyecto = @V_nombreProyecto and Num_semana = @V_i;
					--IF @V_kms = 0 select @V_kms = 1
					--IF @V_lts = 0 select @V_lts = 1
					declare @V_kms_d as float
					declare @V_lts_d as float

				--print cast(@V_kms as varchar(100))


					select @V_kms_d = cast(@V_kms as float)
					select @V_lts_d = cast(@V_lts as float)

				--print cast(@V_kms_d as varchar(100))
--					print cast(@V_lts_d as varchar(100))
					-- obtiene el rendimiento
					IF @V_kms = 0 or @V_lts = 0
					select @V_rend = 0
					else
					Select @V_rend	= @V_kms_d / @V_lts_d
					--print cast(@V_rend as varchar(10))

					Declare @CreaSQL as Varchar(250)
					--Set @CreaSQL = 'Update Diesel_TablaSemanal_JR  Set '+ 'SemKms'+cast(@V_i as varchar(2))+' = '+ cast(@V_kms as varchar(10))+ ', SemLts'+Cast(@V_i as varchar(2)) +' = '+ cast(@V_lts as varchar(10))+', '+	'SemRend'+cast(@V_i as varchar(2)) +' = 0' +' Where proyecto = '+char(39)+ @V_nombreProyecto +char(39) ;
					Set @CreaSQL = 'Update Diesel_TablaSemanal_JR  Set '+ 'SemKms'+cast(@V_i as varchar(2))+' = '+ cast(@V_kms as varchar(10))+ ', SemLts'+Cast(@V_i as varchar(2)) +' = '+ cast(@V_lts as varchar(10))+', '+	'SemRend'+cast(@V_i as varchar(2)) +' = '+cast(@V_rend as varchar(10)) +' Where proyecto = '+char(39)+ @V_nombreProyecto +char(39) ;
					--print @CreaSQL 
					EXEC (@CreaSQL)

					Set @V_i = @V_i +1 ;
					IF @V_i <= @V_SemMax GOTO Way;
				end
			FETCH NEXT FROM Proyectos_Cursor INTO @V_nombreProyecto
		END
			

		close Proyectos_Cursor
		Deallocate Proyectos_Cursor
	
	
	--select name as Proyecto, Numero_semana as No_Semana, sum(Kilometros) as Kms, sum(Litros) as Litros 
	--from @consumossemanal, labelfile 
	--where labeldefinition = 'RevType3'  and abbr =  ID_proyecto 
	--group by name, Numero_semana order by 1,2; 


	--select * from Diesel_TablaSemanal_JR;
	--select * from @T_ConsumosTotales order by 1,2;

END
GO
