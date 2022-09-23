SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[d_partorder_detail_id_sp] (@hid int)
as

/**
 * 
 * NAME:
 * dbo.d_partorder_detail_id_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Proc for dw d_partorder_detail_id
 *
 * RETURNS:
 * dw result set
 *
 * PARAMETERS:
 * 001 - @poh_identity int
 * 
 * REVISION HISTORY:
 * LOR	PTS# 28355	created
 * LOR	PTS# 29450	added pu_zero
 * LOR	PTS# 32081  added pod_release
 * JGUO split (o.ord_hdrnumber = r.por_ordhdr or (r.por_master_ordhdr = o.ord_hdrnumber and o.ord_status = 'MST') to avoid index scan
 *
 **/

create table #part (
		pod_identity INT NOT NULL,
		poh_identity INT NOT NULL,
		pod_partnumber VARCHAR(20) NOT NULL,
		pod_description VARCHAR(35) NULL,
		pod_uom VARCHAR(6) NULL,
		pod_originalcount INT NOT NULL,  -- originally ordered qty
		pod_originalcontainers INT NULL,  -- originally ordered # of containers
		pod_countpercontainer INT NULL, -- if not provided, set to 1
		pod_adjustedcount INT NULL,  -- if adjusted by customer after ordering, new count goes here
		pod_adjustedcontainers INT NULL, -- if adjusted by customer after ordering, new container count goes here
		pod_pu_count INT NULL, 	-- count picked up
		pod_pu_containers INT NULL, -- container count picked up
		pod_del_count INT NULL,
		pod_del_containers INT NULL,
		pod_cur_count INT NOT NULL,
		pod_cur_containers INT NOT NULL,
		pod_status	VARCHAR(6) NULL,
		pod_updatedby	VARCHAR(20) NULL,
		pod_updatedon	DATETIME NULL,
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
		por_identity INT NOT NULL,
		por_master_ordhdr INT NULL,
		por_ordhdr INT NULL,   
        pu_route	varchar(15) null,   
        dl_route	varchar(15) null,
		pu_zero	char(1) null,
		pod_pending_count int null,	--PTS 31196 CGK 1/18/2006
		pod_release	varchar(60) null) 

If (select count(*) from partorder_routing where poh_identity = @hid) > 0 
Begin
 insert #part
 SELECT d.pod_identity,
		d.poh_identity,
		d.pod_partnumber,
		d.pod_description,
		d.pod_uom,
		d.pod_originalcount,
		d.pod_originalcontainers,
		d.pod_countpercontainer, -- if not provided, set to 1
		d.pod_adjustedcount,  -- if adjusted by customer after ordering, new count goes here
		d.pod_adjustedcontainers, -- if adjusted by customer after ordering, new container count goes here
		d.pod_pu_count, 	-- count picked up
		d.pod_pu_containers, -- container count picked up
		d.pod_del_count,
		d.pod_del_containers,
		d.pod_cur_count,
		d.pod_cur_containers,
		d.pod_status,
		d.pod_updatedby,
		d.pod_updatedon,
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
		r.por_identity,
		r.por_master_ordhdr,
		r.por_ordhdr,   
        '',   
        '',
		case
			when IsNull(d.pod_pu_count, -1) = -1 or IsNull(d.pod_pu_containers, -1) = -1 Then 'Y'
--			when IsNull(d.pod_pu_count, 0) = 0 or IsNull(d.pod_pu_containers, 0) = 0 Then 'Y'
			else 'N'
		end pu_zero,
		d.pod_pending_count, --PTS 31196 CGK 1/18/2006
		d.pod_release
 FROM partorder_detail d,   
         partorder_header h,   
         partorder_routing r
 WHERE h.poh_identity = @hid and
		d.poh_identity = h.poh_identity and  
         r.poh_identity = h.poh_identity 

--select * from #part
-- 
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

--select * from #part
-- 
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
--select * from #part

End
Else
 insert #part
 SELECT d.pod_identity,
		d.poh_identity,
		d.pod_partnumber,
		d.pod_description,
		d.pod_uom,
		d.pod_originalcount,
		d.pod_originalcontainers,
		d.pod_countpercontainer, -- if not provided, set to 1
		d.pod_adjustedcount,  -- if adjusted by customer after ordering, new count goes here
		d.pod_adjustedcontainers, -- if adjusted by customer after ordering, new container count goes here
		d.pod_pu_count, 	-- count picked up
		d.pod_pu_containers, -- container count picked up
		d.pod_del_count,
		d.pod_del_containers,
		d.pod_cur_count,
		d.pod_cur_containers,
		d.pod_status,
		d.pod_updatedby,
		d.pod_updatedon,
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
		0,
		0,
		0,   
        '',   
        '',
		case
			when IsNull(d.pod_pu_count, -1) = -1 or IsNull(d.pod_pu_containers, -1) = -1 Then 'Y'
--			when IsNull(d.pod_pu_count, 0) = 0 or IsNull(d.pod_pu_containers, 0) = 0 Then 'Y'
			else 'N'
		end pu_zero,
		d.pod_pending_count, --PTS 31196 CGK 1/18/2006
		d.pod_release
    FROM partorder_detail d, partorder_header h
   WHERE h.poh_identity = @hid and
		d.poh_identity = h.poh_identity 

select distinct pod_identity,
		poh_identity,
		pod_partnumber,
		pod_description,
		pod_uom,
		pod_originalcount,
		pod_originalcontainers,
		pod_countpercontainer, -- if not provided, set to 1
		pod_adjustedcount,  -- if adjusted by customer after ordering, new count goes here
		pod_adjustedcontainers, -- if adjusted by customer after ordering, new container count goes here
		pod_pu_count, 	-- count picked up
		pod_pu_containers, -- container count picked up
		pod_del_count,
		pod_del_containers,
		pod_cur_count,
		pod_cur_containers,
		pod_status,
		pod_updatedby,
		pod_updatedon,
		poh_branch,
		poh_supplier,
		poh_plant,
		poh_dock,
		poh_jittime,
		poh_sequence,
		poh_reftype,
		poh_refnum,
		poh_datereceived,
		poh_pickupdate,
		poh_deliverdate,
		poh_updatedby,
		poh_updatedon,
		poh_comment,
		poh_type,
		poh_release,
		poh_status,
		poh_scanned,
		poh_timelineid,
        pu_route,   
        dl_route,
		pu_zero,
		pod_pending_count, --PTS 31196 CGK 1/18/2006
		pod_release
 from #part

GO
GRANT EXECUTE ON  [dbo].[d_partorder_detail_id_sp] TO [public]
GO
