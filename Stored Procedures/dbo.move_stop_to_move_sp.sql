SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[move_stop_to_move_sp]
	@src_mov_number int,
	@src_stp_number int,
	@mov_number int,
	@stp_number int
AS

/**
 * 
 * NAME:
 * dbo.move_stop_to_move_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * 	Custom stored proc. GE specific.
 *	Move a stop from one Movement to another.
 *
 * RETURNS:
 * None
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @src_mov_number int	- Move number of the stop to move.
 * 002 - @src_stp_number int	- Stop number of the stop to move.
 * 003 - @mov_number int	- Move number of the destination move.
 * 004 - @stp_number int	- Stop number to insert the stop before.
 * 
 * REVISION HISTORY:
 * 08/02/2005.01 - MRH ? Created
 * 08/30/2005.02 - MRH
 * 06/19/2009.03 - MRH PTS 47942
 * 05/07/2011.04 - Add logic the move reference numbers when stop being moved is a backhaul (has LOAD reference type).  Also update events on the last stop to reflect DRL on backhaul.
 **/
Declare @stpmfhSequence int
Declare @SyncFetchStatus int
Declare @Current_Stp_number int
Declare @ord_hdrnumber int
Declare @lgh_number int
Declare @start_sequence int	-- First stop to move
Declare @end_sequence int	-- Last stop to move
Declare @cmp_id varchar(8)
Declare @Sequence_to_move int	-- Sequence of the stop we were reqested to move
Declare @cursor_cmp_id varchar(8)
Declare @cursor_stp_mfh_sequence int
Declare @otm_load_num varchar(30)
Declare @maxSequence int
Declare @src_last_stp_number int
Declare @src_ord_hdrnumber int

-- Find the stops with the same company.
select @cmp_id = cmp_id, @Sequence_to_move = stp_mfh_sequence from stops where stp_number = @src_stp_number
select @otm_load_num =stp_refnum from stops where mov_number = @src_mov_number and cmp_id=@cmp_id and stp_reftype = 'LOAD' and stp_type in ('PUP','NONE')


if (select count(0) from stops where @cmp_id = cmp_id and mov_number = @src_mov_number) > 1
begin

	DECLARE CompanyStopsCursor SCROLL CURSOR FOR
	select stp_number, cmp_id, stp_mfh_sequence from stops where mov_number = @src_mov_number order by stp_mfh_sequence

	OPEN CompanyStopsCursor

	-- Move the cursor forward to the row we have been asked to move
	Fetch next from CompanyStopsCursor
	into @Current_Stp_number, @cursor_cmp_id, @cursor_stp_mfh_sequence
	select @SyncFetchStatus = @@fetch_status

	While @SyncFetchStatus = 0 and @Current_Stp_number <> @src_stp_number
	Begin
		Fetch next from CompanyStopsCursor
		into @Current_Stp_number, @cursor_cmp_id, @cursor_stp_mfh_sequence
		select @SyncFetchStatus = @@fetch_status
	End

	-- Move the cursor back to the first stop to move
	While @SyncFetchStatus = 0 and @cursor_cmp_id = @cmp_id
	Begin
		Fetch Prior from CompanyStopsCursor
		into @Current_Stp_number, @cursor_cmp_id, @cursor_stp_mfh_sequence
		select @SyncFetchStatus = @@fetch_status
	End
	if @SyncFetchStatus <> 0	-- Begining row reached?
	begin
		select @start_sequence = 0	-- Yep. Force first row.
		select @SyncFetchStatus = 0	-- Reset status
	end
	else
		select @start_sequence = @cursor_stp_mfh_sequence

	-- Move the cursor forward to the row we have been asked to move (again)
	While @SyncFetchStatus = 0 and @Current_Stp_number <> @src_stp_number
	Begin
		Fetch next from CompanyStopsCursor
		into @Current_Stp_number, @cursor_cmp_id, @cursor_stp_mfh_sequence
		select @SyncFetchStatus = @@fetch_status
	End

	-- Move the cursor forward to the last row we need to move
	While @SyncFetchStatus = 0 and @cursor_cmp_id = @cmp_id
	Begin
		Fetch next from CompanyStopsCursor
		into @Current_Stp_number, @cursor_cmp_id, @cursor_stp_mfh_sequence
		select @SyncFetchStatus = @@fetch_status
	End
	if @SyncFetchStatus = 0	-- Last row reached?
		select @end_sequence = @cursor_stp_mfh_sequence
	else					-- Yep. Use the last row
		select @end_sequence = max(stp_mfh_sequence) + 1 from stops where mov_number = @src_mov_number

	Close CompanyStopsCursor
	Deallocate CompanyStopsCursor
end
else	-- Only moving one stop. Change set the start and end to the row we are moving.
begin
	select @start_sequence = @Sequence_to_move - 1
	select @end_sequence = @Sequence_to_move + 1
end

--Resequence the stops
DECLARE SequenceCursor CURSOR FOR
select stp_number from stops where mov_number = @mov_number order by stp_mfh_sequence

OPEN SequenceCursor

set @stpmfhSequence = 1

Fetch next from SequenceCursor
into @Current_Stp_number
select @SyncFetchStatus = @@fetch_status

While @SyncFetchStatus = 0
Begin
	-- First check to see if we are to insert the new stop
	if @Current_Stp_number = @stp_number
	begin
		while @start_sequence < @end_sequence - 1
		begin
			select @ord_hdrnumber = ord_hdrnumber, @lgh_number = lgh_number from stops where stp_number = @Current_Stp_number
			select @src_stp_number = stp_number from stops where mov_number = @src_mov_number and stp_sequence = @start_sequence +1
			update stops set skip_trigger = 1, stp_mfh_sequence = @stpmfhSequence, stp_sequence = @stpmfhSequence, 
				mov_number = @mov_number, ord_hdrnumber = @ord_hdrnumber, lgh_number = @lgh_number 
				where mov_number = @src_mov_number and stp_number = @src_stp_number
			update event set skip_trigger = 1, evt_mov_number = @mov_number where stp_number = @src_stp_number
			-- Delete any asset assignments on the stop
			delete from assetassignment where mov_number = @src_mov_number and evt_number in (select evt_number from event where stp_number = @src_stp_number)
			select @stpmfhSequence = @stpmfhSequence + 1
			select @start_sequence = @start_sequence + 1
		end
	end

	-- Set the stp_mfh_sequence number
	update stops set stp_mfh_sequence = @stpmfhSequence, stp_sequence = @stpmfhSequence where current of SequenceCursor

	select @stpmfhSequence = @stpmfhSequence + 1

	Fetch next from SequenceCursor
	into @Current_Stp_number
	select @SyncFetchStatus = @@fetch_status
End

if isnull(@otm_load_num ,'') <> '' -- we moved a backhaul stop
	begin -- updating stops/event on last stop drop since we now have pickup up a backhaul on prior stop.  
		update stops set skip_trigger = 1, stp_type = 'DRP' , stp_event='DRL', stp_reftype = 'LOAD', stp_refnum = @otm_load_num where mov_number = @mov_number and stp_number = @Current_Stp_number and stp_event = 'DMT'
		update event set skip_trigger = 1, evt_pu_dr ='DRP', evt_eventcode='DRL' where evt_mov_number = @mov_number and stp_number = @Current_Stp_number and evt_eventcode='DMT'
		set @src_last_stp_number = @Current_Stp_number -- we'll use this later when we update the reference numbers
	end

-- Now resequence the orginal order.
Close SequenceCursor
Deallocate SequenceCursor

DECLARE SequenceCursor2 CURSOR FOR
select stp_number from stops where mov_number = @src_mov_number order by stp_mfh_sequence

OPEN SequenceCursor2

set @stpmfhSequence = 1

Fetch next from SequenceCursor2
into @Current_Stp_number
select @SyncFetchStatus = @@fetch_status

While @SyncFetchStatus = 0
Begin

	-- Set the stp_mfh_sequence number
	update stops set stp_mfh_sequence = @stpmfhSequence, stp_sequence = @stpmfhSequence where current of SequenceCursor2

	select @stpmfhSequence = @stpmfhSequence + 1

	Fetch next from SequenceCursor2
	into @Current_Stp_number
	select @SyncFetchStatus = @@fetch_status
End

if isnull(@otm_load_num ,'') <> ''  -- we moved a backhaul stop
	begin
		--Orderheader reference number update:
		Select @src_ord_hdrnumber = ord_hdrnumber from orderheader where mov_number = @src_mov_number
		select @maxSequence = isnull(max(ref_sequence),0) from referencenumber where  ref_tablekey=  @ord_hdrnumber and ref_table='orderheader'
		Update referencenumber set ref_tablekey = @ord_hdrnumber, ord_hdrnumber =  @ord_hdrnumber, ref_sequence = @maxSequence + 1 where ord_hdrnumber = @src_ord_hdrnumber and ref_table='orderheader' and ref_type = 'LOAD' and ref_number = @otm_load_num
		--Stops reference number update (updating the last stop on the route, removing to backhaul refence numbers):
		Update referencenumber set ref_tablekey = @src_last_stp_number,ord_hdrnumber= @ord_hdrnumber where ref_tablekey = @Current_Stp_number and ref_table='stops' and ref_type in ('LOAD','PO','GLOG') 
		--Stops / event update since we no longer are dropping a backhaul at the last stop on the route:
		update stops set skip_trigger = 1, stp_type = 'NONE' , stp_event='DMT', stp_reftype = '', stp_refnum = NULL where mov_number = @src_mov_number and stp_number = @Current_Stp_number and stp_event = 'DRL'
		update event set skip_trigger = 1, evt_pu_dr ='NONE', evt_eventcode='DMT' where evt_mov_number = @src_mov_number and stp_number = @Current_Stp_number and evt_eventcode='DRL'
	end

Close SequenceCursor2
Deallocate SequenceCursor2

GO
GRANT EXECUTE ON  [dbo].[move_stop_to_move_sp] TO [public]
GO
