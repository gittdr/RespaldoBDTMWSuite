SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[d_ctx_plan_trc_sp] 
as 
/*
CREATE TABLE #temp (
	ord_tractor VARCHAR(8) 
	, trc_status VARCHAR(6) NULL
	, ord_number VARCHAR(12) NULL
	, ord_hdrnumber INT NULL
	, ord_status VARCHAR(6) NULL
	, ord_totalweight FLOAT NULL
	, ord_totalpieces FLOAT NULL
	, origin_cmp_id VARCHAR(8) NULL
	, ord_startdate DATETIME NULL
	, ord_completiondate DATETIME NULL
	, origin_name VARCHAR(30) NULL
	, origin_city VARCHAR(25) NULL
	, dest_cmp_id VARCHAR(8) NULL
	, dest_name VARCHAR(30) NULL
	, dest_city VARCHAR(25) NULL
	, ord_driver VARCHAR(30) NULL
	, ord_originregion1 VARCHAR(6) NULL
	, ord_destregion1 VARCHAR(6) NULL
	, billto_cmp_id VARCHAR(8) NULL
	, mov_number INT NULL
	, orderby_cmp_id VARCHAR(8) NULL
	)
*/

--INSERT INTO #temp
SELECT	t.trc_number
	, t.trc_status
	, o.ord_number
	, o.ord_hdrnumber
	, legheader_active.lgh_outstatus
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
	, legheader_active.lgh_driver1
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
	, legheader_active
WHERE	o.ord_originpoint = oc.cmp_id
  AND	o.ord_origincity = ocity.cty_code
  AND	o.ord_destpoint = dc.cmp_id
  AND	o.ord_destcity = dcity.cty_code
  AND	legheader_active.ord_hdrnumber = o.ord_hdrnumber
  AND	t.trc_number = legheader_active.lgh_tractor
  AND	t.trc_status <> 'OUT'

--INSERT INTO #temp
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
  AND	t.trc_status <> 'OUT'
/*
UPDATE 	#temp
SET	ord_tractor = ''
WHERE	ord_tractor = 'UNKNOWN'
*/

--INSERT INTO #temp
UNION
SELECT	t.trc_number
	, t.trc_status
	, ''
	, 0
	, legheader_active.lgh_outstatus
	, 0
	, 0
	, legheader_active.cmp_id_start
	, legheader_active.lgh_startdate
	, legheader_active.lgh_enddate
	, oc.cmp_name
	, ocity.cty_nmstct
	, legheader_active.cmp_id_end
	, dc.cmp_name
	, dcity.cty_nmstct
	, legheader_active.lgh_driver1
	, lgh_startregion1
	, lgh_endregion1
	, ''
	, legheader_active.mov_number
	, ''
FROM	tractorprofile t
	, company oc
	, company dc
	, city ocity
	, city dcity
	, legheader_active
WHERE	legheader_active.cmp_id_start = oc.cmp_id
  AND	legheader_active.lgh_startcity = ocity.cty_code
  AND	legheader_active.cmp_id_end = dc.cmp_id
  AND	legheader_active.lgh_endcity = dcity.cty_code
  AND	t.trc_number = legheader_active.lgh_tractor
  AND	legheader_active.ord_hdrnumber = 0
  AND	t.trc_status <> 'OUT'
/*
SELECT *
FROM #temp
*/
GO
GRANT EXECUTE ON  [dbo].[d_ctx_plan_trc_sp] TO [public]
GO
