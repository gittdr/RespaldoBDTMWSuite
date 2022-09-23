SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[d_planned_expirations_sp] 
(@drv varchar(13),
@trc varchar(13), 
@trl varchar(13), 
@drvdays int, 
@trcdays int, 
@trldays int)

as


select 	exp_idtype,
	exp_id,
	exp_code,
	exp_description, 
	exp_expirationdate,exp_compldate,
	1 exp_show_drivers,
	1 exp_show_tractors,
	1 exp_show_trailers,
	'NO' garbage_row, -- used for display purposes
	exp_routeto,
    exp_control_avl_date,
    exp_key
from 	expiration 
where 	exp_idtype = 'DRV' and 
	exp_id = @drv and 
	exp_id <> '' and 
	exp_expirationdate <= dateadd(dd,@drvdays,getdate()) AND
	exp_completed = 'N'

union 

select 	exp_idtype,
	exp_id,
	exp_code,
	exp_description, 
	exp_expirationdate,
	exp_compldate,
	1 exp_show_drivers,
	1 exp_show_tractors,
	1 exp_show_trailers,
	'NO' garbage_row, -- used for display purposes
	exp_routeto,
    exp_control_avl_date,
    exp_key
from 	expiration 
where 	exp_idtype = 'TRC' and 
	exp_id = @trc and 
	exp_id <> '' and 
	exp_expirationdate <= dateadd(dd,@trcdays,getdate()) AND
	exp_completed = 'N'

union

select 	exp_idtype,
	exp_id,
	exp_code,
	exp_description, 
	exp_expirationdate,
	exp_compldate,
	1 exp_show_drivers,
	1 exp_show_tractors,
	1 exp_show_trailers,
	'NO' garbage_row, -- used for display purposes
	exp_routeto,
	exp_control_avl_date,
    exp_key
from 	expiration 
where 	exp_idtype = 'TRL' and 
	exp_id = @trl and 
	exp_id <> '' and 
	exp_expirationdate <= dateadd(dd,@trldays,getdate()) AND
	exp_completed = 'N'

GO
GRANT EXECUTE ON  [dbo].[d_planned_expirations_sp] TO [public]
GO
