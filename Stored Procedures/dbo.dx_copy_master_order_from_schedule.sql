SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[dx_copy_master_order_from_schedule]
	@masterorder varchar(12),
	@reftype varchar(6),
	@refnum varchar(20),
	@startdate datetime,
	@tpid varchar(20),
	@copytimes varchar(5),
	@@ordnumber varchar(12) OUTPUT,
	@@ordstatus varchar(6) OUTPUT
as

declare @retcode int, @schdate datetime, @schnumber int, @masterdate datetime,
	@mastermov int, @masterord int, @masterlgh int, @masterstp int, @masterfgt int, @masterevt int,
	@newmov int, @newlgh int, @newstp int, @newfgt int, @neword int, @newevt int,
	@datediff int, @datetimediff int, @masternot int, @newnot int,
	@masterivd int, @newivd int, @firstlgh int, @shipper varchar(8), @showshipper varchar(8)

declare @schscope varchar(1), @copyassets varchar(5), @copyrates varchar(5),
	@copyaccessorials varchar(5), @copynotes varchar(5), @copydelinstructions varchar(5), @copypay varchar(5),
	@copyorderref varchar(5), @copyotherref varchar(5), @copyloadreqs varchar(5), @copylghtypes char(1),
	@copyextrainfo varchar(5), @copypermits varchar(5), @mastermpp varchar(8), @mastertrc varchar(8),
	@mastertrl varchar(13), @mastercar varchar(8), @masterlghtype1 varchar(6), @masterlghtype2 varchar(6),
	@masterlghcomment varchar(255), @tempord int, @temporder varchar(12)
	
declare @mastermfhseq int, @stpordhdrnumber int
declare @mastercmd_code varchar(8)
	
declare @orderxref table (master_ord_hdrnumber int NOT NULL, new_ord_hdrnumber int NOT NULL, master_ord_number varchar(12))
insert @orderxref values (0,0,'')

if isnull(@reftype,'') = '' select @reftype = 'EDICT#'
if @startdate is null return -2

select @schdate = convert(datetime, convert(varchar, @startdate, 101))

select @mastermov = mov_number, @masterord = ord_hdrnumber
     , @shipper = ord_shipper, @showshipper = ord_showshipper
  from orderheader
 where ord_number = @masterorder

if isnull(@mastermov,0) = 0 
begin
	select @masterord = max(oh.ord_hdrnumber)
	  from orderheader oh
	 inner join referencenumber ref
	    on oh.ord_hdrnumber = ref.ref_tablekey
           and ref.ref_table = 'orderheader'
	 where oh.ord_status = 'MST'
	   and ref.ref_type = 'ROUTE'
	   and ref.ref_number = @masterorder

	if isnull(@masterord, 0) > 0
	begin
		select @mastermov = mov_number, @masterorder = ord_number
		     , @shipper = ord_shipper, @showshipper = ord_showshipper
		  from orderheader
		 where ord_hdrnumber = @masterord
		if isnull(@mastermov,0) = 0 return -3
	end
	else
		return -3
end

--select @retcode = count(distinct(sch_number)) 
--  from schedule_table 
-- where mov_number = @mastermov
--   and sch_timeofday = @schdate

--if @retcode = 0 return -4
--if @retcode > 1 return -5

select @masterdate = null
if @shipper <> @showshipper and @showshipper <> 'UNKNOWN'
	select @masterdate = min(stp_arrivaldate)
	  from stops
	 where mov_number = @mastermov
	   and ord_hdrnumber = @masterord
	   and cmp_id = @showshipper
	   and stp_type = 'PUP'
if @masterdate is null
	select @masterdate = min(stp_arrivaldate)
	  from stops
	 where mov_number = @mastermov
	   and ord_hdrnumber = @masterord
	   and stp_type = 'PUP'

select @datediff = datediff(mi, convert(datetime, convert(varchar, @masterdate, 101)), @schdate)
     , @datetimediff = datediff(mi, @masterdate, @startdate)

if isnull(@copytimes,'') = 'F' and datediff(mi, @startdate, @schdate) = 0
	select @datetimediff = @datediff

select @schnumber = min(sch_number)
  from schedule_table
 where mov_number = @mastermov
--   and sch_timeofday = @schdate

if isnull(@schnumber,0) = 0 select @schnumber = -1

if isnull(@@ordstatus,'') NOT IN ('PND','AVL') select @@ordstatus = 'AVL'

exec @neword = dbo.getsystemnumber 'ORDHDR', null
exec @newmov = dbo.getsystemnumber 'MOVNUM', null

insert @orderxref values (@masterord, @neword, @masterorder)

select @masterlgh = 0, @firstlgh = 0, @mastermfhseq = 0
while 1=1
begin
	if not exists (select lgh_number, stp_mfh_sequence
	  from stops
	 where mov_number = @mastermov
	   and lgh_number <> @masterlgh
	   and stp_mfh_sequence > @mastermfhseq)
	   break
	   
	select top 1 @masterlgh = lgh_number, @mastermfhseq = stp_mfh_sequence
	  from stops
	 where mov_number = @mastermov
	   and lgh_number <> @masterlgh
	   and stp_mfh_sequence > @mastermfhseq 
	   order by stp_mfh_sequence
	
	if @firstlgh = 0 select @firstlgh = @masterlgh
	
	--select '	@firstlgh = @masterlgh'

	if (select count(1) from schedule_table where sch_number = @schnumber and lgh_number = @masterlgh) = 0
		select @schscope = 'T'
		     , @copyassets = 'F'
		     , @copytimes = 'T'
		     , @copyrates = 'T'
		     , @copyaccessorials = 'T'
		     , @copynotes = 'T'
		     , @copydelinstructions = 'T'
		     , @copypay = 'F'
		     , @copyorderref = 'T'
		     , @copyotherref = 'T'
		     , @copyloadreqs = 'T'
		     , @copyextrainfo = 'T'
		     , @copypermits = 'F'
		     , @mastermpp = 'UNKNOWN'
		     , @mastertrc = 'UNKNOWN'
		     , @mastertrl = 'UNKNOWN'
		     , @mastercar = 'UNKNOWN'
	else
		select @schscope = sch_scope
		     , @copyassets = sch_copy_assetassignments
		     , @copytimes = sch_copy_dates
		     , @copyrates = sch_copy_rates
		     , @copyaccessorials = sch_copy_accessorials
		     , @copynotes = sch_copy_notes
		     , @copydelinstructions = sch_copy_delinstructions
		     , @copypay = sch_copy_paydetails
		     , @copyorderref = sch_copy_orderref
		     , @copyotherref = sch_copy_otherref
		     , @copyloadreqs = sch_copy_loadreqs
		     , @copyextrainfo = sch_copy_extrainfo
		     , @copypermits = sch_copy_permitrequirements
		     , @mastermpp = ISNULL(mpp_id,'UNKNOWN')
		     , @mastertrc = ISNULL(trc_number,'UNKNOWN')
		     , @mastertrl = ISNULL(trl_id,'UNKNOWN')
		     , @mastercar = ISNULL(car_id,'UNKNOWN')
		  from schedule_table
		 where sch_number = @schnumber
		   and lgh_number = @masterlgh

	exec @newlgh = dbo.getsystemnumber 'LEGHDR', null
	select @masterstp = 0, @mastermfhseq = 0, @stpordhdrnumber = 0
	while 1=1
	begin
	
	--select '	Hi there '
	
		if not exists (select stp_number, stp_mfh_sequence
	  from stops
	 where mov_number = @mastermov
	   and lgh_number = @masterlgh
	   and stp_mfh_sequence > @mastermfhseq) 
	   break
	   
	select top 1 @masterstp = stp_number, @mastermfhseq = stp_mfh_sequence, 
				 @stpordhdrnumber = ord_hdrnumber, @mastercmd_code = ISNULL(cmd_code,'UNKNOWN')
	  from stops
	 where mov_number = @mastermov
	   and lgh_number = @masterlgh
	   and stp_mfh_sequence > @mastermfhseq 
	   order by stp_mfh_sequence
	   
	   
	   select '@mastercmd_code =' + @mastercmd_code 
	   
	   
		exec @newstp = dbo.getsystemnumber 'STPNUM', null
		/* FMM 11-1-2007
		select @masterfgt = 0
		while 1=1
		begin
			select @masterfgt = min(fgt_number)
			  from freightdetail
			 where stp_number = @masterstp
			   and fgt_number > @masterfgt
			if @masterfgt is null break
			--create freightdetail
			exec @newfgt = dbo.getsystemnumber 'FGTNUM', null
			insert freightdetail (fgt_number, cmd_code, fgt_weight, fgt_weightunit, fgt_description,
				stp_number, fgt_count, fgt_countunit, fgt_volume, fgt_volumeunit,
				fgt_lowtemp, fgt_hitemp, fgt_sequence, fgt_length, fgt_lengthunit,
				fgt_height, fgt_heightunit, fgt_width, fgt_widthunit, fgt_reftype,
				fgt_refnum, fgt_quantity, fgt_rate, fgt_charge, fgt_rateunit,
				cht_itemcode, cht_basisunit, fgt_unit, skip_trigger, tare_weight,
				tare_weightunit, fgt_pallets_in, fgt_pallets_out, fgt_carryins1, fgt_carryins2,
				fgt_stackable, fgt_ratingquantity, fgt_ratingunit, fgt_quantity_type, fgt_ordered_count,
				fgt_ordered_weight, tar_number, tar_tariffnumber, tar_tariffitem, fgt_charge_type, 
				fgt_rate_type, fgt_loadingmeters, fgt_loadingmetersunit, fgt_additionl_description, 
				fgt_specific_flashpoint, fgt_specific_flashpoint_unit, fgt_ordered_volume, 
				fgt_ordered_loadingmeters, fgt_pallet_type)
			select @newfgt, cmd_code, fgt_weight, fgt_weightunit, fgt_description,
				@newstp, fgt_count, fgt_countunit, fgt_volume, fgt_volumeunit,
				fgt_lowtemp, fgt_hitemp, fgt_sequence, fgt_length, fgt_lengthunit,
				fgt_height, fgt_heightunit, fgt_width, fgt_widthunit, 
				case @copyotherref when 'T' then fgt_reftype else 'UNK' end,
				case @copyotherref when 'T' then fgt_refnum else NULL end, 
				case @copyrates when 'T' then fgt_quantity else 0.0 end, 
				case @copyrates when 'T' then fgt_rate else convert(money,0.0) end, 
				case @copyrates when 'T' then fgt_charge else convert(money,0.0) end, 
				fgt_rateunit,
				case @copyrates when 'T' then cht_itemcode else 'UNK' end, 
				cht_basisunit, 
				case @copyrates when 'T' then fgt_unit else 'UNK' end, 
				1, tare_weight, tare_weightunit, fgt_pallets_in, fgt_pallets_out, 
				fgt_carryins1, fgt_carryins2, fgt_stackable, 
				case @copyrates when 'T' then fgt_ratingquantity else NULL end, 
				case @copyrates when 'T' then fgt_ratingunit else NULL end, 
				case @copyrates when 'T' then fgt_quantity_type else 0 end, 
				fgt_ordered_count, fgt_ordered_weight, 
				case @copyrates when 'T' then tar_number else 0 end, 
				case @copyrates when 'T' then tar_tariffnumber else NULL end, 
				case @copyrates when 'T' then tar_tariffitem else NULL end, 
				case @copyrates when 'T' then fgt_charge_type else 0 end, 
				case @copyrates when 'T' then fgt_rate_type else 0 end, 
				fgt_loadingmeters, fgt_loadingmetersunit, fgt_additionl_description, 
				fgt_specific_flashpoint, fgt_specific_flashpoint_unit, fgt_ordered_volume, 
				fgt_ordered_loadingmeters, fgt_pallet_type
			  from freightdetail
			 where fgt_number = @masterfgt
			if @@ERROR <> 0 return -1
			if @copyotherref = 'T'
				insert referencenumber ( ref_tablekey, ref_type, ref_number, ref_typedesc, ref_sequence, 
					ord_hdrnumber, ref_table, ref_sid, ref_pickup ) 
				select @newfgt, ref_type, ref_number, ref_typedesc, ref_sequence, @neword, 'freightdetail', ref_sid, ref_pickup
				  from referencenumber
				 where ref_table = 'freightdetail' and ref_tablekey = @masterfgt
		end
		-- FMM 11/1/2007 */
		select @masterevt = 0
		while 1=1
		begin
			select @masterevt = min(evt_number)
			  from event
			 where stp_number = @masterstp
			   and evt_number > @masterevt
			if @masterevt is null break
			--create event
			select @tempord = ord_hdrnumber
			  from event
			 where evt_number = @masterevt
			if @tempord in (select master_ord_hdrnumber from @orderxref)
				select @neword = new_ord_hdrnumber from @orderxref where master_ord_hdrnumber = @tempord
			else
			begin
				exec @neword = dbo.getsystemnumber 'ORDHDR', null
				insert @orderxref 
					select @tempord, @neword, ord_number
					  from orderheader
					 where ord_hdrnumber = @tempord
			end 
			exec @newevt = dbo.getsystemnumber 'EVTNUM', null
			insert event (ord_hdrnumber, stp_number, evt_eventcode, evt_number, evt_startdate,
				evt_enddate, evt_status, evt_earlydate, evt_latedate, evt_weight,
				evt_weightunit, fgt_number, evt_count, evt_countunit, evt_volume,
				evt_volumeunit, evt_pu_dr, evt_sequence, evt_contact, evt_driver1,
				evt_driver2, evt_tractor, evt_trailer1, evt_trailer2, evt_chassis,
				evt_dolly, evt_carrier, evt_refype, evt_refnum, evt_reason,
				evt_enteredby, evt_hubmiles, skip_trigger, evt_mov_number, evt_departure_status)
			select @neword, @newstp, evt_eventcode, @newevt, 
				dbo.dx_adjust_datetime(evt_startdate, case @copytimes when 'T' then @datetimediff else @datediff end),
				dbo.dx_adjust_datetime(evt_enddate, case @copytimes when 'T' then @datetimediff else @datediff end), 
				case @@ordstatus when 'PND' then 'NON' else 'OPN' end, 
				dbo.dx_adjust_datetime(evt_earlydate, case @copytimes when 'T' then @datetimediff else @datediff end), 
				dbo.dx_adjust_datetime(evt_latedate, case @copytimes when 'T' then @datetimediff else @datediff end), 
				evt_weight, evt_weightunit, @newfgt, evt_count, evt_countunit, evt_volume,
				evt_volumeunit, evt_pu_dr, evt_sequence, evt_contact, 
				case when @@ordstatus = 'PND' then 'UNKNOWN' when @copyassets = 'T' then evt_driver1 else @mastermpp end,
				case when @@ordstatus = 'PND' then 'UNKNOWN' when @copyassets = 'T' then evt_driver2 else 'UNKNOWN' end, 
				case when @@ordstatus = 'PND' then 'UNKNOWN' when @copyassets = 'T' then evt_tractor else @mastertrc end, 
				case @copyassets when 'T' then evt_trailer1 else @mastertrl end, 
				case @copyassets when 'T' then evt_trailer2 else 'UNKNOWN' end, 
				evt_chassis, evt_dolly, 
				case @copyassets when 'T' then evt_carrier else @mastercar end, 
				evt_refype, evt_refnum, 'UNK',
				evt_enteredby, NULL, 1, @newmov, 'OPN'
			  from event
			 where evt_number = @masterevt
			if @@ERROR <> 0 return -1
		end
		if @@ordstatus = 'AVL'
			if (select count(1) from event where stp_number = @newstp and 
			    (evt_driver1 != 'UNKNOWN' or evt_tractor != 'UNKNOWN' or evt_carrier != 'UNKNOWN')) > 0
				select @@ordstatus = 'PLN'
		--create stop
		
		if @stpordhdrnumber in (select master_ord_hdrnumber from @orderxref)
				select @neword = new_ord_hdrnumber from @orderxref where master_ord_hdrnumber = @stpordhdrnumber
			else
			begin
				exec @neword = dbo.getsystemnumber 'ORDHDR', null
				insert @orderxref 
					select @stpordhdrnumber, @neword, ord_number
					  from orderheader
					 where ord_hdrnumber = @stpordhdrnumber 
			end 
			
		insert stops (ord_hdrnumber, stp_number, cmp_id, stp_region1, stp_region2,
			stp_region3, stp_city, stp_state, stp_schdtearliest, stp_origschdt,
			stp_arrivaldate, stp_departuredate, stp_reasonlate, stp_schdtlatest, lgh_number,
			mfh_number, stp_type, stp_paylegpt, shp_hdrnumber, stp_sequence,
			stp_region4, stp_lgh_sequence, trl_id, stp_mfh_sequence, stp_event,
			stp_mfh_position, stp_lgh_position, stp_mfh_status, stp_lgh_status, stp_ord_mileage,
			stp_lgh_mileage, stp_mfh_mileage, mov_number, stp_loadstatus, stp_weight,
			stp_weightunit, cmd_code, stp_description, stp_count, stp_countunit,
			cmp_name, stp_comment, stp_status, stp_reftype,	stp_refnum,
			stp_reasonlate_depart, stp_screenmode, skip_trigger, stp_volume, stp_volumeunit,
			stp_dispatched_sequence, stp_arr_confirmed, stp_dep_confirmed, stp_type1, stp_redeliver,
			stp_osd, stp_pudelpref, stp_phonenumber, stp_delayhours, stp_ooa_mileage, stp_zipcode,
			stp_ooa_stop, stp_address, stp_transfer_stp, stp_phonenumber2, stp_address2,
			stp_contact, stp_custpickupdate, stp_custdeliverydate, stp_podname, stp_cmp_close, 
			stp_activitystart_dt, stp_activityend_dt, stp_departure_status, stp_eta, stp_etd,
			stp_transfer_type, stp_trip_mileage, stp_loadingmeters, stp_loadingmetersunit, stp_country, 
			stp_cod_amount, stp_cod_currency, stp_ord_mileage_mtid, stp_lgh_mileage_mtid, stp_ooa_mileage_mtid)
		select case ord_hdrnumber when 0 then 0 else @neword end, @newstp, cmp_id, stp_region1, stp_region2,
			stp_region3, stp_city, stp_state, 
			dbo.dx_adjust_datetime(stp_schdtearliest, case @copytimes when 'T' then @datetimediff else @datediff end), 
			stp_origschdt,
			dbo.dx_adjust_datetime(stp_arrivaldate, case @copytimes when 'T' then @datetimediff else @datediff end), 
			dbo.dx_adjust_datetime(stp_departuredate, case @copytimes when 'T' then @datetimediff else @datediff end), 
			'UNK', 
			dbo.dx_adjust_datetime(stp_schdtlatest, case @copytimes when 'T' then @datetimediff else @datediff end), 
			@newlgh, 0, stp_type, stp_paylegpt, shp_hdrnumber, stp_sequence, stp_region4,
			stp_lgh_sequence, case @copyassets when 'T' then trl_id else @mastertrl end, 
			stp_mfh_sequence, stp_event,
			stp_mfh_position, stp_lgh_position, stp_mfh_status, 
			case @copyassets when 'T' then 'PLN' else 'AVL' end, 
			stp_ord_mileage,
			CASE stp_sequence WHEN 1 THEN NULL ELSE stp_lgh_mileage END,
			stp_mfh_mileage, @newmov, stp_loadstatus, stp_weight,
			stp_weightunit, @mastercmd_code, stp_description, stp_count, stp_countunit,
			cmp_name, CASE @copydelinstructions WHEN 'T' THEN stp_comment ELSE '' END,
			case @@ordstatus when 'PND' then 'NON' else 'OPN' end, CASE @copyotherref WHEN 'T' THEN stp_reftype ELSE 'UNK' END,	
			CASE @copyotherref WHEN 'T' THEN stp_refnum ELSE NULL END,
			'UNK', stp_screenmode, skip_trigger, stp_volume, stp_volumeunit,
			stp_dispatched_sequence, NULL, NULL, stp_type1, stp_redeliver,
			stp_osd, stp_pudelpref,	stp_phonenumber, stp_delayhours, stp_ooa_mileage, stp_zipcode,
			stp_ooa_stop, stp_address, NULL, stp_phonenumber2, stp_address2,
			stp_contact, stp_custpickupdate, stp_custdeliverydate, stp_podname, stp_cmp_close, 
			'19500101 00:00', '19500101 00:00', case @@ordstatus when 'PND' then 'NON' else 'OPN' end, 
			dbo.dx_adjust_datetime(stp_eta, case @copytimes when 'T' then @datetimediff else @datediff end), 
			dbo.dx_adjust_datetime(stp_etd, case @copytimes when 'T' then @datetimediff else @datediff end),
			stp_transfer_type, stp_trip_mileage, stp_loadingmeters, stp_loadingmetersunit, stp_country, 
			stp_cod_amount, stp_cod_currency, ISNULL(stp_ord_mileage_mtid,0), ISNULL(stp_lgh_mileage_mtid,0), ISNULL(stp_ooa_mileage_mtid,0)
		  from stops
		 where stp_number = @masterstp
		if @@ERROR <> 0 return -1
		if @copyotherref = 'T'
			insert referencenumber ( ref_tablekey, ref_type, ref_number, ref_typedesc, ref_sequence, 
				ord_hdrnumber, ref_table, ref_sid, ref_pickup ) 
			select @newstp, ref_type, ref_number, ref_typedesc, ref_sequence, @neword, 'stops', ref_sid, ref_pickup
			  from referencenumber
			 where ref_table = 'stops' and ref_tablekey = @masterstp and ref_number <> (select stp_refnum from stops where stp_number = @masterstp)
		--FMM 11/1/2007
		exec @newfgt = dbo.getsystemnumber 'FGTNUM', null
		insert freightdetail (fgt_number, cmd_code, fgt_weight, fgt_weightunit, fgt_description,
			stp_number, fgt_count, fgt_countunit, fgt_volume, fgt_volumeunit,
			fgt_lowtemp, fgt_hitemp, fgt_sequence, fgt_length, fgt_lengthunit,
			fgt_height, fgt_heightunit, fgt_width, fgt_widthunit, fgt_reftype,
			fgt_refnum, fgt_quantity, fgt_rate, fgt_charge, fgt_rateunit,
			cht_itemcode, cht_basisunit, fgt_unit, skip_trigger, tare_weight,
			tare_weightunit, fgt_pallets_in, fgt_pallets_out, fgt_carryins1, fgt_carryins2,
			fgt_stackable, fgt_ratingquantity, fgt_ratingunit, fgt_quantity_type, fgt_ordered_count,
			fgt_ordered_weight, tar_number, tar_tariffnumber, tar_tariffitem, fgt_charge_type, 
			fgt_rate_type, fgt_loadingmeters, fgt_loadingmetersunit, fgt_additionl_description, 
			fgt_specific_flashpoint, fgt_specific_flashpoint_unit, fgt_ordered_volume, 
			fgt_ordered_loadingmeters, fgt_pallet_type)
		values (@newfgt, @mastercmd_code, 0, 'LBS', 'UNKNOWN',
			@newstp, 0, 'PCS', 0, 'GAL',
			null, null, 1, null, null,
			null, null, null, null, 'UNK', 
			null, 0.0, 0.0, 0.0, 'UNK',
			'UNK', 'UNK', 'UNK', 1, 0,
			'LBS', null, null, null, null,
			null, null, null, 0, 0,
			0, 0, null, null, 0,
			0, null, null, null, null, 
			null, 0, null, null)
	end
end

if (select count(1) from schedule_table where sch_number = @schnumber and lgh_number = @firstlgh) = 0
	select @schscope = 'T'
	     , @copyassets = 'F'
	     , @copytimes = 'T'
	     , @copyrates = 'T'
	     , @copyaccessorials = 'T'
	     , @copynotes = 'T'
	     , @copyorderref = 'T'
	     , @copyloadreqs = 'T'
	     , @copyextrainfo = 'T'
	     , @copypermits = 'F'
	     , @mastermpp = 'UNKNOWN'
	     , @mastertrc = 'UNKNOWN'
	     , @mastertrl = 'UNKNOWN'
	     , @mastercar = 'UNKNOWN'
else
	select @schscope = sch_scope
	     , @copyassets = sch_copy_assetassignments
	     , @copytimes = sch_copy_dates
	     , @copyrates = sch_copy_rates
	     , @copyaccessorials = sch_copy_accessorials
	     , @copynotes = sch_copy_notes
	     , @copyorderref = sch_copy_orderref
	     , @copyloadreqs = sch_copy_loadreqs
	     , @copyextrainfo = sch_copy_extrainfo
	     , @copypermits = sch_copy_permitrequirements
	     , @mastermpp = ISNULL(mpp_id,'UNKNOWN')
	     , @mastertrc = ISNULL(trc_number,'UNKNOWN')
	     , @mastertrl = ISNULL(trl_id,'UNKNOWN')
	     , @mastercar = ISNULL(car_id,'UNKNOWN')
	  from schedule_table
	 where sch_number = @schnumber
	   and lgh_number = @firstlgh

select @neword = 0
while 1=1
begin
	select @neword = min(new_ord_hdrnumber) from @orderxref where new_ord_hdrnumber > @neword
	if @neword is null break
	select @tempord = master_ord_hdrnumber, @temporder = master_ord_number from @orderxref where new_ord_hdrnumber = @neword

	insert into orderheader ( ord_company, ord_number, ord_customer, ord_bookdate, ord_bookedby, 
		ord_status, ord_originpoint, ord_destpoint, ord_invoicestatus, ord_origincity, 
		ord_destcity, ord_originstate, ord_deststate, ord_originregion1, ord_destregion1, 
		ord_supplier, ord_billto, ord_startdate, ord_completiondate, ord_revtype1, 
		ord_revtype2, ord_revtype3, ord_revtype4, ord_totalweight, ord_totalpieces, 
		ord_totalmiles, ord_totalcharge, ord_currency, ord_currencydate, ord_totalvolume, 
		ord_hdrnumber, ord_refnum, ord_invoicewhole, ord_remark, ord_shipper, ord_consignee, 
		ord_pu_at, ord_dr_at, ord_originregion2, ord_originregion3, ord_originregion4, ord_destregion2, ord_destregion3, 
		ord_destregion4, mfh_hdrnumber, ord_priority, mov_number, tar_tarriffnumber, tar_number, 
		tar_tariffitem, ord_contact, ord_showshipper, ord_showcons, ord_subcompany, ord_lowtemp, 
		ord_hitemp, ord_quantity, ord_rate, ord_charge, ord_rateunit, 
		ord_unit, trl_type1, ord_driver1, ord_driver2, ord_tractor, 
		ord_trailer, ord_length, ord_width, ord_height, ord_lengthunit, ord_widthunit, ord_heightunit, ord_reftype, 
		cmd_code, ord_description, ord_terms, cht_itemcode, ord_origin_earliestdate, 
		ord_origin_latestdate, ord_odmetermiles, ord_stopcount, ord_dest_earliestdate, ord_dest_latestdate, 
		ref_sid, ref_pickup, ord_cmdvalue, ord_accessorial_chrg, ord_availabledate, ord_miscqty, ord_tempunits, ord_datetaken, 
		ord_totalweightunits, ord_totalvolumeunits, ord_totalcountunits, ord_loadtime, ord_unloadtime, 
		ord_drivetime, ord_rateby, ord_quantity_type, ord_thirdpartytype1, ord_thirdpartytype2, 
		ord_charge_type, ord_bol_printed, ord_fromorder, ord_mintemp, ord_maxtemp, ord_distributor, ord_cod_amount, opt_trc_type4, opt_trl_type4, 
		appt_init, appt_contact, ord_ratingquantity, ord_ratingunit, ord_booked_revtype1, ord_hideshipperaddr,
		ord_hideconsignaddr, ord_trl_type2, ord_trl_type3, ord_trl_type4, ord_tareweight, 
		ord_grossweight, ord_mileagetable, ord_allinclusivecharge, ord_rate_type, ord_stlquantity,
		ord_stlunit, ord_stlquantity_type, ord_revenue_pay, ord_reserved_number, ord_customs_document, 
		ord_noautosplit, ord_noautotransfer, ord_totalloadingmeters, ord_totalloadingmetersunit, ord_charge_type_lh,
		ord_mileage_adj_pct, ord_dimfactor, ord_trlconfiguration, ord_rate_mileagetable, ord_raildest,
		ord_railpoolid,	ord_trailer2, ord_route, ord_route_effc_date, ord_route_exp_date,
		ord_odmetermiles_mtid, ord_origin_zip, ord_dest_zip, ord_no_recalc_miles,
		ord_cyclic_dsp_enabled,ord_preassign_ack_required) 
	select ord_company, convert(varchar(12), @neword), ord_customer, getdate(), 'TMWDX',
		@@ordstatus, ord_originpoint, ord_destpoint, 'PND', ord_origincity, 
		ord_destcity, ord_originstate, ord_deststate, ord_originregion1, ord_destregion1, 
		ord_supplier, ord_billto, 
		dbo.dx_adjust_datetime(ord_startdate, case @copytimes when 'T' then @datetimediff else @datediff end),
		dbo.dx_adjust_datetime(ord_completiondate, case @copytimes when 'T' then @datetimediff else @datediff end),
		ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4, ord_totalweight, ord_totalpieces, 
		ord_totalmiles, case @copyrates when 'T' then ord_charge + ord_accessorial_chrg else convert(money, 0.0) end, 
		ord_currency, @startdate, ord_totalvolume, 
		@neword, case @copyorderref when 'T' then ord_refnum else NULL end, ord_invoicewhole, ord_remark, ord_shipper, ord_consignee, 
		ord_pu_at, ord_dr_at, ord_originregion2, ord_originregion3, ord_originregion4, ord_destregion2, ord_destregion3, 
		ord_destregion4, mfh_hdrnumber, ord_priority, @newmov, case @copyrates when 'T' then tar_tarriffnumber else NULL end, 
		case @copyrates when 'T' then tar_number else 0 end, 
		case @copyrates when 'T' then tar_tariffitem else NULL end, 
		ord_contact, ord_showshipper, ord_showcons, ord_subcompany, ord_lowtemp, 
		ord_hitemp, case @copyrates when 'T' then ord_quantity else 0.0 end, 
		case @copyrates when 'T' then ord_rate else convert(money, 0.0) end, 
		case @copyrates when 'T' then ord_charge else convert(money, 0.0) end, ord_rateunit, 
		ord_unit, trl_type1, case when @@ordstatus = 'PND' then 'UNKNOWN' when @copyassets = 'T' then ord_driver1 else @mastermpp end, 
		case when @@ordstatus = 'PND' then 'UNKNOWN' when @copyassets = 'T' then ord_driver2 else 'UNKNOWN' end, 
		case when @@ordstatus = 'PND' then 'UNKNOWN' when @copyassets = 'T' then ord_tractor else @mastertrc end, 
		case @copyassets when 'T' then ord_trailer else @mastertrl end, ord_length, ord_width, ord_height, 
		ord_lengthunit, ord_widthunit, ord_heightunit, case @copyorderref when 'T' then ord_reftype else 'UNK' end, 
		cmd_code, ord_description, ord_terms, case @copyrates when 'T' then cht_itemcode else 'UNK' end, 
		dbo.dx_adjust_datetime(ord_origin_earliestdate, case @copytimes when 'T' then @datetimediff else @datediff end), 
		dbo.dx_adjust_datetime(ord_origin_latestdate, case @copytimes when 'T' then @datetimediff else @datediff end), 
		ord_odmetermiles, ord_stopcount, 
		dbo.dx_adjust_datetime(ord_dest_earliestdate, case @copytimes when 'T' then @datetimediff else @datediff end), 
		dbo.dx_adjust_datetime(ord_dest_latestdate, case @copytimes when 'T' then @datetimediff else @datediff end), 
		ref_sid, ref_pickup, ord_cmdvalue, case @copyaccessorials when 'T' then ord_accessorial_chrg else convert(money, 0.0) end, 
		getdate(), ord_miscqty, ord_tempunits, getdate(), 
		ord_totalweightunits, ord_totalvolumeunits, ord_totalcountunits, ord_loadtime, ord_unloadtime, 
		ord_drivetime, ord_rateby, case @copyrates when 'T' then ord_quantity_type else 0 end, 
		ord_thirdpartytype1, ord_thirdpartytype2, 
		case @copyrates when 'T' then case @copyaccessorials when 'T' then ord_charge_type else 0 end else 0 end, 
		ord_bol_printed, @temporder, ord_mintemp, ord_maxtemp, ord_distributor, ord_cod_amount, opt_trc_type4, opt_trl_type4, 
		appt_init, appt_contact, case @copyrates when 'T' then ord_ratingquantity else NULL end, 
		case @copyrates when 'T' then ord_ratingunit else NULL end, ord_booked_revtype1, ord_hideshipperaddr,
		ord_hideconsignaddr, ord_trl_type2, ord_trl_type3, ord_trl_type4, ord_tareweight, 
		ord_grossweight, ord_mileagetable, case @copyrates when 'T' then ord_allinclusivecharge else NULL end, 
		case @copyrates when 'T' then ord_rate_type else 0 end, 
		case @copyrates when 'T' then ord_stlquantity else 0.0 end,
		case @copyrates when 'T' then ord_stlunit else 'UNK' end, 
		case @copyrates when 'T' then ord_stlquantity_type else 0 end, 
		case @copyrates when 'T' then ord_revenue_pay else 0 end, ord_reserved_number, ord_customs_document, 
		ord_noautosplit, ord_noautotransfer, ord_totalloadingmeters, ord_totalloadingmetersunit, 
		case @copyrates when 'T' then ord_charge_type_lh else 0 end,
		ord_mileage_adj_pct, ord_dimfactor, ord_trlconfiguration, ord_rate_mileagetable, ord_raildest,
		ord_railpoolid,	ord_trailer2, ord_route, ord_route_effc_date, ord_route_exp_date,
		ord_odmetermiles_mtid, ord_origin_zip, ord_dest_zip, ord_no_recalc_miles,
		ord_cyclic_dsp_enabled,ord_preassign_ack_required
	  from orderheader
	 where ord_hdrnumber = @tempord

	if @@ERROR <> 0 return -1
	
	declare @newordnum varchar(12)
	select @newordnum = convert(varchar(12), @neword)
	
	if @copyorderref = 'T'
		insert into referencenumber ( ref_tablekey, ref_type, ref_number, ref_typedesc, ref_sequence, 
			ord_hdrnumber, ref_table, ref_sid, ref_pickup ) 
		select @neword, ref_type, ref_number, ref_typedesc, ref_sequence, @neword, 'orderheader', ref_sid, ref_pickup
		  from referencenumber
		 where ref_table = 'orderheader' and ref_tablekey = @tempord
	
	if (select count(1) from referencenumber 
	     where ref_table = 'orderheader' and ref_tablekey = @neword and ref_type = @reftype and ref_sid = 'Y') = 0
		exec dx_add_refnumber 'orderheader', @newordnum, @reftype, @refnum, 'Y'
	else
		update referencenumber
		   set ref_number = @refnum
		 where ref_table = 'orderheader' and ref_tablekey = @neword and ref_type = @reftype and ref_sid = 'Y'
	
	if @copynotes = 'T'
	begin
		select @masternot = 0  --, @masterorder = convert(varchar(12), @masterord)
		while 1=1
		begin
			select @masternot = min(not_number)
			  from notes
			 where ntb_table = 'orderheader'
			   and nre_tablekey = convert(varchar(12), @tempord)
			   and not_number > @masternot
			if @masternot is null break
			exec @newnot = dbo.getsystemnumber 'NOTES', null
			insert notes (not_number, not_text, not_type, not_urgent, not_senton, not_sentby, not_expires, 
				not_forwardedfrom, ntb_table, nre_tablekey, not_sequence, last_updatedby, last_updatedatetime)
			select @newnot, not_text, not_type, not_urgent, not_senton, not_sentby, not_expires,
				not_forwardedfrom, ntb_table, convert(varchar(12), @neword), not_sequence, 'TMWDX', getdate()
			  from notes
			 where not_number = @masternot and len(not_text) > 0
		end
		select @masternot = 0
		while 1=1
		begin
			select @masternot = min(not_number)
			  from notes
			 where ntb_table = 'movement'
			   and nre_tablekey = @mastermov
			   and not_number > @masternot
			if @masternot is null break
			exec @newnot = dbo.getsystemnumber 'NOTES', null
			insert notes (not_number, not_text, not_type, not_urgent, not_senton, not_sentby, not_expires, 
				not_forwardedfrom, ntb_table, nre_tablekey, not_sequence, last_updatedby, last_updatedatetime)
			select @newnot, not_text, not_type, not_urgent, not_senton, not_sentby, not_expires,
				not_forwardedfrom, ntb_table, @newmov, not_sequence, 'TMWDX', getdate()
			  from notes
			 where not_number = @masternot and len(not_text) > 0
		end
	end
	
	if @copyaccessorials = 'T'
	begin
		select @masterivd = 0
		while 1=1
		begin
			select @masterivd = min(ivd_number)
			  from invoicedetail
			 where ord_hdrnumber = @tempord
			   and ivd_type not in ('PUP','DRP','NONE')
			   and ivd_number > @masterivd
			if @masterivd is null break
			exec @newivd = dbo.getsystemnumber 'INVDET', null
			insert invoicedetail (ivh_hdrnumber, ivd_number, stp_number, ivd_description, cht_itemcode,
				ivd_quantity, ivd_rate, ivd_charge, ivd_taxable1, ivd_taxable2, ivd_taxable3,
				ivd_taxable4, ivd_unit, cur_code, ivd_currencydate, ivd_glnum, ord_hdrnumber,
				ivd_type, ivd_rateunit, ivd_billto, ivd_itemquantity, ivd_subtotalptr,
				ivd_allocatedrev, ivd_sequence, ivd_invoicestatus, mfh_hdrnumber, ivd_refnum,
				cmd_code, cmp_id, ivd_distance, ivd_distunit, ivd_wgt,
				ivd_wgtunit, ivd_count, ivd_countunit, evt_number, ivd_reftype, ivd_volume,
				ivd_volunit, ivd_orig_cmpid, ivd_payrevenue, ivd_sign, ivd_length,
				ivd_lengthunit,	ivd_width, ivd_widthunit, ivd_height, ivd_heightunit,
				ivd_exportstatus, cht_basisunit, ivd_remark, tar_number, tar_tariffnumber,
				tar_tariffitem, ivd_fromord, ivd_zipcode, ivd_quantity_type, cht_class,
				ivd_mileagetable, ivd_charge_type, cht_lh_min, cht_lh_rev, cht_lh_stl,
				cht_lh_rpt, cht_rollintolh)
			select 0, @newivd, NULL, ivd_description, cht_itemcode,
				ivd_quantity, ivd_rate, ivd_charge, ivd_taxable1, ivd_taxable2, ivd_taxable3,
				ivd_taxable4, ivd_unit, cur_code, getdate(), ivd_glnum, @neword,
				ivd_type, ivd_rateunit, ivd_billto, ivd_itemquantity, 0,
				ivd_allocatedrev, 999, NULL, NULL, ivd_refnum,
				cmd_code, cmp_id, ivd_distance, ivd_distunit, ivd_wgt,
				ivd_wgtunit, ivd_count, ivd_countunit, NULL, ivd_reftype, ivd_volume,
				ivd_volunit, ivd_orig_cmpid, ivd_payrevenue, ivd_sign, ivd_length,
				ivd_lengthunit,	ivd_width, ivd_widthunit, ivd_height, ivd_heightunit,
				NULL, cht_basisunit, ivd_remark, tar_number, tar_tariffnumber,
				tar_tariffitem, ivd_fromord, ivd_zipcode, ivd_quantity_type, cht_class,
				ivd_mileagetable, ivd_charge_type, cht_lh_min, cht_lh_rev, cht_lh_stl,
				cht_lh_rpt, cht_rollintolh
			  from invoicedetail
			 where ivd_number = @masterivd
		end
	end
	
	if @copyloadreqs = 'T'
	begin
		insert into loadrequirement (ord_hdrnumber, lrq_sequence, lrq_equip_type, lrq_type, lrq_not, 
			lrq_manditory, lrq_quantity, cmp_id, def_id_type, mov_number, 
			lrq_default, cmd_code)
		select @neword, lrq_sequence, lrq_equip_type, lrq_type, lrq_not, 
			lrq_manditory, lrq_quantity, cmp_id, def_id_type, @newmov,
			lrq_default, cmd_code
		  from loadrequirement lrq
		 where ord_hdrnumber = @tempord
		 
		if (select left(upper(isnull(gi_string1,'N')),1) from generalinfo where gi_name = 'CloneOrdersDefaultLRQ') = 'Y'
		begin
			insert into loadrequirement (ord_hdrnumber, lrq_sequence, lrq_equip_type, lrq_type, lrq_not, 
				lrq_manditory, lrq_quantity, cmp_id, def_id_type, mov_number, 
				lrq_default, cmd_code)
			select @neword, lrq_sequence, lrq_equip_type, lrq_type, lrq_not, 
				lrq_manditory, lrq_quantity, cmp_id, def_id_type, @newmov,
				lrq_default, cmd_code
			  from loadrequirement lrq
			 where mov_number = @mastermov and isnull(lrq_default,'N') = 'X'
		end
	end
end

exec dbo.update_assetassignment @newmov

exec dbo.update_audit @newmov

exec dbo.update_move_light @newmov

select @masterlgh = 0, @newlgh = 0
while 1=1
begin
	select @masterlgh = min(lgh_number)
	  from stops
	 where mov_number = @mastermov
	   and lgh_number > @masterlgh
	if @masterlgh is null break

	if (select count(1) from schedule_table where sch_number = @schnumber and lgh_number = @masterlgh) = 0
		select @copypay = 'F'
		     , @copylghtypes = 'F'
		     , @masterlghtype1 = 'UNK'
		     , @masterlghtype2 = 'UNK'
		     , @masterlghcomment = ''
	else
		select @copypay = sch_copy_paydetails
		     , @copylghtypes = sch_copy_lghtypes
		     , @masterlghtype1 = ISNULL(lgh_type1,'UNK')
		     , @masterlghtype2 = ISNULL(lgh_type2,'UNK')
		     , @masterlghcomment = ISNULL(lgh_comment,'')
		  from schedule_table
		 where sch_number = @schnumber
		   and lgh_number = @masterlgh

	select @newlgh = min(lgh_number)
	  from legheader
	 where mov_number = @newmov
	   and lgh_number > @newlgh
	if @newlgh is null break

	--copy paydetails
	if @copylghtypes = 'T'
		update legheader
		   set lgh_type1 = @masterlghtype1
		     , lgh_type2 = @masterlghtype2
		     , lgh_comment = @masterlghcomment
		 where lgh_number = @newlgh
		   and (ISNULL(lgh_type1,'UNK') <> @masterlghtype1 
		     or ISNULL(lgh_type2,'UNK') <> @masterlghtype2 
		     or ISNULL(lgh_comment,'') <> @masterlghcomment)
end

exec dbo.cleanup_asgns

exec dbo.validate_move @newmov

select @@ordnumber = convert(varchar(12), new_ord_hdrnumber) from @orderxref where master_ord_hdrnumber = @masterord

update orderheader
   set ord_editradingpartner = @tpid
		,ord_edipurpose = 'N'
 where ord_number = @@ordnumber

return 1

GO
GRANT EXECUTE ON  [dbo].[dx_copy_master_order_from_schedule] TO [public]
GO
