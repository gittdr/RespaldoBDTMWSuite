SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[TMWScrollStopView2] AS

--Empty move (no order) stops
SELECT
		stops.ord_hdrnumber,
		stops.stp_number,
		stops.cmp_id, 
		stops.cmp_name, 
		stops.stp_arrivaldate, 
		stops.stp_departuredate,
		stops.stp_type, 
		stops.stp_zipcode, 
		stops.stp_status, 
		stops.cmd_code,
		stops.stp_volume,
		stops.stp_volumeunit,
		stops.stp_city,
		stops.stp_state,
		stops.stp_schdtearliest,
		stops.stp_schdtlatest,
		stops.stp_description,
		stops.stp_sequence,
		stops.trl_id,
		stops.stp_mfh_sequence,
		stops.stp_event,
		stops.stp_ord_mileage,
		stops.stp_lgh_mileage,
		stops.stp_mfh_mileage,
		stops.mov_number,
		stops.stp_weight,
		stops.stp_weightunit,
		stops.stp_count,
		stops.stp_countunit,
		stops.stp_comment,
		stops.stp_reftype,
		stops.stp_refnum,
		stops.stp_phonenumber,
		stops.stp_OOA_stop,
		stops.stp_address,
		stops.stp_podname,
		dbo.city.cty_nmstct as cty_nmstct, 
		dbo.company.cmp_latseconds as cmp_latseconds,
		dbo.company.cmp_longseconds as cmp_longseconds,
		null as [ord_BelongsTo],
		null as [ord_rowsec_rsrv_id]
FROM	dbo.stops (NOLOCK) 
		LEFT OUTER JOIN dbo.city (NOLOCK) ON dbo.stops.stp_city = dbo.city.cty_code 
		LEFT OUTER JOIN dbo.company (NOLOCK) ON dbo.stops.cmp_id = dbo.company.cmp_id
WHERE	ISNULL(dbo.stops.ord_hdrnumber, 0) = 0
		
		
UNION

--Order stops
SELECT
		stops.ord_hdrnumber,
		stops.stp_number,
		stops.cmp_id, 
		stops.cmp_name, 
		stops.stp_arrivaldate, 
		stops.stp_departuredate,
		stops.stp_type, 
		stops.stp_zipcode, 
		stops.stp_status, 
		stops.cmd_code,
		stops.stp_volume,
		stops.stp_volumeunit,
		stops.stp_city,
		stops.stp_state,
		stops.stp_schdtearliest,
		stops.stp_schdtlatest,
		stops.stp_description,
		stops.stp_sequence,
		stops.trl_id,
		stops.stp_mfh_sequence,
		stops.stp_event,
		stops.stp_ord_mileage,
		stops.stp_lgh_mileage,
		stops.stp_mfh_mileage,
		stops.mov_number,
		stops.stp_weight,
		stops.stp_weightunit,
		stops.stp_count,
		stops.stp_countunit,
		stops.stp_comment,
		stops.stp_reftype,
		stops.stp_refnum,
		stops.stp_phonenumber,
		stops.stp_OOA_stop,
		stops.stp_address,
		stops.stp_podname,
		dbo.city.cty_nmstct as cty_nmstct, 
		dbo.company.cmp_latseconds as cmp_latseconds,
		dbo.company.cmp_longseconds as cmp_longseconds,
		oh.ord_BelongsTo as [ord_BelongsTo], --It's doubtful these are actually in use at the client for purposes other than security, but returned for compatibility
		oh.rowsec_rsrv_id as [ord_rowsec_rsrv_id]  --It's doubtful these are actually in use at the client for purposes other than security, but returned for compatibility
		--(select ord_BelongsTo from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber) as [ord_BelongsTo],
		--(select rowsec_rsrv_id from orderheader where orderheader.ord_hdrnumber = stops.ord_hdrnumber) as [ord_rowsec_rsrv_id]
FROM	dbo.stops (NOLOCK) 
		INNER JOIN dbo.orderheader oh on (dbo.stops.ord_hdrnumber = oh.ord_hdrnumber)
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('orderheader', null) rsva ON (oh.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
		LEFT OUTER JOIN dbo.city (NOLOCK) ON dbo.stops.stp_city = dbo.city.cty_code 
		LEFT OUTER JOIN dbo.company (NOLOCK) ON dbo.stops.cmp_id = dbo.company.cmp_id
WHERE	ISNULL(dbo.stops.ord_hdrnumber, 0) <> 0
		
		
GO
GRANT DELETE ON  [dbo].[TMWScrollStopView2] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollStopView2] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollStopView2] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollStopView2] TO [public]
GO
