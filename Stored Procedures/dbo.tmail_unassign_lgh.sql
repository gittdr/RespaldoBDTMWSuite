SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_unassign_lgh] 
	@p_lghnum varchar(11),
	@p_flags varchar(11) = '1'
		-- +1 = un-actualize (default); 
		-- +2 = un-assign drivers; 
		-- +4 = un-assign tractor;
		-- +8 = un-assign trailers;
		-- +16 = delete beginning deadhead

AS

SET NOCOUNT ON 

declare 
	@evtnum int,
	@evtdrv1 varchar(8),
	@evtdrv2 varchar(8),
	@evttrc varchar(8),
	@evttrl1 varchar(8),
	@evttrl2 varchar(8),
	@flags int,
	@flg_unact int,
	@flg_unasndrv int,
	@flg_unasntrc int,
	@flg_unasntrl int,
	@flg_deldh int,
	@lghnum int,
	@lghstatus varchar(6),
	@movnum int,
	@ordhdrnum int,
	@ordstatus varchar(6),
	@stpnum int,
	@stpstatus varchar(6),
	@stpevt varchar(6),
	@stpct int,
	@stpseq int,
	@stpnewseq int,
	@stpmaxseq int,
	@stpordseq int,
	@stp_firstpup_seq int,
	@updated int,
	@deleted int

if isnull(@p_lghnum, '') = '' 
	BEGIN
	RAISERROR('Legheader Number is missing.', 16, 1)
	RETURN 2
	END

if isnumeric(@p_lghnum) = 0 
	BEGIN
	RAISERROR('Legheader Number %s is not numeric.', 16, 1, @p_lghnum)
	RETURN 2
	END

if @p_flags = '' SET @p_flags = '1'
if isnumeric(@p_flags) = 0 
	BEGIN
	RAISERROR('Flags %s is not numeric.', 16, 1, @p_flags)
	RETURN 2
	END

set @flags = convert(int, @p_flags)

set @flg_unact = @flags & 1
set @flg_unasndrv = @flags & 2
set @flg_unasntrc = @flags & 4
set @flg_unasntrl = @flags & 8
set @flg_deldh = @flags & 16

if @flg_unact = 0 and @flg_unasndrv = 0 and @flg_unasntrc = 0 and @flg_unasntrl = 0 and @flg_deldh = 0
	BEGIN
	RAISERROR('Flags %s does not specify any operation.', 16, 1, @p_flags)
	RETURN 2
	END
 
set @lghnum = convert(int, @p_lghnum)

if @lghnum < 1
	BEGIN
	RAISERROR('Legheader Number %d is not positive.', 16, 1, @lghnum)
	RETURN 2
	END

select @movnum = isnull(mov_number,0), @lghstatus = isnull(lgh_outstatus,'') from legheader (NOLOCK) where lgh_number = @lghnum

if @lghstatus = 'CMP'
	BEGIN
	RAISERROR('Legheader %d is complete, cannot change.', 16, 1, @lghnum)
	RETURN 3 
	END

set @updated = 0

select @stpct = count(stp_number) from stops (NOLOCK) where lgh_number = @lghnum

select @stpmaxseq = max(isnull(stp_mfh_sequence,0)) from stops (NOLOCK) where lgh_number = @lghnum
set @stpmaxseq = isnull(@stpmaxseq,0)

select @stp_firstpup_seq = min(isnull(stp_mfh_sequence,0)) from stops (NOLOCK) where lgh_number = @lghnum 
	and (ord_hdrnumber > 0 or stp_event = 'HLT' or stp_event = 'HCT')
set @stp_firstpup_seq = isnull(@stp_firstpup_seq,0)

BEGIN TRANSACTION

/* Un-actualize */

if @flg_unact > 0
	BEGIN
	if exists (select stp_number from stops (NOLOCK) where lgh_number = @lghnum and stp_event = 'DLT')
		if exists (select stp_number from stops (NOLOCK)
			where mov_number = @movnum and stp_mfh_sequence > @stpmaxseq 
				and stp_event in ('HLT', 'HCT') and stp_status = 'DNE')
			BEGIN
			RAISERROR('This trip segment %d has a dropped loaded trailer (DLT) that has been hooked (HLT or HCT) on a later segment of the move %d; cannot un-actualize.', 16, 1, @lghnum, @movnum)
			RETURN 3 
			END
	set @stpseq = @stpmaxseq
	while (@stpseq > 0)
		BEGIN
			select @stpstatus = isnull(stp_status,''), @stpnum = stp_number, @ordhdrnum = ord_hdrnumber, @stpordseq = isnull(stp_sequence,0) 
			from  stops (NOLOCK)
			where lgh_number = @lghnum and stp_mfh_sequence = @stpseq
		if @stpstatus = 'DNE'
			BEGIN
			update stops
				set	stp_status = 'OPN',
					stp_departure_status = 'OPN'
				where	stp_number = @stpnum 
			set @updated = 1
			END
		if @ordhdrnum <> 0 
			if @stpordseq = 1
				update orderheader 
					set ord_status = 'PLN'
					where ord_hdrnumber = @ordhdrnum and ord_status <> 'PLN'
			else
				update orderheader
					set ord_status = 'STD'
					where ord_hdrnumber = @ordhdrnum and ord_status = 'CMP'	
		select @stpseq = max(isnull(stp_mfh_sequence,0)) from stops (NOLOCK) where lgh_number = @lghnum and stp_mfh_sequence < @stpseq
		set @stpseq = isnull(@stpseq,0)
		END
	END

/* Un-assign */

if @flg_unasndrv > 0 or @flg_unasntrc > 0 or @flg_unasntrl > 0
	BEGIN
	if exists (select stp_number from stops where stp_status = 'DNE' and lgh_number = @lghnum)
		BEGIN
		RAISERROR('Legheader %d has a complete stop; cannot un-assign any assets.', 16, 1, @lghnum)
		RETURN 3 
		END
	set @stpseq = @stpmaxseq
	while (@stpseq > 0)
		BEGIN
		select @stpnum = stp_number, @ordhdrnum = ord_hdrnumber, @stpordseq = isnull(stp_sequence,0) 
			from stops  (NOLOCK)
			where lgh_number = @lghnum and stp_mfh_sequence = @stpseq 
		select @evtnum = evt_number, @evtdrv1 = evt_driver1, @evtdrv2 = evt_driver2, @evttrc = evt_tractor, @evttrl1 = evt_trailer1, @evttrl2 = evt_trailer2
			from event (NOLOCK)
			where stp_number = @stpnum and evt_sequence = 1
		if @ordhdrnum <> 0 
			select @ordstatus = ord_status from orderheader where ord_hdrnumber = @ordhdrnum
		set @ordstatus = isnull(@ordstatus,'')			
		set @evtdrv1 = isnull(@evtdrv1,'UNKNOWN')
		set @evtdrv2 = isnull(@evtdrv2,'UNKNOWN')
		set @evttrc = isnull(@evttrc,'UNKNOWN')
		set @evttrl1 = isnull(@evttrl1,'UNKNOWN')
		set @evttrl2 = isnull(@evttrl2,'UNKNOWN')
		if (@flg_unasndrv > 0 and (@evtdrv1 <> 'UNKNOWN' or @evtdrv2 <> 'UNKNOWN'))
			or (@flg_unasntrc > 0 and @evttrc <> 'UNKNOWN')
			or (@flg_unasntrl > 0 and @evttrl1 <> 'UNKNOWN')
			BEGIN
			if @flg_unasndrv > 0 
				BEGIN
				set @evtdrv1 = 'UNKNOWN'
				set @evtdrv2 = 'UNKNOWN'
				END
			if @flg_unasntrc > 0 
				BEGIN
				set @evttrc = 'UNKNOWN'
				set @ordstatus = 'AVL'
				END
			if @flg_unasntrl > 0
				BEGIN
				set @evttrl1 = 'UNKNOWN'
				set @evttrl2 = 'UNKNOWN'
				END
			update event
				set 	evt_driver1 = @evtdrv1,
					evt_driver2 = @evtdrv2,
					evt_tractor = @evttrc,
					evt_trailer1 = @evttrl1,
					evt_trailer2 = @evttrl2
				where evt_number = @evtnum
			update stops
				set trl_id = @evttrl1
				where stp_number = @stpnum and trl_id <> @evttrl1
			if isnull(@ordhdrnum,0) <> 0 and @stpordseq = 1
				update orderheader
					set ord_driver1 = @evtdrv1,
						ord_driver2 = @evtdrv2,
						ord_tractor = @evttrc,
						ord_trailer = @evttrl1,
						ord_trailer2 = @evttrl2,
						ord_status = @ordstatus
					where ord_hdrnumber = @ordhdrnum
						and (isnull(ord_driver1,'UNKNOWN') <> @evtdrv1
							or isnull(ord_driver2,'UNKNOWN') <> @evtdrv2
							or isnull(ord_tractor,'UNKNOWN') <> @evttrc
							or isnull(ord_trailer,'UNKNOWN') <> @evttrl1
							or isnull(ord_trailer2,'UNKNOWN') <> @evttrl2
							or isnull(ord_status,'') <> @ordstatus)
			set @updated = 1
			END
		select @stpseq = max(isnull(stp_mfh_sequence,0)) from stops (NOLOCK) where lgh_number = @lghnum and stp_mfh_sequence < @stpseq
		set @stpseq = isnull(@stpseq,0)
		END
	END

/* Delete beginning deadhead */

if @flg_deldh > 0 
	BEGIN
	if exists (select stp_number from stops (NOLOCK) where stp_status = 'DNE' and lgh_number = @lghnum)
		BEGIN
		RAISERROR('Legheader %d has a complete stop; cannot delete the beginning deadhead.', 16, 1, @lghnum)
		RETURN 3 
		END
	select @stpseq = max(isnull(stp_mfh_sequence,0)) 
		from stops (NOLOCK) 
		where lgh_number = @lghnum and isnull(stp_mfh_sequence,0) < @stp_firstpup_seq
	set @stpseq = isnull(@stpseq,0)
	set @deleted = 0
	while (@stpseq > 0)
		BEGIN
			delete stops where lgh_number = @lghnum and stp_mfh_sequence = @stpseq
			set @deleted = @deleted + 1
			set @updated = 1		
			select @stpseq = max(isnull(stp_mfh_sequence,0)) 
				from stops (NOLOCK) 
				where lgh_number = @lghnum and stp_mfh_sequence < @stpseq
			set @stpseq = isnull(@stpseq,0)
		END
	if @deleted > 0
		BEGIN
		select @stpnum = stp_number, @ordhdrnum = ord_hdrnumber 
			from stops (NOLOCK) 
			where lgh_number = @lghnum and stp_mfh_sequence = @stp_firstpup_seq
		update stops
			set stp_lgh_mileage = 0, stp_trip_mileage = 0
			where stp_number = @stpnum
				and (stp_lgh_mileage <> 0 or stp_trip_mileage <> 0)

		-- Renumber stop sequences.
		set @stpnewseq = 0
		select @stpseq = min(isnull(stp_mfh_sequence,0)) 
			from stops (NOLOCK) 
			where mov_number = @movnum
		set @stpseq = isnull(@stpseq,0)
		while @stpseq > 0
			BEGIN
			set @stpnewseq = @stpnewseq + 1
			update stops 
				set stp_mfh_sequence = @stpnewseq
				where lgh_number = @lghnum and stp_mfh_sequence = @stpseq				
					and stp_mfh_sequence <> @stpnewseq
			select @stpseq = min(isnull(stp_mfh_sequence,0))
				from stops (NOLOCK)
				where mov_number = @movnum and stp_mfh_sequence > @stpseq
			set @stpseq = isnull(@stpseq,0)
			END

		END
	END

if @updated = 0
	BEGIN
	ROLLBACK TRANSACTION
	RETURN 1 -- nothing updated - update not needed
	END

COMMIT TRANSACTION 

EXEC dbo.update_move @movnum

RETURN 0

GO
GRANT EXECUTE ON  [dbo].[tmail_unassign_lgh] TO [public]
GO
