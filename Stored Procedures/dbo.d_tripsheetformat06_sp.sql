SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
  PTS35296 DPM - changes needed to correct a bol issue where Order/VIN's would not 
  show up on the tripsheet if multiple Extra Info records had been added to an order.
 PTS 40828 BDH Removed the phone number format around the cons.cmp_primaryphone
*/

CREATE PROCEDURE [dbo].[d_tripsheetformat06_sp] (@pl_mov int)
AS

create table #report (bol           varchar(30),
                      pup_cmp_id    varchar(8),
                      drp_cmp_id    varchar(8),
                      mpp_id        varchar(8),
                      carrier       varchar(8),
                      cmd_code      varchar(8),
                      ord_hdrnumber int,
                      stp_type      varchar(6),
                      stp_comment   varchar(254) null,
					  carrier_name  varchar(64) null, --pts 34668
					  mpp_id2        varchar(8)) --pts 34668
					  
-- PTS 33314 -- BL (start)
--insert into #report (bol, stp_type, pup_cmp_id, drp_cmp_id, mpp_id, carrier, cmd_code, ord_hdrnumber)
--select mov_number,
--       stp_type,
--       '',
--       s.cmp_id,
--       e.evt_driver1,
--       e.evt_carrier,
--       f.cmd_code,
--       s.ord_hdrnumber
--  from freightdetail f
--  left outer join stops s on s.stp_number = f.stp_number
--  left outer join event e on s.stp_number = e.stp_number and e.evt_sequence = 1
--where s.mov_number = @pl_mov
--   and f.cmd_code <> 'UNKNOWN'
--   and (s.stp_type = 'DRP'
--    or  s.stp_event = 'XDU')
--vjh 33252 add stp_comment
insert into #report (bol, stp_type, pup_cmp_id, drp_cmp_id, mpp_id, carrier, cmd_code, ord_hdrnumber, stp_comment, carrier_name, mpp_id2)
select s.mov_number,
       Case stp_type
	When 'NONE' then 'DRP'
	When 'DRP' then 'DRP'
	End,
       '',
       s.cmp_id,
       e.evt_driver1,
       e.evt_carrier,
       o.cmd_code,
       s.ord_hdrnumber,
       s.stp_comment,
	   c.car_name, --pts 34668
	   e.evt_driver2 --pts 34668
  from freightdetail f
  left outer join stops s on s.stp_number = f.stp_number
  left outer join orderheader o on o.ord_hdrnumber = s.ord_hdrnumber 
  left outer join event e on s.stp_number = e.stp_number and e.evt_sequence = 1
  join carrier c on (e.evt_carrier = c.car_id) --pts 34668
 where s.mov_number = @pl_mov
   and o.cmd_code <> 'UNKNOWN'
   and (s.stp_type = 'DRP'
    or  s.stp_event = 'XDU')
-- PTS 33314 -- BL (end)

update #report
   set pup_cmp_id = s.cmp_id
  from stops s
 where s.mov_number = @pl_mov
   and s.ord_hdrnumber = #report.ord_hdrnumber
   and (s.stp_type = 'PUP'
    or  s.stp_event = 'XDL')
-- update #report
--    set pup_cmp_id = ord_shipper,
--        drp_cmp_id = ord_consignee
--   from orderheader o
-- where o.ord_hdrnumber = #report.ord_hdrnumber



select bol,
       #report.stp_type,
       #report.ord_hdrnumber,
       gsst.cmp_id as gsst_cmp_id,
       gsst.cmp_name as gsst_cmp_name,
       gsst.cmp_address1 as gsst_cmp_address1,
       gsst_city.cty_name as gsst_cty_city,
       gsst_city.cty_state as gsst_cty_state,
       isnull(gsst.cmp_zip, '') as gsst_cmp_zip,
       gsst.cmp_primaryphone as gsst_phone,
       ship.cmp_id as ship_cmp_id,
       ship.cmp_name as ship_cmp_name,
       ship.cmp_address1 as ship_address_1,
       ship_city.cty_name as ship_cty_name,
       ship_city.cty_state as ship_cty_state, 
       isnull(ship.cmp_zip, '') as ship_cmp_zip,
       ship.cmp_primaryphone as ship_phone,
       cons.cmp_id as cons_cmp_id,
       cons.cmp_name as cons_cmp_name,
       cons.cmp_address1 as cons_cmp_address1,
       cons_city.cty_name as cons_cty_name,
       cons_city.cty_state as cons_cty_state,
       isnull(cons.cmp_zip, '') as cons_cmp_zip,
       isnull(cons.cmp_primaryphone, '') as cons_phone,
       isnull(mpp.mpp_firstname, '') + ' ' + isnull(mpp.mpp_lastname, '') as driver_name,
       (lbl2.name) as mpp_terminal,
       mpp.mpp_division,
       #report.carrier,
       getdate() as now,
--PTS35296  cons.cmp_misc1 as cons_cmp_misc1,
--PTS40828      ' SHIP PH#:('+cons.cmp_primaryphone+')   ' +cons.cmp_misc1  as cons_cmp_misc1,  -- went back to original and did phone on the front end for better formatting.
	isnull(cons.cmp_misc1, '')  as cons_cmp_misc1,

       #report.cmd_code,
       vin.ref_number as vin,
       extclr.ref_number as color,
--       loc.ref_number as loc,
--       priflg.ref_number as status,
--PTS35296 (select col_data from extra_info_data data, extra_info_cols cols where data.extra_id = 7 and o.ord_hdrnumber = data.table_key and cols.col_id = data.col_id and cols.extra_id = 7 and cols.col_name = 'loc') as loc,
--PTS35296 (select col_data from extra_info_data data, extra_info_cols cols where data.extra_id = 7 and o.ord_hdrnumber = data.table_key and cols.col_id = data.col_id and cols.extra_id = 7 and cols.col_name = 'status') as status,
       (select col_data from extra_info_data data, extra_info_cols cols where data.extra_id = 7 and o.ord_hdrnumber = data.table_key and cols.col_id = data.col_id and data.col_row = 1 and cols.extra_id = 7 and cols.col_name = 'loc') as loc,
       (select col_data from extra_info_data data, extra_info_cols cols where data.extra_id = 7 and o.ord_hdrnumber = data.table_key and cols.col_id = data.col_id and data.col_row = 1 and cols.extra_id = 7 and cols.col_name = 'status') as status,
       cmd.cmd_name,
       o.ord_origin_earliestdate,
       vess.ref_number as vessel,
       lbl.name,
       #report.stp_comment,
	   o.ord_number, --pts34668
	   mpp.mpp_type1, --pts34668    
	   isnull(mpp2.mpp_firstname, '') + ' ' + isnull(mpp2.mpp_lastname, '') as driver_name2, --pts34668    
  	   #report.carrier_name --pts34668
  from #report
  left outer join company gsst on gsst.cmp_id = '42981'
  left outer join city gsst_city on gsst_city.cty_code = gsst.cmp_city
  left outer join company ship on ship.cmp_id = #report.pup_cmp_id
  left outer join city ship_city on ship_city.cty_code = ship.cmp_city
  left outer join company cons on cons.cmp_id = #report.drp_cmp_id
  left outer join city cons_city on cons_city.cty_code = cons.cmp_city
  left outer join manpowerprofile mpp on mpp.mpp_id = #report.mpp_id
  left outer join commodity cmd on cmd.cmd_code = #report.cmd_code
  left outer join referencenumber vin on vin.ref_type = 'VIN#' and vin.ref_table = 'orderheader' and vin.ref_tablekey = #report.ord_hdrnumber and vin.ref_sequence = (select min(ref_sequence) from referencenumber r where r.ref_table = 'orderheader' and r.ref_tablekey = #report.ord_hdrnumber and r.ref_type = 'VIN#')
  left outer join referencenumber extclr on extclr.ref_type = 'EXTCLR' and extclr.ref_table = 'orderheader' and extclr.ref_tablekey = #report.ord_hdrnumber and extclr.ref_sequence = (select min(ref_sequence) from referencenumber r where r.ref_table = 'orderheader' and r.ref_tablekey = #report.ord_hdrnumber and r.ref_type = 'EXTCLR')
--  left outer join referencenumber loc on loc.ref_type = 'LOC' and loc.ref_table = 'orderheader' and loc.ref_tablekey = #report.ord_hdrnumber and loc.ref_sequence = (select min(ref_sequence) from referencenumber r where r.ref_table = 'orderheader' and r.ref_tablekey = #report.ord_hdrnumber and r.ref_type = 'LOC')
--  left outer join referencenumber priflg on priflg.ref_type = 'PRIFLG' and priflg.ref_table = 'orderheader' and priflg.ref_tablekey = #report.ord_hdrnumber and priflg.ref_sequence = (select min(ref_sequence) from referencenumber r where r.ref_table = 'orderheader' and r.ref_tablekey = #report.ord_hdrnumber and r.ref_type = 'PRIFLG')
  left outer join orderheader o on o.ord_hdrnumber = #report.ord_hdrnumber
--              join extra_info_data loc on loc.extra_id = 7 and o.ord_hdrnumber = loc.table_key 
--              join extra_info_cols cols on cols.extra_id = 7 and cols.col_name = 'loc' and loc.col_id = cols.col_id
--              join extra_info_data status on status.extra_id = 7 and o.ord_hdrnumber = status.table_key 
--              join extra_info_cols cols2 on cols2.extra_id = 7 and cols2.col_name = 'status' and status.col_id = cols2.col_id
  left outer join referencenumber vess on vess.ref_type = 'VESS#' and vess.ref_table = 'orderheader' and vess.ref_tablekey = #report.ord_hdrnumber and vess.ref_sequence = (select min(ref_sequence) from referencenumber r where r.ref_table = 'orderheader' and r.ref_tablekey = #report.ord_hdrnumber and r.ref_type = 'VESS#')
  left outer join labelfile lbl on lbl.labeldefinition = 'revtype2' and o.ord_revtype2 = lbl.abbr
  left outer join labelfile lbl2 on lbl2.labeldefinition = 'Terminal' and mpp.mpp_terminal = lbl2.abbr
  left outer join manpowerprofile mpp2 on mpp2.mpp_id = #report.mpp_id2 --pts34668
order by ship.cmp_id, cons.cmp_id
GO
GRANT EXECUTE ON  [dbo].[d_tripsheetformat06_sp] TO [public]
GO
