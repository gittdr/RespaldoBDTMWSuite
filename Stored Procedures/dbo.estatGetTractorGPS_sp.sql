SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[estatGetTractorGPS_sp] (@tractor varchar(8))
-- For a given tractor, returns the most recent GPS location info. 
as
select ckc_date Date,		-- isnull(ckc_cityname,'') ckc_cityname,  ckc_state, 
cty_name + ', ' + cty_state Location,
							-- ckc_commentlarge, 
ckc_comment Comment,		--ckc_status Status,  
ckc_event [Event]			--ckc_minutes_to_final, --ckc_miles_to_final [Miles to Final],--ckc_zip zip 
from checkcall, city 
where ckc_tractor =  @tractor 
and ckc_date = (SELECT max(ckc_date)  from checkcall where ckc_tractor =  @tractor)
and cty_code = ckc_city
GO
GRANT EXECUTE ON  [dbo].[estatGetTractorGPS_sp] TO [public]
GO
