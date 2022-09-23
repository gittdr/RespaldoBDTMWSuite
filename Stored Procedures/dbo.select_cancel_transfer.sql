SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[select_cancel_transfer] @ord_hdrnumber int,
                                        @stp_transfer_stp int
as
create table #temp
(mov_number int,
 ord_hdrnumber int,
 min_stp int,
 max_stp int,
 mfh_number int)

declare @stp_event varchar(8)
declare @mov int,
        @minstp int,
        @maxstp int,
        @stpnum int

select @stp_event = stp_event
from stops
where stp_number = @stp_transfer_stp

if @stp_event = 'LUL' or @stp_event = 'DRL' /*PTS 24550  CGK 10/27/2004*/ or @stp_event = 'DUL' /*END PTS 24550*/
begin
   insert into #temp
   select stops1.mov_number, stops1.ord_hdrnumber, stops1.stp_number, stops2.stp_number, stops1.mfh_number
     from stops stops1, stops stops2,
          (select mov_number, min(stp_mfh_sequence)  stp_min, max(stp_mfh_sequence) stp_max
             from stops
            where ord_hdrnumber = @ord_hdrnumber and
                  stp_transfer_stp = @stp_transfer_stp
           group by mov_number) movseq
    where stops1.mov_number = movseq.mov_number and
          stops1.stp_mfh_sequence = movseq.stp_min and
          stops2.mov_number = movseq.mov_number and
          stops2.stp_mfh_sequence = movseq.stp_max
   declare curs1 cursor for
      select mov_number, min_stp, max_stp
        from #temp
   open curs1
   fetch next from curs1 into @mov, @minstp, @maxstp
   while @@fetch_status = 0
   begin
      if @minstp = @maxstp
      begin
         select @stpnum = stops.stp_number
            from stops, (select min(stp_mfh_sequence) stp_min
                                   from stops
                                 where mov_number = @mov and 
                                            ord_hdrnumber = @ord_hdrnumber) movseq
           where stops.mov_number = @mov and
                      stops.stp_mfh_sequence = movseq.stp_min
         update #temp
            set min_stp = @stpnum
          where #temp.mov_number = @mov and
                     #temp.min_stp = @minstp
      end
      fetch next from curs1 into @mov, @minstp, @maxstp
   end
   close curs1
   deallocate curs1
end

if @stp_event = 'LLD'
begin
insert into #temp
   select stops1.mov_number, stops1.ord_hdrnumber, stops1.stp_number, stops2.stp_number, stops1.mfh_number
     from stops stops1, stops stops2,
          (select mov_number, min(stp_mfh_sequence) stp_min, max(stp_mfh_sequence) stp_max
             from stops
            where ord_hdrnumber = @ord_hdrnumber and
                  stp_transfer_stp = @stp_transfer_stp
           group by mov_number) movseq
    where stops1.mov_number = movseq.mov_number and
          stops1.stp_mfh_sequence = movseq.stp_min and
          stops2.mov_number = movseq.mov_number and
          stops2.stp_mfh_sequence = movseq.stp_max
    
   declare curs1 cursor for
      select mov_number, min_stp, max_stp
        from #temp
   open curs1
   fetch next from curs1 into @mov, @minstp, @maxstp
   while @@fetch_status = 0
   begin
      if @minstp = @maxstp
      begin
         select @stpnum = stops.stp_number
           from stops,(select max(stp_mfh_sequence) stp_max
                         from stops
                        where mov_number = @mov) movseq
          where stops.mov_number = @mov and
                stops.stp_mfh_sequence = movseq.stp_max
         update #temp
            set max_stp = @stpnum
          where #temp.mov_number = @mov and
                #temp.max_stp = @maxstp
      end
      fetch next from curs1 into @mov, @minstp, @maxstp
   end
   close curs1
   deallocate curs1
end

select stops1.cmp_id, cmp1.cmp_name, city1.cty_nmstct,
       stops1.stp_arrivaldate, stops1.stp_departuredate, stops1.stp_event,
       stops2.cmp_id, cmp2.cmp_name, city2.cty_nmstct, stops2.stp_arrivaldate,
       stops2.stp_departuredate, stops2.stp_event, #temp.mov_number, #temp.mfh_number
  from #temp, stops stops1, stops stops2, company cmp1, company cmp2,
       city city1, city city2
 where #temp.min_stp = stops1.stp_number and
       stops1.cmp_id = cmp1.cmp_id and
       stops1.stp_city = city1.cty_code and
       #temp.max_stp = stops2.stp_number and
       stops2.cmp_id = cmp2.cmp_id and
       stops2.stp_city = city2.cty_code
order by stops1.stp_arrivaldate 

GO
GRANT EXECUTE ON  [dbo].[select_cancel_transfer] TO [public]
GO
