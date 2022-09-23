SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[aeom_insert_stop] @mov_number int,
			@ord_hdrnumber int, 
			@lgh_number int, 
			@stp_number int, 
			@fgt_number int, 
			@evt_number int, 
			@event varchar(6), 
			@stp_sequence int, 
			@stp_mfh_sequence int, 
			@cmd_code varchar(8), 
			@cmp_id varchar(8), 
			@stp_city int, 
			@stp_zip varchar(9),
			@stp_address varchar(40), 
			@stp_address2 varchar(40),
			@stp_contact  varchar(30), 
			@stp_phonenumber  varchar(20), 
			@stp_phonenumber2  varchar(20), 
			@arrivaldate datetime, 
			@earlydate datetime, 
			@latedate datetime,
			@weight float, 
			@weightunit varchar(6), 
			@count smallint,
			@countunit varchar(6), 
			@volume float, 
			@volumeunit varchar(6),
			@qty float, 
			@qtyunit varchar(6),
			@stp_transfer_stp int,
			@mfh_number int,
			@driver1 varchar(8),
			@driver2 varchar(8),
			@tractor varchar(8),
			@trailer1 varchar(13),
			@trailer2 varchar(13),
			@carrier varchar(8),
			@stp_transfer_type char(3)
as
declare @pupdrp varchar(8), @cmd_name varchar(60), @cmp_name varchar(30),
                @stp_state varchar(2)

select @cmd_name = cmd_name from commodity where cmd_code=@cmd_code
select @pupdrp = fgt_event from eventcodetable where abbr=@event
select @cmp_name = cmp_name from company where cmp_id = @cmp_id
select @stp_state=cty_state from city where cty_code=@stp_city

INSERT INTO freightdetail 
	( stp_number, fgt_sequence, fgt_number, 		--1	
	cmd_code, fgt_description, fgt_reftype, 		--2
	tare_weight, tare_weightunit, fgt_pallets_in, 		--3
	fgt_pallets_out, fgt_pallets_on_trailer, fgt_carryins1, --4	
	fgt_carryins2, skip_trigger, fgt_quantity,		--5
	fgt_weight, fgt_weightunit, fgt_count,			--6
	fgt_countunit, fgt_volume, fgt_volumeunit)		--7
	
VALUES ( @stp_number, 1, @fgt_number, 				--1
	@cmd_code, @cmd_name, 'BL#',				--2
	@qty, @qtyunit, 0,					--3
	0, 0, 0,						--4
	0, 1, @qty,						--5
	@weight, @weightunit, @count,				--6
	@countunit, @volume, @volumeunit)			--7 

if @@error<>0
begin
	--exec at_log_error 0, "INSERT INTO freightdetail Failed", @@error, ''
	return -1
end

INSERT INTO event 
	( evt_driver1, evt_driver2, evt_tractor, 		--1
	evt_trailer1, evt_trailer2, ord_hdrnumber, 		--2
	stp_number, evt_startdate, evt_earlydate, 		--3
	evt_latedate, evt_enddate, evt_reason, 			--4
	evt_carrier, evt_sequence, fgt_number, 			--5
	evt_number, evt_pu_dr, evt_eventcode, 			--6
	evt_status , skip_trigger) 				--7
values (@driver1, @driver2, @tractor, 			--1
	@trailer1, @trailer2, @ord_hdrnumber, 			--2
	@stp_number, @arrivaldate, @earlydate, 			--3	
	@latedate, @arrivaldate, 'UNK', 			--4
	@carrier, 1, @fgt_number, 				--5
	@evt_number, @pupdrp, @event, 				--6
	'DNE' , 1)						--7

if @@error<>0
begin
	--exec at_log_error 0, "INSERT INTO event Failed", @@error, ''
	return -1
end

INSERT INTO stops 
	( trl_id, ord_hdrnumber, stp_number, 			--1
	stp_city, stp_arrivaldate, stp_schdtearliest, 		--2
	stp_schdtlatest, cmp_id, cmp_name, 			--3
	stp_departuredate, stp_reasonlate, lgh_number, 		--4
	stp_reasonlate_depart, stp_sequence, stp_mfh_sequence, 	--5	
	cmd_code, stp_description, stp_type, 			--6
	stp_event, stp_status, mfh_number, 			--7
	mov_number, stp_origschdt, stp_paylegpt, 		--8
	stp_region1, stp_region2, stp_region3, 			--9
	stp_region4, stp_state, stp_lgh_status, 		--10
	stp_reftype, stp_loadstatus, stp_redeliver, 		--11
	stp_phonenumber, stp_delayhours, stp_zipcode, 		--12
	stp_ooa_stop, stp_address, stp_contact, 		--13
	stp_address2 , skip_trigger, stp_phonenumber2,		--14
	stp_weight, stp_weightunit, stp_count,                  --15 
	stp_countunit, stp_volume, stp_volumeunit, stp_transfer_stp, stp_transfer_type, stp_type1) 	--16
VALUES 	( @trailer1, @ord_hdrnumber, @stp_number, 		--1
	@stp_city, @arrivaldate, @earlydate,			--2 
	@latedate, @cmp_id, @cmp_name,				--3 
	@arrivaldate, 'UNK', @lgh_number, 			--4
	'UNK', @stp_sequence, @stp_mfh_sequence, 		--5
	@cmd_code, @cmd_name, 'AEM', 				--6
	@event, 'DNE', @mfh_number, 					--7
	@mov_number, @arrivaldate, 'Y', 			--8
	'UNK', 'UNK', 'UNK', 					--9
	'UNK', @stp_state, 'AVL', 				--10
	'BL#', 'LD', '0', 					--11
	@stp_phonenumber, 0, @stp_zip,				--12 
	0, @stp_address, @stp_contact, 				--13
	@stp_address2 , 1, @stp_phonenumber2,			--14
	@weight, @weightunit, @count,				--15
	@countunit, @volume, @volumeunit, @stp_transfer_stp, @stp_transfer_type, 'AEM')			--16 
if @@error<>0
begin
	--exec at_log_error 0, "INSERT INTO stop Failed", @@error, ''
	return -1
end

GO
GRANT EXECUTE ON  [dbo].[aeom_insert_stop] TO [public]
GO
