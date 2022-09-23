SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[d_partorder_header_id_sp] (@hid int )
as


/**
 * 
 * NAME:
 * dbo.d_partorder_header_id_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Proc for dw d_partorder_header_id
 * do similar changes in d_partorder_header_sp
 *
 * RETURNS:
 * dw result set
 *
 * PARAMETERS:
 * 001 - @hid int partorder header id
 * 
 * REVISION HISTORY:
 * LOR	PTS# 28355	createsd
 * LOR	PTS# 29932	added alias
 * JGUO split o.ord_hdrnumber = r.por_ordhdr or (r.por_master_ordhdr = o.ord_hdrnumber and o.ord_status = 'MST') to avoid index scan
 **/

create table #part (
		poh_identity INT NOT NULL,
		poh_branch		varchar(12) NOT NULL,
		poh_supplier	varchar(8) NOT NULL,
		poh_plant		varchar(8) NOT NULL,
		poh_dock			VARCHAR(8) NULL,
		poh_jittime		INT NULL,
		poh_sequence	INT NULL,
		poh_reftype		VARCHAR(6) NOT NULL,
		poh_refnum		VARCHAR(30) NOT NULL,
		poh_datereceived	DATETIME NOT NULL,
		poh_pickupdate	DATETIME NULL,
		poh_deliverdate	DATETIME NULL,
		poh_updatedby	VARCHAR(20) NULL,
		poh_updatedon	DATETIME NULL,
		poh_comment		VARCHAR(40) NULL,
		poh_type			VARCHAR(6) NULL,
		poh_release		VARCHAR(12) NULL,
		poh_status		VARCHAR(6) NOT NULL,
		poh_scanned		CHAR(1) NULL,
		poh_timelineid	INT NULL,
		tlh_name	varchar(60) null,
		ref_count	int	null,   
        pu_route	varchar(15) null,   
        dl_route	varchar(15) null,
		poh_tlmod_reason	varchar(6) null,
		alias		varchar(25) NULL,
		poh_srf_recieve DATETIME NULL,
		lotnumber VARCHAR(50))

Declare	@ord_hdrnumber int, 
		@ord_status varchar(6), 
		@ord_route varchar(15),
		@from_ord	varchar(12),
		@lot VARCHAR(6)

SELECT @lot = ISNULL(gi_string1, '')
FROM generalinfo
WHERE gi_name = 'LotNumberRefType'

 insert #part
 SELECT h.poh_identity,
		h.poh_branch,
		h.poh_supplier,
		h.poh_plant,
		h.poh_dock,
		h.poh_jittime,
		h.poh_sequence,
		h.poh_reftype,
		h.poh_refnum,
		h.poh_datereceived,
		h.poh_pickupdate,
		h.poh_deliverdate,
		h.poh_updatedby,
		h.poh_updatedon,
		h.poh_comment,
		h.poh_type,
		h.poh_release,
		h.poh_status,
		h.poh_scanned,
		h.poh_timelineid,
		case IsNull(poh_timelineid, 0)
			when 0 then ''
			else tlh_name
		end tlh_name,
		0,
		'',
		'',
		IsNull(h.poh_tlmod_reason, 'UNK'),
		h.poh_supplieralias, --PTS 31196 CGK 1/17/2006
		h.poh_srf_recieve
		,ISNULL(ref_number, '')
 FROM partorder_header h  Left OUTER JOIN timeline_header On tlh_number = h.poh_timelineid
		LEFT OUTER JOIN referencenumber ON ref_table = 'partorder_header' AND ref_tablekey = h.poh_identity AND ref_type = @lot 
 WHERE h.poh_identity = @hid
/*
--jg begin split the update to avoid index scan on orderheader table
--  update #part
--  set pu_route = o.ord_route
--  from orderheader o, partorder_routing r 
--  where r.poh_identity = #part.poh_identity and
-- 		r.por_origin = #part.poh_supplier and
-- 		(o.ord_hdrnumber = r.por_ordhdr or
-- 		 (r.por_master_ordhdr = o.ord_hdrnumber and o.ord_status = 'MST'))
 update #part
 set pu_route = o.ord_route
 from orderheader o, partorder_routing r 
 where r.poh_identity = #part.poh_identity and
		r.por_origin = #part.poh_supplier and
		o.ord_hdrnumber = r.por_ordhdr 
 update #part
 set pu_route = o.ord_route
 from orderheader o, partorder_routing r 
 where r.poh_identity = #part.poh_identity and
		r.por_origin = #part.poh_supplier and
		r.por_master_ordhdr = o.ord_hdrnumber and o.ord_status = 'MST'

--  update #part
--  set dl_route = o.ord_route
--  from orderheader o, partorder_routing r 
--  where r.poh_identity = #part.poh_identity and
-- 		r.por_destination = #part.poh_plant and
-- 		(o.ord_hdrnumber = r.por_ordhdr or
-- 		 (r.por_master_ordhdr = o.ord_hdrnumber and o.ord_status = 'MST'))
 update #part
 set dl_route = o.ord_route
 from orderheader o, partorder_routing r 
 where r.poh_identity = #part.poh_identity and
		r.por_destination = #part.poh_plant and
		o.ord_hdrnumber = r.por_ordhdr 
 update #part
 set dl_route = o.ord_route
 from orderheader o, partorder_routing r 
 where r.poh_identity = #part.poh_identity and
		r.por_destination = #part.poh_plant and
		r.por_master_ordhdr = o.ord_hdrnumber and o.ord_status = 'MST'
--jg end
*/
-----------------------------------------------------------
--MRH Link by route means there may not be an order.
--MRH Link by route means there may not be an order. See if there is already a route routing table first, if not then get it from the order / master order.
 update #part
 set pu_route = isnull(r.por_route, '') from partorder_routing r where r.poh_identity = #part.poh_identity and r.por_sequence = (select min(por_sequence) from partorder_routing r1 where r1.poh_identity = #part.poh_identity)

 update #part
 set dl_route = isnull(r.por_route, '') from partorder_routing r where r.poh_identity = #part.poh_identity and r.por_sequence = (select max(por_sequence) from partorder_routing r1 where r1.poh_identity = #part.poh_identity)

-- If not found on the routing table pull it from the order.
 update #part
 set pu_route = o.ord_route
 from orderheader o, partorder_routing r 
 where isnull(#part.pu_route, '') = '' and 
	r.poh_identity = #part.poh_identity and
	r.por_origin = #part.poh_supplier and
	o.ord_hdrnumber = r.por_ordhdr 

 update #part
 set pu_route = o.ord_route
 from orderheader o, partorder_routing r 
 where isnull(#part.pu_route,'') = '' and 
	r.poh_identity = #part.poh_identity and
	r.por_origin = #part.poh_supplier and
	r.por_master_ordhdr = o.ord_hdrnumber and o.ord_status = 'MST'

 update #part
 set dl_route = o.ord_route
 from orderheader o, partorder_routing r 
 where isnull(#part.dl_route, '') = '' and 
	r.poh_identity = #part.poh_identity and
	r.por_destination = #part.poh_plant and
	o.ord_hdrnumber = r.por_ordhdr 

 update #part
 set dl_route = o.ord_route
 from orderheader o, partorder_routing r 
 where isnull(#part.dl_route, '') = '' and  
	r.poh_identity = #part.poh_identity and
	r.por_destination = #part.poh_plant and
	r.por_master_ordhdr = o.ord_hdrnumber and o.ord_status = 'MST'

update #part
set ref_count = (SELECT COUNT(*)  
				FROM referencenumber, #part
				WHERE ref_table = 'partorder_header' AND  
				     ref_tablekey = poh_identity)

--Commented out for PTS 31196 CGK 1/17/2006
-- update #part
-- set alias = (SELECT c.cmp_altid
-- 			FROM company_alternates a LEFT OUTER JOIN company c ON a.ca_alt = c.cmp_id  
-- 			WHERE a.ca_alt = c.cmp_id and a.ca_id = poh_supplier and c.cmp_revtype1 = poh_branch)

select * from #part
GO
GRANT EXECUTE ON  [dbo].[d_partorder_header_id_sp] TO [public]
GO
