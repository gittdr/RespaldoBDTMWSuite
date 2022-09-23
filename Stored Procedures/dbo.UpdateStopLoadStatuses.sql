SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[UpdateStopLoadStatuses]
	@p_mov_number int

as
set nocount on 

declare 			
@v_stat varchar(3),
@v_row int,
@v_from varchar(10),
@v_to varchar(10),	
@v_lgh int,
@v_trailer varchar(13),
@v_prevstat varchar(3),
@v_prevrow int,
@v_prevfrom varchar(10),
@v_prevto varchar(10),	
@v_prevlgh int,
@v_prevtrailer varchar(13),
@v_stp_number int,			
@v_totnull int,
@v_smi_id int,	
@v_rowcount int,
@v_priorlegsmatter int,
@v_laterlegsmatter int

create table #stops_info(
smi_id int identity (1, 1) NOT NULL PRIMARY KEY ,
lgh_number int not null,
stp_number int not null,	
stp_mfh_sequence int not null,
stp_loadstatus varchar(3) null,
stp_event varchar(6) not null,
mile_typ_to_stop varchar(6) not null,
mile_typ_from_stop varchar(6) not null,
stp_trailer1 varchar(13) null,
stp_ordhdrnumber int null)

insert #stops_info(lgh_number, stp_number, stp_mfh_sequence, stp_loadstatus, stp_event, mile_typ_to_stop, mile_typ_from_stop, stp_trailer1, stp_ordhdrnumber)
select s.lgh_number, s.stp_number, s.stp_mfh_sequence, s.stp_loadstatus, s.stp_event, ec.mile_typ_to_stop, ec.mile_typ_from_stop, isnull(ev.evt_trailer1, 'UNKNOWN'), ISNULL(s.ord_hdrnumber, 0)
  from stops s inner join eventcodetable ec on s.stp_event = ec.abbr
             inner join event ev on ev.stp_number = s.stp_number and ev.evt_sequence = 1 and ev.evt_number = (select MIN(sub.evt_number) from event sub where sub.stp_number = s.stp_number and sub.evt_sequence = 1)
 where s.mov_number = @p_mov_number
 order by stp_mfh_sequence

-- HLT/HCT signal that earlier legheaders could bring an order onto this one, so mark them accordingly.
update #stops_info set stp_ordhdrnumber = -1 where stp_event in ('HLT', 'HCT')

-- Likewise, DLT means that later legheaders could drop an order from this one, so mark them too.
update #stops_info set stp_ordhdrnumber = -2 where stp_event in ('DLT')

-- Leave NONE on Begin/End Bobtail/Empty events only.
update #stops_info set mile_typ_to_stop = 'UND', mile_typ_from_stop = 'UND' where mile_typ_from_stop in ('NONE', 'UND') and mile_typ_to_stop in ('NONE', 'UND')

-- At this point all UND events will either have UND in both from and to (in which case they do not change the status), or will have UND in one and LD in the 
--	other (in which case they are a LLD or LUL type stop).

-- If an event does not actually do anything with cargo (IBMT/IBBT/IEMT/IEBT), then this routine should not treat it as part of any order.
update #stops_info set stp_ordhdrnumber = 0 where mile_typ_from_stop <> 'LD' and mile_typ_to_stop <> 'LD'

select @v_rowcount = count(0) from #stops_info

select @v_row = 0, @v_lgh = 0, @v_prevstat = 'UND'

while @v_row + 1<= @v_rowcount
begin	
	select @v_prevto = @v_to,
	       @v_prevfrom = @v_from,
	       @v_prevlgh = @v_lgh,
	       @v_prevrow = @v_row,
	       @v_prevstat = @v_stat,
	       @v_prevtrailer = @v_trailer

	select @v_to = mile_typ_to_stop, 
	       @v_from = mile_typ_from_stop, 
	       @v_lgh = lgh_number, 
	       @v_row = smi_id, 
	       @v_stat = stp_loadstatus,
	       @v_trailer = stp_trailer1
	  from #stops_info where smi_id = @v_row + 1

	if @v_lgh <> @v_prevlgh
	BEGIN
		-- If prior legheader ended undetermined, then all those statuses must be MT.  Only way they can be undetermined is if there was activity after 
		--	a LUL, or if all stops on the whole legheader were UND/UND.  After a LUL would be MT.  All stops UND/UND is MT if there is a trailer,
		--	or undeterminable between MT & BT if there is not.  Since we cannot save undeterminable, things are much simpler if we just say MT in 
		--	all cases.
		IF @v_prevstat = 'UND'
			UPDATE #stops_info SET stp_loadstatus = 'MT' where stp_loadstatus = 'UND' and smi_id < @v_row

		-- OK, now start the new legheader.  Prior legheaders cannot have an influence on the first event of a new legheader.
		IF @v_to = 'NONE'
			-- If first event on legheader is a Begin event, then claim the same status in as out.
			select @v_stat = @v_from
		ELSE
			-- Otherwise since prior legheaders cannot influence this one, just look at the event for status (if it says).
			select @v_stat = @v_to	-- Note that an LD in this situation is actually illegal, but that should have been checked elsewhere.
	END
	else if @v_to in ('MT', 'BT', 'LD')	-- The simplest case.  Event says what to do.
		select @v_stat = @v_to
	else if @v_to = 'NONE'			-- If it is a Begin Empty or Bobtail, then claim same in as out.
		select @v_stat = @v_from
	else if @v_to = 'UND'			-- This event doesn't say.  See if prior one did.
	begin
		if @v_prevfrom in ('MT', 'LD', 'BT')	-- Prior did indeed say what this is.
			set @v_stat = @v_prevfrom
		else if @v_prevfrom = 'NONE' -- Prior was an EMT/EBT type, so 
			set @v_stat = @v_prevto
		else if @v_prevto = 'UND'  -- To get to here, from must be UND.  If To is also, then prior activity did not change status, so this must match that one's status.
			set @v_stat = @v_prevstat
		else if ltrim(rtrim(@v_prevto)) = 'LD'      -- Prior row is a LUL type stop.  That makes this row's status undeterminable.  Save this row as UND for now.
			set @v_stat = 'UND'
	end

	-- Liveloads will terminate a UND sequence.  If we hit one and we don't know its status, then we will need to search to determine it.
	if @v_stat = 'UND' and @v_from = 'LD'
	BEGIN
		-- This is a live load.  This and all prior UNDs must be either MT or LD.  To determine which see if there is a single order which appears on 
		--	both sides of this stop.

		-- First check if there is an earlier HLT/HCT on this legheader (if so, then the order may match from earlier legs).
		SELECT @v_PriorLegsMatter = COUNT(*) FROM #stops_info WHERE stp_ordhdrnumber = -1 and lgh_number = @v_lgh and smi_id < @v_row
		-- Likewise later DLTs signal that the order may match from later legs.
		SELECT @v_LaterLegsMatter = COUNT(*) FROM #stops_info WHERE stp_ordhdrnumber = -2 and lgh_number = @v_lgh and smi_id >= @v_row

		-- Now do the search for an order that flanks this stop.
		IF EXISTS (SELECT * FROM #stops_info earlier, #stops_info later 
				WHERE earlier.smi_id < @v_row
				  AND later.smi_id >= @v_row
				  AND earlier.stp_ordhdrnumber = later.stp_ordhdrnumber
				  AND earlier.stp_ordhdrnumber > 0
				  AND (@v_PriorLegsMatter >0 OR earlier.lgh_number = @v_lgh)
				  AND (@v_LaterLegsMatter >0 OR later.lgh_number = @v_lgh))
			set @v_stat = 'LD'
		ELSE
			set @v_stat = 'MT'
	END

	if @v_stat <> 'UND' and @v_prevstat = 'UND' and @v_lgh = @v_prevlgh
		-- Since all the prior undetermined events have not changed the status, they must all match this To status.
		UPDATE #stops_info SET stp_loadstatus = @v_stat WHERE stp_loadstatus = 'UND' and smi_id < @v_row

	if @v_lgh <> @v_prevlgh	-- At start of a new legheader, regardless of real derived status, status in is always saved as NON.
		update #stops_info
		set stp_loadstatus = 'NON'
		where smi_id = @v_row
	else
		update #stops_info
		set stp_loadstatus = @v_stat
		where smi_id = @v_row
end 

-- Clean up all final undetermineds (just as though we had changed legheader).
IF @v_stat = 'UND'
	UPDATE #stops_info SET stp_loadstatus = 'MT' where stp_loadstatus = 'UND'

/* Now save results, uncomment the following and comment the save for a testing version. */
-- select * from #stops_info
-- select stp_loadstatus, stp_event, * from stops where mov_number = @p_mov_number order by stp_mfh_sequence
select @v_row = ISNULL(MIN(smi_id), 0) FROM stops inner join #stops_info on stops.stp_number = #stops_info.stp_number where #stops_info.stp_loadstatus <> ISNULL(stops.stp_loadstatus, '')
while @v_row > 0
	BEGIN
	UPDATE stops SET stp_loadstatus = #stops_info.stp_loadstatus FROM stops inner join #stops_info on stops.stp_number = #stops_info.stp_number where #stops_info.smi_id = @v_row
	select @v_row = ISNULL(MIN(smi_id), 0) FROM stops inner join #stops_info on stops.stp_number = #stops_info.stp_number where #stops_info.stp_loadstatus <> ISNULL(stops.stp_loadstatus, '')
	END

set nocount off

GO
GRANT EXECUTE ON  [dbo].[UpdateStopLoadStatuses] TO [public]
GO
