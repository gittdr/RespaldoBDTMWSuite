SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[vista_rptoport]

as

select 
(select usr_fname+' '+ usr_lname from ttsusers where usr_userid =  aSSIGNED_USER) as Usuario,
 sum(cast(description as int) ) as Monto,count(*) as Numero,
(select name from labelfile where labeldefinition = 'Task Status' and abbr = status) as Estatus
from task
where activity_type = 'OPORT' 
group by aSSIGNED_USER,status
GO
GRANT SELECT ON  [dbo].[vista_rptoport] TO [public]
GO
