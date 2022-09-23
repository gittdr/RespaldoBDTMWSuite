SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_getMoveEvents] 
	(@evt_mov_number int)
AS

set nocount on
	select 	s.lgh_number
		, ec.name as eventName
		, isnull(c.cmp_name + ' at ' + c.cty_nmstct, '') as Description
		, evt_startdate
		, evt_enddate
		, evt_earlydate
		, evt_latedate
		, isnull(s.stp_ord_mileage,0) as stp_ord_mileage
		, e.evt_eventcode
		, e.evt_sequence
	from event e
		join stops s on e.stp_number = s.stp_number
		join eventcodetable ec on e.evt_eventcode = ec.abbr and IsNull(ec.ect_retired, 'N') <> 'Y'
		join company c on c.cmp_id = s.cmp_id
		join city ct on ct.cty_code = s.stp_city
	where evt_mov_number = @evt_mov_number
	order by e.stp_number, evt_sequence

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[transf_getMoveEvents] TO [public]
GO
