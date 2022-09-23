SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE PROC [dbo].[d_settlement_sheet_summary_87_trip] (@ord_hdrnumber int)
as 

/*
* BDH 41742 4/4/08.  Created for d_settlement_sheet_summary_87 and d_settlement_sheet_summary_89


exec d_settlement_sheet_summary_87_trip 1051	4266


*/

create table #temp_ord(
	ord_hdrnumber int null,
	stp_number int null,
	stp_city int null,
	pyt_itemcode varchar(6) null,
	evt_trailer varchar(13) null,
	stp_seq int)

create table #temp_stops(
	ord_hdrnumber int,
	stp_1 int,
	stp_1city int,
	stp_2 int,
	stp_2city int,
	fromto varchar(100) null,
	evt_trailer varchar(13) null)

declare 
	@stp_1 int,
	@stp_2 int,
	@stp_1city int,
	@stp_2city int,
	@evt_trailer varchar(13),
	@stp_seq1 int,
	@stp_seq2 int


insert #temp_ord
select pd.ord_hdrnumber, st.stp_number, st.stp_city, pt.pyt_itemcode, evt.evt_trailer1, st.stp_sequence
from paydetail pd
join stops st on pd.ord_hdrnumber = st.ord_hdrnumber
join paytype pt on pd.pyt_itemcode = pt.pyt_itemcode
join event evt on st.stp_number = evt.stp_number
where pd.ord_hdrnumber = @ord_hdrnumber
and pd.pyt_itemcode in (select pyt_itemcode from paytype where pyt_basis = 'LGH')
and @ord_hdrnumber > 0


select @stp_seq1 = min(stp_seq) from #temp_ord
select @stp_1 = stp_number from #temp_ord where stp_seq = @stp_seq1
while isnull(@stp_1, 0) > 0 
begin
	
	select @stp_seq2 = min(stp_seq) from #temp_ord where stp_seq > @stp_seq1
	select @stp_2 = stp_number from #temp_ord where stp_seq = @stp_seq2

	if isnull(@stp_seq2, 0) = 0
		break

	select @stp_1city = stp_city from #temp_ord where stp_number = @stp_1
	select @stp_2city = stp_city from #temp_ord where stp_number = @stp_2
	select @evt_trailer = evt_trailer from #temp_ord where stp_number = @stp_2

	insert 	#temp_stops (ord_hdrnumber,	stp_1, stp_1city, stp_2, stp_2city, evt_trailer)
	values (@ord_hdrnumber, @stp_1, @stp_1city, @stp_2, @stp_2city, @evt_trailer)

	set @stp_1 = @stp_2
	set @stp_seq1 = @stp_seq2
end



update #temp_stops set fromto = c1.cty_name + ', ' + c1.cty_state+ '/ to ' + c2.cty_name + ', ' + c2.cty_state
from city c1, city c2
where #temp_stops.stp_1city = c1.cty_code
and #temp_stops.stp_2city = c2.cty_code


select * from #temp_stops

GO
GRANT EXECUTE ON  [dbo].[d_settlement_sheet_summary_87_trip] TO [public]
GO
