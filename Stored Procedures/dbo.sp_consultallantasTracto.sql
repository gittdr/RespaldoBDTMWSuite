SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






--execute sp_consultallantasTracto '1010'
--drop procedure sp_consultallantas
CREATE PROCEDURE [dbo].[sp_consultallantasTracto] 
(
@unidad varchar (20)
)
as 

declare

@llantas varchar (20),
@desgaste numeric (20),
@posicion int,
@llantas1 varchar (20),
@llantas2 varchar (20),
@llantas3 varchar (20),
@llantas4 varchar (20),
@llantas5 varchar (20),
@llantas6 varchar (20),
@llantas7 varchar (20),
@llantas8 varchar (20),
@llantas9 varchar (20),
@llantas10 varchar (20),
@llantas11 varchar (20),
@llantas12 varchar (20),
@desgaste1 numeric,
@desgaste2 numeric,
@desgaste3 numeric,
@desgaste4 numeric,
@desgaste5 numeric,
@desgaste6 numeric,
@desgaste7 numeric,
@desgaste8 numeric,
@desgaste9 numeric,
@desgaste10 numeric,
@desgaste11 numeric,
@desgaste12 numeric,
@fecha datetime

--Tabla temporal para almacenar las llantas
create table #tblllantas(
	llantas1 varchar (20),
	desgaste1 numeric,
	llantas2 varchar (20),
	desgaste2 numeric,
	llantas3 varchar (20),
	desgaste3 numeric,
	llantas4 varchar (20),
	desgaste4 numeric,
	llantas5 varchar (20),
	desgaste5 numeric,
	llantas6 varchar (20),
	desgaste6 numeric,
	llantas7 varchar (20),
	desgaste7 numeric,
	llantas8 varchar (20),
	desgaste8 numeric,
	llantas9 varchar (20),
	desgaste9 numeric,
	llantas10 varchar (20),
	desgaste10 numeric,
	llantas11 varchar (20),
	desgaste11 numeric,
	llantas12 varchar (20),
	desgaste12 numeric,
	fecha datetime
)
		

	--Obtiene las llantas de la unidad
			Declare llantasUnidad cursor for select no_economico,profundidad,posicion_unidad,fecha_kms_unidad_ultimo from tdrsilt..llantas where id_unidad = @unidad order by posicion_unidad asc
			open llantasUnidad
			fetch llantasUnidad into @llantas,@desgaste,@posicion,@fecha
			while @@FETCH_STATUS = 0
				begin
					if @posicion = 1
						begin
							select @llantas1 = @llantas
							select @desgaste1 = @desgaste
						end
					else if @posicion = 2
						begin
							select @llantas2 = @llantas
							select @desgaste2 = @desgaste
						end
					else if @posicion = 3
						begin
							select @llantas3 = @llantas
							select @desgaste3 = @desgaste
						end
					else if @posicion = 4
						begin
							select @llantas4 = @llantas
							select @desgaste4 = @desgaste
						end
					else if @posicion = 5
						begin
							select @llantas5 = @llantas
							select @desgaste5 = @desgaste
						end
					else if @posicion = 6
						begin
							select @llantas6 = @llantas
							select @desgaste6 = @desgaste
						end
					else if @posicion = 7
						begin
							select @llantas7 = @llantas
							select @desgaste7 = @desgaste
						end
					else if @posicion = 8
						begin
							select @llantas8 = @llantas
							select @desgaste8 = @desgaste
						end
					else if @posicion = 9
						begin
							select @llantas9 = @llantas
							select @desgaste9 = @desgaste
						end
					else if @posicion = 10
						begin
							select @llantas10 = @llantas
							select @desgaste10 = @desgaste
						end
					else if @posicion = 11
						begin
							select @llantas11 = @llantas
							select @desgaste11 = @desgaste
						end
					else if @posicion = 12
						begin
							select @llantas12 = @llantas
							select @desgaste12 = @desgaste
						end
					FETCH NEXT FROM llantasUnidad into @llantas,@desgaste,@posicion,@fecha

				end
			CLOSE llantasUnidad 
			DEALLOCATE llantasUnidad

	insert into #tblllantas (llantas1,desgaste1,llantas2,desgaste2,llantas3,desgaste3,llantas4,desgaste4,llantas5,desgaste5,
		llantas6,desgaste6,llantas7,desgaste7,llantas8,desgaste8,llantas9,desgaste9,llantas10,desgaste10,llantas11,desgaste11,llantas12,desgaste12,fecha)values(
@llantas1,@desgaste1,@llantas2,@desgaste2,@llantas3,@desgaste3,@llantas4,@desgaste4,@llantas5,@desgaste5,
		@llantas6,@desgaste6,@llantas7,@desgaste7,@llantas8,@desgaste8,@llantas9,@desgaste9,@llantas10,@desgaste10,@llantas11,@desgaste11,@llantas12,@desgaste12,@fecha)

select * from #tblllantas





GO
GRANT ALTER ON  [dbo].[sp_consultallantasTracto] TO [ADMINISTRADOR]
GO
GRANT CONTROL ON  [dbo].[sp_consultallantasTracto] TO [ADMINISTRADOR]
GO
GRANT EXECUTE ON  [dbo].[sp_consultallantasTracto] TO [ADMINISTRADOR]
GO
GRANT TAKE OWNERSHIP ON  [dbo].[sp_consultallantasTracto] TO [ADMINISTRADOR]
GO
GRANT VIEW DEFINITION ON  [dbo].[sp_consultallantasTracto] TO [ADMINISTRADOR]
GO
GRANT ALTER ON  [dbo].[sp_consultallantasTracto] TO [CONTROL DE EQUIPO]
GO
GRANT CONTROL ON  [dbo].[sp_consultallantasTracto] TO [CONTROL DE EQUIPO]
GO
GRANT EXECUTE ON  [dbo].[sp_consultallantasTracto] TO [CONTROL DE EQUIPO]
GO
GRANT TAKE OWNERSHIP ON  [dbo].[sp_consultallantasTracto] TO [CONTROL DE EQUIPO]
GO
GRANT VIEW DEFINITION ON  [dbo].[sp_consultallantasTracto] TO [CONTROL DE EQUIPO]
GO
GRANT ALTER ON  [dbo].[sp_consultallantasTracto] TO [GERENCIAS]
GO
GRANT CONTROL ON  [dbo].[sp_consultallantasTracto] TO [GERENCIAS]
GO
GRANT EXECUTE ON  [dbo].[sp_consultallantasTracto] TO [GERENCIAS]
GO
GRANT TAKE OWNERSHIP ON  [dbo].[sp_consultallantasTracto] TO [GERENCIAS]
GO
GRANT VIEW DEFINITION ON  [dbo].[sp_consultallantasTracto] TO [GERENCIAS]
GO
GRANT ALTER ON  [dbo].[sp_consultallantasTracto] TO [LIDER DE FLOTA]
GO
GRANT CONTROL ON  [dbo].[sp_consultallantasTracto] TO [LIDER DE FLOTA]
GO
GRANT EXECUTE ON  [dbo].[sp_consultallantasTracto] TO [LIDER DE FLOTA]
GO
GRANT TAKE OWNERSHIP ON  [dbo].[sp_consultallantasTracto] TO [LIDER DE FLOTA]
GO
GRANT VIEW DEFINITION ON  [dbo].[sp_consultallantasTracto] TO [LIDER DE FLOTA]
GO
GRANT ALTER ON  [dbo].[sp_consultallantasTracto] TO [LIQUIDACIONES]
GO
GRANT CONTROL ON  [dbo].[sp_consultallantasTracto] TO [LIQUIDACIONES]
GO
GRANT EXECUTE ON  [dbo].[sp_consultallantasTracto] TO [LIQUIDACIONES]
GO
GRANT TAKE OWNERSHIP ON  [dbo].[sp_consultallantasTracto] TO [LIQUIDACIONES]
GO
GRANT VIEW DEFINITION ON  [dbo].[sp_consultallantasTracto] TO [LIQUIDACIONES]
GO
GRANT ALTER ON  [dbo].[sp_consultallantasTracto] TO [public]
GO
GRANT CONTROL ON  [dbo].[sp_consultallantasTracto] TO [public]
GO
GRANT EXECUTE ON  [dbo].[sp_consultallantasTracto] TO [public]
GO
GRANT TAKE OWNERSHIP ON  [dbo].[sp_consultallantasTracto] TO [public]
GO
GRANT VIEW DEFINITION ON  [dbo].[sp_consultallantasTracto] TO [public]
GO
GRANT ALTER ON  [dbo].[sp_consultallantasTracto] TO [RECURSOS HUMANOS]
GO
GRANT CONTROL ON  [dbo].[sp_consultallantasTracto] TO [RECURSOS HUMANOS]
GO
GRANT EXECUTE ON  [dbo].[sp_consultallantasTracto] TO [RECURSOS HUMANOS]
GO
GRANT TAKE OWNERSHIP ON  [dbo].[sp_consultallantasTracto] TO [RECURSOS HUMANOS]
GO
GRANT VIEW DEFINITION ON  [dbo].[sp_consultallantasTracto] TO [RECURSOS HUMANOS]
GO
