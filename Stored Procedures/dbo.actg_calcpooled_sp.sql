SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[actg_calcpooled_sp]
	@p_ivh_hdrnumber int,
	@p_ord_hdrnumber int,
	@p_chargeroundoff int,
	@p_rateroundoff int,
	@ivh_curcode varchar (6)

as
set nocount on 
--sett nocount off 

declare @total_pooled_charges as decimal (18,6)
declare @total_charges as decimal (18,6)
declare @total_rate_charge as decimal (18,6)
declare @total_rate_charge2 as decimal (18,6)
declare @total_running_charge as decimal (18,6)
declare @total_running_charge2 as decimal (18,6)
declare @min_id as integer
declare @min_thr_processing_sequence as int
declare @min_thr_id as int
declare @fail as int
declare @rule_found as int
declare @count as int
declare @ret as int
declare @lane_lgh_number as int

declare	@tkr_drop_stop as varchar (6)
declare	@tkr_pickup_stop as varchar (6)
declare	@tkr_split_first_segment_origin as varchar (8)
declare	@tkr_split_first_segment_dest as varchar (8)
declare	@tkr_eventcode as varchar (6)
declare	@tkr_event_loadstatus as varchar (3)
declare @cht_itemcode as varchar (6)
declare @thr_rate as money
declare @cht_unit as varchar (6)
declare @cht_basisunit as varchar (6)
declare @cht_rateunit as varchar (6)
declare @cht_glnum as varchar (32)
declare @cht_currunit as varchar (6)

declare @ord_revtype1 as varchar (6)
declare @ord_revtype2 as varchar (6)
declare @ord_revtype3 as varchar (6)
declare @ord_revtype4 as varchar (6)
declare @ord_completiondate as datetime --PTS 32559 CGK 6/15/2006

declare @p_alloc_sequence as integer 

declare @tkr_id as integer  --PTS 32559 CGK 6/15/2006
declare @tkr_startdate as datetime --PTS 32559 CGK 6/15/2006
declare @tkr_enddate as datetime --PTS 32559 CGK 6/15/2006

declare @lgh_count as integer
declare @converstion_rate as float

CREATE TABLE #workrevallocpooled (
	id integer identity (1, 1),
	sp_id integer NULL,
	ivh_number integer NULL,           -- The invoiceheader for which this proration detail exists.
        ivd_number integer NULL,           -- The invoicedetail for which this proration detail exists (NULL for pooled).
	lgh_number integer NULL,           -- A representative legheader of those for which this proration detail was cut.
	thr_id integer NULL,               -- The tariffheaderrevall record for which this proration detail was cut (if any, typically only present on Pooled).
        ral_proratequantity money NULL,    -- The quantity that this portion of the proration was based on.
        ral_totalprorates money NULL,      -- The total quantity for this proration rule.
        ral_rate money NULL,               -- The prorated rate of the invoice detail.
	ral_amount money NULL,             -- The prorated amount of this invoice detail.
	cur_code varchar (6) NULL,         -- The currency of this particular proration detail.
	ral_conversion_rate money NULL,    -- The conversion rate from the invoiceheader currency to this record's currency as of the time this record was cut.
	cht_itemcode varchar (6) NULL,     -- The final chargetype of this proration detail.
        ral_sequence int NULL,             -- The sequence in which these proration details should appear.
	ral_converted_rate money NULL,     -- The effective invoicedetail rate after dealing with proration and currency conversions.
	ral_converted_amount money NULL,   -- The final amount after converting this prorated line to the specified currency code (and dealing with round offs).
	ral_glnum varchar (32) NULL,       -- The gl number for this proration detail.
	ral_prorateitem varchar (30) NULL)  -- Alows from alocations for things that are not numeric

--PTS 34889 CGK 10/27/2006 Remove Temp Tables since causing a recompile
delete from actg_temp_orderstops where sp_id = @@spid
-- CREATE TABLE actg_temp_orderstops (
-- 	ord_hdrnumber integer NULL,
-- 	stp_number integer NULL,
-- 	mov_number integer NULL,
-- 	lgh_number integer NULL,
-- 	stp_ord_mileage integer NULL,
-- 	stp_type varchar (6) NULL,
-- 	stp_loadstatus varchar (3) NULL,
-- 	stp_sequence integer NULL,
-- 	cmp_id varchar (8) NULL,
-- 	stp_event varchar (6) NULL,
-- 	evt_eventcode varchar (6) NULL,
-- 	evt_sequence integer NULL)

--PTS 34889 CGK 10/27/2006 Remove Temp Tables since causing a recompile
delete from actg_temp_stoplist where sp_id = @@spid
-- CREATE TABLE actg_temp_stoplist (
-- 	ord_hdrnumber integer NULL,
-- 	stp_number integer NULL,           
-- 	lgh_number integer NULL,
-- 	evt_sequence integer NULL)

--PTS 34889 CGK 10/27/2006 Remove Temp Tables since causing a recompile
delete from actg_temp_stoplist where sp_id = @@spid
-- CREATE TABLE actg_temp_tempstoplist (
-- 	ord_hdrnumber integer NULL,
-- 	stp_number integer NULL,           
-- 	lgh_number integer NULL,
-- 	evt_sequence integer NULL)

--PTS 34889 CGK 10/27/2006 Remove Temp Tables since causing a recompile
delete from actg_temp_legcount where sp_id = @@spid
-- CREATE TABLE actg_temp_legcount (          
-- 	lgh_number integer NULL,
-- 	occurrences integer NULL)


select @total_charges = Sum (ral_amount) 
from actg_temp_workrevalloc
where ral_amount is not null
and sp_id = @@spid

IF IsNull (@total_charges, 0) = 0  Begin
	Return
End

select @total_pooled_charges = Sum (ral_amount) 
from actg_temp_workrevalloc
where sp_id = @@spid 
and cht_itemcode = 'POOLED'
and ral_amount is not null

SELECT @total_pooled_charges = IsNull (@total_pooled_charges, 0)

IF IsNull (@total_pooled_charges, 0) = 0  Begin
	Return
End

select @total_running_charge = 0

delete from actg_temp_workrevalloc where sp_id = @@spid and cht_itemcode = 'POOLED'

insert into actg_temp_orderstops
select @@spid, stops.ord_hdrnumber, stops.stp_number, stops.mov_number, lgh_number, stp_ord_mileage, stp_type, stp_loadstatus, stp_sequence, cmp_id, stp_event, evt_eventcode, evt_sequence
from stops, event 
where stops.stp_number = event.stp_number
/*and stp_event <> 'XDL' and stp_event <> 'XDU' PTS 37504 CGK 5/17/2007*/
and stops.mov_number in (select distinct mov_number from stops where ord_hdrnumber = @p_ord_hdrnumber)
and stops.ord_hdrnumber in (0, @p_ord_hdrnumber)
-- Used in validation rules below
select @ord_revtype1 = ord_revtype1, @ord_revtype2 = ord_revtype2, @ord_revtype3 = ord_revtype3, @ord_revtype4 = ord_revtype4, @ord_completiondate = ord_completiondate
from orderheader where ord_hdrnumber = @p_ord_hdrnumber

select @ord_revtype1 = IsNull (@ord_revtype1, 'UNK')
select @ord_revtype2 = IsNull (@ord_revtype2, 'UNK')
select @ord_revtype3 = IsNull (@ord_revtype3, 'UNK')
select @ord_revtype4 = IsNull (@ord_revtype4, 'UNK')
select @ord_completiondate = IsNull (@ord_completiondate, '19500101')

--Find first rule
SELECT @min_thr_processing_sequence = Min (thr_processing_sequence) FROM tariffheaderrevall WHERE thr_processing_sequence IS NOT NULL

WHILE (IsNULL (@min_thr_processing_sequence, -999999999) > -999999999)
BEGIN
	
	select @min_thr_id = Min (thr_id) from tariffheaderrevall where thr_processing_sequence = @min_thr_processing_sequence and thr_id IS NOT NULL
	WHILE (IsNull (@min_thr_id, 0) > 0)
	BEGIN
		select @fail = 0
		select @rule_found = 0
		
		SELECT @cht_itemcode = t.cht_itemcode,
		       @thr_rate = t.thr_rate,
		       @cht_unit = c.cht_unit,
		       @cht_basisunit = c.cht_basisunit,
		       @cht_rateunit = c.cht_rateunit,
		       @cht_glnum = c.cht_glnum,
		       @cht_currunit = c.cht_currunit  /*PTS 32559 CGK 6/19/2006*/
		FROM tariffheaderrevall t, chargetype c
		WHERE t.cht_itemcode = c.cht_itemcode
		AND t.thr_id = @min_thr_id	
		
		SELECT	@tkr_drop_stop = tkr_drop_stop, 
			@tkr_pickup_stop = tkr_pickup_stop, 
			@tkr_split_first_segment_origin = tkr_split_first_segment_origin, 
			@tkr_split_first_segment_dest = tkr_split_first_segment_dest, 
			@tkr_eventcode = tkr_eventcode, 
			@tkr_event_loadstatus = tkr_event_loadstatus,
			@tkr_id = tkr_id, /*PTS 32559 CGK 6/15/2006*/
			@tkr_startdate = tkr_startdate, /*PTS 32559 CGK 6/15/2006*/
			@tkr_enddate = tkr_enddate /*PTS 32559 CGK 6/15/2006*/
		FROM tariffkeyrevall
		WHERE thr_id = @min_thr_id				

		IF @cht_itemcode = NULL Begin
			select @fail = 1
		End
		
		delete from actg_temp_tempstoplist where sp_id = @@spid
		delete from actg_temp_stoplist where sp_id = @@spid
		delete from #workrevallocpooled
		delete from actg_temp_legcount where sp_id = @@spid

-- PTS 32559 CGK 6/15/2006
		--Effective Start Date Check
		SELECT @tkr_startdate = IsNull (@tkr_startdate, '19500101')
		SELECT @tkr_enddate = IsNull (@tkr_enddate, '20500101')

		IF @ord_completiondate < @tkr_startdate OR @ord_completiondate >= @tkr_enddate
		Begin
		--	Print 'Fail Effective Start Check'
			select @fail = 1
		End

		select @ivh_curcode = IsNull (@ivh_curcode, 'US$')
		select @cht_currunit = IsNull (@cht_currunit, @ivh_curcode)
		
-- 		Print '@cht_currunit = ' + @cht_currunit
-- 		Print '@ivh_curcode = ' + @ivh_curcode
		
		-- No need to conver revenue based rates since by definition they are in the currency of the invoice
		IF @cht_unit <> 'USD' OR @cht_basisunit <> 'REV' OR @cht_rateunit <> 'USUS' Begin
		
			IF @cht_currunit <> @ivh_curcode Begin
				     
				exec s_get_exchangerate_2 @cht_currunit ,@ivh_curcode ,@ord_completiondate ,@converstion_rate OUT 
	--			print '@converstion_rate = ' + Cast (@converstion_rate as varchar)
	--			print 'Unconverted @thr_rate = ' + Cast (@thr_rate as varchar)
				IF @converstion_rate > Cast (0 as float) Begin
					select @thr_rate = @thr_rate * Cast (@converstion_rate as decimal (11,2))
	--				print 'Converted @thr_rate = ' + Cast (@thr_rate as varchar)
				End
			End
		End

		IF @fail = 0 Begin
			select @count = 0
			select @count = count (*) from tariffkeyrevall_codes where tkc_type = 'RevType1' AND tkr_id = @tkr_id
			IF @count > 0 Begin
				select @count = 0
				select @count = count (*) from tariffkeyrevall_codes where tkc_type = 'RevType1' AND tkc_code = @ord_revtype1 AND tkr_id = @tkr_id
				IF IsNull (@count, 0) = 0 Begin
					select @fail=1
				End
			End
		End
		
		IF @fail = 0 Begin
			select @count = 0
			select @count = count (*) from tariffkeyrevall_codes where tkc_type = 'RevType2' AND tkr_id = @tkr_id
			IF @count > 0 Begin
				select @count = 0
				select @count = count (*) from tariffkeyrevall_codes where tkc_type = 'RevType2' AND tkc_code = @ord_revtype2 AND tkr_id = @tkr_id
				IF IsNull (@count, 0) = 0 Begin
					select @fail=1
				End
			End
		End

		IF @fail = 0 Begin
			select @count = 0
			select @count = count (*) from tariffkeyrevall_codes where tkc_type = 'RevType3' AND tkr_id = @tkr_id
--			print 'Rev3 @count1 = ' + Cast (@count as varchar)
			IF @count > 0 Begin
				select @count = 0
				select @count = count (*) from tariffkeyrevall_codes where tkc_type = 'RevType3' AND tkc_code = @ord_revtype3 AND tkr_id = @tkr_id
				IF IsNull (@count, 0) = 0 Begin
					select @fail=1
				End
--				print 'Rev3 @count2 = ' + Cast (@count as varchar)
			End
		End
		
		If @fail = 0 Begin
			select @count = 0
			select @count = count (*) from tariffkeyrevall_codes where tkc_type = 'RevType4' AND tkr_id = @tkr_id
			IF @count > 0 Begin
				select @count = 0
				select @count = count (*) from tariffkeyrevall_codes where tkc_type = 'RevType4' AND tkc_code = @ord_revtype4 AND tkr_id = @tkr_id
				IF IsNull (@count, 0) = 0 Begin
					select @fail=1
				End
			End
		End
		--Check the Order Revenue Type1 rule
--		IF IsNull (@tkr_ord_revtype1, 'UNK') <> 'UNK' AND @tkr_ord_revtype1 <> '' And IsNull (@tkr_ord_revtype1, 'UNK') <> @ord_revtype1 Begin
--			select @fail = 1
--		End
-- 
-- 		--Check the Order Revenue Type2 rule
-- 		IF IsNull (@tkr_ord_revtype2, 'UNK') <> 'UNK' AND @tkr_ord_revtype2 <> '' And IsNull (@tkr_ord_revtype2, 'UNK') <> @ord_revtype2 Begin
-- 			select @fail = 1
-- 		End
-- 
-- 		--Check the Order Revenue Type3 rule
-- 		IF IsNull (@tkr_ord_revtype3, 'UNK') <> 'UNK' AND @tkr_ord_revtype3 <> '' And IsNull (@tkr_ord_revtype3, 'UNK') <> @ord_revtype3 Begin
-- 			select @fail = 1
-- 		End
-- 
-- 		--Check the Order Revenue Type4 rule
-- 		IF IsNull (@tkr_ord_revtype4, 'UNK') <> 'UNK' AND @tkr_ord_revtype4 <> '' And IsNull (@tkr_ord_revtype4, 'UNK') <> @ord_revtype4 Begin
-- 			select @fail = 1
-- 		End			
			
-- 		Print '@cht_unit = '  + @cht_unit
-- 		Print '@cht_basisunit = '  + @cht_basisunit
-- 		Print '@cht_rateunit = '  + @cht_rateunit
--END PTS 32559 CGK 6/15/2006

		--Analyze the stop based rules
		IF @cht_unit = 'STOP' AND @cht_basisunit = 'STOP' AND @cht_rateunit = 'STOP' AND @fail = 0 Begin
--			Print '@cht_itemcode = '  + @cht_itemcode			
			select @rule_found = 1
			exec actg_calcpooled_stoplist_sp @p_ord_hdrnumber, @tkr_drop_stop, @tkr_pickup_stop, @tkr_eventcode, @tkr_event_loadstatus
			
--			select * from #stoplist

			select @count = count (*) from actg_temp_stoplist where sp_id = @@spid and evt_sequence = 1 
-- 			Print '@tkr_id = ' + cast (@tkr_id as varchar )
-- 			Print 'Stop List @count = ' + cast (@count as varchar )
			IF IsNull (@count, 0) = 0 Begin
				Select @fail = 1
			End
			Else Begin
				select @fail = 0
			End 
			
			--Validate Lanes
			IF @fail = 0 Begin
				exec dbo.actg_calcpooled_lane_validation_sp @p_ord_hdrnumber, /*PTS 37504 */
									@tkr_split_first_segment_origin, 
									@tkr_split_first_segment_dest,
									@tkr_id,
									@ret out

--				Print '@tkr_id = ' + cast (@tkr_id as varchar )
--				Print '@ret = ' + cast (@ret as varchar )
				IF @ret < 0 Begin
					select @fail = 1
				End
				
				IF @ret > 0 Begin
--					select @count = count (*) from #legcount where lgh_number = 4818
--					Print 'Leg Count @count = ' + cast (@count as varchar )

					Delete from actg_temp_stoplist where sp_id = @@spid and lgh_number NOT IN (select lgh_number from actg_temp_legcount where sp_id = @@spid)

					select @count = count (*) from actg_temp_stoplist where sp_id = @@spid and evt_sequence = 1
					IF IsNull (@count, 0) = 0 Begin
						Select @fail = 1
					End
					Else Begin
						select @fail = 0
					End 

				End 						
			End
			IF @fail = 0 Begin

				INSERT #workrevallocpooled (ivh_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_glnum)
				SELECT @p_ivh_hdrnumber, lgh_number, @min_thr_id, count (*), count (*), @thr_rate, @thr_rate * count (*), @ivh_curcode, 1, @cht_itemcode, @cht_glnum
				FROM actg_temp_stoplist where sp_id = @@spid and evt_sequence = 1 and ord_hdrnumber = @p_ord_hdrnumber
				group by lgh_number
				
--				select * from #workrevallocpooled			

				select @total_rate_charge = sum (ral_amount) from #workrevallocpooled where ral_amount is not null
				select @total_rate_charge = IsNull (@total_rate_charge, 0)
-- 				print '@total_rate_charge = ' + Cast (@total_rate_charge as varchar)
-- 				print '@total_running_charge = ' + Cast (@total_running_charge as varchar)

				IF @total_pooled_charges - (@total_running_charge + @total_rate_charge) < 0 Begin
					select @min_id = min (id) from #workrevallocpooled where id IS NOT NULL

					While IsNull (@min_id, 0) > 0  Begin
						select @total_rate_charge2 = ral_amount from #workrevallocpooled where id = @min_id
						select @total_rate_charge2 = IsNull (@total_rate_charge, 0)
						
						select @total_running_charge2 = @total_pooled_charges - (@total_running_charge + @total_rate_charge2)
-- 						print '@total_running_charge2 = ' + Cast (@total_running_charge2 as varchar)
						IF  @total_running_charge2 < 0 Begin
							--select @total_rate_charge2 = @total_rate_charge2 - @total_running_charge2
							select @total_rate_charge2 = @total_pooled_charges - @total_running_charge
-- 							print '@total_rate_charge2 = ' + Cast (@total_rate_charge2 as varchar) 
							update #workrevallocpooled set ral_amount = @total_rate_charge2 where id = @min_id
							delete from #workrevallocpooled where id > @min_id
							select @min_id = 0
							select @total_running_charge = @total_pooled_charges
						End
						Else Begin
							select @total_running_charge = @total_running_charge +  @total_rate_charge2				
							select @min_id = min (id) from #workrevallocpooled where id > @min_id
						End					


					End
				End
				Else Begin
					select @total_running_charge = @total_running_charge + @total_rate_charge					
				End

				

				INSERT actg_temp_workrevalloc (sp_id, ivh_number, ivd_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_sequence, ral_converted_rate, ral_converted_amount, ral_glnum)
				SELECT @@spid, ivh_number, NULL, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, NULL, NULL, NULL, ral_glnum from #workrevallocpooled
			
-- 			        INSERT #workrevalloc (ivh_number, ivd_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_sequence, ral_converted_rate, ral_converted_amount, ral_glnum)
-- 				SELECT @p_ivh_hdrnumber, NULL, lgh_number, @min_thr_id, 1, 1, @thr_rate, @thr_rate * count (*), @ivh_curcode, NULL, @cht_itemcode, NULL, NULL, NULL, @cht_glnum
-- 				FROM #stoplist where evt_sequence = 1
-- 				group by lgh_number
			        --EXEC dbo.actg_calc_one_prorate_sp @p_chargeroundoff, @p_rateroundoff, @p_ivh_hdrnumber, @ivh_ordhdrnum, @ivh_curcode, NULL, @ivd_lghnum, @ivd_rate, @ivd_amount, @ivd_glnum, @cht_itemcode, @p_alloc_sequence OUT
			End
		End
			

		--Analyze the Event based rules
		IF @cht_unit = 'EVT' AND @cht_basisunit = 'EVT' AND @cht_rateunit = 'EVT' AND @fail = 0 Begin

			select @rule_found = 1
			exec actg_calcpooled_stoplist_sp @p_ord_hdrnumber, @tkr_drop_stop, @tkr_pickup_stop, @tkr_eventcode, @tkr_event_loadstatus
			
			select @count = count (*) from actg_temp_stoplist where sp_id = @@spid
			IF IsNull (@count, 0) = 0 Begin
				Select @fail = 1
			End
			Else Begin
				select @fail = 0
			End 
			
			--Validate Lanes
			IF @fail = 0 Begin
				exec dbo.actg_calcpooled_lane_validation_sp @p_ord_hdrnumber, /*PTS 37504 */
									@tkr_split_first_segment_origin, 
									@tkr_split_first_segment_dest,
									@tkr_id,
									@ret out

				IF @ret < 0 Begin
					select @fail = 1
				End
				
				IF @ret > 0 Begin
					Delete from actg_temp_stoplist where sp_id = @@spid and lgh_number NOT IN (select lgh_number from actg_temp_legcount where sp_id = @@spid)

					select @count = count (*) from actg_temp_stoplist where sp_id = @@spid and evt_sequence = 1
					IF IsNull (@count, 0) = 0 Begin
						Select @fail = 1
					End
					Else Begin
						select @fail = 0
					End 
				End 						
			End
			IF @fail = 0 Begin

				INSERT #workrevallocpooled (ivh_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_glnum)
				SELECT @p_ivh_hdrnumber, lgh_number, @min_thr_id, count (*), count (*), @thr_rate, @thr_rate * count (*), @ivh_curcode, 1, @cht_itemcode, @cht_glnum
				FROM actg_temp_stoplist
				WHERE sp_id = @@spid
				group by lgh_number

				select @total_rate_charge = sum (ral_amount) from #workrevallocpooled where ral_amount is not null
				select @total_rate_charge = IsNull (@total_rate_charge, 0)
-- 				print '@total_rate_charge = ' + Cast (@total_rate_charge as varchar)
-- 				print '@total_running_charge = ' + Cast (@total_running_charge as varchar)

				IF @total_pooled_charges - (@total_running_charge + @total_rate_charge) < 0 Begin
					select @min_id = min (id) from #workrevallocpooled where id IS NOT NULL

					While IsNull (@min_id, 0) > 0  Begin
						select @total_rate_charge2 = ral_amount from #workrevallocpooled where id = @min_id
						select @total_rate_charge2 = IsNull (@total_rate_charge, 0)
						
						select @total_running_charge2 = @total_pooled_charges - (@total_running_charge + @total_rate_charge2)
-- 						print '@total_running_charge2 = ' + Cast (@total_running_charge2 as varchar)
						IF  @total_running_charge2 < 0 Begin
							--select @total_rate_charge2 = @total_rate_charge2 - @total_running_charge2
							select @total_rate_charge2 = @total_pooled_charges - @total_running_charge
-- 							print '@total_rate_charge2 = ' + Cast (@total_rate_charge2 as varchar) 
							update #workrevallocpooled set ral_amount = @total_rate_charge2 where id = @min_id
							delete from #workrevallocpooled where id > @min_id
							select @min_id = 0
							select @total_running_charge = @total_pooled_charges
						End
						Else Begin
							select @total_running_charge = @total_running_charge +  @total_rate_charge2				
							select @min_id = min (id) from #workrevallocpooled where id > @min_id
						End					


					End
				End
				Else Begin
					select @total_running_charge = @total_running_charge + @total_rate_charge					
				End

				

				INSERT actg_temp_workrevalloc (sp_id, ivh_number, ivd_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_sequence, ral_converted_rate, ral_converted_amount, ral_glnum)
				SELECT @@spid, ivh_number, NULL, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, NULL, NULL, NULL, ral_glnum from #workrevallocpooled
			
			End
		End


		--Analyze Revenue Based Rules
		IF @cht_unit = 'USD' AND @cht_basisunit = 'REV' AND @cht_rateunit = 'USUS' AND @fail = 0 Begin

--  			Print '@cht_itemcode = '  + @cht_itemcode
			select @rule_found = 1
			exec actg_calcpooled_stoplist_sp @p_ord_hdrnumber, @tkr_drop_stop, @tkr_pickup_stop, @tkr_eventcode, @tkr_event_loadstatus
			
			select @count = count (*) from actg_temp_stoplist where sp_id = @@spid and evt_sequence = 1
			IF IsNull (@count, 0) = 0 Begin
				Select @fail = 1
			End
			Else Begin
				select @fail = 0
			End 
			
			--Validate Lanes
			IF @fail = 0 Begin
				exec dbo.actg_calcpooled_lane_validation_sp @p_ord_hdrnumber, /*PTS 37504 */
									@tkr_split_first_segment_origin, 
									@tkr_split_first_segment_dest,
									@tkr_id,
									@ret out

				IF @ret < 0 Begin
					select @fail = 1
				End
				
				IF @ret > 0 Begin
					Delete from actg_temp_stoplist where sp_id = @@spid and lgh_number NOT IN (select lgh_number from actg_temp_legcount where sp_id = @@spid)

					select @count = count (*) from actg_temp_stoplist where sp_id = @@spid and evt_sequence = 1
					IF IsNull (@count, 0) = 0 Begin
						Select @fail = 1
					End
					Else Begin
						select @fail = 0
					End 
				End 						
			End
			IF @fail = 0 Begin
				--PTS 34803 CGK 10/16/2006 only use the amount in the pool for this calculation.
				select @total_rate_charge = @thr_rate * (@total_pooled_charges - @total_running_charge)
--				select @total_rate_charge = @thr_rate * @total_charges
-- 				print '@total_rate_charge 1 = ' + Cast (@total_rate_charge as varchar)

				IF @total_pooled_charges - (@total_running_charge + @total_rate_charge) < 0 Begin
					select @total_rate_charge = @total_pooled_charges - @total_running_charge
				End

-- 				print '@total_rate_charge 2 = ' + Cast (@total_rate_charge as varchar)				
				INSERT #workrevallocpooled (sp_id, ivh_number, ivd_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_sequence, ral_converted_rate, ral_converted_amount, ral_glnum, ral_prorateitem)
			        EXEC dbo.actg_calc_one_prorate_sp @p_chargeroundoff, @p_rateroundoff, @p_ivh_hdrnumber, @p_ord_hdrnumber, @ivh_curcode, NULL, NULL, @thr_rate, @total_rate_charge, @cht_glnum, @cht_itemcode, @p_alloc_sequence OUT
				
--				select * from #workrevallocpooled				

				delete from #workrevallocpooled where lgh_number not in (select distinct lgh_number from actg_temp_stoplist where sp_id = @@spid)
				update #workrevallocpooled set thr_id = @min_thr_id	

--				select * from #workrevallocpooled				


				select @total_rate_charge = sum (ral_amount) from #workrevallocpooled where ral_amount is not null
				select @total_rate_charge = IsNull (@total_rate_charge, 0)
--  				print '@total_rate_charge 3 = ' + Cast (@total_rate_charge as varchar)
--  				print '@total_running_charge = ' + Cast (@total_running_charge as varchar)
-- 				print '@total_pooled_charges = ' + Cast (@total_pooled_charges as varchar)
-- 				print '@total_pooled_charges - (@total_running_charge + @total_rate_charge = ' + Cast ((@total_pooled_charges - (@total_running_charge + @total_rate_charge)) as varchar)	
				IF @total_pooled_charges - (@total_running_charge + @total_rate_charge) < 0 Begin
					select @min_id = min (id) from #workrevallocpooled WHERE id IS NOT NULL
					
					While IsNull (@min_id, 0) > 0  Begin
						select @total_rate_charge2 = ral_amount from #workrevallocpooled where id = @min_id
						select @total_rate_charge2 = IsNull (@total_rate_charge, 0)
						
						select @total_running_charge2 = @total_pooled_charges - (@total_running_charge + @total_rate_charge2)
--  						print '@total_running_charge2 = ' + Cast (@total_running_charge2 as varchar)
						IF  @total_running_charge2 < 0 Begin
							--select @total_rate_charge2 = @total_rate_charge2 - @total_running_charge2
							select @total_rate_charge2 = @total_pooled_charges - @total_running_charge
--  							print '@total_rate_charge2 = ' + Cast (@total_rate_charge2 as varchar) 
							update #workrevallocpooled set ral_amount = @total_rate_charge2 where id = @min_id
							delete from #workrevallocpooled where id > @min_id
							select @min_id = 0
							select @total_running_charge = @total_pooled_charges
						End
						Else Begin
							select @total_running_charge = @total_running_charge +  @total_rate_charge2				
							select @min_id = min (id) from #workrevallocpooled where id > @min_id
						End					


					End
				End
				Else Begin
					select @total_running_charge = @total_running_charge + @total_rate_charge					
				End

				

				INSERT actg_temp_workrevalloc (sp_id, ivh_number, ivd_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_sequence, ral_converted_rate, ral_converted_amount, ral_glnum)
				SELECT @@spid, ivh_number, NULL, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, NULL, NULL, NULL, ral_glnum from #workrevallocpooled

--				select * from #workrevalloc
			End
		End

		--Analyze Flat Based Rules
		IF @rule_found = 0 AND @fail = 0 Begin
			select @lgh_count = 0
--			Print 'In Flat'
			exec actg_calcpooled_stoplist_sp @p_ord_hdrnumber, @tkr_drop_stop, @tkr_pickup_stop, @tkr_eventcode, @tkr_event_loadstatus
			
			select @count = count (*) from actg_temp_stoplist where sp_id = @@spid and evt_sequence = 1
			IF IsNull (@count, 0) = 0 Begin
				Select @fail = 1
			End
			Else Begin
				select @fail = 0
			End 
			
			--Validate Lanes
			IF @fail = 0 Begin
-- 				Print '@tkr_split_first_segment_origin = ' + @tkr_split_first_segment_origin
-- 				Print '@tkr_split_first_segment_dest = ' + @tkr_split_first_segment_dest

				exec dbo.actg_calcpooled_lane_validation_sp @p_ord_hdrnumber, /*PTS 37504 */
									@tkr_split_first_segment_origin, 
									@tkr_split_first_segment_dest,
									@tkr_id,
									@ret out

-- 				Print '@lane_lgh_number = ' + Cast (IsNull (@lane_lgh_number, -1) as varchar)
-- 				Print '@ret = ' + Cast (@ret as varchar)
				IF @ret < 0 Begin
					select @fail = 1
				End
				
--				Print 'Lane Validation @ret = ' + Cast (@ret as varchar)
				IF @ret > 0 Begin
					
					Delete from actg_temp_legcount where sp_id = @@spid and lgh_number NOT IN (select lgh_number from actg_temp_stoplist where sp_id = @@spid)

					select @lgh_count = count (*) from actg_temp_legcount where sp_id = @@spid
					IF IsNull (@lgh_count, 0) = 0 Begin
						Select @fail = 1
					End
					Else Begin
						select @fail = 0
					End 

				End 						
			End
-- 			Print '@fail = ' + Cast (@fail as varchar)
			IF @fail = 0 Begin
				IF IsNull (@lgh_count, 0) > 0
					INSERT #workrevallocpooled (ivh_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_glnum)
					SELECT @p_ivh_hdrnumber, lgh_number, @min_thr_id, 1, 1, @thr_rate, @thr_rate * Sum (IsNull(occurrences,0)), @ivh_curcode, 1, @cht_itemcode, @cht_glnum
					FROM actg_temp_legcount
					WHERE sp_id = @@spid
					group by lgh_number
				Else Begin
					select @lane_lgh_number = max (lgh_number) from actg_temp_stoplist where sp_id = @@spid and lgh_number IS NOT NULL

					INSERT #workrevallocpooled (ivh_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_glnum)
					SELECT @p_ivh_hdrnumber, @lane_lgh_number, @min_thr_id, 1, 1, @thr_rate, @thr_rate , @ivh_curcode, 1, @cht_itemcode, @cht_glnum
				End


				select @total_rate_charge = sum (ral_amount) from #workrevallocpooled where ral_amount is not null
				select @total_rate_charge = IsNull (@total_rate_charge, 0)
-- 				print '@total_rate_charge = ' + Cast (@total_rate_charge as varchar)
-- 				print '@total_running_charge = ' + Cast (@total_running_charge as varchar)

				IF @total_pooled_charges - (@total_running_charge + @total_rate_charge) < 0 Begin
					select @min_id = min (id) from #workrevallocpooled WHERE id is not null

					While IsNull (@min_id, 0) > 0  Begin
						select @total_rate_charge2 = ral_amount from #workrevallocpooled where id = @min_id
						select @total_rate_charge2 = IsNull (@total_rate_charge, 0)
						
						select @total_running_charge2 = @total_pooled_charges - (@total_running_charge + @total_rate_charge2)
-- 						print '@total_running_charge2 = ' + Cast (@total_running_charge2 as varchar)
						IF  @total_running_charge2 < 0 Begin
							--select @total_rate_charge2 = @total_rate_charge2 - @total_running_charge2
							select @total_rate_charge2 = @total_pooled_charges - @total_running_charge
-- 							print '@total_rate_charge2 = ' + Cast (@total_rate_charge2 as varchar) 
							update #workrevallocpooled set ral_amount = @total_rate_charge2 where id = @min_id
							delete from #workrevallocpooled where id > @min_id
							select @min_id = 0
							select @total_running_charge = @total_pooled_charges
						End
						Else Begin
							select @total_running_charge = @total_running_charge +  @total_rate_charge2				
							select @min_id = min (id) from #workrevallocpooled where id > @min_id
						End					


					End
				End
				Else Begin
					select @total_running_charge = @total_running_charge + @total_rate_charge					
				End

				INSERT actg_temp_workrevalloc (sp_id, ivh_number, ivd_number, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, ral_sequence, ral_converted_rate, ral_converted_amount, ral_glnum)
				SELECT @@spid, ivh_number, NULL, lgh_number, thr_id, ral_proratequantity, ral_totalprorates, ral_rate, ral_amount, cur_code, ral_conversion_rate, cht_itemcode, NULL, NULL, NULL, ral_glnum from #workrevallocpooled
			End
		End

		delete from actg_temp_excludedlegs where sp_id = @@spid
		INSERT INTO actg_temp_excludedlegs
			select distinct @@spid, lgh_number from actg_temp_workrevalloc, tariffheaderrevall where actg_temp_workrevalloc.thr_id =  tariffheaderrevall.thr_id and actg_temp_workrevalloc.sp_id = @@spid and tariffheaderrevall.thr_prevent_chrg_flag = 'Y'
	
		select @min_thr_id = Min (thr_id) from tariffheaderrevall where thr_processing_sequence = @min_thr_processing_sequence and thr_id > @min_thr_id	
	END
    	SELECT @min_thr_processing_sequence = MIN(thr_processing_sequence) from tariffheaderrevall where thr_processing_sequence > @min_thr_processing_sequence

			

END
--pts 34689 kpm 10/5/06
--delete from #workrevalloc where thr_id > 0 and ral_amount = 0

-- IF @total_running_charge <> @total_pooled_charges Begin
-- 	RAISERROR ('Charges created from the Invoice Allocation Rules do not add up to the total charges in the in pool for invoice %d.  Please setup a percent based Invoice Allocation Rule to allocate the remaining quantity.', 18, 1, @p_ivh_hdrnumber)
-- 	Return
-- End

GO
GRANT EXECUTE ON  [dbo].[actg_calcpooled_sp] TO [public]
GO
