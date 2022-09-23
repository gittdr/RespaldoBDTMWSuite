SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE   View [dbo].[vSSRSRB_StopActualizations]
As

/**
 *
 * NAME:
 * dbo.vSSRSRB_StopActualizations
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * Retrieve Data on whether stops were actualized by TotalMail or Dispatcher, based on the stops.stp_arr_confirmed and stp_dep_confirmed fields
 *
 *
 * REVISION HISTORY:
 *
* 4/16/2014 JR created
 **/
 
SELECT
leg.lgh_tractor as [Tractor],
trc.trc_type1 as [TrcType1],
trc.trc_type2 as [TrcType2],
trc.trc_type3 as [TrcType3],
trc.trc_type4 as [TrcType4],
trc.trc_company as [Tractor Company],
trc.trc_division as [Tractor Division],
trc.trc_terminal as [Tractor Terminal],
trc.trc_teamleader as [Tractor Teamleader],
leg.lgh_driver1 as [Driver ID],
mpp.mpp_lastfirst as [Driver Name],
mpp.mpp_type1 as [DrvType1],
mpp.mpp_type2 as [DrvType2],
mpp.mpp_type3 as [DrvType3],
mpp.mpp_type4 as [DrvType4],
mpp.mpp_company as [Driver Company],
mpp.mpp_division as [Driver Division],
mpp.mpp_terminal as [Driver Terminal],
mpp.mpp_teamleader as [Driver Teamleader],
leg.lgh_number as [Leg Number],
leg.lgh_outstatus as [Leg Status],
leg.lgh_startdate as [Leg Start Date],
(Cast(Floor(Cast(leg.lgh_startdate as float))as smalldatetime))  as [Leg Start Date Only],
leg.lgh_enddate as [Leg end Date],
(Cast(Floor(Cast(leg.lgh_enddate as float))as smalldatetime))  as [Leg EndDate Only],
leg.mov_number as [Move Number],
leg.ord_hdrnumber as [Order Header Number],
ISNULL((select top 1 o.ord_number from orderheader o where o.ord_hdrnumber = leg.ord_hdrnumber),'') as [Order Number],
stp.stp_number as [Stop Number],
stp.stp_mfh_sequence as [Stop Sequence],
evt.evt_eventcode as [Event Code],
eta.name as [Event Name],
eta.drv_pay_event as [Driver Payable],
eta.ect_billable as [Billable],
stp.cmp_id as [Stop Company ID],
cmp.cmp_name as [Stop Company Name],
cmp.cty_nmstct as [Stop Company City State],
case stp.stp_status
when 'DNE' then 'Arrived'
else 'Not Arrived'
end as [Stop Status],
case stp_arr_confirmed
when 'Y' then 1
else 0
end as [Arrived by TotalMail],
stp.stp_arrivaldate as [Stop Arrival Date],
(Cast(Floor(Cast(stp.stp_arrivaldate  as float))as smalldatetime))  as [Stop Arrival Date Only],
case stp.stp_departure_status
when 'DNE' then 'Departed'
else 'Not Departed'
end as [Stop Departure Status],
case stp_dep_confirmed
when 'Y' then 1
else 0
end as [Departed by TotalMail],
stp.stp_departuredate as [Stop Departure Date],
(Cast(Floor(Cast(stp.stp_departuredate   as float))as smalldatetime))  as [Stop Departure Date Only],
datediff(mi,stp.stp_arrivaldate,stp.stp_departuredate) as [Minutes at Stop],
datediff(mi,leg.lgh_startdate,leg.lgh_enddate) as [Minutes on Leg]
from stops stp 
join event evt on stp.stp_number = evt.stp_number
join eventcodetable eta on evt.evt_eventcode = eta.abbr
join legheader leg on stp.lgh_number = leg.lgh_number
join company cmp on stp.cmp_id = cmp.cmp_id
join tractorprofile trc on trc.trc_number = leg.lgh_tractor
join manpowerprofile mpp on mpp.mpp_id = leg.lgh_driver1
GO
GRANT SELECT ON  [dbo].[vSSRSRB_StopActualizations] TO [public]
GO
