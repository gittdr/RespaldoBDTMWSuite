SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_tripsheetformat08_sp] (@pl_mov int)
AS

/*
PTS 40622 BDH 3/13/08.  New tripsheet format created for Tidewater Transit.
PTS 42809 BDH 5/16/08.  Changed logic for BL#, Rail#, Arrival and Departure Dates.
*/

create table #results(
ord_hdrnumber int null,
lgh_number int null,
stp_number int null,
ord_refnum varchar(30) null,
stp_refnum varchar(30) null,
ord_number varchar(12) null,
shipper_id varchar(8) null,
shipper_name varchar(100) null,
shipper_ctyst varchar(30) null,
consig_id  varchar(8) null,
consig_name varchar(100) null,
consig_address1 varchar(100) null,
consig_ctyst varchar(30) null,
lgh_driver1 varchar(8) null,
mpp_firstname  varchar(40) null,
mpp_lastname  varchar(40) null,
lgh_tractor varchar(8) null,
lgh_trailer varchar(13) null,
cmd1 varchar(8) null,
cmd1_name varchar(60) null,
cmd1_weight float null,
compartment1 int null,
cmd2 varchar(8) null,
cmd2_name varchar(60) null,
cmd2_weight float null,
compartment2 int null,
cmd3 varchar(8) null,
cmd3_name varchar(60) null,
cmd3_weight float null,
compartment3 int null,
cmd4 varchar(8) null,
cmd4_name varchar(60) null,
cmd4_weight float null,
compartment4 int null,
cmd5 varchar(8) null,
cmd5_name varchar(60) null,
cmd5_weight float null,
compartment5 int null,
ord_remark varchar(254) null,
consig_directions varchar(254) null,
consig_city varchar(18) null,
consig_state varchar(6) null,
departure_date datetime null,
arrival_date datetime null
)


insert #results(
	ord_hdrnumber,
	lgh_number,
	stp_number,
	ord_refnum,
	stp_refnum,
	ord_number,
	shipper_id,
	departure_date,
	arrival_date,
	consig_id,
	lgh_driver1,
	mpp_firstname,
	mpp_lastname,
	lgh_tractor,
	lgh_trailer,
	cmd1,
	cmd1_weight,
	compartment1,
	cmd2,
	cmd2_weight,
	compartment2,
	cmd3,
	cmd3_weight,
	compartment3,
	cmd4,
	cmd4_weight,
	compartment4,
	cmd5,
	cmd5_weight,
	compartment5,
	ord_remark
)


select 
	s.ord_hdrnumber,
	s.lgh_number,
	s.stp_number,
	'', --o.ord_refnum,  --42809
	'', --s.stp_refnum,  --42809
	o.ord_number,
	o.ord_shipper shipper_id, --(select cmp_id from stops where mov_number = @pl_mov and stp_type = 'PUP' and stp_number = #results.stp_number) shipper_id,
	'' departure_date,	--(select stp_departuredate from stops where stp_number = s.stp_number) departure_date,	-- 42809
	'' arrival_date,  --s.stp_arrivaldate arrival_date,  -- 42809
	(select cmp_id from stops 
		where stp_number = s.stp_number) consig_id,
	lgh_driver1,
	mpp_firstname,
	mpp_lastname,
	lgh_tractor,
	lgh_primary_trailer,
	(SELECT f.cmd_code
				FROM	freightdetail f
				where f.stp_number = s.stp_number and fgt_sequence = 1) cmd1,

	(SELECT	(case when fgt_quantity > 0 then fgt_quantity else 
					case when fgt_volume >0 then fgt_volume else
					case when fgt_weight > 0 then fgt_weight else
					case when fgt_count >0 then fgt_count else 0 end end end end)
				FROM	freightdetail f
				where f.stp_number = s.stp_number and fgt_sequence = 1) ,
	(SELECT fgt_count
				FROM	freightdetail f
				where f.stp_number = s.stp_number and fgt_sequence = 1) compartment1,
	(SELECT f.cmd_code
				FROM	freightdetail f
				where f.stp_number = s.stp_number and fgt_sequence = 2) cmd2,

	(SELECT	(case when fgt_quantity > 0 then fgt_quantity else 
					case when fgt_volume >0 then fgt_volume else
					case when fgt_weight > 0 then fgt_weight else
					case when fgt_count >0 then fgt_count else 0 end end end end)
				FROM	freightdetail f
				where f.stp_number = s.stp_number and fgt_sequence = 2) cmd2_weight,	
	(SELECT fgt_count
				FROM	freightdetail f
				where f.stp_number = s.stp_number and fgt_sequence = 2) compartment2,

	(SELECT f.cmd_code
				FROM	freightdetail f
				where f.stp_number = s.stp_number and fgt_sequence = 3) cmd3,

	(SELECT	quantity1 = (case when fgt_quantity > 0 then fgt_quantity else 
					case when fgt_volume >0 then fgt_volume else
					case when fgt_weight > 0 then fgt_weight else
					case when fgt_count >0 then fgt_count else 0 end end end end)
				FROM	freightdetail f
				where f.stp_number = s.stp_number and fgt_sequence = 3) cmd3_weight,
	(SELECT fgt_count
				FROM	freightdetail f
				where f.stp_number = s.stp_number and fgt_sequence = 3) compartment3,
	(SELECT f.cmd_code
				FROM	freightdetail f
				where f.stp_number = s.stp_number and fgt_sequence = 4) cmd4,

	(SELECT	quantity1 = (case when fgt_quantity > 0 then fgt_quantity else 
					case when fgt_volume >0 then fgt_volume else
					case when fgt_weight > 0 then fgt_weight else
					case when fgt_count >0 then fgt_count else 0 end end end end)
				FROM	freightdetail f
				where f.stp_number = s.stp_number and fgt_sequence = 4) cmd4_weight,
	(SELECT fgt_count
				FROM	freightdetail f
				where f.stp_number = s.stp_number and fgt_sequence = 4) compartment4,
	(SELECT f.cmd_code
				FROM	freightdetail f
				where f.stp_number = s.stp_number and fgt_sequence = 5) cmd5,

	(SELECT	quantity1 = (case when fgt_quantity > 0 then fgt_quantity else 
					case when fgt_volume >0 then fgt_volume else
					case when fgt_weight > 0 then fgt_weight else
					case when fgt_count >0 then fgt_count else 0 end end end end)
				FROM	freightdetail f
				where f.stp_number = s.stp_number and fgt_sequence = 5) cmd5_weight,
	(SELECT fgt_count
				FROM	freightdetail f
				where f.stp_number = s.stp_number and fgt_sequence = 5) compartment5,
	o.ord_remark
	
from stops s
join orderheader o on s.ord_hdrnumber = o.ord_hdrnumber
join legheader lgh on s.lgh_number = lgh.lgh_number 
left outer join manpowerprofile mpp on lgh_driver1 = mpp.mpp_id

where  s.mov_number = @pl_mov
	and (s.stp_type = 'DRP')-- or  s.stp_event = 'XDU')

update #results
set shipper_name = cmp_name,
	shipper_ctyst = city.cty_name + ', ' + city.cty_state 
from   company, city
where  shipper_id = cmp_id
and cmp_city = city.cty_code

update #results
set consig_name = cmp_name,
	consig_address1 = isnull(cmp_address1, ''),
	consig_ctyst = city.cty_name + ', ' + city.cty_state,
	consig_city = city.cty_name,
	consig_state = city.cty_state,
	consig_directions = cmp_directions 
from #results 
join company on consig_id = cmp_id
join city on cmp_city = city.cty_code


update #results
set cmd1_name = c1.cmd_name,
cmd2_name = c2.cmd_name,
cmd3_name = c3.cmd_name,
cmd4_name = c4.cmd_name,
cmd5_name = c5.cmd_name
from #results
left outer join commodity c1 on cmd1 = c1.cmd_code 
left outer join commodity c2 on cmd2 = c2.cmd_code 
left outer join commodity c3 on cmd3 = c3.cmd_code 
left outer join commodity c4 on cmd4 = c4.cmd_code 
left outer join commodity c5 on cmd5 = c5.cmd_code 

-- BDH 5/16/08 PTS 42809.  In the datawindow, the BOL is the stp_refnum and the Railcar is the ord_refnum.
-- The actual data is in the referencenumber table with types of BL# and Rail#.
-- Arrival and Departure dates are the scheduled earliest dates.
-- Changes made here instead of the datawindow so we can deliver without a service pack.
update #results
set stp_refnum = (
	select top 1 ref_number 
	from referencenumber 
	where #results.ord_hdrnumber = referencenumber.ord_hdrnumber
	and ref_table = 'orderheader' 
	and ref_tablekey = #results.ord_hdrnumber
	and ref_type = 'BL#')


update #results
set ord_refnum = (
	select top 1 ref_number 
	from referencenumber 
	where #results.ord_hdrnumber = referencenumber.ord_hdrnumber
	and ref_table = 'orderheader' 
	and ref_tablekey = #results.ord_hdrnumber
	and ref_type = 'RAIL#')


update #results
set departure_date = (
	select stp_schdtearliest 
	from stops
	where #results.ord_hdrnumber = stops.ord_hdrnumber
	and stops.stp_sequence = (
		select min(stp_sequence) 
		from stops
		where stp_type = 'PUP'
		and #results.ord_hdrnumber = stops.ord_hdrnumber
		))  

update #results
set arrival_date = (select stp_schdtearliest from stops	where stops.stp_number = #results.stp_number) 
-- 42809 end

select * from #results

GO
GRANT EXECUTE ON  [dbo].[d_tripsheetformat08_sp] TO [public]
GO
