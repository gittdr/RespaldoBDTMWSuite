SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_checkcalledit_carrier_legselect_sp](@ps_carid varchar(8))
AS
/*
 * 
 * NAME:dbo.d_checkcalledit_carrier_legselect_sp
 * 
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set legs assigned to the carrier passed in.
 * Used by the check call window to allow the user to attach
 * a check call to a particular leg.
 *
 * RETURNS:
 * N/A
 *
 * RESULT SETS: 
 * 001 - ord_number
 * 002 - manualcheckcalltime
 * 003 - cty_nmstct
 * 004 - cty_nmstct
 * 005 - lgh_number
 *
 * PARAMETERS:
 * 001 - @ps_carid, varchar(8)
 *
 * REFERENCES:
 * N/A
 * 
 * REVISION HISTORY:
 * 07/30/2007 - PTS 38301 - jbauw - Created 
 * 08/28/2007 - PTS 38677 - vjh - use new logic for event call definition
 * 08/31/2007 - PTS 38577 - vjh - add route id
 **/
declare @vs_CarrierCheckCallLegsRequireSchedule varchar(1)

select @vs_CarrierCheckCallLegsRequireSchedule = isnull(left(gi_string1,1),'Y')
  from generalinfo
 where gi_name = 'CarrierCkcLegsRequireSchedule'

if left(@vs_CarrierCheckCallLegsRequireSchedule,1) = 'Y'
	select o.ord_number, 
		manualcheckcalltime = 
			case
			when s1.stp_status = 'OPN' and ord_manualeventcallminutes = -1 then convert(datetime,'20491231 23:59:59')
			when s1.stp_status = 'OPN' then dateadd(minute, -1*isnull(ord_manualeventcallminutes,0), dbo.convert_to_local_dispatch_time_func(s1.stp_city,s1.stp_arrivaldate,s1.stp_arrivaldate))
			when ord_manualcheckcallminutes = 0 then convert(datetime,'20491231 23:59:59')
			when (select max(ckc_date) from checkcall where ckc_lghnumber = l.lgh_number) > dbo.convert_to_local_dispatch_time_func(s1.stp_city,s1.stp_departuredate,s1.stp_departuredate) then
				 dateadd(minute, isnull(ord_manualcheckcallminutes,0), (select max(ckc_date) from checkcall where ckc_lghnumber = l.lgh_number))
			else dateadd(minute, isnull(ord_manualcheckcallminutes,0), dbo.convert_to_local_dispatch_time_func(s1.stp_city,s1.stp_departuredate,s1.stp_departuredate))
			end,
		c1.cty_nmstct,
		c2.cty_nmstct,
		a.lgh_number,
		o.ord_route
	from assetassignment a 
	join legheader l on a.lgh_number= l.lgh_number
	join orderheader o on l.ord_hdrnumber = o.ord_hdrnumber
	join stops s1 on s1.stp_number = l.stp_number_start
	join city c1 on c1.cty_code = s1.stp_city
	join stops s2 on s2.stp_number = l.stp_number_end
	join city c2 on c2.cty_code = s2.stp_city
	where a.asgn_type='CAR' and a.asgn_id=@ps_carid and asgn_status <> 'CMP'
	and (
			(s1.stp_status = 'OPN' and ord_manualeventcallminutes <> -1)
		or
			(s1.stp_status <> 'OPN' and ord_manualcheckcallminutes <> 0)
		)
else
	select o.ord_number, 
		manualcheckcalltime = 
			case
			when s1.stp_status = 'OPN' and ord_manualeventcallminutes = -1 then convert(datetime,'20491231 23:59:59')
			when s1.stp_status = 'OPN' then dateadd(minute, -1*isnull(ord_manualeventcallminutes,0), dbo.convert_to_local_dispatch_time_func(s1.stp_city,s1.stp_arrivaldate,s1.stp_arrivaldate))
			when ord_manualcheckcallminutes = 0 then convert(datetime,'20491231 23:59:59')
			when (select max(ckc_date) from checkcall where ckc_lghnumber = l.lgh_number) > dbo.convert_to_local_dispatch_time_func(s1.stp_city,s1.stp_departuredate,s1.stp_departuredate) then
				 dateadd(minute, isnull(ord_manualcheckcallminutes,0), (select max(ckc_date) from checkcall where ckc_lghnumber = l.lgh_number))
			else dateadd(minute, isnull(ord_manualcheckcallminutes,0), dbo.convert_to_local_dispatch_time_func(s1.stp_city,s1.stp_departuredate,s1.stp_departuredate))
			end,
		c1.cty_nmstct,
		c2.cty_nmstct,
		a.lgh_number,
		o.ord_route
	from assetassignment a 
	join legheader l on a.lgh_number= l.lgh_number
	join orderheader o on l.ord_hdrnumber = o.ord_hdrnumber
	join stops s1 on s1.stp_number = l.stp_number_start
	join city c1 on c1.cty_code = s1.stp_city
	join stops s2 on s2.stp_number = l.stp_number_end
	join city c2 on c2.cty_code = s2.stp_city
	where a.asgn_type='CAR' and a.asgn_id=@ps_carid and asgn_status <> 'CMP'

GO
GRANT EXECUTE ON  [dbo].[d_checkcalledit_carrier_legselect_sp] TO [public]
GO
