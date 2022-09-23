SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




create proc [dbo].[core_GetTrip] (
@lgh_number int
) as
	
-- Rows needed to instantiate trip (1 leg header, stops, cities, companies, events, load requirements)
select
	lga.lgh_number,
	lga.lgh_outstatus,
	lga.ord_hdrnumber,
	lga.mov_number,
	oh.trl_type1,
	oh.ord_number,
	oh.ord_billto,
	oh.ord_shipper,
	oh.ord_consignee,
	lga.lgh_recommended_car_id
from legheader_active as lga (NOLOCK)
left join orderheader as oh (NOLOCK)
on lga.ord_hdrnumber = oh.ord_hdrnumber
where lga.lgh_number=@lgh_number

select distinct
	stp.lgh_number,
	stp.stp_number,
	stp.stp_mfh_sequence,
	stp.stp_type,
	stp.cmp_id,
	stp.stp_city,
	stp.stp_schdtearliest,
	stp.stp_schdtlatest,
	stp.stp_arrivaldate,
	stp.stp_departuredate
from legheader_active lgh (NOLOCK)
inner join stops stp (NOLOCK)
on lgh.lgh_number=stp.lgh_number
where lgh.lgh_number=@lgh_number
order by stp.stp_mfh_sequence asc

select distinct
	cty.cty_code,
	cty.cty_name,
	cty.cty_state,
	cty.cty_nmstct,
	cty.cty_latitude,
	cty.cty_longitude
from legheader_active lgh (NOLOCK)
inner join stops stp (NOLOCK)
on lgh.lgh_number=stp.lgh_number
left join city cty (NOLOCK)
on stp.stp_city=cty.cty_code
where lgh.lgh_number=@lgh_number
order by cty.cty_code asc

select distinct
	cmp.cmp_id,
	cmp.cmp_name,
	cmp.cmp_latseconds,
	cmp.cmp_longseconds
from legheader_active lgh (NOLOCK)
inner join stops stp (NOLOCK)
on lgh.lgh_number=stp.lgh_number
left join company cmp (NOLOCK)
on stp.cmp_id=cmp.cmp_id
where lgh.lgh_number=@lgh_number
order by cmp.cmp_id asc

select distinct
	evt.evt_number,
	evt.evt_sequence,
	evt.evt_eventcode
from legheader_active lgh (NOLOCK)
inner join stops stp (NOLOCK)
on lgh.lgh_number=stp.lgh_number
left join event evt (NOLOCK)
on stp.stp_number=evt.stp_number
where lgh.lgh_number=@lgh_number
order by evt.evt_sequence asc

--PTS56718 MBR 04/19/11 Added lrq.lrq_derault <> 'X' 
select distinct
	lgh.lgh_number,
	lrq.loadrequirement_id,
	lrq.lrq_sequence,
	lrq.lrq_equip_type,
	lrq.lrq_not,
	lrq.lrq_manditory,
	lrq.lrq_type
from legheader_active lgh (NOLOCK)
inner join loadrequirement lrq (NOLOCK)
on lgh.mov_number=lrq.mov_number and lrq.lrq_default <> 'X'
where lgh.lgh_number=@lgh_number
order by lrq.lrq_sequence asc


select * from core_fncGetLanesForLeg (@lgh_number) 

GO
GRANT EXECUTE ON  [dbo].[core_GetTrip] TO [public]
GO
