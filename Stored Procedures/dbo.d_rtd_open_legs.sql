SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[d_rtd_open_legs]	@leg integer
as  

Declare @RTD_lghtype	varchar(10),
	@RTD_value			varchar(12),
	@RTD_ignore			varchar(12),
	@RTD_startdate		datetime,
	@oo_trc				varchar(10)



Select @RTD_lghtype = gi_string1,
	@RTD_value = gi_string2,
	@RTD_ignore = gi_string3,
	@RTD_startdate = gi_date1
from generalinfo where gi_name = 'TRCRTDTracking'

Select leg.lgh_number, 
	leg.mov_number, 	
	lgh_startdate,
	lgh_enddate,
	lgh_startstate,
	lgh_endstate,
	lgh_startcity,
	lgh_endcity,
	lgh_outstatus,
	isNull(lgh_rtd_id,0) lgh_rtd_id,
	0 include_rtd,
	asgn.asgn_id,
	asgn.pyd_status,
	ord_hdrnumber,
	(select ord_number from orderheader where orderheader.ord_hdrnumber = leg.ord_hdrnumber) ord_number,
	(select cty_nmstct from city where cty_code =  lgh_startcity) startcity,
	(select cty_nmstct from city where cty_code =  lgh_endcity) endcity,
	lgh_type1,
	lgh_type2, 
	lgh_type3,
	lgh_type4,
	0 lgh_ignore
from Legheader leg join assetassignment asgn on leg.lgh_number = asgn.lgh_number
	join tractorprofile trc on asgn.asgn_id = trc.trc_number and asgn_type = 'TRC'
where asgn_type = 'TRC'
	and asgn_id = (select asgn_id from assetassignment where assetassignment.lgh_number = @leg and asgn_type = 'TRC')
	--and leg.lgh_outstatus = 'CMP'
	and (Case @RTD_lghtype
			when 'lgh_type1' then leg.lgh_type1 
			when 'lgh_type2' then leg.lgh_type2 
			when 'lgh_type3' then leg.lgh_type3 
			when 'lgh_type4' then leg.lgh_type4
		End) <> @RTD_ignore
	and isNull(leg.lgh_rtd_id,0) = 0
	and isNull(trc_actg_type ,'N') = 'A'
	and leg.lgh_startdate > @RTD_startdate


GO
GRANT EXECUTE ON  [dbo].[d_rtd_open_legs] TO [public]
GO
