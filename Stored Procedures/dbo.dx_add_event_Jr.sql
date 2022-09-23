SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  procedure [dbo].[dx_add_event_Jr]
	@stp_number int,
	@event varchar(6),
	@@evt_number int OUTPUT
AS
/* se cambia el campo evt_pu_dr por el valor de 'NONE' atte Jr*/

DECLARE @evt_sequence INT

IF ISNULL(@event, '') = '' RETURN -3
IF (SELECT COUNT(*) FROM eventcodetable WHERE abbr = @event) = 0 RETURN -3

IF (SELECT COUNT(*) FROM event WHERE stp_number = @stp_number and evt_sequence = 1) <> 1 RETURN -2

SELECT @evt_sequence = MAX(evt_sequence) + 1 FROM event WHERE stp_number = @stp_number
EXEC @@evt_number = dbo.getsystemnumber 'EVTNUM', NULL

INSERT event 
	(ord_hdrnumber, stp_number, evt_eventcode, evt_number, evt_startdate, evt_enddate,
	 evt_status, evt_earlydate, evt_latedate, evt_weight, evt_weightunit, fgt_number, 
	 evt_count, evt_countunit, evt_volume, evt_volumeunit, evt_pu_dr, evt_sequence, evt_driver1,
	 evt_driver2, evt_tractor, evt_trailer1, evt_trailer2, evt_chassis, evt_dolly,
	 evt_carrier, evt_refype, evt_refnum, evt_reason, skip_trigger, evt_mov_number)
SELECT ord_hdrnumber, stp_number, @event, @@evt_number, evt_startdate, evt_enddate,
	 evt_status, evt_earlydate, evt_latedate, evt_weight, evt_weightunit, fgt_number, 
	 evt_count, evt_countunit, evt_volume, evt_volumeunit, 'NONE', @evt_sequence, 'UNKNOWN',
	 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'UNKNOWN',
	 'UNKNOWN', 'UNK', 'UNKNOWN', 'UNK', 1, evt_mov_number
  FROM event WHERE stp_number = @stp_number AND evt_sequence = 1

IF @@ERROR <> 0 RETURN -1

RETURN 1

GO
