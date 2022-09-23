SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  Stored Procedure dbo.sp_netwise_export    Script Date: 8/4/2000 10:30:12 PM ******/
/* Created per PTS 8596 */

/*	PTS 27688 - DJM - Updated the proc to supply a couple new columns (load_division_code,
		fuel_surcharge, and additional padding at the end of the file. Also Modified 
		the Postal code fields to 10 characters from 6.

	PTS 30055 - DJM - Modified Proc to include data for Empty Movements.

	DZ (IDSC) - modified proc to correctly pull the PTA information

	The criteria for identifying fuel surchage may need to be modified depending on how the customer
	denotes the additional revenue.  Get some examples of loads with fuel surcharge and query the TMW 
	database to see what is in the cht_itemcode of the invoicedetail file.

	Some costs can be pulled directly from the TMW system if the customer feels they are accurate.  The
	drivers pay as well as other costs can be found by looking for specific codes inthe pyt_itemcode and 
	pyd_description fields of the paydetail file.

	PTS 41543 - DJM - Checked in IDSC changes from above.
	PTS 41588 - DJM - 2/27/08 - Modified SQL to correct issues getting the Power Available stop location.

	PTS 41669 - DJM - extensive modifications to better match what IDSC is looking for in Netwise.
*/
	


create procedure [dbo].[sp_netwise_export] (@begindate datetime,@enddate datetime)
 
as

Set Nocount on

Set Ansi_warnings off
--set Nolock on


--Create table #dougtest(
--	rstuff1 char(255) null,
--	rstuff2 char(255) null,
--	rstuff3 char(255) null)

/*
	Table to store 'standard' orders that have NOT been cross-docked or consolidated.
*/

Create table #netwise_format(
	ord_hdrnumber		varchar(20)	null,
	power_id				char(10)	null,
	power_avail_postalcode	char(10)	null,
	power_avail_statecode	varchar(6)		null,
	power_avail_date	char(8)		null,
	power_avail_time	char(4)		null,
	power_deadhead_miles_to_origin	int	null,
	load_id				char(10)	null,
	origin_postalcode	char(10)	null,
	origin_statecode	varchar(6)		null,
	pickup_date			char(8)		null,
	pickup_time			char(4)		null,
	load_pickup_type	char(1)		null,
	pickup_id			char(10)	null,
	shipper_id			char(10)	null,
	time_to_load		float(2)	null,
	division_code		char(3)		null,
	load_division_code	char(3)		null,
	dest_postalcode		char(10)	null,
	dest_state			varchar(6)		null,
	delivery_date		char(8)		null,
	delivery_time		char(4)		null,
	load_delivery_type	char(1)		null,
	delivery_id			char(10)	null,
	consignee_id		char(10)	null,
	time_to_unload		float(2)	null,
	fuel_surcharge		float(6)	null,
	total_revenue		integer		null,
	linehaul_cost		integer		null,
	accessorial_revenue	integer		null,
	total_weight		integer		null,
	total_cube			integer		null,
	loaded_miles		integer		null,
	number_of_inter_stops	integer		null,
	commodity_code		char(6)		null,
	pallets				integer		null,
	pallet_type			integer		null,
	capacity_type_assn	char(1)		null,
	trailer_type_assn	char(10)	null,
	home_flag			char(1)		null,
	pad2				integer		null,
	billto_id		char(15)	null,
	billto_name		char(15)	null,
	power_avail_city	char(13)	null,
	origin_city		char(13)	null,
	dest_city		char(13)	null,
	user_def1		char(10)	null,
	user_def2		char(10)	null,
	user_def3		char(10)	null,
	user_def4		char(10)	null,
	single_mileage		integer		null,
	team_mileage		integer		null,
	number_of_repowers	integer		null,
	second_capacity_type	char(2)	null,
	order_cost			float(3)	null,
	empty_mileage_cost	float(3)	null,
	loaded_mileage_cost	float(3)	null,
	cost_to_load		float(3)	null,
	cost_to_unload		float(3)	null,
	toll_cost			float(3)	null,
	pallet_cost			float(3)	null,
	pre_trip_trailer_prep	float(3)	null,
	post_trip_trailer_prep	float(3)	null,
	extra_stop_compensation	float(3)	null,
	lumper_cost_origin	float(3)	null,
	lumper_cost_dest	float(3)	null,
	other 				float(3)	null,
	powerstop			int			null,
	origstop			int		null,
	deststop			int		null,
	availstop			int		null,
	emptymiles_updt		int		null,
	origstop_stp_arrivaldate datetime null,
	availstop_stp_arrivaldate datetime null	)


Declare @pad	varchar(20)

-- Create the Padding variable
select @pad = Space(20)

declare @std_orders table( 
	ord_hdrnumber	int,
	mov_number		int)

/* Populate the table variable with all the orders to be included in the Extract	*/
insert into @std_orders
select ord_hdrnumber,
	mov_number
from orderheader o with (NOLOCK)
where o.ord_completiondate between @begindate and @enddate
	and o.ord_status in ('CMP', 'ICO')
	and not exists (select 1
				from stops s with (NOLOCK) 
				where s.ord_hdrnumber = o.ord_hdrnumber
				group by s.ord_hdrnumber
				having count(distinct s.mov_number) > 1)
	and not exists (select 1
				from stops s with (NOLOCK)
				where s.mov_number = o.mov_number
					and s.ord_hdrnumber > 0
				group by s.mov_number
				having count(distinct s.ord_hdrnumber) > 1)
Order by ord_hdrnumber


		
insert into #netwise_format (
	ord_hdrnumber,
	power_id,
	power_avail_postalcode, 
	power_avail_statecode, 
	power_avail_date, 
	power_avail_time,
	power_deadhead_miles_to_origin,
	load_id,
	origin_postalcode,
	origin_statecode,	
	pickup_date,
	pickup_time,
	load_pickup_type,
	pickup_id,
	shipper_id ,
	time_to_load,
	division_code,
	load_division_code,
	dest_postalcode,
	dest_state,
	delivery_date,
	delivery_time,
	load_delivery_type,
	delivery_id,
	consignee_id,
	time_to_unload,
	fuel_surcharge,
	total_revenue,
	linehaul_cost,
	accessorial_revenue,
	total_weight,
	total_cube,
	loaded_miles,
	number_of_inter_stops,
	commodity_code,
	pallets,
	pallet_type ,
	capacity_type_assn,
	trailer_type_assn,
	home_flag,
	pad2,
	billto_id,
	billto_name,
	power_avail_city,
	origin_city,
	dest_city,
	user_def1,
	user_def2,
	user_def3,
	user_def4,
	single_mileage,
	team_mileage,
	number_of_repowers,
	second_capacity_type,
	order_cost,
	empty_mileage_cost,
	loaded_mileage_cost,
	cost_to_load,
	cost_to_unload,
	toll_cost,
	pallet_cost,
	pre_trip_trailer_prep,
	post_trip_trailer_prep,
	extra_stop_compensation,
	lumper_cost_origin,
	lumper_cost_dest,
	other,
	powerstop,
	origstop,
	deststop,
	availstop,
	origstop_stp_arrivaldate,
	availstop_stp_arrivaldate)
Select orderheader.ord_hdrnumber,
	(select evt_tractor
		from event e with (NOLOCK)
		where e.stp_number = origstop.stp_number and e.evt_sequence = 1) power_id,
	'' power_avail_postalcode,
	'' power_avail_statecode,
	'491231' power_avail_date,
	'0000' power_avail_time, 
	0 power_deadhead_miles_to_origin,
	cast(orderheader.ord_number as char(10)) load_id,
	isNull(origstop.stp_zipcode,isNull((select cty_zip from city where city.cty_code = origstop.stp_city),'')) origin_postalcode,
	origstop.stp_state origin_statecode,
	convert(char(8),origstop.stp_arrivaldate,112) pickup_date,
	Right('0'+datename(hh,origstop.stp_arrivaldate),2)+Right('0'+datename(mi,origstop.stp_arrivaldate),2) pickup_time,
	load_pickup_type = 
		Case origstop.stp_event 
			when 'LLD' then 'L'
			when 'DJD' then 'W'
			when 'HPL' then 'S'
			when 'PLD' then 'S'
			else 'L'
			end , 
	pickup_id = 
		Case origstop.cmp_id 
			when 'UNK' then 'ZZZZZZZ'
			when 'UNKNOWN' then 'ZZZZZZZ'
			else origstop.cmp_id 
		end   ,
	isNull(origstop.cmp_id, 'UNKNOWN') shipper_id, 
	cast(cast((datediff (mi, origstop.stp_arrivaldate, origstop.stp_departuredate)) as decimal (8,2))/60 as decimal(8,2)) time_to_load, 
	isNull((select trc_division from tractorprofile t with (NOLOCK) join event e with (NOLOCK) on t.trc_number = e.evt_tractor 
		where e.stp_number = origstop.stp_number and evt_sequence = 1),'UNK') division_code, -- Tractor Division
	isNull(orderheader.ord_revtype1,'UNK') load_division_code,	-- These fields are typically customized by customer. Usually RevType1-4
	isNull(deststop.stp_zipcode, isNull((select cty_zip from city with (NOLOCK) where city.cty_code = deststop.stp_city),'')) dest_postalcode,
	deststop.stp_state dest_state,
	convert(char(8),deststop.stp_arrivaldate,112) delivery_date,
	Right('0'+ datename(hh,deststop.stp_arrivaldate),2) + Right('0' + Datename(mi,deststop.stp_arrivaldate),2) delivery_time,
	load_delivery_type = 
		Case deststop.stp_event 
			when 'LUL' then 'L'	
			when 'DUL' then 'W'
			when 'DRL' then 'S'
			when 'PUL' then 'S'
			else ' '
		end,
	isNull(deststop.cmp_id, 'UNKNOWN') delivery_id ,
	isNull(orderheader.ord_consignee,'UNKNOWN') consinee_id,
	cast(cast((datediff (mi, deststop.stp_arrivaldate, deststop.stp_departuredate)) as decimal (8,2))/60 as decimal(8,2)) time_to_unload, 
	isNull((select isnull(sum(id.ivd_charge),0)
		from invoicedetail id with (NOLOCK)
		where id.ord_hdrnumber = orderheader.ord_hdrnumber
			and cht_itemcode like '%FSC%'),0) fuel_surcharge ,
	isNull(Cast((Select sum(ivh_totalcharge) from invoiceheader with (NOLOCK) where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber) as Int),0) total_revenue ,
	--isNull((select sum(pyd_amount) from paydetail where paydetail.ord_hdrnumber = orderheader.ord_hdrnumber),0) linehaul_cost,
	isNull((select sum(pyd_amount) from paydetail with (NOLOCK) where paydetail.ord_hdrnumber = orderheader.ord_hdrnumber and pyd_pretax ='Y'),0) linehaul_cost,
--	ISNULL((SELECT sum( ISNULL( ivd_charge, 0 ) )
--            FROM invoicedetail with (NOLOCK), chargetype with (NOLOCK)
--            WHERE orderheader.ord_hdrnumber = invoicedetail.ord_hdrnumber
--            AND invoicedetail.cht_itemcode=chargetype.cht_itemcode
--            AND ((chargetype.cht_basis='acc')
--            OR  (invoicedetail.cht_itemcode='UNK'))),0) accessorial_revenue,
	ISNULL((SELECT sum( ISNULL( ivh_totalcharge, 0 ) - isNull(ivh_charge,0) )
            FROM invoiceheader with (NOLOCK)
            WHERE orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber),0) accessorial_revenue,
	isNull((select Sum(ivh_totalweight)
		from invoiceheader with (NOLOCK)
		where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber and
			Right(invoiceheader.ivh_invoicenumber,1 )= 'A'),0) total_weight,
	isNull((select sum(s.stp_volume)
		from stops s with (NOLOCK)
		where s.ord_hdrnumber = orderheader.ord_hdrnumber and
			s.stp_volumeunit = 'CUB' and
			s.stp_type = 'DRP' ),0) total_cube,
	(select sum(s.stp_lgh_mileage) 
		from stops s with (NOLOCK)
		where s.mov_number = orderheader.mov_number and
			s.stp_loadstatus = 'LD') loaded_miles,
	(select count(s.stp_number)- 2
		from stops s with (NOLOCK)
		where s.mov_number = orderheader.mov_number and
			s.ord_hdrnumber <> 0) number_of_inter_stops,
	(select cast(o.cmd_code as char(6))
		from orderheader o with (NOLOCK)
		where o.ord_hdrnumber = orderheader.ord_hdrnumber) commodity_code ,
	0 pallets,
	0 pallet_type,
	(select 'capacity_type_assn' = 
		Case 
			When lgh_driver1 <> 'UNKNOWN' and lh.lgh_driver2 <> 'UNKNOWN' and lh.lgh_driver2 <> '' then 'T'
			else 'S'
		end
		from legheader lh
		where lh.lgh_number = origstop.lgh_number) capacity_type_asgn,
	(select lh.trl_type1
		from legheader lh with (NOLOCK)
		where lh.lgh_number  = origstop.lgh_number ) trailer_type_assn,
	'' home_flag,
	0 pad2,
	orderheader.ord_billto billto_id,
	Cast((select c.cmp_name 
		from company c
		where orderheader.ord_billto = c.cmp_id)as char(15)) billto_name,
	'' power_avail_city,
	Cast((select cty_name from city where city.cty_code = origstop.stp_city) as char(13)) origin_city,
	Cast((select cty_name from city where city.cty_code = deststop.stp_city) as char(13)) dest_city,
	orderheader.ord_revtype1 user_def1,
	orderheader.ord_revtype2 user_def2,
	orderheader.ord_revtype3 user_def3,
	orderheader.ord_revtype4 user_def4,
	(select sum(s.stp_lgh_mileage)
		from stops s with (NOLOCK),
			legheader lh with (NOLOCK)
		where s.mov_number = orderheader.mov_number and
			s.lgh_number = lh.lgh_number and
			Upper(lh.lgh_driver2) = 'UNKNOWN') single_mileage,
	(select sum(s.stp_lgh_mileage)
		from stops s with (NOLOCK),
			legheader lh with (NOLOCK)
		where s.mov_number = orderheader.mov_number and
			s.lgh_number = lh.lgh_number and
			Upper(lh.lgh_driver1) <> 'UNKNOWN' and
			Upper(lh.lgh_driver2) <> 'UNKNOWN') team_mileage,
--	(select count(lh.lgh_number) 		
--		from legheader lh, legheader startleg
--		where startleg.lgh_number = origstop.lgh_number and
--			lh.mov_number = orderheader.mov_number and
--			lh.lgh_tractor <> startleg.lgh_tractor) number_of_repowers,
	(select (count(distinct e.evt_tractor) - 1)
			from event e with (NOLOCK) join stops s with (NOLOCK) on e.stp_number = s.stp_number 
			where s.ord_hdrnumber = orderheader.ord_hdrnumber) number_of_repowers,
	(select 'second_capacity_type' = 
		Case 
			When lh.lgh_driver1 <> 'UNKNOWN' and lh.lgh_driver2 <> 'UNKNOWN' and lh.lgh_driver2 <> '' then 'T'
			else 'S'
		end
		from legheader lh with (NOLOCK)
		where lh.lgh_number = deststop.lgh_number) second_capacity_type,
	0 order_cost,
	0 empty_mileage_cost,
	0 loaded_mileage_cost,
	0 cost_to_load,
	0 cost_to_unload,
	0 toll_cost,
	0 pallet_cost,
	0 pre_trip_trailer_prep,
	0 post_trip_trailer_prep,
	0 extra_stop_compensation,
	0 lumper_cost_origin,
	0 lumper_cost_dest,
	(select isnull(sum(pd.pyd_amount),0)
		from paydetail pd
		where pd.mov_number = orderheader.mov_number) other,
	0,
	origstop.stp_number,
	deststop.stp_number,	
	0 availstop	,
	origstop.stp_arrivaldate,
	null availstop_stp_arrivaldate
from orderheader with (NOLOCK) inner join @std_orders std on orderheader.ord_hdrnumber = std.ord_hdrnumber
	inner join stops origstop with (NOLOCK) on orderheader.mov_number = origstop.mov_number 
	inner join stops deststop with (NOLOCK) on orderheader.mov_number = deststop.mov_number
where -- PTS 41588 - DJM - Modified the join to verify that the Power stop found is for the tractor that actually performs the pickup.
	origstop.stp_mfh_sequence = (select min(stp_mfh_sequence)
				from stops s
				where s.mov_number = orderheader.mov_number and
					s.stp_type = 'PUP' and
					s.ord_hdrnumber = orderheader.ord_hdrnumber) and
	deststop.stp_mfh_sequence = (select max(stp_mfh_sequence)
				from stops s
				where s.mov_number = orderheader.mov_number and
					s.stp_type = 'DRP' and
					s.ord_hdrnumber = orderheader.ord_hdrnumber)


/* 
	Insert summarized Order data for Trips with multiple Orders (Consolidated Orders)
*/

-- Table to identify Movements with multiple Orders
declare @consolidated_moves table( 
	mov_number		int,
	ord_hdrnumber	int)

insert into @consolidated_moves
select mov_number,
	ord_hdrnumber
from orderheader o with (NOLOCK)
where o.ord_completiondate between @begindate and @enddate
	and o.ord_status = 'CMP'
	and not exists (select 1
				from stops s with (NOLOCK) 
				where s.ord_hdrnumber = o.ord_hdrnumber
				group by s.ord_hdrnumber
				having count(distinct s.mov_number) > 1)
	and exists (select 1
				from stops s with (NOLOCK)
				where s.mov_number = o.mov_number
					and s.ord_hdrnumber > 0
				group by s.mov_number
				having count(distinct s.ord_hdrnumber) > 1)
Order by ord_hdrnumber

insert into #netwise_format (
	ord_hdrnumber,
	power_id,
	power_avail_postalcode, 
	power_avail_statecode, 
	power_avail_date, 
	power_avail_time,
	power_deadhead_miles_to_origin,
	load_id,
	origin_postalcode,
	origin_statecode,	
	pickup_date,
	pickup_time,
	load_pickup_type,
	pickup_id,
	shipper_id ,
	time_to_load,
	division_code,
	load_division_code,
	dest_postalcode,
	dest_state,
	delivery_date,
	delivery_time,
	load_delivery_type,
	delivery_id,
	consignee_id,
	time_to_unload,
	fuel_surcharge,
	total_revenue,
	linehaul_cost,
	accessorial_revenue,
	total_weight,
	total_cube,
	loaded_miles,
	number_of_inter_stops,
	commodity_code,
	pallets,
	pallet_type ,
	capacity_type_assn,
	trailer_type_assn,
	home_flag,
	pad2,
	billto_id,
	billto_name,
	power_avail_city,
	origin_city,
	dest_city,
	user_def1,
	user_def2,
	user_def3,
	user_def4,
	single_mileage,
	team_mileage,
	number_of_repowers,
	second_capacity_type,
	order_cost,
	empty_mileage_cost,
	loaded_mileage_cost,
	cost_to_load,
	cost_to_unload,
	toll_cost,
	pallet_cost,
	pre_trip_trailer_prep,
	post_trip_trailer_prep,
	extra_stop_compensation,
	lumper_cost_origin,
	lumper_cost_dest,
	other,
	powerstop,
	origstop,
	deststop,
	availstop,
	origstop_stp_arrivaldate,
	availstop_stp_arrivaldate)
Select moves.mov_number,
	 IsNull((select e.evt_tractor
		from event e with (NOLOCK)
		where e.stp_number = origstop.stp_number
			and e.evt_sequence = 1),'UNKNOWN') power_id,
	'' power_avail_postalcode,
	'' power_avail_statecode,
	'' power_avail_date,
	'' power_avail_time, 
	0 power_deadhead_miles_to_origin,
	cast(moves.mov_number as char(10))+ '(M)' load_id,
	isNull(origstop.stp_zipcode,(select cty_zip from city where city.cty_code = origstop.stp_city)) origin_postalcode,
	origstop.stp_state origin_statecode,
	convert(char(8),origstop.stp_arrivaldate,112) pickup_date,
	Right('0'+datename(hh,origstop.stp_arrivaldate),2)+Right('0'+datename(mi,origstop.stp_arrivaldate),2) pickup_time,
	load_pickup_type = 
		Case origstop.stp_event 
			when 'LLD' then 'L'
			when 'DJD' then 'W'
			when 'HPL' then 'S'
			when 'PLD' then 'S'
			else 'L'
			end , 
	pickup_id = 
		Case origstop.cmp_id 
			when 'UNK' then 'ZZZZZZZ'
			when 'UNKNOWN' then 'ZZZZZZZ'
			else origstop.cmp_id 
		end   ,
	origstop.cmp_id shipper_id, 
	cast(cast((datediff (mi, origstop.stp_arrivaldate, origstop.stp_departuredate)) as decimal (8,2))/60 as decimal(8,2)) time_to_load, 
	'' division_code, 	-- These fields are typically customized by customer. Usually RevType1-4
	'' load_division_code,	-- These fields are typically customized by customer. Usually RevType1-4
	isNull((select cty_zip from city where city.cty_code = deststop.stp_city),'') dest_postalcode,
	deststop.stp_state dest_state,
	convert(char(8),deststop.stp_arrivaldate,112) delivery_date,
	Right('0'+ datename(hh,deststop.stp_arrivaldate),2) + Right('0' + Datename(mi,deststop.stp_arrivaldate),2) delivery_time,
	load_delivery_type = 
		Case deststop.stp_event 
			when 'LUL' then 'L'	
			when 'DUL' then 'W'
			when 'DRL' then 'S'
			when 'PUL' then 'S'
			else ' '
		end,
	deststop.cmp_id delivery_id,
	(select max(orderheader.ord_consignee) from orderheader with (NOLOCK) where orderheader.mov_number = moves.mov_number) consinee_id,
	cast(cast((datediff (mi, deststop.stp_arrivaldate, deststop.stp_departuredate)) as decimal (8,2))/60 as decimal(8,2)) time_to_unload, 
	isNull((select isnull(sum(id.ivd_charge),0)
		from orderheader o with (NOLOCK) join invoicedetail id with (NOLOCK) on o.ord_hdrnumber = id.ord_hdrnumber
		where o.mov_number = moves.mov_number
			and id.cht_itemcode like '%FSC%'),0) fuel_surcharge,
	isNull(Cast((Select sum(ivh_totalcharge) 
		from invoiceheader ih with (NOLOCK) join orderheader o with (NOLOCK) on ih.ord_hdrnumber = o.ord_hdrnumber
		where o.mov_number = moves.mov_number
			and ih.ord_hdrnumber = o.ord_hdrnumber) as Int),0) total_revenue ,
	0 linehaul_cost,
--	ISNULL((SELECT sum( ISNULL( ivd_charge, 0 ) )
--            FROM invoicedetail with (NOLOCK) join orderheader o with (NOLOCK) on o.ord_hdrnumber = invoicedetail.ord_hdrnumber
--				join chargetype on invoicedetail.cht_itemcode=chargetype.cht_itemcode
--            WHERE o.mov_number = moves.mov_number
--				AND ((chargetype.cht_basis='acc')
--				OR  (invoicedetail.cht_itemcode='UNK'))),0) accessorial_revenue,
	ISNULL((SELECT sum( ISNULL( ivh_totalcharge, 0 ) - isNull(ivh_charge,0) )
            FROM invoiceheader with (NOLOCK) join orderheader o with (NOLOCK) on o.ord_hdrnumber = invoiceheader.ord_hdrnumber
            WHERE o.mov_number = moves.mov_number),0) accessorial_revenue,
	(select Sum(ivh_totalweight)
		from invoiceheader with (NOLOCK)join orderheader o with (NOLOCK) on invoiceheader.ord_hdrnumber = o.ord_hdrnumber
		where o.mov_number = moves.mov_number
			and invoiceheader.ord_hdrnumber = o.ord_hdrnumber 
			and Right(invoiceheader.ivh_invoicenumber,1 )= 'A') total_weight,
	(select sum(s.stp_volume)
		from stops s with (NOLOCK)
		where s.mov_number = moves.mov_number and
			s.stp_volumeunit = 'CUB' and
			s.stp_type = 'DRP' ) total_cube,
	(select sum(s.stp_lgh_mileage) 
		from stops s with (NOLOCK)
		where s.mov_number = moves.mov_number and
			s.stp_loadstatus = 'LD') loaded_miles,
	(select count(s.stp_number)- 2
		from stops s with (NOLOCK)
		where s.mov_number = moves.mov_number and
			s.ord_hdrnumber <> 0) number_of_inter_stops,
	'UNKNOWN' commodity_code ,
	0 pallets,
	0 pallet_type,
	(select 'capacity_type_assn' = 
		Case 
			When lgh_driver1 <> 'UNKNOWN' and lh.lgh_driver2 <> 'UNKNOWN' and lh.lgh_driver2 <> '' then 'T'
			else 'S'
		end
	from legheader lh with (NOLOCK)
	where lh.lgh_number = origstop.lgh_number) capacity_type_asgn,
	isNull((select lh.trl_type1
		from legheader lh with (NOLOCK)
		where lh.lgh_number  = origstop.lgh_number ),'UNKNOWN') trailer_type_assn,
	'' home_flag,
	0 pad2,
	'UNKNOWN' billto_id,
	'UNKNOWN' billto_name,
	--Cast((select cty_name from city where city.cty_code = powerstop.stp_city) as char(13)) power_avail_city,
	0 power_avail_city,
	Cast((select cty_name from city where city.cty_code = origstop.stp_city) as char(13)) origin_city,
	Cast((select cty_name from city where city.cty_code = deststop.stp_city) as char(13)) dest_city,
	'UNKNOWN',
	'UNKNOWN',
	'UNKNOWN',
	'UNKNOWN',
	(select sum(s.stp_lgh_mileage)
		from stops s with (NOLOCK),
			legheader lh with (NOLOCK)
		where s.mov_number = moves.mov_number 
			and s.lgh_number = lh.lgh_number 
			and Upper(isNull(lh.lgh_driver1,'UNKNOWN')) <> 'UNKNOWN'
			and Upper(isNull(lh.lgh_driver2,'UNKNOWN')) = 'UNKNOWN') single_mileage,
	(select sum(s.stp_lgh_mileage)
		from stops s with (NOLOCK),
			legheader lh with (NOLOCK)
		where s.mov_number = moves.mov_number 
			and s.lgh_number = lh.lgh_number 
			and Upper(isNull(lh.lgh_driver1,'UNKNOWN')) <> 'UNKNOWN'
			and Upper(isNull(lh.lgh_driver2,'UNKNOWN')) <> 'UNKNOWN') team_mileage,
	(select (count(distinct e.evt_tractor) - 1)
			from event e with (NOLOCK) join stops s with (NOLOCK) on e.stp_number = s.stp_number 
			where s.mov_number = moves.mov_number) number_of_repowers,
	(select 'second_capacity_type' = 
		Case 
			When lh.lgh_driver1 <> 'UNKNOWN' and lh.lgh_driver2 <> 'UNKNOWN' and lh.lgh_driver2 <> '' then 'T'
			else 'S'
		end
		from legheader lh with (NOLOCK)
		where lh.lgh_number = deststop.lgh_number) second_capacity_type,
	0 order_cost,
	0 empty_mileage_cost,
	0 loaded_mileage_cost,
	0 cost_to_load,
	0 cost_to_unload,
	0 toll_cost,
	0 pallet_cost,
	0 pre_trip_trailer_prep,
	0 post_trip_trailer_prep,
	0 extra_stop_compensation,
	0 lumper_cost_origin,
	0 lumper_cost_dest,
	(select isnull(sum(pd.pyd_amount),0)
		from paydetail pd
		where pd.mov_number = moves.mov_number) other,
	0,
	origstop.stp_number,
	deststop.stp_number,	
	0 availstop	,
	origstop.stp_arrivaldate,
	null availstop_stp_arrivaldate
from (select distinct mov_number from @consolidated_moves) moves 
	--inner join stops powerstop on moves.mov_number = powerstop.mov_number
	inner join stops origstop with (NOLOCK) on moves.mov_number = origstop.mov_number 
	inner join stops deststop with (NOLOCK) on moves.mov_number = deststop.mov_number
where -- PTS 41588 - DJM - Modified the join to verify that the Power stop found is for the tractor that actually performs the pickup.
--	powerstop.stp_mfh_sequence = (select min(s.stp_mfh_sequence)
--				from stops s inner join event e on s.stp_number = e.stp_number and e.evt_sequence = 1
--				where s.mov_number = moves.mov_number
--					and e.evt_tractor = (select evt_tractor from event e where e.stp_number = origstop.stp_number and e.evt_sequence = 1)) and
	origstop.stp_mfh_sequence = (select min(stp_mfh_sequence)
				from stops s
				where s.mov_number = moves.mov_number and
					s.stp_type = 'PUP') and 
	deststop.stp_mfh_sequence = (select max(stp_mfh_sequence)
				from stops s
				where s.mov_number = moves.mov_number and
					s.stp_type = 'DRP')
					

/*
End Consolidated Order logic
*/



/* Update the Power Availability fields with the appropriate information		
	PTS 41669 - DJM - modified to look at the stp_loadstatus so it finds DLT
		locations.  Those stops are NOT marked as PUP or DRP stops but SHOULD
		be listed as the location the tractor became available.
*/
update #netwise_format
set availstop = (select top 1 s.stp_number
				   from event e join stops s on e.stp_number = s.stp_number
				  where evt_sequence = 1
					and evt_status = 'DNE'
					--and evt_pu_dr in ('DRP', 'PUP')
					and s.stp_loadstatus = 'LD'
					and evt_tractor = power_id
					and evt_startdate < (select stp_arrivaldate from stops where stp_number = origstop)
				 order by evt_startdate desc)

update #netwise_format
set availstop_stp_arrivaldate = (select stp_arrivaldate from stops where stops.stp_number = availstop)
where isNull(availstop,0) > 0

/*
update #netwise_format
set availstop = a.stp_number,
	availstop_stp_arrivaldate = a.stp_arrivaldate 
from #netwise_format inner join 
(select stops.stp_number, stp_arrivaldate, evt_tractor, max(evt_startdate) max_event_startdate
				   from [event] inner join stops on [event].stp_number = stops.stp_number
				  where evt_sequence = 1
					and evt_status = 'DNE'
					and evt_pu_dr in ('DRP', 'PUP')
					--and evt_tractor = power_id
					and evt_startdate < stops.stp_arrivaldate
					group by stops.stp_number, stp_arrivaldate, evt_tractor) a
on #netwise_format.origstop = a.stp_number
where #netwise_format.power_id = a.evt_tractor
*/

/*	Update #netwise_export - set the location information		*/

Update #netwise_format
set power_avail_postalcode = isnull(stops.stp_zipcode, IsNull((select cty_zip from city where city.cty_code = stops.stp_city),'')),
	power_avail_statecode = stops.stp_state ,
	power_avail_date = convert(char(8),stops.stp_arrivaldate,112) ,
	power_avail_time = Right('0'+ datename(hh,stops.stp_arrivaldate),2) + Right('0'+ datename(mi, stops.stp_arrivaldate),2),
	power_avail_city = Cast((select cty_name from city with (NOLOCK) where city.cty_code = stops.stp_city) as char(13))
from stops with (NOLOCK)
where stops.stp_number = #netwise_format.availstop
	and #netwise_format.availstop > 0

/* set the Deadhead Miles to Origin field for each record in the Temp table		*/
Update #netwise_format
set power_deadhead_miles_to_origin = (

Select sum(isNull(s.stp_lgh_mileage,0))
		from stops s with (NoLock) join event e with (NOLOCK) on s.stp_number = e.stp_number and e.evt_sequence = 1 --,
			--(select stp_number, stp_arrivaldate from stops where stp_number = #netwise_format.availstop) availstop
			--(select stp_number, stp_arrivaldate from stops where stp_number = #netwise_format.origstop) origstop		
		where #netwise_format.availstop <> #netwise_format.origstop
			and e.evt_tractor = #netwise_format.power_id
			and s.stp_arrivaldate > #netwise_format.availstop_stp_arrivaldate--availstop.stp_arrivaldate 
			and s.stp_arrivaldate <= #netwise_format.origstop_stp_arrivaldate --origstop.stp_arrivaldate 
			and s.stp_status = 'DNE')
where #netwise_format.availstop > 0
	

--declare @load_id as varchar(10)
--Select @load_id = min(load_id) from #netwise_format where isNull(emptymiles_updt,0) = 0 and availstop > 0
	
--While @load_id > 0
--Begin 
--	Update #netwise_format
--	set emptymiles_updt = 1,
--		power_deadhead_miles_to_origin = (Select sum(isNull(s.stp_lgh_mileage,0))
--			from stops s join event e on s.stp_number = e.stp_number and e.evt_sequence = 1 ,
--				(select stp_number, stp_arrivaldate from stops where stp_number = me.availstop) availstop,
--				(select stp_number, stp_arrivaldate from stops where stp_number = me.origstop) origstop		
--			where me.availstop <> me.origstop
--				and e.evt_tractor = me.power_id
--				and s.stp_arrivaldate > availstop.stp_arrivaldate 
--				and s.stp_arrivaldate <= origstop.stp_arrivaldate
--				and s.stp_status = 'DNE')
--	from #netwise_format me
--	where me.load_id = @load_id
--		and me.availstop > 0
--
--	Select @load_id = min(load_id) from #netwise_format where isNull(emptymiles_updt,0) = 0 and availstop > 0
--
--End


/*	To SQL Server's automatice trimming of following spaces when inserted into a 
	table, tilde's (~) are used in the last field concatenated to each column.  
	The tildes are replaced in the Select from the temp table.
*/

--insert into #dougtest
Select Left(LTrim(isNull(power_id,'')) + Space(10), 10) +
	Case isnumeric(power_avail_postalcode)
		When '1' then Right( space(6) + RTrim(isNull(power_avail_postalcode,'')),6)
		else Left( LTrim(isNull(Replace(power_avail_postalcode,' ',''),''))  + Space(6),6)
		end +
	Left(isNull(power_avail_statecode,Space(2)),2) +
	isNull(power_avail_date, Space(8)) +
	isNull(power_avail_time,Space(4)) +
	Right(Space(5) + RTrim(str(isNull(power_deadhead_miles_to_origin,0),5,0)) ,5) +
	Left( LTrim(isNull(load_id,'')) + Space(10),10) +
	--Left( LTrim(isNull(origin_postalcode,''))  + Space(6), 6)+
	Case isnumeric(origin_postalcode)
		When '1' then Right( space(6) + RTrim(isNull(origin_postalcode,'')),6)
		else Left( LTrim(isNull(Replace(origin_postalcode,' ',''),''))  + Space(6),6)
		end +
	Left(isNull(origin_statecode, Space(2)),2) +
	IsNull(pickup_date, Space(8)) +
	IsNull(pickup_time, Space(4)) +
	isNull(load_pickup_type,Space(1)) +
	Left( LTrim(isNull(pickup_id,'')) + Space(10), 10) +
	Left( LTrim(isNull(shipper_id,'')) + Space(10), 10) +
	Right(Space(6) + RTrim(Str(isNUll(time_to_load,0),6,2)),6) +
	Left( isNull(division_code,Space(3)) + Space(3) ,3) +
	Left( isNull(load_division_code,Space(3)) + Space(3) ,3) +
	--Left(LTrim(IsNull(dest_postalcode,'')) + Space(6),6) +
	Case isnumeric(dest_postalcode)
		When 1 then Right( space(6) + RTrim(isNull(dest_postalcode,'')),6)
		else Left( LTrim(isNull(Replace(dest_postalcode,' ',''),''))  + Space(6),6)
		end +
	Left(isNull(dest_state, Space(2)),2) +
	isNull(delivery_date,Space(8))+
	isNull(Right(Space(4) + delivery_time, 4),Space(4)) +
	isNull(Right(Space(1) + load_delivery_type,1),Space(1)) +
	Left( LTrim(isNull(delivery_id,'')) + Space(10), 10) +
	Left( LTrim(isNull(consignee_id,'')) + Space(10), 10) +
	Right( Space(6) + RTrim(Str(isNUll(time_to_unload,0),6,2)),6) +
	Right( Space(6) + RTrim(str(IsNull(fuel_surcharge,0),6,1)),6) +
	Right( Space(5) + RTrim(str(isNull(total_revenue,0),5,0)) ,5) +
	Right( Space(5) + RTrim(str(isNUll(linehaul_cost,0),5,0)) ,5) +
	Right( Space(5) + RTrim(str(isNUll(accessorial_revenue,0),5,0)) ,5)  +
	Right( Space(5) + RTrim(str(isNUll(total_weight ,0),5,0)) ,5) +
	Right( Space(5) + RTrim(str(isNUll(total_cube ,0),5,0)) ,5) +
	Right( Space(5) + RTrim(str(isNUll(loaded_miles ,0),5,0)) ,5) +
	Right( Space(2) + RTrim(str(isNull(number_of_inter_stops ,0),2,0)),2) +
	Left( LTrim(isNull(commodity_code,'')) + Space(6), 6) +
	Right(Space(5) + RTrim(str(isNUll(pallets ,0),5,0)) ,5) +
	Right(Space(3) + RTrim(str(isNUll(pallet_type ,0),3,0)) ,3) +
	IsNull(capacity_type_assn, Space(1)) +
	Left( LTrim(isNull(trailer_type_assn,'')) + Space(10), 10) +
	isNull(home_flag, Space(1)) +
	Left(isNull(str(pad2,2,0), space(2)) + Space(2),2) +
	Left( LTrim(isNull(billto_id,'')) + Space(15) , 15) +
	Left( LTrim(isNull(billto_name,'')) + Space(15), 15) +
	Left( LTrim(isNull(power_avail_city,'')) + Space(13), 13) +
	Left( LTrim(isNull(origin_city,'')) + Space(13), 13) +
	Left( LTrim(isNull(dest_city,'')) + Space(13), 13) +
	Left( LTrim(isNull(user_def1,'')) + Space(10), 10) +
	Left( LTrim(isNull(user_def2,'')) + Space(10), 10) +
	Left( LTrim(isNull(user_def3,'')) + Space(10), 10) +
	Left( LTrim(isNull(user_def4,'')) + Space(10), 10) +
	Right( Space(5) + RTrim(str(isNUll(single_mileage ,0),5,0)),5) +
	Right( Space(5) + RTrim(str(isNUll(team_mileage ,0),5,0)),5) +
	Right( Space(3) + RTrim(str(isNUll(number_of_repowers ,0),3,0)) ,3) +
	isNull(Left(second_capacity_type + Space(1),1),Space(1)) +
	Right( Space(8) + RTrim(str(isNull(order_cost,0),8,3)),8) +
	Right( Space(8) + RTrim(str(isNull(empty_mileage_cost,0),8,3)) ,8) +
	Right( Space(8) + RTrim(str(isNull(loaded_mileage_cost,0),8,3)) ,8) +
	Right( Space(8) + RTrim(str(isNull(cost_to_load,0),8,3)) ,8) + 
	Right( Space(8) + RTrim(str(isNull(cost_to_unload,0),8,3)),8) +
	Right( Space(8) + RTrim(str(isNull(toll_cost,0),8,3)),8) +
	Right( Space(8) + RTrim(str(isNull(pallet_cost,0),8,3)),8) +
	Right( Space(8) + RTrim(str(isNull(pre_trip_trailer_prep,0),8,3)) ,8) +
	Right( Space(8) + RTrim(str(isNull(post_trip_trailer_prep,0),8,3)),8) +
	Right( Space(8) + RTrim(str(isNull(extra_stop_compensation,0),8,3)),8) +
	Right( Space(8) + RTrim(str(isNull(lumper_cost_origin,0),8,3)) ,8) +
	Right( Space(8) + RTrim(str(isNull(lumper_cost_dest,0),8,3)),8) +
	Right( Space(8) + RTrim(str(isNull(other,0),8,3)),8)
	--Space(6) + 
	--Space(7)--+
	--Char(10) + Char(13)
from #netwise_format



/*	Must remember to replace the tildes with spaces
*/
--select Cast(Replace(rstuff1,'~',Space(1)) + Replace(rstuff2,'~',Space(1)) + Replace(rstuff3,'~',Space(1)) as Text) from #dougtest
--select Cast(Replace(rstuff1,'~',Space(1)) + Replace(rstuff2,'~',Space(1)) + Replace(rstuff3,'~',Space(1)) as char(453)) from #dougtest
--
--
--drop table #dougtest
Drop table #netwise_format

GO
GRANT EXECUTE ON  [dbo].[sp_netwise_export] TO [public]
GO
