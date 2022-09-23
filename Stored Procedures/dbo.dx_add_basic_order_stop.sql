SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[dx_add_basic_order_stop] 
	@mov_number int, @ord_hdrnumber int, @lgh_number int, @stp_number int, 
	@fgt_number int, @evt_number int, @event varchar(6), @stp_sequence int, 
	@stp_mfh_sequence int, @cmd_code varchar(8), 
	@cmp_id varchar(8), @stp_city int, 
	@stp_contact  varchar(30), @stp_phonenumber  varchar(20), 
	@arrivaldate datetime, 	@earlydate datetime, @latedate datetime,
	@weight float, @weightunit varchar(6), @count smallint,
	@countunit varchar(6), @volume float, @volumeunit varchar(6),
	@stp_reftype varchar(6),@stp_refnum varchar(30),
    @fgt_reftype varchar(6), @fgt_refnum varchar(30), @ord_status varchar(6) = 'AVL'
AS

  DECLARE @pupdrp varchar(8), @cmd_name varchar(60), @cmp_name varchar(30),
	@stp_state varchar(2),@stp_address1 varchar(40),@stp_address2 varchar(40),
	@stp_zip varchar(9),@status_code int,@stp_status varchar(6), @retcode int

  SELECT @cmd_name = ISNULL(cmd_name,'UNKNOWN') 
  FROM commodity 
  WHERE cmd_code=@cmd_code

  SELECT @pupdrp = fgt_event 
  FROM eventcodetable 
  WHERE abbr=@event

  SELECT @cmp_name = cmp_name 
  FROM company 
  WHERE cmp_id = @cmp_id

  SELECT @stp_state=cty_state 
  FROM city 
  WHERE cty_code=@stp_city

	/* determine address information from the company if provided    */

 IF @cmp_id = 'UNKNOWN'
   BEGIN
     SELECT @stp_address1 = ''
     SELECT @stp_address2 = ''
     SELECT @stp_zip = ''
     SELECT cmp_name = 'UNKNOWN'
   END
 ELSE
   SELECT @stp_address1 = cmp_address1,
          @stp_address2 = cmp_address2,
          @stp_zip = cmp_zip,
          @cmp_name = cmp_name,
          @stp_contact = case isnull(@stp_contact,'') when '' then ISNULL(cmp_contact,'') else @stp_contact end,
		  @stp_phonenumber = case isnull(@stp_phonenumber,'') when '' then ISNULL(cmp_primaryphone,'') else @stp_phonenumber end
   FROM company
   WHERE cmp_id = @cmp_id

 SELECT @status_code = code from labelfile where labeldefinition = 'DispStatus' and abbr = @ord_status
 IF (select upper(isnull(gi_string1,'N')) from generalinfo where gi_name = 'DisplayPendingOrders') = 'Y'
	SELECT @stp_status = CASE WHEN @status_code >= 190 THEN 'OPN' ELSE 'NON' END
 ELSE
	SELECT @stp_status = CASE WHEN @status_code >= 200 THEN 'OPN' ELSE 'NON' END

INSERT INTO freightdetail 
	( stp_number, fgt_sequence, fgt_number, 		--1	
	cmd_code, fgt_description, fgt_reftype, 		--2
	fgt_refnum,fgt_pallets_in, 				--3
	fgt_pallets_out, fgt_pallets_on_trailer, fgt_carryins1, --4	
	fgt_carryins2, skip_trigger, fgt_quantity,		--5
	fgt_weight, fgt_weightunit, fgt_count,			--6
	fgt_countunit, fgt_volume, fgt_volumeunit)		--7
	
VALUES ( @stp_number, 1, @fgt_number, 				--1
	@cmd_code, @cmd_name, @fgt_reftype,			--2
	@fgt_refnum,0,					--3
	0, 0, 0,						--4
	0, 1, 0,						--5
	@weight, @weightunit, @count,				--6
	@countunit, @volume, @volumeunit)			--7 

SELECT @retcode = @@error
if @retcode<>0
begin
	exec dx_log_error 0, 'INSERT INTO freightdetail Failed', @retcode, ''
	return -1
end

INSERT INTO event 
	( evt_driver1, evt_driver2, evt_tractor, 		--1
	evt_trailer1, evt_trailer2, ord_hdrnumber, 		--2
	stp_number, evt_startdate, evt_earlydate, 		--3
	evt_latedate, evt_enddate, evt_reason, 			--4
	evt_carrier, evt_sequence, fgt_number, 			--5
	evt_number, evt_pu_dr, evt_eventcode, 			--6
	evt_status , skip_trigger, evt_departure_status) 				--7
values ('UNKNOWN', 'UNKNOWN', 'UNKNOWN', 			--1
	'UNKNOWN', 'UNKNOWN', @ord_hdrnumber, 			--2
	@stp_number, @arrivaldate, @earlydate, 			--3	
	@latedate, @arrivaldate, 'UNK', 			--4
	'UNKNOWN', 1, @fgt_number, 				--5
	@evt_number, @pupdrp, @event, 				--6
	@stp_status, 1, @stp_status)						--7

SELECT @retcode = @@error
if @retcode<>0
begin
	exec dx_log_error 0, 'INSERT INTO event Failed', @retcode, ''
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
	stp_reftype, stp_refnum,stp_loadstatus, stp_redeliver,	--11
	stp_phonenumber, stp_delayhours, stp_zipcode, 		--12
	stp_ooa_stop, stp_address, stp_contact, 		--13
	stp_address2 , skip_trigger, stp_phonenumber2,		--14
	stp_weight, stp_weightunit, stp_count,                  --15 
	stp_countunit, stp_volume, stp_volumeunit,
	stp_departure_status) 		--16
VALUES 	( 'UNKNOWN', @ord_hdrnumber, @stp_number, 		--1
	@stp_city, @arrivaldate, @earlydate,			--2 
	@latedate, @cmp_id, @cmp_name,				--3 
	@arrivaldate, 'UNK', @lgh_number, 			--4
	'UNK', @stp_sequence, @stp_mfh_sequence, 		--5
	@cmd_code, @cmd_name, @pupdrp, 				--6
	@event, @stp_status, 0, 					--7
	@mov_number, @arrivaldate, 'Y', 			--8
	'UNK', 'UNK', 'UNK', 					--9
	'UNK', @stp_state, 'AVL', 				--10
	@stp_reftype,@stp_refnum, 'LD', '0', 			--11
	@stp_phonenumber, 0, @stp_zip,				--12 
	0, @stp_address1, @stp_contact, 			--13
	@stp_address2 , 1, '',			                --14
	@weight, @weightunit, @count,				--15
	@countunit, @volume, @volumeunit,
	@stp_status)			--16 

SELECT @retcode = @@error
  IF @retcode<>0
    BEGIN
	exec dx_log_error 0, 'INSERT INTO stop Failed', @retcode, ''
	return -1
    END

  /* add stop and freight ref numbers */
  IF @stp_reftype <> '' 
     INSERT INTO referencenumber(
	ref_tablekey,
	ref_type,
	ref_number,
	ref_sequence,
	ref_table,
	ref_sid,
	ref_pickup,
	ord_hdrnumber)
    VALUES  (@stp_number,
	@stp_reftype,
	@stp_refnum,
	1,
	'STOPS',
	'Y',
	Null,
	@ord_hdrnumber)

  IF @fgt_reftype <> '' 
     INSERT INTO referencenumber(
	ref_tablekey,
	ref_type,
	ref_number,
	ref_sequence,
	ref_table,
	ref_sid,
	ref_pickup,
	ord_hdrnumber)
    VALUES  (@fgt_number,
	@fgt_reftype,
	@fgt_refnum,
	1,
	'FREIGHTDETAIL',
	'Y',
	Null,
	@ord_hdrnumber)

  RETURN 1


GO
GRANT EXECUTE ON  [dbo].[dx_add_basic_order_stop] TO [public]
GO
