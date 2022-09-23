SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[transf_getRoutesForMonitor_sp] 
(	
	@carrier_id varchar(8)
)
AS

set nocount on

	select isnull(lgh_route, '') Route,
		ord_hdrnumber as OrderNo,
		lgh_driver1,
		lgh_tractor,
		isnull((select trc_mctid from tractorprofile where trc_number = lgh_tractor), '') as trc_mctid,
		lgh_primary_trailer,
		lgh_startdate as Dispatched,
		lgh_extrainfo2 as Delay,
		isnull (lgh_extrainfo3, '') as Color,
		(case when lgh_extrainfo4 is null or lgh_extrainfo4 = '1' then '' else '*' end) as Confirmed,
		reverse(convert(char(20), reverse(lgh_extrainfo5))) as DelayMinutes,
		lgh_number
	FROM legheader_active
	where lgh_carrier = @carrier_id
		and ltrim(rtrim(lgh_extrainfo5)) <> ''
		and convert (int, ltrim(rtrim(lgh_extrainfo5)))>15
	order by Confirmed, DelayMinutes desc

GO
GRANT EXECUTE ON  [dbo].[transf_getRoutesForMonitor_sp] TO [public]
GO
