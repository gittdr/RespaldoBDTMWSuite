SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[WebProductsTractorMapDetailsView_WithMoreDetails] 
AS
SELECT	DISTINCT  [number],[status],[Consignee],[PickupName],[PickupCity],[PickupState],[legNumber],[movenumber],
		[ETAtoStop],[MinOut],[next_drp_stp_number],[dropeta.stp_number],[Appointment_Time],[ETA_Update],[dropetastop],
		[CompanyName],[MileOut],[GPSDate],[GPS_Location],[StopArrivalTime],[TimeETAUpdate],[CurrentStopSequence], [CurrentStopNumber],[RouteName],
		[ord_number],[ord_billto],dbo.TractorColorAndDirection([legnumber],[dropetastop],[ord_billto], [NextDrop_StopArrivalTime], [NextDrop_ScheduledEarliest], [NextDrop_ScheduledLatest], [StopArrivalTime]) as 'Icon1'		
FROM	(
		SELECT  t.trc_number AS number, 
				t.trc_status AS status,
				ccompany.cmp_name 'Consignee',
				scompany.cmp_name 'PickupName',
				scity.cty_name 'PickupCity',
				scity.cty_state 'PickupState',
				lgh.lgh_number 'legNumber',
				lgh.mov_number 'movenumber',
				ISNULL(dropeta.ste_seconds_out/60,ISNULL(pickupeta.ste_seconds_out/60,0)) 'ETAtoStop',
				ISNULL(dropeta.ste_seconds_out/60,0) 'MinOut',
				lgh.next_drp_stp_number 'next_drp_stp_number',
				dropeta.stp_number 'dropeta.stp_number',
				cs.stp_schdtlatest 'Appointment_Time',
				dropeta.ste_updated 'ETA_Update',
				dropeta.stp_number 'dropetastop',
				cs.cmp_name 'CompanyName',
				dropeta.ste_miles_out 'MileOut',
				mpp.mpp_gps_Date 'GPSDate',
				mpp.mpp_gps_desc 'GPS_Location',
				DATEADD(ss, dropeta.ste_seconds_out,dropeta.ste_updated) 'StopArrivalTime',
				dropeta.ste_updated 'TimeETAUpdate',
				cs.stp_mfh_sequence 'CurrentStopSequence',
				cs.stp_number 'CurrentStopNumber',
				[RouteName] = ISNULL(ord.ord_refnum,'NONE'),
				[ord_number] = ord.ord_hdrnumber,
				ord.ord_billto,
				[NextDrop_StopArrivalTime] = NextDrop.stp_arrivaldate, 
				[NextDrop_ScheduledEarliest] = NextDrop.stp_schdtearliest,
				[NextDrop_ScheduledLatest] = NextDrop.stp_schdtlatest 
		FROM	dbo.tractorprofile t WITH (NOLOCK) 
				JOIN legheader_active lgh WITH (NOLOCK) ON t.trc_number = lgh.lgh_tractor
				LEFT OUTER JOIN company  ccompany WITH (NOLOCK) ON lgh.cmp_id_end = ccompany.cmp_id  
				LEFT OUTER JOIN company  scompany WITH (NOLOCK) ON lgh.cmp_id_start = scompany.cmp_id 
				LEFT OUTER JOIN city scity WITH (NOLOCK)  ON lgh.lgh_startcity = scity.cty_code 
				LEFT OUTER JOIN orderheader ord WITH (NOLOCK) ON lgh.ord_hdrnumber = ord.ord_hdrnumber
				LEFT OUTER JOIN Stops_eta dropeta WITH (NOLOCK) ON lgh.next_drp_stp_number = dropeta.stp_number
				LEFT OUTER JOIN Stops_eta pickupeta WITH (NOLOCK) ON lgh.next_pup_stp_number = pickupeta.stp_number
				LEFT OUTER JOIN (
								SELECT	mov_number, lgh_number, [StopSequence] = MIN(stp_mfh_sequence)
								FROM	stops WITH (NOLOCK)
								WHERE	stp_departure_status = 'OPN'
								GROUP BY mov_number, lgh_number
								) seq ON lgh.lgh_number = seq.lgh_number
				LEFT OUTER JOIN stops cs WITH (NOLOCK) ON seq.mov_number = cs.mov_number and seq.StopSequence = cs.stp_mfh_sequence
				LEFT OUTER JOIN manpowerprofile mpp WITH (NOLOCK) ON ord.ord_driver1 = mpp.mpp_id 
				LEFT OUTER JOIN stops NextDrop WITH (NOLOCK) ON lgh.next_drp_stp_number = NextDrop.stp_number
		WHERE	t.trc_status <> 'OUT' AND cs.stp_status <> 'DNE' AND lgh.lgh_outstatus = 'STD' AND cs.stp_departure_status <> 'DNE' AND lgh_tractor <> 'UNKNOWN'
		) as StopInfo 
GO
GRANT SELECT ON  [dbo].[WebProductsTractorMapDetailsView_WithMoreDetails] TO [public]
GO
