SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[d_tripsheetformat07_sp] (@pl_mov int)
AS
/**
* NAME:
* dbo.d_tripsheetformat07_sp 
*
* TYPE:
* StoredProcedure
*
* DESCRIPTION:
* Return data for d_tripsheetformat07
*
* RETURNS:
* 
* 001 lgh_number 			int	4
* 002 lgh_tractor			varchar	8
* 003 lgh_primary_trailer	varchar	13
* 004 ord_hdrnumber			int	4
* 005 stp_ord_mileage		int	4
* 006 ord_number			char	12
* 007 ord_revtype1			varchar	6
* 008 ord_remark			varchar	254
* 009 ord_dest_latestdate	datetime 8
* 010 consignee_id			varchar	8
* 011 consignee_name		varchar	100
* 012 consignee_address1	varchar	100
* 013 consignee_address2	varchar	100
* 014 consignee_cty			varchar	18
* 015 consignee_state		varchar	6
* 016 consignee_zip			varchar	10
* 017 consignee_nmstct		varchar	42
* 018 consignee_phone		varchar	20
* 019 consignee_contact		varchar	30
* 020 consignee_directions	text	16
* 021 billto_id				varchar	8
* 022 billto_name			varchar	100
* 023 ship_id				varchar	8
* 024 ship_name				varchar	100
* 025 ship_cty				varchar	18
* 026 ship_state			varchar	6
* 027 l_refnumber			varchar	100
* 028 po_refnumber			varchar	100
* 029 latest_pup			datetime 8
* 030 latest_drp			datetime 8
* 031 stp_number			int	4
* 032 dolly_ref_number		varchar	30
* 033 lgh_primary_pup		varchar	13
* 034 consignee_misc1		varchar	254
* 035 consignee_misc2		varchar	254
* 036 ship_misc1			varchar	254
* 037 ship_misc2			varchar	254
* 038 stp_event				char	6
* 039 trc_terminal			varchar	6
* 040 num_stops				int	4
* 041 num_legs				int	4
* 042 consignee_ext			varchar	6
* 043 num_preloads 			int 4
* 044 lgh_driver1			varchar 8
* 045 bill_miles			int 4
* PARAMETERS:
* 001 @pl_mov 				int 4  
* REFERENCES:
* REVISION HISTORY:
*	10/24/06 33989 EMK - Created
*	11/09/06 33989 EMK - Added max stops condition on final select to limit printing to one sheet.
*	11/13/06 33898 EMK - Modified to print one per order per leg.
**/

DECLARE @li_min_stp int, @li_max_stp int,@li_ord int,@li_num_stops int
DECLARE @li_num_legs int, @li_preload int, @tot_miles int, @bill_miles int
DECLARE @v_bl_list varchar(100)
DECLARE @v_po_list varchar(100)


SELECT @li_ord = MIN(ord_hdrnumber) FROM stops WHERE mov_number = @pl_mov and ord_hdrnumber > 0 
SELECT @li_min_stp = MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @pl_mov and stp_type='PUP' and ord_hdrnumber = @li_ord
SELECT @li_max_stp = MAX(stp_mfh_sequence) FROM stops WHERE mov_number = @pl_mov and stp_type='DRP' and ord_hdrnumber = @li_ord
SELECT @li_num_stops = 	COUNT(stp_number) FROM stops WHERE mov_number = @pl_mov and stp_type='DRP'
SELECT @li_num_legs = COUNT(distinct lgh_number) FROM stops where ord_hdrnumber = @li_ord
SELECT @li_preload = COUNT(stp_number) FROM stops WHERE ord_hdrnumber = @li_ord and (stp_event = 'HPL' or stp_event = 'HMT' or stp_event = 'HLT')
SELECT @bill_miles = SUM(IsNull(stp_ord_mileage,0)) FROM stops WHERE mov_number = @pl_mov
SELECT @tot_miles = SUM(IsNull(stp_lgh_mileage,0)) FROM stops WHERE mov_number = @pl_mov 

-- Gather reference numbers.  Customer (Transwood) wants 2 BL# in one field, and 3 of the rest in another.
CREATE TABLE #allrefnums (ref_ident int identity,
	ref_number varchar(30) null,
	ref_table varchar(30) null,
	ref_type varchar(6) null, 	
	ref_tablekey int,
	ref_sequence int null)

-- All reference numbers
INSERT INTO #allrefnums (ref_number,ref_table,ref_tablekey,ref_type,ref_sequence)
SELECT rn.ref_number, rn.ref_table, rn.ref_tablekey,rn.ref_type,rn.ref_sequence
FROM referencenumber rn, stops s, legheader l, orderheader o
WHERE rn.ref_table='orderheader' 
	AND l.lgh_number = s.lgh_number
	AND o.ord_hdrnumber = s.ord_hdrnumber
	AND rn.ref_tablekey = o.ord_hdrnumber 
	AND l.mov_number = @pl_mov
	AND s.stp_type = 'DRP'
	AND s.ord_hdrnumber > 0
	AND s.stp_number = (SELECT MIN(stp_number) -- To eliminate duplicates
								FROM stops 
								WHERE mov_number = @pl_mov AND stp_type='DRP' AND ord_hdrnumber = @li_ord) 

-- Note: The COALESCE statements make use of the fact that NULL + a string = NULL. 
-- An optional setting, CONCAT_NULL_YIELDS_NULL can change this.  In the datwindow,
-- we will check for a first comma and erase it if necessary.

-- Want first two BL# in comma separted list. 
SELECT TOP 2 @v_bl_list =  COALESCE(@v_bl_list + ', ', '') + ref_number
	FROM #allrefnums 
	WHERE ref_type = 'BL#'

--Want all other reference numbers in another comma separted list. 
SELECT @v_po_list =  COALESCE(@v_po_list + ', ', '') + ref_number
	FROM #allrefnums 
	WHERE ref_ident NOT IN (SELECT TOP 2 ref_ident FROM  #allrefnums WHERE ref_type = 'BL#') 


SELECT l.lgh_number,
	l.lgh_tractor,
	l.lgh_primary_trailer,
	o.ord_hdrnumber,
	@tot_miles AS stp_ord_mileage,
	o.ord_number,
	o.ord_revtype1,
	o.ord_remark,
	o.ord_dest_latestdate,
	-- Consignee
	consig_cmp.cmp_id AS consignee_id,
	consig_cmp.cmp_name AS consignee_name,
	consig_cmp.cmp_address1 AS consignee_address1,
	consig_cmp.cmp_address2 AS consignee_address2,
	consig_city.cty_name AS consignee_cty,
	consig_city.cty_state AS consignee_state,
	ISNULL(consig_cmp.cmp_zip, '') AS consignee_zip,
	CASE consig_city.cty_nmstct 
		WHEN 'UNKNOWN' THEN 'UNKNOWN' 
		ELSE SUBSTRING(consig_city.cty_nmstct,1,CHARINDEX('/',consig_city.cty_nmstct) - 1) + '  '+ ISNULL(consig_cmp.cmp_zip, '')
	END AS consignee_nmstct,

	consig_cmp.cmp_primaryphone AS  consignee_phone,
	consig_cmp.cmp_contact AS consignee_contact,
	consig_cmp.cmp_directions AS consignee_directions,
	-- Bill to
	billto_cmp.cmp_id AS billto_id,
	billto_cmp.cmp_name AS billto_name,
	-- cityShipper
	ship_cmp.cmp_id AS ship_id,
	ship_cmp.cmp_name AS ship_name,
	ship_city.cty_name AS ship_cty,
	ship_city.cty_state AS ship_state,
	(SELECT @v_bl_list) AS bl_refnumber,
	(SELECT @v_po_list) AS po_refnumber,

	-- Earliest Pick up
	-- NOTE:  Return values are named latest.  Changed to earliest during development.  Did not
	-- change names to keep consistent with datawindow. 
	(SELECT stp_schdtearliest
		FROM stops 
		WHERE stops.mov_number = @pl_mov AND stp_mfh_sequence = @li_min_stp) AS latest_pup,
	-- Earliest delivery
	(SELECT stp_schdtearliest
		FROM stops 
		WHERE stops.mov_number = @pl_mov AND stp_mfh_sequence = @li_max_stp) AS latest_drp,
	0 as stp_number, --s.stp_number,  -- Removed not used in tripsheet
	-- Dolly ID 
	'' as dolly_ref_number, -- Set to empty -- Customer will place in order remarks
		--(SELECT MAX(ref_number) 
		--		FROM referencenumber 
		--		WHERE ref_table = 'stops' and ref_type = 'DOLLY' and ref_tablekey = s.stp_number) AS dolly_ref_number,
	lgh_primary_pup,
	ISNULL(consig_cmp.cmp_misc1,0) AS consignee_misc1,
	ISNULL(consig_cmp.cmp_misc2,0) AS consignee_misc2, 
	ISNULL(ship_cmp.cmp_misc1,0) AS ship_misc1,
	ISNULL(ship_cmp.cmp_misc2,0) AS ship_misc2,
	'' as stp_event, --s.stp_event,
	--t.trc_terminal,
	--pts 36812 -os- if tractor has not been assigned then get o.ord_revtype1, if tractor has been assigned but no terminal then get nothing 
	'trc_terminal' = 
      CASE 
         WHEN l.lgh_tractor = 'UNKNOWN' THEN o.ord_revtype1
         WHEN l.lgh_tractor <> 'UNKNOWN' AND t.trc_terminal = 'UNK' THEN ''
         ELSE t.trc_terminal 
      END,
	-- 36812 end
 	@li_num_stops AS num_stops,
	@li_num_legs AS num_legs,
	ISNULL(consig_cmp.cmp_primaryphoneext,'') AS  consignee_ext,
	@li_preload AS num_preload,
	lgh_driver1,
	@bill_miles AS bill_miles

FROM 
	(SELECT DISTINCT lgh_number, ord_hdrnumber FROM stops where mov_number = @pl_mov and ord_hdrnumber > 0) lao
	JOIN orderheader o on lao.ord_hdrnumber = o.ord_hdrnumber
	JOIN legheader l on lao.lgh_number = l.lgh_number
	INNER JOIN company consig_cmp ON consig_cmp.cmp_id = o.ord_consignee
 	INNER JOIN city consig_city ON consig_city.cty_code = consig_cmp.cmp_city
	INNER JOIN company billto_cmp ON billto_cmp.cmp_id = o.ord_billto
	INNER JOIN company ship_cmp ON ship_cmp.cmp_id = o.ord_shipper
 	INNER JOIN city ship_city ON ship_city.cty_code = ship_cmp.cmp_city
	INNER JOIN tractorprofile t ON l.lgh_tractor = t.trc_number
	JOIN (SELECT DISTINCT lgh_number FROM stops WHERE mov_number = @pl_mov) mylegs ON l.lgh_number = mylegs.lgh_number

DROP TABLE #allrefnums
GO
GRANT EXECUTE ON  [dbo].[d_tripsheetformat07_sp] TO [public]
GO
