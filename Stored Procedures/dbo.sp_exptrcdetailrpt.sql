SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  proc [dbo].[sp_exptrcdetailrpt] (@fleet varchar(20) , @exp_code varchar(20),@anio int , @mes int, @dia int)

as

declare @minutedayoffset int = 56

select exp_id, (select max(name) from labelfile where labeldefinition in ('drvexp', 'trcexp','trlexp') and abbr = exp_code) as expiracion,
	exp_expirationdate as inicio, exp_lastdate as fin, 

	datediff(day,exp_expirationdate,exp_compldate) as dias,
	exp_compldate as completada,
	 ( select usr_fname+ ' ' + usr_lname from ttsusers where usr_userid =   exp_updateby) as creadapor,
	  exp_description as descripcion,
	   exp_id  as recname,
	  exp_completed,
	  (select mpp_id+' | ' +mpp_firstname+' '+ mpp_lastname from manpowerprofile where  mpp_id = (select trc_driver  from tractorprofile where trc_number  = exp_id )) as Operador,
	  (select case when  trc_driver is null then 'Unseated'  when trc_driver = 'Unknown' then 'Unseated'  else 'Seated' end  from tractorprofile where trc_number  = exp_id ) as SeatedUnseated,
	  (select  format(trc_gps_date,'dd-MM-yy hh:mm') + ' | ' + trc_gps_desc  from tractorprofile where trc_number  = exp_id ) as GPS,
	  cast(@anio as varchar(5)) + '-'+ 
	 case when @mes <9 then '0' + cast(@mes as varchar(3)) else cast(@mes as varchar(3))  end + '-'+
	 case when @dia <9 then '0' + cast(@dia as varchar(3)) else cast(@dia as varchar(3))  end as searchdate
 from expiration
 
 where exp_code = @exp_code and
 exp_id in (select trc_number from tractorprofile where  trc_Status <> 'OUT' and  trc_fleet = (  (select abbr from labelfile where labeldefinition = 'fleet' and name in (@fleet ))))
 and
 cast(@anio as varchar(5)) + '-'+  case when @mes <9 then '0' + cast(@mes as varchar(3)) else cast(@mes as varchar(3))  end + '-'+
 case when @dia <9 then '0' + cast(@dia as varchar(3)) else cast(@dia as varchar(3))  end
 between CAST(CAST(exp_expirationdate AS DATE) AS DATETIME) and case when DATEDIFF(day,exp_expirationdate, exp_compldate)>= 1 then  dateadd(minute, @minutedayoffset,exp_compldate) else exp_compldate  end

GO
