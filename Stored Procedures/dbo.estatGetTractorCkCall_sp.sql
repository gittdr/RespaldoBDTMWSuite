SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[estatGetTractorCkCall_sp]    Script Date: 10/22/2008 08:25:57 ******/
CREATE procedure [dbo].[estatGetTractorCkCall_sp] 
				(@tractor varchar(8), 
				 @from_date datetime, 
				 @to_date datetime)
-- For a given tractor, returns the most recent check call within date range. 
as
select ckc_date Date,
		-- isnull(ckc_cityname,'') ckc_cityname,  ckc_state, 
		cty_name + ', ' + cty_state Location,
		-- ckc_zip zip
		-- ckc_commentlarge, 
		ckc_comment Comment,
		--ckc_status Status,  
		--ckc_minutes_to_final, 
		--ckc_miles_to_final [Miles to Final], 
		ckc_event [Event]
from checkcall, city 
where ckc_tractor =  @tractor 
		and ckc_date = (SELECT max(ckc_date) from checkcall 
						where ckc_tractor =  @tractor and (ckc_date >= @from_date and ckc_date <= @to_date))
		and cty_code = ckc_city
GO
GRANT EXECUTE ON  [dbo].[estatGetTractorCkCall_sp] TO [public]
GO
