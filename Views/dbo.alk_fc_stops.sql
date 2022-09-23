SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create view [dbo].[alk_fc_stops] as

select	lgh_tractor st_unit
	, stops.lgh_number st_tripid
	, stops.stp_event st_event
	, stp_status st_sts
	, stp_arrivaldate st_arvl_date
	, stp_schdtlatest st_arvl_ltst
	, cty_stp.cty_name st_city
	, cty_stp.cty_state st_st
	, cty_stp.cty_county st_cnty
	, cty_stp.cty_zip st_zip
	, stops.stp_mfh_sequence st_stop
	, orderheader.ord_number st_order
	, 'st_check_eta' = 
		case 
		when stp_type in ('DRP', 'PUP') then 'Y'
		else 'N'
		end
	, 'st_load' = 
		case
		when stp_loadstatus = ('LD') THEN 'LOADED'
		else 'EMPTY'
		end
from 	legheader
	, stops
	, city cty_stp
	, company cmp_stp
	, orderheader
where 	legheader.lgh_number = stops.lgh_number
  and	stops.stp_city = cty_stp.cty_code
  and	stops.cmp_id = cmp_stp.cmp_id
  AND	stops.ord_hdrnumber *= orderheader.ord_hdrnumber

GO
GRANT DELETE ON  [dbo].[alk_fc_stops] TO [public]
GO
GRANT INSERT ON  [dbo].[alk_fc_stops] TO [public]
GO
GRANT REFERENCES ON  [dbo].[alk_fc_stops] TO [public]
GO
GRANT SELECT ON  [dbo].[alk_fc_stops] TO [public]
GO
GRANT UPDATE ON  [dbo].[alk_fc_stops] TO [public]
GO
