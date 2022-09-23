SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE  proc [dbo].[d_partorder_browse_trial_sp] (
			@branch			varchar(12),
			@supplier 		varchar(8),
			@plant 			varchar(8),
			@dock  			varchar(8),
			@part_number 	varchar(20),
			@route 			varchar(15),
 			@reftype  		varchar(6),
			@refnum 		varchar(30),
			@pickup_from	datetime,
			@pickup_to 		datetime,
			@delivery_from 	datetime,
			@delivery_to	datetime,
			@timeline		int,
			@received		datetime,
			@unk_supplier		char(1),
			@refnum_to		varchar(30))
as

/**
 * 
 * NAME:
 * dbo.d_partorder_browse_trial_sp
 *
 * TYPE:
 * [StoredProcedure|
 *
 * DESCRIPTION:
 * for dw d_partorder_browse
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * dw result set
 *
 * PARAMETERS:
 * 			@branch			varchar(12)	branch
			@supplier 		varchar(8),	supplier
			@plant 			varchar(8), plant
			@dock  			varchar(8), dock
			@part_number 	varchar(20), part #
			@route 			varchar(15), route
 			@reftype  		varchar(6),	ref type
			@refnum 		varchar(30), ref #
			@pickup_from	datetime, pickup date from
			@pickup_to 		datetime, pickup date to
			@delivery_from 	datetime, delivery date from
			@delivery_to	datetime, delivery date to
			@timeline		int, timeline id
			@received		datetime date received
			@unk_supplier		char(1) include UNKNOWN supplier
 *
 * 
 * REVISION HISTORY:
 * 08/10/05	LOR	PTS# 29264
 * 08/12/05	LOR	PTS# 29095
 * 8/17/05 DSK PTS# 29317 -- re-write joins
 * 11/24/05 DSK 30696 
 * 06/12/06	LOR	PTS# 32784	add incl. UNKNOWN supplier
 * 03/29/07	MRH 	New window for trail part orders.
 **/

-- 30696
DECLARE 
  @lot VARCHAR(6)
, @sid VARCHAR(6)
, @lotname VARCHAR(15)
, @sidname VARCHAR(15)

CREATE TABLE #ref (
	  poh_identity INTEGER)

SELECT @lot = gi_string1, @lotname = name 
FROM generalinfo
JOIN labelfile ON abbr = gi_string1
WHERE gi_name = 'LotNumberRefType'

SELECT @sid = gi_string1, @sidname = name 
FROM generalinfo
JOIN labelfile ON abbr = gi_string1 
WHERE gi_name = 'ManifestNumberRefType'

IF @refnum <> 'UNKNOWN' AND @refnum_to <> 'UNKNOWN' -- 35368
BEGIN
	INSERT INTO #ref
	SELECT CAST(ref_tablekey AS INTEGER)
	FROM referencenumber
	WHERE ref_table = 'partorder_header'
	  AND ref_number BETWEEN @refnum AND @refnum_to
	  AND	@reftype IN (ref_type, 'UNK') 

   SELECT Distinct h.poh_identity,   
         h.poh_branch,   
         h.poh_supplier,   
         h.poh_plant,   
         h.poh_dock,   
         h.poh_jittime,   
         h.poh_sequence,   
         @sidname sid_ref_type,   
         sid.ref_number,   
         h.poh_pickupdate,   
         h.poh_deliverdate,   
         h.poh_timelineid ,
			case IsNull(h.poh_timelineid, 0)
				when 0 then ''
				else tlh_name
			end tlh_name,
			c_details = (select count(*) from partorder_detail 
							where h.poh_identity = partorder_detail.poh_identity ),
			h.poh_datereceived,
			supplier_city = cty_nmstct,
			@lotname lot_ref_type,
			lot.ref_number lot_ref_number,
	-- MRH 3/30
	d.pod_adjustedcount,
	d.pod_adjustedcontainers,
	d.pod_pu_count,
	d.pod_pu_containers,
	d.pod_cur_count,
	d.pod_cur_containers,
	h.poh_srf_recieve,
	isnull(r.por_ordhdr, 0) por_ordhdr,
	'' update_po,
	0 modflag,
	h.poh_supplieralias,
	d.pod_partnumber,
	d.pod_description,
	d.pod_pending_date,
	h.poh_comment,
	d.pod_updatedon,
	d.pod_updatedby
    FROM partorder_header h
	JOIN partorder_detail d ON h.poh_identity = d.poh_identity
	JOIN company ON cmp_id = poh_supplier
	LEFT OUTER JOIN timeline_header ON tlh_number = h.poh_timelineid
	LEFT OUTER JOIN partorder_routing r ON r.poh_identity = h.poh_identity
	LEFT OUTER JOIN orderheader oh ON oh.ord_hdrnumber = r.por_ordhdr AND @route in (ord_route, 'UNKNOWN')
	LEFT OUTER JOIN referencenumber sid ON sid.ref_tablekey = h.poh_identity AND sid.ref_type = @sid
	LEFT OUTER JOIN referencenumber lot ON lot.ref_tablekey = h.poh_identity AND lot.ref_type = @lot
	JOIN #ref ON h.poh_identity = #ref.poh_identity
	WHERE ((oh.ord_hdrnumber IS NOT NULL AND @route IN (ord_route, 'UNKNOWN')) 
			OR (oh.ord_hdrnumber IS NULL AND @route = 'UNKNOWN'))
		AND poh_branch = @branch 
--		AND @supplier IN (poh_supplier, 'UNKNOWN') 
		AND @plant IN (poh_plant, 'UNKNOWN') 
		AND @dock IN (poh_dock, 'UNKNOWN') 
		AND (@part_number IN (d.pod_partnumber, 'UNKNOWN') OR (@part_number <> 'UNKNOWN' AND d.pod_partnumber LIKE @part_number + '%'))
		AND ((@timeline = 0 AND ISNULL(poh_timelineid, 0) = 0) 
					OR (@timeline = 1 AND ISNULL(poh_timelineid, 0) > 0)
					OR (@timeline = 2))
		AND (poh_pickupdate BETWEEN @pickup_from AND @pickup_to OR poh_pickupdate = '19000101 00:00')
		AND (poh_deliverdate BETWEEN @delivery_from AND @delivery_to OR poh_deliverdate = '19000101 00:00')
		AND (poh_datereceived = @received  OR @received = '19000101 00:00')
		AND ((poh_supplier in ('UNKNOWN', @supplier) and @unk_supplier = 'Y') or
			(@supplier IN (poh_supplier, 'UNKNOWN') and @unk_supplier = 'N'))
END
ELSE IF @refnum <> 'UNKNOWN' -- 35368
BEGIN
	INSERT INTO #ref
	SELECT CAST(ref_tablekey AS INTEGER)
	FROM referencenumber
	WHERE ref_table = 'partorder_header'
	  AND ref_number LIKE @refnum + '%'
	  AND	@reftype IN (ref_type, 'UNK') 

   SELECT Distinct h.poh_identity,   
         h.poh_branch,   
         h.poh_supplier,   
         h.poh_plant,   
         h.poh_dock,   
         h.poh_jittime,   
         h.poh_sequence,   
         @sidname sid_ref_type,   
         sid.ref_number,   
         h.poh_pickupdate,   
         h.poh_deliverdate,   
         h.poh_timelineid ,
			case IsNull(h.poh_timelineid, 0)
				when 0 then ''
				else tlh_name
			end tlh_name,
			c_details = (select count(*) from partorder_detail 
							where h.poh_identity = partorder_detail.poh_identity ),
			h.poh_datereceived,
			supplier_city = cty_nmstct,
			@lotname lot_ref_type,
			lot.ref_number lot_ref_number,
	d.pod_adjustedcount,
	d.pod_adjustedcontainers,
	d.pod_pu_count,
	d.pod_pu_containers,
	d.pod_cur_count,
	d.pod_cur_containers,
	h.poh_srf_recieve,
	isnull(r.por_ordhdr, 0) por_ordhdr,
	'' update_po,
	0 modflag,
	h.poh_supplieralias,
	d.pod_partnumber,
	d.pod_description,
	d.pod_pending_date,
	h.poh_comment,
	d.pod_updatedon,
	d.pod_updatedby
    FROM partorder_header h
	JOIN partorder_detail d ON h.poh_identity = d.poh_identity
	JOIN company ON cmp_id = poh_supplier
	LEFT OUTER JOIN timeline_header ON tlh_number = h.poh_timelineid
	LEFT OUTER JOIN partorder_routing r ON r.poh_identity = h.poh_identity
	LEFT OUTER JOIN orderheader oh ON oh.ord_hdrnumber = r.por_ordhdr AND @route in (ord_route, 'UNKNOWN')
	LEFT OUTER JOIN referencenumber sid ON sid.ref_tablekey = h.poh_identity AND sid.ref_type = @sid
	LEFT OUTER JOIN referencenumber lot ON lot.ref_tablekey = h.poh_identity AND lot.ref_type = @lot
	JOIN #ref ON h.poh_identity = #ref.poh_identity
	WHERE ((oh.ord_hdrnumber IS NOT NULL AND @route IN (ord_route, 'UNKNOWN')) 
			OR (oh.ord_hdrnumber IS NULL AND @route = 'UNKNOWN'))
		AND poh_branch = @branch 
--		AND @supplier IN (poh_supplier, 'UNKNOWN') 
		AND @plant IN (poh_plant, 'UNKNOWN') 
		AND @dock IN (poh_dock, 'UNKNOWN') 
		AND (@part_number IN (d.pod_partnumber, 'UNKNOWN') OR (@part_number <> 'UNKNOWN' AND d.pod_partnumber LIKE @part_number + '%'))
		AND ((@timeline = 0 AND ISNULL(poh_timelineid, 0) = 0) 
					OR (@timeline = 1 AND ISNULL(poh_timelineid, 0) > 0)
					OR (@timeline = 2))
		AND (poh_pickupdate BETWEEN @pickup_from AND @pickup_to OR poh_pickupdate = '19000101 00:00')
		AND (poh_deliverdate BETWEEN @delivery_from AND @delivery_to OR poh_deliverdate = '19000101 00:00')
		AND (poh_datereceived = @received  OR @received = '19000101 00:00')
		AND ((poh_supplier in ('UNKNOWN', @supplier) and @unk_supplier = 'Y') or
			(@supplier IN (poh_supplier, 'UNKNOWN') and @unk_supplier = 'N'))
END
ELSE
BEGIN
   SELECT Distinct h.poh_identity,   
         h.poh_branch,   
         h.poh_supplier,   
         h.poh_plant,   
         h.poh_dock,   
         h.poh_jittime,   
         h.poh_sequence,   
         @sidname sid_ref_type,   
         sid.ref_number,   
         h.poh_pickupdate,   
         h.poh_deliverdate,   
         h.poh_timelineid ,
			case IsNull(h.poh_timelineid, 0)
				when 0 then ''
				else tlh_name
			end tlh_name,
			c_details = (select count(*) from partorder_detail 
							where h.poh_identity = partorder_detail.poh_identity ),
			h.poh_datereceived,
			supplier_city = cty_nmstct,
			@lotname lot_ref_type,
			lot.ref_number lot_ref_number,
	d.pod_adjustedcount,
	d.pod_adjustedcontainers,
	d.pod_pu_count,
	d.pod_pu_containers,
	d.pod_cur_count,
	d.pod_cur_containers,
	h.poh_srf_recieve,
	isnull(r.por_ordhdr, 0) por_ordhdr,
	'' update_po,
	0 modflag,
	h.poh_supplieralias,
	d.pod_partnumber,
	d.pod_description,
	d.pod_pending_date,
	h.poh_comment,
	d.pod_updatedon,
	d.pod_updatedby
    FROM partorder_header h
	JOIN partorder_detail d ON h.poh_identity = d.poh_identity
	JOIN company ON cmp_id = poh_supplier
	LEFT OUTER JOIN timeline_header ON tlh_number = h.poh_timelineid
	LEFT OUTER JOIN partorder_routing r ON r.poh_identity = h.poh_identity
	LEFT OUTER JOIN orderheader oh ON oh.ord_hdrnumber = r.por_ordhdr AND @route in (ord_route, 'UNKNOWN')
	LEFT OUTER JOIN referencenumber sid ON sid.ref_tablekey = h.poh_identity AND sid.ref_type = @sid
	LEFT OUTER JOIN referencenumber lot ON lot.ref_tablekey = h.poh_identity AND lot.ref_type = @lot
	WHERE ((oh.ord_hdrnumber IS NOT NULL AND @route IN (ord_route, 'UNKNOWN')) 
		OR (oh.ord_hdrnumber IS NULL AND @route = 'UNKNOWN'))
		AND poh_branch = @branch 
--		AND @supplier IN (poh_supplier, 'UNKNOWN') 
		AND @plant IN (poh_plant, 'UNKNOWN') 
		AND @dock IN (poh_dock, 'UNKNOWN') 
		-- 30696
		--AND	@reftype IN (poh_reftype, 'UNK') 
		--AND	@refnum IN (poh_refnum, 'UNKNOWN') 	
		--AND	@part_number IN (d.pod_partnumber, 'UNKNOWN') 
		AND (@part_number IN (d.pod_partnumber, 'UNKNOWN') OR (@part_number <> 'UNKNOWN' AND d.pod_partnumber LIKE @part_number + '%'))
		-- 30696
		--AND	(@timeline IN (poh_timelineid, 0)  or (poh_timelineid IS NULL AND @timeline = 0)) 
		AND ((@timeline = 0 AND ISNULL(poh_timelineid, 0) = 0) 
				OR (@timeline = 1 AND ISNULL(poh_timelineid, 0) > 0)
				OR (@timeline = 2))
		AND (poh_pickupdate BETWEEN @pickup_from AND @pickup_to OR poh_pickupdate = '19000101 00:00')
		AND (poh_deliverdate BETWEEN @delivery_from AND @delivery_to OR poh_deliverdate = '19000101 00:00')
		AND (poh_datereceived = @received  OR @received = '19000101 00:00')
		AND ((poh_supplier in ('UNKNOWN', @supplier) and @unk_supplier = 'Y') or
			(@supplier IN (poh_supplier, 'UNKNOWN') and @unk_supplier = 'N'))
END
GO
GRANT EXECUTE ON  [dbo].[d_partorder_browse_trial_sp] TO [public]
GO
