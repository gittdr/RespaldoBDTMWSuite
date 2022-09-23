SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[BoardConfigurationDetailExpirations] @lgh_number int 
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
    exp_key, assetassignment.lgh_number
from assetassignment join expiration on exp_idtype = asgn_type and exp_id = asgn_id
where 	exp_id <> '' and 
	exp_expirationdate <= dateadd(dd,14,getdate()) AND
	exp_completed = 'N' and assetassignment.lgh_number = @lgh_number
GO
GRANT EXECUTE ON  [dbo].[BoardConfigurationDetailExpirations] TO [public]
GO
