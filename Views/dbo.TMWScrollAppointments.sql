SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWScrollAppointments] 
AS

SELECT
	legheader_active.lgh_number, 
	legheader_active.mov_number,
	stops.stp_number, 
	lgh_outstatus,
	legheader_active.lgh_startdate,
	legheader_active.lgh_enddate,
	legheader_active.ord_billto,
	stops.cmp_id,
	stops.cmp_name, 
	stpcmp.cty_nmstct, 
	stpcmp.cmp_state, 
	stpcmp.cmp_region1, 
	stpcmp.cmp_region2, 
	stpcmp.cmp_region3, 
	stpcmp.cmp_region4,   
    legheader_active.mpp_teamleader,
    lgh_priority,
    IsNull(stops.stp_AppointmentStatus, 'N') AS stp_AppointmentStatus,
    IsNull(StopSchedules.sch_BillToContactMade, 'N') AS sch_BillToContactMade,
    IsNull(StopSchedules.sch_CreatedBy, 'UNKNOWN') AS sch_CreatedBy,
    IsNull(StopSchedules.sch_CreatedOn, '12/31/2049 23:59:59') AS sch_CreatedOn,
    IsNull(StopSchedules.sch_LocationContactMade, 'N') AS sch_LocationContactMade,
    IsNull(StopSchedules.sch_LastUpdateBy, 'UNKNOWN') AS sch_LastUpdateBy,
	IsNull(StopSchedules.sch_LastUpdateOn, '12/31/2049 23:59:59') AS sch_LastUpdateOn,
	CompanyScheduleDetail.csd_ReschedulePenalty,
	stops.ord_hdrnumber,
	oh.ord_number,
	ISNULL(StopSchedules.sch_id, -1) AS sch_id,
	stops.stp_status,
	oh.ord_revtype1,
	oh.ord_revtype2,
	oh.ord_revtype3,
	oh.ord_revtype4,
	stops.stp_type,
	shipcmp.cmp_id as ShipperId,
	shipcty.cty_nmstct as ShipperCity,
	shipcmp.cmp_state as ShipperState,
	shipcmp.cmp_region1 as ShipperRegion1,
	shipcmp.cmp_region2 as ShipperRegion2,
	shipcmp.cmp_region3 as ShipperRegion3,
	shipcmp.cmp_region4 as ShipperRegion4,
	conscmp.cmp_id as ConsigneeId,
	conscity.cty_nmstct as ConsigneeCity,
	conscmp.cmp_state as ConsigneeState,
	conscmp.cmp_region1 as ConsigneeRegion1,
	conscmp.cmp_region2 as ConsigneeRegion2,
	conscmp.cmp_region3 as ConsigneeRegion3,
	conscmp.cmp_region4 as ConsigneeRegion4
FROM stops WITH (NOLOCK)
	LEFT JOIN StopSchedules WITH (NOLOCK) ON stops.stp_number = StopSchedules.stp_number
	LEFT JOIN legheader_active WITH (NOLOCK) ON legheader_active.lgh_number = stops.lgh_number
	JOIN company stpcmp WITH (NOLOCK) ON (stops.cmp_id = stpcmp.cmp_id) 
	LEFT JOIN orderheader oh with (NOLOCK) ON stops.ord_hdrnumber = oh.ord_hdrnumber
	LEFT JOIN CompanyScheduleDetail with (NOLOCK) ON oh.ord_billto = CompanyScheduleDetail.cmp_id 
	LEFT JOIN company shipcmp WITH (NOLOCK) ON shipcmp.cmp_id = (select top 1 oh.ord_shipper from orderheader oh with (nolock) where oh.ord_hdrnumber = stops.ord_hdrnumber)
	LEFT JOIN company conscmp WITH (NOLOCK) ON conscmp.cmp_id = (select top 1 oh.ord_consignee from orderheader oh with (nolock) where oh.ord_hdrnumber = stops.ord_hdrnumber)
	LEFT JOIN city shipcty WITH (NOLOCK) ON shipcty.cty_code = shipcmp.cmp_city
	LEFT JOIN city conscity WITH (NOLOCK) ON conscity.cty_code = conscmp.cmp_city
WHERE lgh_outstatus IN ('AVL', 'PLN', 'STD', 'DSP')
	AND ISNULL(stops.stp_AppointmentStatus, 'N') IN ('S', 'R', 'N', 'SCH', 'C')
	AND stops.ord_hdrnumber <> 0
	AND stops.stp_type IN ('PUP', 'DRP')
GO
GRANT SELECT ON  [dbo].[TMWScrollAppointments] TO [public]
GO
