SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*

autor_ Emilio Olvera
fecha: 11- 17-2020 5.17pm
version 1.0

SP para generar reporte de puntos comportamientos de operador


exec sp_driverpoints  'detall','2020-09-01','2020-10-01','BAJIO','JOSE MONTERO','ABIERTO1','LARRU','Operaciones'
exec sp_driverpoints  'depto','2020-09-01','2020-10-01',NULL,NULL, NULL, NULL, NULL
exec sp_driverpoints  'lider','2021-01-01','2021-02-02',NULL,NULL, NULL, NULL, 'Abastecimiento'

exec sp_driverpoints  'flota','2021-01-01','2021-02-02','BAJIO','DEPTO', NULL, NULL, 'Abastecimiento'
exec sp_driverpoints  'flota','2021-01-01','2021-02-02','BAJIO','DEPTO', NULL, NULL, 'NULL'



exec sp_driverpoints  'opera','2021-01-01','2021-02-02','BAJIO','JOSE MONTERO','ABIERTO1','NULL','Abastecimiento'
*/


 CREATE proc [dbo].[sp_driverpoints] (
 @modo varchar(10),
 @fechaini datetime,
 @fechafin datetime,
 @proyecto varchar(20),
 @lider varchar(200),
 @flota varchar(20),
 @driver varchar(20),
 @depto varchar(20)
 )

as

declare @detail table (driver varchar(20), lider varchar(300), flota varchar(50), proyecto varchar(50), descrip varchar(max),
observo varchar(200) , comentariosdrv varchar(max), fecha datetime, depto varchar(100), dro_code varchar(200), puntos int)


insert into @detail

select 
d.mpp_id,
(select isnull(name,'')  from labelfile where labeldefinition = 'teamleader' and abbr =  m.mpp_teamleader) as lider,
(select name from labelfile where labeldefinition = 'fleet' and abbr = m.mpp_fleet) as flota,
(select name from labelfile where labeldefinition = 'drvtype3' and abbr = m.mpp_type3) as proyecto,
dro_description, 
dro_observedby,
dro_drivercomments,
dro_observationdt,
(select name from labelfile where  labeldefinition = 'RoadSurface' and abbr = road_conditions)  as depto,
(select name from labelfile where  labeldefinition = 'DrvObsCd' and abbr = dro_code) as tipoob,
isnull(dro_points,4)
 from driverobservation d
 left join manpowerprofile  m on m.mpp_id = d.mpp_id
 where dro_observationdt between @fechaini and @fechafin
 

 declare @agrupa table (driver varchar(20), lider varchar(300), flota varchar(50), proyecto varchar(50), puntos int)
 declare @agrupad table (driver varchar(20), lider varchar(300), flota varchar(50), proyecto varchar(50), puntos int, depto varchar(100))


  insert into @agrupad

  select driver, lider, flota, proyecto,sum(puntos),depto
  from @detail
  group by driver,lider,flota, proyecto, depto




 insert into @agrupa

  select driver, lider, flota, proyecto, sum(puntos)
  from @detail
  group by driver,lider,flota, proyecto


  ----agrupacion por depto-----------------------------------------

 if (@modo = 'depto') 
 begin
 if @depto is not null
 begin

 select depto, cast(avg(cast(puntos as float)) as float) as puntos,
      case when  avg(puntos) = 0 then 'Optimo'  
	       when  avg(puntos) between 1 and 4 then 'Aceptable'
	       when  avg(puntos) between  5 and 9 then 'Medio'
	       when  avg(puntos) < 10 then 'Alto'
	  end as nivel from @agrupad
	  where depto = @depto
 group by depto

 end

else

 begin

 select depto, cast(avg(cast(puntos as float)) as float) as puntos,
      case when  avg(puntos) = 0 then 'Optimo'  
	       when  avg(puntos) between 1 and 4 then 'Aceptable'
	       when  avg(puntos) between  5 and 9 then 'Medio'
	       when  avg(puntos) < 10 then 'Alto'
	  end as nivel from @agrupad
 group by depto

 end

 end
 -----agrupacion por proyecto--------------------------------------

 if (@modo = 'proy') or (@modo = 'all')
 begin

 if @proyecto is not null
 begin

 select proyecto, cast(avg(cast(puntos as float)) as float) as puntos,
      case when  avg(puntos) = 0 then 'Optimo'  
	       when  avg(puntos) between 1 and 4 then 'Aceptable'
	       when  avg(puntos) between  5 and 9 then 'Medio'
	       when  avg(puntos) < 10 then 'Alto'
	  end as nivel from @agrupa
	  where proyecto = @proyecto
 group by proyecto

 end

else

 begin

 select proyecto, cast(avg(cast(puntos as float)) as float) as puntos,
      case when  avg(puntos) = 0 then 'Optimo'  
	       when  avg(puntos) between 1 and 4 then 'Aceptable'
	       when  avg(puntos) between  5 and 9 then 'Medio'
	       when  avg(puntos) < 10 then 'Alto'
	  end as nivel from @agrupa
 group by proyecto

 end

 end


 
 -----agrupacion por lider--------------------------------------

     if (@modo = 'lidera')
	 begin 
		 if (@lider = 'nono')

		 begin 
			 select lider, cast(avg(cast(puntos as float)) as float) as puntos,
				  case when  avg(puntos) = 0 then 'Optimo'  
					   when  avg(puntos) between 1 and 4 then 'Aceptable'
					   when  avg(puntos) between  5 and 9 then 'Medio'
					   when  avg(puntos) < 10 then 'Alto'
				  end as nivel from @agrupad
				  where proyecto = @proyecto
				  and depto = @depto
			 group by lider
		 end

		 else

		  begin 
			 select lider, cast(avg(cast(puntos as float)) as float) as puntos,
				  case when  avg(puntos) = 0 then 'Optimo'  
					   when  avg(puntos) between 1 and 4 then 'Aceptable'
					   when  avg(puntos) between  5 and 9 then 'Medio'
					   when  avg(puntos) < 10 then 'Alto'
				  end as nivel from @agrupad
				  where proyecto = @proyecto
				  and depto = @depto
				  and @lider = lider
			 group by lider
		 end

	 end



	  if (@modo = 'lider')  or (@modo = 'all')
	 begin

		 if (@lider = 'nada') or (@lider is null) or (@lider = '')

		 if @proyecto is null and @depto is not null
		 begin
		   select proyecto, cast(avg(cast(puntos as float)) as float) as puntos,
			  case when  avg(puntos) = 0 then 'Optimo'  
				   when  avg(puntos) between 1 and 4 then 'Aceptable'
				   when  avg(puntos) between  5 and 9 then 'Medio'
				   when  avg(puntos) < 10 then 'Alto'
			  end as nivel from @agrupad
			  where depto = @depto
		 group by proyecto


		 end

		  if @proyecto is not null and @depto is not null
		 begin
		   select proyecto, cast(avg(cast(puntos as float)) as float) as puntos,
			  case when  avg(puntos) = 0 then 'Optimo'  
				   when  avg(puntos) between 1 and 4 then 'Aceptable'
				   when  avg(puntos) between  5 and 9 then 'Medio'
				   when  avg(puntos) < 10 then 'Alto'
			  end as nivel from @agrupad
			  where depto = @depto
			  and proyecto = @proyecto
		 group by proyecto


		 end

		 else 

		 begin

		  select lider, cast(avg(cast(puntos as float)) as float) as puntos,
			  case when  avg(puntos) = 0 then 'Optimo'  
				   when  avg(puntos) between 1 and 4 then 'Aceptable'
				   when  avg(puntos) between  5 and 9 then 'Medio'
				   when  avg(puntos) < 10 then 'Alto'
			  end as nivel from @agrupa
			  where proyecto = @proyecto
		 group by lider

		 end

	 

	 	 if @lider <> 'nada'

		 begin

		  select lider, cast(avg(cast(puntos as float)) as float) as puntos,
			  case when  avg(puntos) = 0 then 'Optimo'  
				   when  avg(puntos) between 1 and 4 then 'Aceptable'
				   when  avg(puntos) between  5 and 9 then 'Medio'
				   when  avg(puntos) < 10 then 'Alto'
			  end as nivel from @agrupa
			  where proyecto = @proyecto
			  and lider = @lider
		 group by lider

		 end

	end


 ------agrupacion flota----------------------------------------

  if (@modo = 'flota')  or (@modo = 'all')
 begin

  if (@depto is null)
  begin
   select flota, cast(avg(cast(puntos as float)) as float) as puntos,
      case when  avg(puntos) = 0 then 'Optimo'  
	       when  avg(puntos) between 1 and 4 then 'Aceptable'
	       when  avg(puntos) between  5 and 9 then 'Medio'
	       when  avg(puntos) < 10 then 'Alto'
	  end as nivel from @agrupa
	  where proyecto = @proyecto
	  and lider = @lider 
 group by flota
 end

 else

 begin
   select flota, cast(avg(cast(puntos as float)) as float) as puntos,
      case when  avg(puntos) = 0 then 'Optimo'  
	       when  avg(puntos) between 1 and 4 then 'Aceptable'
	       when  avg(puntos) between  5 and 9 then 'Medio'
	       when  avg(puntos) < 10 then 'Alto'
	  end as nivel from @agrupad
	  where proyecto = @proyecto
	  and depto = @depto
	  and lider = @lider
 group by flota
  
 end

 end


 ----agrupacion operadores----------------------------------------

 if @modo = 'oper'  or (@modo = 'all')
 begin

 declare @operador table (driver varchar(20), Nivel varchar(20), abastecimiento int, seguridadvial int, legal int, liquidaciones int, mesacontrol int, mantenimiento int, normatividad int, operaciones int, recursoshumanos int,  segpatrimonial int, total int) 

 if @driver is null 
 begin


insert into @operador

select driver,
      case when  sum(puntos) = 0 then 'Optimo'  
	       when  sum(puntos) between 1 and 4 then 'Aceptable'
	       when  sum(puntos) between  5 and 9 then 'Medio'
	       when  sum(puntos) >= 10 then 'Alto' end as puntos,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Abastecimiento'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Seguridad vial'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Legal'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Liquidaciones'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Mesa de control'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Mantenimiento'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Normatividad'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Operaciones'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Recursos Humanos'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Seguridad patrimonia'),0) ,
isnull(sum(puntos),0)
from @detail e
  where proyecto = @proyecto
  and lider = @lider 
  and flota = @flota
  group by driver

  select * from  @operador
end

else

begin


insert into @operador

select driver,
      case when  sum(puntos) = 0 then 'Optimo'  
	       when  sum(puntos) between 1 and 4 then 'Aceptable'
	       when  sum(puntos) between  5 and 9 then 'Medio'
	       when  sum(puntos) >= 10 then 'Alto' end as puntos,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Abastecimiento'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Seguridad vial'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Legal'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Liquidaciones'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Mesa de control'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Mantenimiento'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Normatividad'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Operaciones'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Recursos Humanos'),0) ,
isnull((select sum(puntos) from @detail t where t.driver = e.driver and depto = 'Seguridad patrimonia'),0) ,
isnull(sum(puntos),0)
from @detail e
  where proyecto = @proyecto
  and lider = @lider 
  and flota = @flota
  and driver = @driver
  group by driver

  select * from  @operador


end


end --modo operador


 ----agrupacion operadores----------------------------------------

 if @modo = 'opera'  or (@modo = 'all')
 begin

 declare @operadora table (driver varchar(20), Nivel varchar(20), abastecimiento int, seguridadvial int, legal int, liquidaciones int, mesacontrol int, mantenimiento int, normatividad int, operaciones int, recursoshumanos int,  segpatrimonial int, total int) 

 if @driver is null 
 begin


insert into @operadora

select driver,
      case when  sum(puntos) = 0 then 'Optimo'  
	       when  sum(puntos) between 1 and 4 then 'Aceptable'
	       when  sum(puntos) between  5 and 9 then 'Medio'
	       when  sum(puntos) >= 10 then 'Alto' end as puntos,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Abastecimiento'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Seguridad vial'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Legal'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Liquidaciones'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Mesa de control'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Mantenimiento'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Normatividad'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Operaciones'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Recursos Humanos'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Seguridad patrimonia'),0) ,
isnull(sum(puntos),0)
from @detail e
  where proyecto = @proyecto
  and lider = @lider 
  and flota = @flota
  and depto = @depto
  group by driver

  select * from  @operadora
end

else

begin


insert into @operadora

select driver,
      case when  sum(puntos) = 0 then 'Optimo'  
	       when  sum(puntos) between 1 and 4 then 'Aceptable'
	       when  sum(puntos) between  5 and 9 then 'Medio'
	       when  sum(puntos) >= 10 then 'Alto' end as puntos,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Abastecimiento'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Seguridad vial'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Legal'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Liquidaciones'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Mesa de control'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Mantenimiento'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Normatividad'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Operaciones'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Recursos Humanos'),0) ,
isnull((select sum(puntos) from @detail t where t.depto = @depto and t.driver = e.driver and depto = 'Seguridad patrimonia'),0) ,
isnull(sum(puntos),0)
from @detail e 
  where proyecto = @proyecto
  and lider = @lider 
  and flota = @flota
  and driver = @driver
  and depto = @depto
  group by driver

  select * from  @operadora


end


end --modo operador

--detalle de observaciones total por operador----------------------------------

if @modo = 'detall'  or (@modo = 'all')
begin

 
 select depto, dro_code,fecha,observo,descrip, comentariosdrv, puntos from @detail
 where driver = @driver
 end

 --detale por tipo en particular---------------------------------------
 if @modo = 'detpar'  or (@modo = 'all')
 begin

 if @depto <> 'Operaciones'
  begin 
   select dro_code,fecha,observo,descrip, comentariosdrv, puntos from @detail
   where driver = @driver
   and depto =   @depto
 end

 else

  begin
     select dro_code,fecha,observo,descrip, comentariosdrv, puntos from @detail
     where driver = @driver
     and depto  in ( select name from labelfile where  labeldefinition = 'RoadSurface' and name not in ('Abastecimiento','Seguridad cial','Seguridad patrimonia'))
  end

  end
GO
