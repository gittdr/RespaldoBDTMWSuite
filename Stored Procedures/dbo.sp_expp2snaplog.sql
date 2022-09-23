SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[sp_expp2snaplog] @modo varchar(10), @semanastring varchar(20), @flota varchar(20), @num varchar(30) = null, @trctrl varchar(3) = null
as

/*
--INSERTAR REGISTROS DE MANERA RECURRRENTE PARA JOB
 --exec sp_expp2snaplog 'INSERT', 0 ,'ALL'
 
 --SENTECIA PARA DESLPEGAR DETALLE
 exec sp_expp2snaplog 'GREEN', '2021W1', 'ABIERTO2','D'

  exec sp_expp2snaplog 'GREEN', '2021W1', 'ABIERTO2','T'

 exec sp_expp2snaplog 'GREEN', 49, 'ABIERT'

 --SENTECIA PARA DESPLEGAR DATOS AGRUPADOS
 exec sp_expp2snaplog 'GROUP', 49, 'ABIERTO1'

  --SENTECIA PARA DESPLEGAR TENDENCIA
  exec sp_expp2snaplog 'TREND', 0, 'SAYER'
   exec sp_expp2snaplog 'TRENDO', 0, 'SAYER'


  select * from expp2_log where tractor = '1794'
*/


if @num is null
begin


-----INSERCION DE DATOS------------------------------------------------------------------------------------------------------------------------------------------------------
	if @modo = 'INSERT'
	begin

	----CASO TRACTORES------------------------------------------------------------------------------------------

		insert into expp2_log

	
		select 
		getdate() as fechasnap,
		DATEPART(week,getdate()) as semana,
		trc_number,
		(select name from labelfile where labeldefinition = 'fleet' and abbr =  trc_fleet)  as flota,
		q.exp_expirationdate,
		datediff(day,q.exp_expirationdate, getdate()) as dif,
		case when datediff(day,q.exp_expirationdate, getdate())  >= 0 then 'RED' 
			 when datediff(day,q.exp_expirationdate, getdate())  between -5 and -1 then 'YELLOW'
			 when datediff(day,q.exp_expirationdate, getdate())  < -5 then 'GREEN'  else 'GREEN' end as status,
		q.exp_description,
		q.exp_updateby,
		cast(year(getdate()) as varchar (4)) +'W'+ case when DATEPART(week,getdate()) < 10 then '0'+ cast(DATEPART(week,getdate()) as varchar (4))  else
		cast(DATEPART(week,getdate()) as varchar (4))   end ,
		'TRC'
		from 
		tractorprofile
		left join 
		  (select exp_expirationdate, exp_id, exp_code, exp_description, exp_updateby
		   from expiration where exp_idtype = 'TRC' and exp_completed = 'N' and exp_priority = 9 and exp_code in ('PRE')) as q
		on q.exp_id = trc_number
		 where 
		 trc_status <> 'OUT' 


		 ----CASO TRAILERS------------------------------------------------------------------------------------------

		insert into expp2_log

	
		select 
		getdate() as fechasnap,
		DATEPART(week,getdate()) as semana,
		trl_number,
		(select name from labelfile where labeldefinition = 'fleet' and abbr =  trl_fleet)  as flota,
		q.exp_expirationdate,
		datediff(day,q.exp_expirationdate, getdate()) as dif,
		case when datediff(day,q.exp_expirationdate, getdate())  >= 0 then 'RED' 
			 when datediff(day,q.exp_expirationdate, getdate())  between -5 and -1 then 'YELLOW'
			 when datediff(day,q.exp_expirationdate, getdate())  < -5 then 'GREEN'  else 'GREEN' end as status,
		q.exp_description,
		q.exp_updateby,
		cast(year(getdate()) as varchar (4)) +'W'+ case when DATEPART(week,getdate()) < 10 then '0'+ cast(DATEPART(week,getdate()) as varchar (4))  else
		cast(DATEPART(week,getdate()) as varchar (4))   end ,
		'TRL'
		from 
		trailerprofile
		left join 
		  (select exp_expirationdate, exp_id, exp_code, exp_description, exp_updateby
		   from expiration where exp_idtype = 'TRL' and exp_completed = 'N' and exp_priority = 9 and exp_code in ('PRE')) as q
		on q.exp_id = trl_number
		 where 
		 trl_status <> 'OUT' 



		 -----Cursor pra eliminar exp duplicadas---------------------------------------------------------------------------------------------------------------------------------------------

		 declare @semana varchar(20) = ( select max(semanastring) from expp2_log)


		 declare @tractor varchar(20)

				declare cursordelexpdup cursor
				for

				select tractor from (
				select  tractor, count(*)  as cuenta from expp2_log  where semanastring = @semana group by tractor having count(*) >= 2) as q

				  OPEN cursordelexpdup 
					FETCH NEXT FROM cursordelexpdup INTO @tractor
 
				  WHILE @@FETCH_STATUS = 0  
    
					BEGIN  
				   delete  expp2_log  where semanastring = @semana and tractor = @tractor and dif <> (select max(dif) from expp2_log where semanastring = @semana and tractor = @tractor)


					 FETCH NEXT FROM cursordelexpdup INTO @tractor  
						END  
  
					CLOSE cursordelexpdup  
					DEALLOCATE cursordelexpdup

	 end

 -------------------DETALLE------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	if( @modo = 'GREEN') or (@modo = 'RED' ) or (@modo = 'YELLOW')
	begin

 
   
	select fechasnap,semanastring, tractor, flota, expdate, dif,status, case when expdate is null then 'Sin Expiracion'
	 else exp_description end as exp_description, exp_updatedby 
	from expp2_log
	where  semanastring = @semanastring and flota like replace(@flota,'ALL','')+'%'
	and status = @modo
	and type = @trctrl

	

	end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	 if @modo = 'GROUP'
	  begin
	   select status, count(*) as expiraciones 
	   from expp2_log
	  where semanastring = @semanastring and flota like replace(@flota,'ALL','')+'%'
	  and type = @trctrl
	  group by status

	  end

  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

   if @modo = 'TREND'
  begin

	  declare @trend table (semanastring varchar(20), red int, yellow int, green int, total int, redpct float,  yellowpct float, greenpct float)

	  insert into @trend

	  select  semanastring,
	  ( select count(*) from expp2_log  as t  where flota like replace(@flota,'ALL','')+'%'and  t.semanastring = e.semanastring and status = 'RED'  and type = @trctrl) as red,
	  ( select count(*) from expp2_log  as t  where flota like replace(@flota,'ALL','')+'%'and  t.semanastring = e.semanastring and status = 'YELLOW'and type = @trctrl ) as yellow,
	  ( select count(*) from expp2_log  as t  where flota like replace(@flota,'ALL','')+'%'and  t.semanastring = e.semanastring and status = 'GREEN' and type = @trctrl ) as green,
	   count(*),
	   0,0,0  from expp2_log e 
	   where flota like replace(@flota,'ALL','')+'%'  
	   and type = @trctrl
	   group by semanastring

	   update @trend set redpct = round(cast(red as float)/ cast(total as float),2), yellowpct =  round(cast(yellow as float)/ cast(total as float),2), greenpct = round(cast(green as float)/ cast(total as float),2)

	  select * from @trend

	 end

	   if @modo = 'TRENDO'

	   select status, semanastring, count(*) as expiraciones,
	   ( select count(*) from expp2_log  as t  where flota like replace(@flota,'ALL','')+'%'
		and  t.semanastring = e.semanastring and type = @trctrl ) as unidades,
		case when ( select count(*) from expp2_log  as t  where type = @trctrl and flota like replace(@flota,'ALL','')+'%'
		and  t.semanastring = e.semanastring ) = 0 then 0 else  round(cast(count(*) as float),2) /  ( select round(cast(count(*) as float),2) from expp2_log  as t  where type = @trctrl and flota like replace(@flota,'ALL','')+'%'
		and  t.semanastring = e.semanastring ) end as pct

	   from expp2_log e
	  where flota like replace(@flota,'ALL','')+'%'
	  and type = @trctrl
	  group by status, semanastring


	  end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

else



begin

  if @num = 'D'
 begin
    select  case when cast((select count(*) from expp2_log where  semanastring = @semanastring and flota like replace(@flota,'ALL','')+'%' )as float) = 0 then 0 else
	 cast (count(*) as float)  /  cast((select count(*) from expp2_log where  semanastring = @semanastring and flota like replace(@flota,'ALL','')+'%' )as float)  end as cant 
	 from expp2_log
	where  semanastring = @semanastring and flota like replace(@flota,'ALL','')+'%'
	and status = @modo
	and type = @trctrl
	end

	  if @num = 'T'
 begin

	  select  count(*) as tot  from expp2_log
		where
		  semanastring = @semanastring  
		and status = @modo
		and flota like replace(@flota,'ALL','')+'%'
		and type = @trctrl

		 
	end

end
GO
