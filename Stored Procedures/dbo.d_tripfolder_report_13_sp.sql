SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[d_tripfolder_report_13_sp] 	@mov_number integer, @asset_type varchar(6)
as

/**
 *
 * NAME:
 * dbo.d_tripfolder_report_13_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * source of data for d_tripfolder_report13 for Miller Transporters
 *
 *
 * RETURNS:
 * no return code
 *
 * RESULT SETS:
 *  see below
 *
 * PARAMETERS:
 * 001 -  @lgh_number
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 *
 *	PTS 53138 - DJM - 7/8/2010 - Add Referencenumber, Booked By, and Carrier information.
 *	PTS 55470 - DJM - corrected display the Quantities for Orders.
 *	PTS 56556 - DJM - Modified to display Company Name from the Company Table instead of the Stops table.
 *
 *	NOTE: Load INstructions, Commodity Instructions, Stop requirements, and Weighing Instructions are all derived
 *		from specific Note Types that must be attached to the Company. The logic also looks at the Type of stop
 *		(PUP, DRP) to determine which not should be used.
 **/
DECLARE @showexpired 			CHAR(1)
DECLARE @grace 					INTEGER
DECLARE @first_ord_hdrnumber	INTEGER
DECLARE @second_ord_hdrnumber	INTEGER
DECLARE @first_note				VARCHAR (254)
DECLARE @second_note			VARCHAR (254)
DECLARE @first_billto			VARCHAR (18)
DECLARE @second_billto			VARCHAR (18),
	@est_pay					money,
	@driver						varchar(13),
	@tractor					varchar(13),	
	@load_inst					varchar(3000),
	@stpcnt						int,
	@curr_stp					int,
	@hold						varchar(3000),
	@note_count					int,
	@min_note					int


Create Table #stop_notes(
	stp_number			integer			not null,
	lgh_number			integer			not null,
	stp_type			varchar(3)		null,
	cmp_id				varchar(8)		null,
	load_inst			varchar(3000)	null,
	commodity_inst		varchar(3000)	null,
	requirements		varchar(3000)	null,
	weigh_inst			varchar(3000)	null)
SELECT @showexpired = gi_string1
	FROM generalinfo
	WHERE gi_name = 'showexpirednotes'
SET @showexpired = COALESCE (@showexpired, 'Y')

SELECT @grace = gi_integer1
	FROM generalinfo
	WHERE gi_name = 'showexpirednotesgrace'
SET @grace = COALESCE (@grace, 0)


SELECT TOP 1 @first_ord_hdrnumber = stops.ord_hdrnumber, @first_billto = orderheader.ord_billto
	FROM stops LEFT OUTER JOIN orderheader ON stops.ord_hdrnumber = orderheader.ord_hdrnumber
	WHERE stops.ord_hdrnumber > 0
	  AND stops.ord_hdrnumber IS NOT NULL
	  AND stops.mov_number = @mov_number
	ORDER BY stops.ord_hdrnumber



insert into #stop_notes (stp_number, lgh_number, stp_type, cmp_id)
select stp_number, lgh_number, stp_type, cmp_id
from stops 
where mov_number = @mov_number 
	and stops.ord_hdrnumber > 0


-- Loop through the stops and build a list of all the applicable notes for each stop.

select @stpcnt = count(*) from #stop_notes

select @curr_stp = isnull(min(stp_number),0)
from #stop_notes 

Do while @curr_stp > 0
	Begin

		-- Get the loading instructions
		select @note_count = count(*) 
		from notes n join #stop_notes sn on sn.cmp_id = nre_tablekey and ntb_table = 'company'
		where sn.stp_number = @curr_stp
			and (case sn.stp_type
				when 'PUP' then 'LI'
				when 'DRP' then 'DI'
			  end) = n.not_type

		if @note_count > 0
			Begin
				select @min_note = min(not_number),
					@hold = ''
				from notes n join #stop_notes sn on sn.cmp_id = nre_tablekey and ntb_table = 'company'
				where sn.stp_number = @curr_stp
					and (case sn.stp_type
							when 'PUP' then 'LI'
							when 'DRP' then 'DI'
						   end) = n.not_type
		
				While @min_note > 0 
					Begin
						Select @hold = @hold + not_text + Char(13) + Char(10) from notes where not_number = @min_note	

						select @min_note = isnull(min(not_number),0)
						from notes n join #stop_notes sn on sn.cmp_id = nre_tablekey and ntb_table = 'company'
						where sn.stp_number = @curr_stp
							and (case sn.stp_type
									when 'PUP' then 'LI'
									when 'DRP' then 'DI'
								end) = n.not_type
							and not_number > @min_note
					end
	
				update #stop_notes set load_inst = @hold where stp_number = @curr_stp
				

			End
		
		-- Get the Weighing instructions
		select @note_count = count(*) 
		from notes n join #stop_notes sn on sn.cmp_id = nre_tablekey and ntb_table = 'company'
		where sn.stp_number = @curr_stp
			and n.not_type = 'weigh'

		if @note_count > 0
			Begin
				select @min_note = min(not_number),
					@hold = ''
				from notes n join #stop_notes sn on sn.cmp_id = nre_tablekey and ntb_table = 'company'
				where sn.stp_number = @curr_stp
					and n.not_type = 'weigh'
		
				While @min_note > 0 
					Begin
						Select @hold = @hold + not_text + Char(13) + Char(10) from notes where not_number = @min_note	

						select @min_note = isnull(min(not_number),0)
						from notes n join #stop_notes sn on sn.cmp_id = nre_tablekey and ntb_table = 'company'
						where sn.stp_number = @curr_stp
							and n.not_type = 'weigh'
							and not_number > @min_note
					end
	
				update #stop_notes set weigh_inst = @hold where stp_number = @curr_stp

			End
		-- End Weighing instructions.
	


		-- Get the next stop
		select @curr_stp = isnull(min(stp_number),0)
		from #stop_notes 
		where stp_number > @curr_stp

	End




---- Get any Pay already generated for the Trip and the Asset.
--if @asset_type = 'DRV'
--	Begin
--		select @driver = asgn_id
--		from assetassignment
--		where asgn_type = 'DRV'
--			and lgh_number = @lgh_number
--		
--		Select @est_pay = sum(pyd_amount)
--		from paydetail
--		where asgn_type = 'DRV'
--			and asgn_id = @driver
--			and lgh_number = @lgh_number
--
--	End
--Else
--	Begin
--		select @tractor = asgn_id
--		from assetassignment
--		where asgn_type = 'TRC'
--			and lgh_number = @lgh_number
--		
--		Select @est_pay = sum(pyd_amount)
--		from paydetail
--		where asgn_type = 'TRC'
--			and asgn_id = @tractor
--			and lgh_number = @lgh_number
--
--
--	End




Select 	stops.ord_hdrnumber,
	stops.stp_number,
	stops.stp_city stp_city,
	event.evt_startdate arrivaldate,
	event.evt_earlydate earliestdate,
	event.evt_latedate latestdate,
	stops.cmp_id,
	company.cmp_name,
	evt_enddate departuredate,
	stops.stp_reasonlate reasonlate_arrival,
	stops.lgh_number,
	stops.stp_reasonlate_depart reasonlate_depart,
	stops.stp_sequence,
	stops.stp_comment comment, 
	stops.stp_type,
	event.evt_hubmiles hubmiles,
	event.evt_sequence,
	stops.stp_mfh_sequence stp_mfh_sequence,
	orderheader.ord_number, 
	freightdetail.fgt_sequence,
	freightdetail.fgt_number,
	freightdetail.cmd_code,
	freightdetail.fgt_description cmd_description,
	Case evt_sequence when 1 then freightdetail.fgt_weight else 0 end weight,
	freightdetail.fgt_weightunit  weightunit,
	Case evt_sequence when 1 then freightdetail.fgt_count else 0 end cnt,
	freightdetail.fgt_countunit countunit,
	Case evt_sequence when 1 then freightdetail.fgt_volume else 0 end volume,
	freightdetail.fgt_volumeunit volumeunit,
	Case 
		when isNull(freightdetail.fgt_quantity,0) > 0 then freightdetail.fgt_quantity
		when ISNULL(freightdetail.fgt_weight,0) > 0 then  freightdetail.fgt_weight
		when ISNULL(freightdetail.fgt_count,0) > 0 then  freightdetail.fgt_count
		when ISNULL(freightdetail.fgt_volume,0) > 0 then  freightdetail.fgt_volume		
	end quantity,
	Case
		when isNull(freightdetail.fgt_quantity,0) > 0 then freightdetail.fgt_unit 
		when ISNULL(freightdetail.fgt_weight,0) > 0 then  freightdetail.fgt_weightunit
		when ISNULL(freightdetail.fgt_count,0) > 0 then  freightdetail.fgt_countunit
		when ISNULL(freightdetail.fgt_volume,0) > 0 then  freightdetail.fgt_volumeunit		
	end quantityunit,
	freightdetail.fgt_reftype,
	freightdetail.fgt_refnum,
	freightdetail.fgt_ratingunit, 
	commodity.cmd_hazardous,
	commodity.cmd_dot_name,
	commodity.cmd_haz_num,
	commodity.cmd_haz_class,
	(select name from labelfile where labeldefinition = 'CmdHazClass' and abbr = commodity.cmd_haz_class) haz_description,
	event.evt_pu_dr evt_pu_dr,
	event.evt_eventcode eventcode,
	event.evt_status evt_status,
	stops.stp_mfh_mileage mfh_mileage,
	stops.stp_ord_mileage ord_mileage,
	stops.stp_lgh_mileage lgh_mileage,
	stops.mfh_number,
	(select cmp_name
		from company
		where company.cmp_id = orderheader.ord_billto) billto_name,
	city.cty_nmstct cty_nmstct,
	stops.mov_number,
	stops.stp_origschdt,
	stops.stp_paylegpt,
	stops.stp_region1,
	stops.stp_region2,
	stops.stp_region3,
	stops.stp_region4,
	stops.stp_state ,
	stops.stp_zipcode,
	stops.stp_OOA_stop,
	stops.stp_address,
	stops.stp_transfer_stp,
	stops.stp_contact,
	stops.stp_phonenumber2,
	stops.stp_address2,
	IsNull(orderheader.ord_revtype1, '') ord_revtype1,
	orderheader.ord_revtype2,
	orderheader.ord_revtype3,
	orderheader.ord_revtype4,
	'RevType1' ord_revtype1_t,
	'RevType2' ord_revtype2_t,
	'RevType3' ord_revtype3_t,
	'RevType4' ord_revtype4_t,
	freightdetail.fgt_rate,
	freightdetail.fgt_charge,
	freightdetail.fgt_rateunit,
	freightdetail.cht_itemcode,
	company.cmp_address1,
	company.cmp_address2,
	company.cty_nmstct,
	company.cmp_state,
	company.cmp_zip,
	company.cmp_directions,
	company.cmp_primaryphone,
	Case @asset_type
		when 'DRV' then 
			(Select sum(pyd_amount)
			from paydetail
			where asgn_type = 'DRV'
				and asgn_id = event.evt_driver1
				and lgh_number = stops.lgh_number)
		else
			(Select  sum(pyd_amount)
			from paydetail
			where asgn_type = 'TRC'
				and asgn_id = event.evt_tractor
				and lgh_number = stops.lgh_number)
		end projected_pay,
	event.evt_trailer1,
	(select trl_type3 from trailerprofile where trailerprofile.trl_id = event.evt_trailer1) tank_type,
	(select labelfile.name from labelfile where labelfile.labeldefinition = 'TrlType3' and abbr = (select trl_type3 from trailerprofile where trailerprofile.trl_id = event.evt_trailer1)) tank_type_desc,
	(select load_inst from #stop_notes sn where stops.stp_number = sn.stp_number) ld_instructions,
	(select commodity_inst from #stop_notes sn where stops.stp_number = sn.stp_number) commodity_instructions,
	(select requirements from #stop_notes sn where stops.stp_number = sn.stp_number) stp_requirements,
	(select weigh_inst from #stop_notes sn where stops.stp_number = sn.stp_number) weighing_instructions,
	company.cmp_contact,
	stops.stp_schdtearliest,
	stops.stp_schdtlatest,
	event.evt_driver1 driver1,
	event.evt_driver2 driver2,
	event.evt_tractor tractor,
	event.evt_trailer1 trailer1,
	event.evt_trailer2 trailer2,
	legheader.lgh_startdate,
	legheader.lgh_enddate,
	(select cmp_id
		from company
		where company.cmp_id = orderheader.ord_billto) billto_id,
	--(select WindowStart from company_hourswindow where cmp_id = stops.cmp_id and WindowDay = left(datename(dw, stops.stp_arrivaldate),3)) hrs_open,
	--select WindowEnd from company_hourswindow where cmp_id = stops.cmp_id and WindowDay = left(datename(dw, stops.stp_arrivaldate),3)) hrs_close,
	isNull(Case datename(dw, stops.stp_arrivaldate)
		when 'monday' then company.cmp_opens_mo
		when 'tuesday' then company.cmp_opens_tu
		when 'wednesday' then company.cmp_opens_we
		when 'thursday' then company.cmp_opens_th
		when 'friday' then company.cmp_opens_fr
		when 'saturday' then company.cmp_opens_sa
		when 'sunday' then company.cmp_opens_su
	End,0) hrs_open,
	isNull(Case datename(dw, stops.stp_arrivaldate)
		when 'monday' then company.cmp_closes_mo
		when 'tuesday' then company.cmp_closes_tu
		when 'wednesday' then company.cmp_closes_we
		when 'thursday' then company.cmp_closes_th
		when 'friday' then company.cmp_closes_fr
		when 'saturday' then company.cmp_closes_sa
		when 'sunday' then company.cmp_closes_su
	End,0) hrs_close,
	(select mpp_actg_type from manpowerprofile where event.evt_driver1 = manpowerprofile.mpp_id) driver_act_type,
	event.evt_carrier carrier,
	(select Rtrim(city.cty_name) from city where city.cty_code = company.cmp_city) city_name,
	legheader.lgh_chassis,
	legheader.lgh_chassis2,
	orderheader.ord_bookedby,
	legheader.lgh_carrier,
	(select car_name from carrier where car_id = legheader.lgh_carrier) carrier_name,
	(select isNull(usr_fname,'') + ' ' + isnull(usr_lname,'') from ttsusers where usr_userid = orderheader.ord_bookedby) booked_name,
	orderheader.trl_type1 tank_type1,
	(select labelfile.name from labelfile where labelfile.labeldefinition = 'TrlType1' and abbr = orderheader.trl_type1) tank_type1_desc,
	legheader.lgh_trailer3,
	legheader.lgh_trailer4,
	legheader.lgh_dolly,
	legheader.lgh_dolly2
FROM stops
    join legheader on stops.lgh_number = legheader.lgh_number
    left outer join city on stops.stp_city = city.cty_code
	join event on stops.stp_number = event.stp_number and event.evt_sequence = 1
    join freightdetail on  stops.stp_number = freightdetail.stp_number
    join eventcodetable on event.evt_eventcode = eventcodetable.abbr
	left outer join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
    left outer join company on stops.cmp_id = company.cmp_id
	left outer join commodity on freightdetail.cmd_code = commodity.cmd_code
WHERE stops.mov_number = @mov_number
	and stops.ord_hdrnumber > 0
order by stp_mfh_sequence



GO
GRANT EXECUTE ON  [dbo].[d_tripfolder_report_13_sp] TO [public]
GO
