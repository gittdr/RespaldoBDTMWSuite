SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


/*
  PTS 17348 -- BL (8/19/2003)

  NEW PROC  (for Express Leasing)

	Will CREATE  'PUL' event for the given stop
*/

CREATE PROC [dbo].[add_pul_event_sp] (@stp_number INT, @evt_mov_number INT, @fgt_number INT, 
		@evt_startdate DATETIME, @evt_enddate DATETIME, @evt_earlydate DATETIME, @evt_latedate DATETIME, 
		@evt_trailer1 VARCHAR(13), @evt_trailer2 VARCHAR(13), @evt_weight float, @evt_weightunit varchar(6), 
		@evt_count decimal(10,2), @evt_countunit varchar(6))
AS

DECLARE
	@evt_number int, @evt_sequence int, @return_code int, @evt_pu_dr varchar(6), @evt_reason varchar(6), 
	@evt_driver1 varchar(8), @evt_driver2 varchar(8), @evt_tractor varchar(8), @evt_carrier varchar(8),
	@evt_status VARCHAR(6), @evt_eventcode VARCHAR(6), @ord_hdrnumber INT, @skip_trigger tinyint

BEGIN
	-- Set Defaults
	Set @evt_driver1 = 'UNKNOWN'
	Set @evt_driver2 = 'UNKNOWN' 
	Set @evt_tractor = 'UNKNOWN'
	Set @evt_carrier = 'UNKNOWN'
	Set @evt_reason = 'UNK'
	Set @evt_status = 'OPN'
	Set @skip_trigger = 1
	Set @evt_pu_dr = 'DRP'
	Set @evt_eventcode = 'PUL'
	Set @ord_hdrnumber = 0

	-- Get next Sequence Number
	SELECT @evt_sequence = isnull(max(evt_sequence), 0) + 1
	FROM event
	WHERE stp_number = @stp_number

	-- Stop processing if original event does NOT already exist
	if @evt_sequence = 1
		return -1

	-- Get new Event Number
	EXECUTE @evt_number = getsystemnumber 'EVTNUM', ''

	-- Insert NEW Event
	INSERT INTO Event(ord_hdrnumber, 
		stp_number, 
		evt_eventcode, 
		evt_number, 
		evt_startdate, 
		evt_enddate, 
		evt_status, 
		evt_earlydate, 
		evt_latedate,
		evt_weight, 
		evt_weightunit, 
		fgt_number,
		evt_count, 
		evt_countunit, 
		evt_pu_dr, 
		evt_sequence, 
		evt_driver1, 
		evt_driver2, 
		evt_tractor, 
		evt_trailer1, 
		evt_trailer2, 
		evt_carrier,
		evt_reason, 
		skip_trigger, 
		evt_mov_number)
	VALUES (@ord_hdrnumber, 
		@stp_number, 
		@evt_eventcode, 
		@evt_number, 
		@evt_startdate, 
		@evt_enddate, 
		@evt_status, 
		@evt_earlydate, 
		@evt_latedate, 
		@evt_weight,
		@evt_weightunit, 
		@fgt_number,
		@evt_count, 
		@evt_countunit, 
		@evt_pu_dr, 
		@evt_sequence, 
		@evt_driver1, 
		@evt_driver2, 
		@evt_tractor, 
		@evt_trailer1, 
		@evt_trailer2, 
		@evt_carrier,
		@evt_reason, 
		@skip_trigger, 
		@evt_mov_number)

	Set @return_code = @@Error

	return @return_code
END

GO
GRANT EXECUTE ON  [dbo].[add_pul_event_sp] TO [public]
GO
