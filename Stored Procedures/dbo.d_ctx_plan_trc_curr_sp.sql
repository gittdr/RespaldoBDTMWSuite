SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[d_ctx_plan_trc_curr_sp]
		@vs_trc_number	varchar(8)
as 
/*	Same as d_ctx_plan_trc_sp, only it excludes completed orders.

	Revision History:
	Date		Name			PTS		Label	Description
	-----------	---------------	-------	-------	-----------------------------------------------
	01/23/2003	Vern Jewett		16884	(none)	Original.
*/
SELECT	t.trc_number
	, t.trc_status
	, o.ord_number
	, o.ord_hdrnumber
	, lh.lgh_outstatus
	, o.ord_totalweight
	, o.ord_totalpieces
	, o.ord_originpoint
	, o.ord_startdate
	, o.ord_completiondate
	, oc.cmp_name
	, ocity.cty_nmstct
	, o.ord_destpoint
	, dc.cmp_name
	, dcity.cty_nmstct
	, lh.lgh_driver1
	, ord_originregion1
	, ord_destregion1
	, o.ord_billto
	, o.mov_number
	, o.ord_company
FROM	tractorprofile t
	, orderheader o
	, company oc
	, company dc
	, city ocity
	, city dcity
	, legheader lh
WHERE	o.ord_originpoint = oc.cmp_id
  AND	o.ord_origincity = ocity.cty_code
  AND	o.ord_destpoint = dc.cmp_id
  AND	o.ord_destcity = dcity.cty_code
  AND	lh.ord_hdrnumber = o.ord_hdrnumber
  AND	lh.lgh_active = 'Y'
  AND	lh.lgh_outstatus <> 'CMP'
  AND	t.trc_number = lh.lgh_tractor
  AND	t.trc_number = @vs_trc_number

UNION
SELECT	t.trc_number
	, t.trc_status
	, o.ord_number
	, o.ord_hdrnumber
	, 'MPN'
	, o.ord_totalweight
	, o.ord_totalpieces
	, o.ord_originpoint
	, o.ord_startdate
	, o.ord_completiondate
	, oc.cmp_name
	, ocity.cty_nmstct
	, o.ord_destpoint
	, dc.cmp_name
	, dcity.cty_nmstct
	, ppa.ppa_driver1
	, ord_originregion1
	, ord_destregion1
	, ord_billto
	, o.mov_number
	, o.ord_company
FROM	tractorprofile t
	, orderheader o
	, company oc
	, company dc
	, city ocity
	, city dcity
	, preplan_assets ppa
WHERE	o.ord_originpoint = oc.cmp_id
  AND	o.ord_origincity = ocity.cty_code
  AND	o.ord_destpoint = dc.cmp_id
  AND	o.ord_destcity = dcity.cty_code
  AND	ppa.ppa_mov_number = o.mov_number
  AND	ppa.ppa_status = 'Active'
  AND	ppa.ppa_tractor = t.trc_number
  AND	t.trc_number = @vs_trc_number
GO
GRANT EXECUTE ON  [dbo].[d_ctx_plan_trc_curr_sp] TO [public]
GO
