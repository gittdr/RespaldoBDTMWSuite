SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[d_view_planned_ltl_route_sp] (@pl_mov_number int)
as

declare @PWSumOrdExtraInfo		char(1),
        @PWExtraInfoLocation	varchar(11),
        @leg_count				int,
		@last_hook				int,
		@last_lgh				int

select @PWSumOrdExtraInfo = left(Upper(isnull(gi_string1,'N')),1) 
  from generalinfo 
 where gi_name = 'PWSumOrdExtraInfo'

select @PWExtraInfoLocation = UPPER(isnull(gi_string1,'ORDERHEADER'))
  from generalinfo
 where gi_name = 'PWExtraInfoLocation'
 
 select @leg_count = 0, @last_hook = 0, @last_lgh = -1
 
 select @leg_count = count(*)
   from legheader
  where mov_number = @pl_mov_number
 
 select @last_lgh = max(lgh_number)
   from stops
  where mov_number = @pl_mov_number
    and stp_mfh_sequence = (select MAX(stp_mfh_sequence)
							  from stops
							 where mov_number = @pl_mov_number)
  
if @leg_count > 1
begin
	select @last_hook = MAX(stp_mfh_sequence)
	  from stops
	 where mov_number = @pl_mov_number
	   and stp_event in ('HLT', 'HCT')
	select @last_hook = isnull(@last_hook, -1)
end 

select 
		s.ord_hdrnumber as 'ord_hdrnumber',
		s.stp_number as 'stp_number',
		s.stp_city as 'stp_city',
		s.stp_arrivaldate as 'stp_arrivaldate',
        s.stp_departuredate as 'stp_departuredate',
		s.stp_schdtearliest as 'stp_schdtearliest',
		s.stp_schdtlatest as 'stp_schdtlatest',
		s.cmp_id as 'cmp_id',
		s.cmp_name as 'cmp_name',
		s.lgh_number as 'lgh_number',
		s.stp_comment as 'stp_comment',
		e.evt_sequence as 'evt_sequence',
		s.stp_mfh_sequence as 'stp_mfh_sequence',
		s.cmd_code as 'cmd_code',
		cmd.cmd_name as 'cmd_name',
		convert(float,(select sum(dbo.sync_qty_with_units_fn(s2.stp_weightunit, fgt_weightunit, fgt_weight)) from freightdetail fd join stops s2 on s2.stp_number = fd.stp_number and (s2.stp_type = 'DRP' or s2.stp_event = 'XDU') where fd.stp_number = s.stp_number)) as 'weight',
		s.stp_weightunit as 'stp_weightunit',
        convert(float,(select sum(dbo.sync_qty_with_units_fn(s2.stp_countunit, fgt_countunit, fgt_count)) from freightdetail fd join stops s2 on s2.stp_number = fd.stp_number and (s2.stp_type = 'DRP' or s2.stp_event = 'XDU') where fd.stp_number = s.stp_number)) as 'count',
		s.stp_countunit as 'countunit',
		convert(float,(select sum(dbo.sync_qty_with_units_fn(s2.stp_countunit, isnull(fgt_count2unit, fgt_countunit), fgt_count2)) from freightdetail fd join stops s2 on s2.stp_number = fd.stp_number and (s2.stp_type = 'DRP' or s2.stp_event = 'XDU') where fd.stp_number = s.stp_number)) as 'count2',
		isnull(s.stp_countunit, 'PLT') as 'count2unit',
		convert(float,(select sum(dbo.sync_qty_with_units_fn(s2.stp_volumeunit, fgt_volumeunit, fgt_volume)) from freightdetail fd join stops s2 on s2.stp_number = fd.stp_number and (s2.stp_type = 'DRP' or s2.stp_event = 'XDU') where fd.stp_number = s.stp_number)) as 'weight',
		s.stp_volumeunit as 'volumeunit',
		e.evt_number as 'evt_number',
		e.evt_pu_dr as 'evt_pu_dr',
		e.evt_eventcode as 'evt_eventcode',
		e.evt_status as 'evt_status',
		s.stp_lgh_mileage as 'stp_lgh_mileage',
		cty.cty_nmstct as 'cty_nmstct',
		s.mov_number as 'mov_number',
		s.stp_region1 as 'stp_region1',
		s.stp_region2 as 'stp_region2',
		s.stp_region3 as 'stp_region3',
		s.stp_region4 as 'stp_region4',
		s.stp_state as 'stp_state',
		l.lgh_outstatus as 'lgh_outstatus',
		s.stp_loadstatus as 'stp_loadstatus',
		l.lgh_type1 as 'lgh_type1',
		'LghType1' as 'lgh_type1_t',
		s.stp_type1 as 'stp_type1',
		s.stp_phonenumber as 'stp_phonenumber',
		s.stp_zipcode as 'stp_zipcode',
		s.stp_address as 'stp_address',
		s.stp_contact as 'stp_contact',
		s.stp_phonenumber2 as 'stp_phonenumber2',
		s.stp_address2 as 'stp_address2',
		o.ord_revtype1 as 'ord_revtype1',
		o.ord_revtype2 as 'ord_revtype2',
		o.ord_revtype3 as 'ord_revtype3',
		o.ord_revtype4 as 'ord_revtype4',
		'RevType1' as 'ord_revtype1_t',
		'RevType2' as 'ord_revtype2_t',
		'RevType3' as 'ord_revtype3_t',
		'RevType4' as 'ord_revtype4_t',
		e.evt_departure_status as 'evt_departure_status',
		l.lgh_type2 as 'lgh_type2',
		'LghType2' as 'lgh_type2_t',
		s.stp_country as 'stp_country',
		l.lgh_comment as 'lgh_comment',
		l.lgh_type3 as 'lgh_type3',
		'LghType3' as 'lgh_type3_t',
		l.lgh_type4 as 'lgh_type4',
		'LghType4' as 'lgh_type4_t',
		o.ord_shipper as 'ord_shipper',
		(CASE WHEN @PWExtraInfoLocation = 'ORDERHEADER' AND @PWSumOrdExtraInfo <> 'Y' THEN o.ord_extrainfo1 ELSE la.lgh_extrainfo1 END) as 'extrainfo1',
		(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN o.ord_extrainfo2 ELSE la.lgh_extrainfo2 END) as 'extrainfo2',
		(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN o.ord_extrainfo3 ELSE la.lgh_extrainfo3 END) as 'extrainfo3',
		(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN o.ord_extrainfo4 ELSE la.lgh_extrainfo4 END) as 'extrainfo4',
		(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN o.ord_extrainfo5 ELSE la.lgh_extrainfo5 END) as 'extrainfo5',
		(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN o.ord_extrainfo6 ELSE la.lgh_extrainfo6 END) as 'extrainfo6',
		(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN o.ord_extrainfo7 ELSE la.lgh_extrainfo7 END) as 'extrainfo7',
		(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN o.ord_extrainfo8 ELSE la.lgh_extrainfo8 END) as 'extrainfo8',
		(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN o.ord_extrainfo9 ELSE la.lgh_extrainfo9 END) as 'extrainfo9',
		(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN o.ord_extrainfo10 ELSE la.lgh_extrainfo10 END) as 'extrainfo10',
		(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN o.ord_extrainfo11 ELSE la.lgh_extrainfo11 END) as 'extrainfo11',
		(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN o.ord_extrainfo12 ELSE la.lgh_extrainfo12 END) as 'extrainfo12',
		(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN o.ord_extrainfo13 ELSE la.lgh_extrainfo13 END) as 'extrainfo13',
		(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN o.ord_extrainfo14 ELSE la.lgh_extrainfo14 END) as 'extrainfo14',
		(CASE @PWExtraInfoLocation WHEN 'ORDERHEADER' THEN o.ord_extrainfo15 ELSE la.lgh_extrainfo15 END) as 'extrainfo15',
		(CASE WHEN @last_lgh = s.lgh_number and stp_mfh_sequence > @last_hook THEN 0 ELSE 1 END) AS 'islocked',
		'' as 'dummy_column' 
  from stops s
  join event e on e.stp_number = s.stp_number and e.evt_sequence = 1
  join legheader l on l.lgh_number = s.lgh_number
  join commodity cmd on cmd.cmd_code = s.cmd_code
  join city cty on cty.cty_code = s.stp_city
  left outer join orderheader o on o.ord_hdrnumber = s.ord_hdrnumber
  left outer join legheader_active la on la.lgh_number = l.lgh_number
 where s.mov_number = @pl_mov_number
order by stp_mfh_sequence, stp_arrivaldate

GO
GRANT EXECUTE ON  [dbo].[d_view_planned_ltl_route_sp] TO [public]
GO
