SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
@ftype:
	LOAD
	UNLOAD
	CONLOAD
	CONUNLOAD
	HOOK
	UNHOOK
*/
CREATE PROCEDURE [dbo].[tm_nse_validate_stop] @stp_number int, 
					   @stp_seq int, 
					   @city varchar(50), 
					   @ftype varchar(10) 
AS

SET NOCOUNT ON 

DECLARE @stp_num_valid int,
	 @stp_event varchar(6),
	 @stp_dispatched_sequence int,
	 @ord_hdrnumber int

select @stp_num_valid=0, @ord_hdrnumber=ord_hdrnumber, @stp_event=stp_event, @stp_dispatched_sequence=stp_dispatched_sequence 
  from stops where stp_number=@stp_number

IF @stp_seq > 0 AND @stp_seq<>@stp_dispatched_sequence	
	-- driver entered stop sequence as appeared on Load Assignment
	-- first non-update (flag 4) UpdateMove view produced stop number different that entered by driver
	-- let's see which stop driver had in mind...
	select @stp_number=stp_number, @stp_event=stp_event, @stp_dispatched_sequence=stp_dispatched_sequence 
	  from stops where ord_hdrnumber=@ord_hdrnumber and stp_dispatched_sequence=@stp_seq 

IF @ftype = 'LOAD' AND @stp_event='LLD'
	SELECT @stp_num_valid=@stp_number
ELSE IF @ftype = 'UNLOAD' AND @stp_event='LUL'
	SELECT @stp_num_valid=@stp_number
ELSE IF @ftype = 'CONLOAD' AND @stp_event='LLD'
	SELECT @stp_num_valid=@stp_number
ELSE IF @ftype = 'CONUNLOAD' AND @stp_event='LUL'
	SELECT @stp_num_valid=@stp_number
ELSE IF @ftype = 'HOOK' AND @stp_event='HPL' OR @stp_event='HMT'
	SELECT @stp_num_valid=@stp_number
ELSE IF @ftype = 'UNHOOK' AND @stp_event='DRL' OR @stp_event='DMT'
	SELECT @stp_num_valid=@stp_number

IF @stp_num_valid=0
	RAISERROR ('Form of type %s is trying to update stop %d of type %s on order %d. Action aborted. Please reconcile manually.', 16, 1, @ftype, @stp_number, @stp_event, @ord_hdrnumber)

select @stp_num_valid, ABS(@stp_number-@stp_num_valid)

GO
GRANT EXECUTE ON  [dbo].[tm_nse_validate_stop] TO [public]
GO
