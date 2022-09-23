SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_get_tolls_spnv] @tollfilter char(1), @number int AS 
/*
INPUT PARMS:

tollfilter:  This input parm determines what to look the tolls up by
Valid values:  
1) 'O'      Order
2) 'L'      Trip Segment

@number:		key to lookup
*/

declare @segments table(ord_hdrnumber	int				NULL,
						lgh_number		int				NULL, 
						mov_number		int				NULL,
						stp_sequence	int				NULL,
                        orig_city		int				NULL,
                        dest_city		int				NULL,
						ord_revtype1	varchar(6)		NULL,
						ord_revtype2	varchar(6)		NULL,
						ord_revtype3	varchar(6)		NULL,
						ord_revtype4	varchar(6)		NULL,
						lgh_type1		varchar(6)		NULL,
						lgh_type2		varchar(6)		NULL,
						lgh_type3		varchar(6)		NULL,
						lgh_type4		varchar(6)		NULL,
						stp_loadstatus	char(3)			NULL,
						stp_number		int				NULL,
						axle_count		int				NULL)

declare	@li_stopcounter		int,
		@dest_city			int,
		@max_sequence		int,
		@ord_hdrnumber		int,
		@stp_loadstatus		char(3),
		@axles				tinyint

--Lookup by order for invoicing



if @tollfilter = 'O' and @number > 0
begin
	insert into @segments (ord_hdrnumber, lgh_number, mov_number, stp_sequence, orig_city, ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4, lgh_type1, lgh_type2, lgh_type3, lgh_type4, stp_loadstatus, stp_number)
	select s.ord_hdrnumber, s.lgh_number, s.mov_number, s.stp_mfh_sequence, s.stp_city, o.ord_revtype1, o.ord_revtype2, o.ord_revtype3, o.ord_revtype4, l.lgh_type1, l.lgh_type2, l.lgh_type3, l.lgh_type4, s.stp_loadstatus, s.stp_number
	  from stops s
	  join legheader l on l.lgh_number = s.lgh_number
	  left outer join orderheader o on s.ord_hdrnumber = o.ord_hdrnumber and s.ord_hdrnumber > 0
	 where s.ord_hdrnumber = @number
	 order by stp_mfh_sequence
end

--Lookup by leg for settlements
else if @tollfilter = 'L' and @number > 0
begin
	insert into @segments (ord_hdrnumber, lgh_number, mov_number, stp_sequence, orig_city, ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4, lgh_type1, lgh_type2, lgh_type3, lgh_type4, stp_loadstatus, stp_number)
	select s.ord_hdrnumber, s.lgh_number, s.mov_number, s.stp_mfh_sequence, s.stp_city, o.ord_revtype1, o.ord_revtype2, o.ord_revtype3, o.ord_revtype4, l.lgh_type1, l.lgh_type2, l.lgh_type3, l.lgh_type4, s.stp_loadstatus, s.stp_number
	  from stops s
	  join legheader l on l.lgh_number = s.lgh_number
	  left outer join orderheader o on s.ord_hdrnumber = o.ord_hdrnumber and s.ord_hdrnumber > 0
	 where s.lgh_number = @number
	 order by stp_mfh_sequence
end

else
begin
	--invalid search by... return nothing
	insert into @segments (ord_hdrnumber, lgh_number, mov_number, stp_sequence, orig_city, ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4, lgh_type1, lgh_type2, lgh_type3, lgh_type4, stp_loadstatus, stp_number, axle_count)
	values (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
end

select @max_sequence = max(stp_sequence)
  from @segments

select @li_stopcounter = min(isnull(stp_sequence,-1))
  from @segments

while @li_stopcounter <= @max_sequence
begin
	select @dest_city = orig_city,
		   @ord_hdrnumber = ord_hdrnumber,
		   @stp_loadstatus = stp_loadstatus
	  from @segments
	 where stp_sequence = (select min(stp_sequence)
							 from @segments
							where stp_sequence > @li_stopcounter)

	update @segments
	   set ord_hdrnumber = @ord_hdrnumber
	 where stp_sequence = @li_stopcounter
	   and ord_hdrnumber = 0

	select @axles = isnull(trc_axles,0)
      from @segments s, event e, tractorprofile t
     where s.stp_number = e.stp_number
       and e.evt_sequence = 1
       and e.evt_tractor = t.trc_number
	   and s.stp_sequence = @li_stopcounter

	select @axles = @axles + isnull(trl_axles,0)
      from @segments s, event e, trailerprofile t
     where s.stp_number = e.stp_number
       and e.evt_sequence = 1
       and e.evt_trailer1 = t.trl_number
	   and s.stp_sequence = @li_stopcounter

	select @axles = @axles + isnull(trl_axles,0)
      from @segments s, event e, trailerprofile t
     where s.stp_number = e.stp_number
       and e.evt_sequence = 1
       and e.evt_trailer2 = t.trl_number
	   and s.stp_sequence = @li_stopcounter

	update @segments
	   set dest_city = @dest_city,
		   stp_loadstatus = @stp_loadstatus,
		   axle_count = @axles
	 where stp_sequence = @li_stopcounter

	select @li_stopcounter = min(isnull(stp_sequence,-1))
	  from @segments
	 where stp_sequence > @li_stopcounter
end

--debug
--select * from @segments

--now remove any stops that have a NULL dest city (these will be the last stop and there is no destination for that stop)
delete 
 from @segments
where dest_city is null

--debug
--select * from @segments

--now that we have all the origin/dest pairs need to find all the tolls that match the load status
select tb.tb_name, t.tb_axlecount, t.tb_cash_toll, t.tb_card_toll, seg.ord_hdrnumber, seg.lgh_number, seg.mov_number, seg.stp_sequence, seg.orig_city, seg.dest_city, seg.ord_revtype1, seg.ord_revtype2, seg.ord_revtype3, seg.ord_revtype4, seg.lgh_type1, seg.lgh_type2, seg.lgh_type3, seg.lgh_type4, seg.stp_loadstatus, tb.cht_itemcode, tb.pyt_itemcode, seg.axle_count, tb.tb_ident
  from @segments seg
  join toll_route tr on seg.orig_city = tr.tr_origin_city and seg.dest_city = tr.tr_dest_city and seg.stp_loadstatus = tr.tr_loadstatus
  join tollroute_booth_mapping trbm on trbm.tr_ident = tr.tr_ident
  join tollbooth tb on tb.tb_ident = trbm.tb_ident
  join toll t on t.tb_ident = tb.tb_ident and t.tb_axlecount = seg.axle_count

UNION
--also bring in any that are not specefied as loaded or MT that match the orgin/dest pair

select tb.tb_name, t.tb_axlecount, t.tb_cash_toll, t.tb_card_toll, seg.ord_hdrnumber, seg.lgh_number, seg.mov_number, seg.stp_sequence, seg.orig_city, seg.dest_city, seg.ord_revtype1, seg.ord_revtype2, seg.ord_revtype3, seg.ord_revtype4, seg.lgh_type1, seg.lgh_type2, seg.lgh_type3, seg.lgh_type4, seg.stp_loadstatus, tb.cht_itemcode, tb.pyt_itemcode, seg.axle_count, tb.tb_ident
  from @segments seg
  join toll_route tr on seg.orig_city = tr.tr_origin_city and seg.dest_city = tr.tr_dest_city and tr.tr_loadstatus = 'UND'
  join tollroute_booth_mapping trbm on trbm.tr_ident = tr.tr_ident
  join tollbooth tb on tb.tb_ident = trbm.tb_ident and tb.tb_status <> 'OUT'
  join toll t on t.tb_ident = tb.tb_ident and t.tb_axlecount = seg.axle_count
where tr.tr_ident not in(	select tr1.tr_ident
							  from @segments seg1
							  join toll_route tr1 on seg1.orig_city = tr1.tr_origin_city and seg1.dest_city = tr1.tr_dest_city and seg1.stp_loadstatus = tr1.tr_loadstatus
							  join tollroute_booth_mapping trbm1 on trbm1.tr_ident = tr1.tr_ident
							  join tollbooth tb1 on tb1.tb_ident = trbm.tb_ident and tb1.tb_status <> 'OUT'
							  join toll t1 on t1.tb_ident = tb1.tb_ident)
 
GO
