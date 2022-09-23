SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


create proc [dbo].[update_assetassignment] @mov_number int
as
/*
   9158 dpete temp fix - getting multiple rows retrieved on subquery error.  Put MAX(..)
         on line 104 to stop this.  Needs review by MF to see if this is a fix or a plug

	PTS 33335 - DJM - IF a movement STARTS with a CTR event, the assetassignment for the stop is set
		to an asgn_id=null.
*/

/* 07/26/2010 MDH PTS 52531: SET NOCOUNT ON to reduce chatter */
--vjh 63018 add branches
/* PTS 79330 added with (nolock) in 2 places to prevent deadlocks at CRE. */

SET NOCOUNT ON

declare @test int, @field varchar(10), @alt varchar(10), @asgn_number int, @rec_id int,
	@asgn_id varchar(13), @asgn_type varchar(6), @ret int, @use_evt_depart_for_trl_status Char(1),
	@completeondeparture Char(1)

-- PTS 36009 Begin, JZ 2/1/2007
DECLARE @trlevent_temp table
       (seq					int identity,
		evt_number			int NULL,
		stp_number			int NULL,
		evt_sequence		int NULL,
		evt_eventcode		varchar(8) null,
		evt_status			varchar(6) NULL,
		evt_departure_status varchar(6) NULL,
		evt_startdate		datetime NULL,
		evt_enddate			datetime NULL,
		evt_trailer1		varchar(13) NULL,
		evt_trailer2		varchar(13) NULL,
		stp_mfh_sequence	int null,
		lgh_number			int null,
		evt_tractor			varchar(8) null,
		evt_driver1			varchar(8) null,
		evt_driver2			varchar(8) null,
		evt_carrier			varchar(8) null,
		evt_pu_dr			VARCHAR(8) null,
		evt_chassis			varchar(13) null,
		evt_chassis2		varchar(13) null,
		evt_dolly			varchar(13) null,
		evt_dolly2			varchar(13) null,
		evt_trailer3		varchar(13) null,
		evt_trailer4		varchar(13) null)
-- PTS 36009 End

--CREATE TABLE #trlevent
DECLARE @trlevent table
       (seq					int	identity,
		evt_number			int NULL,
		stp_number			int NULL,
		evt_sequence		int NULL,
		evt_eventcode		varchar(8) null,
		evt_status			varchar(6) NULL,
		evt_departure_status varchar(6) NULL,
		evt_startdate		datetime NULL,
		evt_enddate			datetime NULL,
		evt_trailer1		varchar(13) NULL,
		evt_trailer2		varchar(13) NULL,
		stp_mfh_sequence	int null,
		lgh_number			int null,
		evt_tractor			varchar(8) null,
		evt_driver1			varchar(8) null,
		evt_driver2			varchar(8) null,
		evt_carrier			varchar(8) null,
		evt_pu_dr			VARCHAR(8) null,
		evt_chassis			varchar(13) null,
		evt_chassis2		varchar(13) null,
		evt_dolly			varchar(13) null,
		evt_dolly2			varchar(13) null,
		evt_trailer3		varchar(13) null,
		evt_trailer4		varchar(13) null)

--CREATE TABLE #assethold
DECLARE @assethold TABLE
	   (rec_id				int	identity,
		lgh_number			int NULL,
		asgn_number			int NULL,
		asgn_type			varchar(6) NULL,
		asgn_id				varchar(13) NULL,
		asgn_date			datetime NULL,
		asgn_eventnumber	int NULL,
		asgn_controlling	varchar(1) NULL,
		asgn_status			varchar(6) NULL,
		asgn_dispdate		datetime NULL,
		asgn_enddate		datetime NULL,
		asgn_dispmethod		varchar(6) NULL,
		mov_number			int NULL,
		pyd_status			varchar(6) NULL,
		actg_type			char(1) NULL,
		evt_number			int NULL,
		asgn_trl_first_asgn int NULL,
		asgn_trl_last_asgn	int NULL,
		last_evt_number		int null,
		first_seq			int null,
		last_seq			int null,
		completed_seq		int null,
		started_seq			int null,
		new_row				char(1) null,
		loaded				char(1) null,
		last_dne_evt_number int null,
		next_opn_evt_number int null,
		asgn_branch			varchar(12) null)

DECLARE @tmp TABLE (lgh_number int NULL)

/* PTS 33550 - DJM - Added field to indicate the lgh_type used for DoNotPay settings.	*/
Declare @donotpay_status as varchar(6),
	@donotpay_type as varchar(6),
	@donotpay_field as varchar(60),
	@lgh_type5 varchar(6),
	@lgh_type3 varchar(6),
	@minlgh int

--PTS35229 MBR 11/30/06
SELECT @completeondeparture = UPPER(LEFT(ISNULL(gi_string1, 'No'), 1))
  FROM generalinfo
 WHERE gi_name = 'CompleteOnDeparture'

--Added with PTS 36009, JZ, 1/30/2007
SELECT @completeondeparture = ISNULL(@completeondeparture, 'N')

/* build l;ist of all events*/
-- PTS 36009, JZ 2/1/2007, changed to insert data into the temp table
insert @trlevent_temp(evt_number, event.stp_number, evt_sequence,
	evt_eventcode, evt_status, evt_departure_status, evt_startdate,
	evt_enddate, evt_trailer1, evt_trailer2, stp_mfh_sequence, lgh_number,
	evt_tractor, evt_driver1, evt_driver2, evt_carrier, evt_pu_dr, evt_chassis,
	evt_chassis2, evt_dolly, evt_dolly2, evt_trailer3, evt_trailer4)
select evt_number, event.stp_number, (case evt_eventcode
						when 'PUL' then -1
						when 'SAP' then -1
						else evt_sequence end) evt_sequence,
	evt_eventcode, evt_status, stp_departure_status, evt_startdate,
	evt_enddate, evt_trailer1, evt_trailer2, stp_mfh_sequence, lgh_number,
	evt_tractor, evt_driver1, evt_driver2, evt_carrier, evt_pu_dr, evt_chassis,
	evt_chassis2, evt_dolly, evt_dolly2, evt_trailer3, evt_trailer4
from event with (nolock)
JOIN stops  with (nolock) ON event.stp_number = stops.stp_number -- 29797
JOIN eventcodetable  with (nolock) ON evt_eventcode = abbr -- 29797
where mov_number = @mov_number
-- PTS 28901 -- BL (start)
	and evt_eventcode <> 'SAP'
	and (primary_event = 'Y' OR evt_eventcode = 'PUL' OR evt_eventcode = 'PLD') -- 29797
-- PTS 28901 -- BL (end)
union
/*include an extra row for the drop part of a CTR */
select evt_number, event.stp_number, 999, 'CTD', evt_status, stp_departure_status,
       evt_startdate, evt_enddate, evt_trailer1, evt_trailer2, stp_mfh_sequence,
       lgh_number,evt_tractor, evt_driver1, evt_driver2, evt_carrier, evt_pu_dr,
       evt_chassis,	evt_chassis2, evt_dolly, evt_dolly2, evt_trailer3, evt_trailer4
from event  with (nolock), stops  with (nolock)
where event.stp_number = stops.stp_number and
	mov_number = @mov_number and
	evt_eventcode = 'CTR'
order by stp_mfh_sequence asc, evt_sequence desc

if @@error <> 0 goto exitpoint

-- PTS 33335 - DJM - test for Isnull
-- PTS 36009, JZ 2/1/2007, changed to update data into the temp table
if (select count(*) from @trlevent_temp
	where evt_sequence = 999 and evt_eventcode = 'CTD') > 0
begin
	update @trlevent_temp
	set evt_trailer1 = isNull((select evt_trailer1 from @trlevent_temp a where a.seq = b.seq - 1), evt_trailer1),
		evt_trailer2 = isNull((select evt_trailer2 from @trlevent_temp a where a.seq = b.seq - 1), evt_trailer2)
	from @trlevent_temp b
	where evt_sequence = 999 and evt_eventcode = 'CTD'
	if @@error <> 0 goto exitpoint
end

-- PTS 36009 Begin, JZ 1/30/2007, remove the CTD row in the @trlevent_temp if its prior row is
--		in the list of drop trailer events, so that the trailer can be released.
-- check general info
declare @DropPrecedingCTR as char(1)
SELECT @DropPrecedingCTR = UPPER(LEFT(ISNULL(gi_string1, 'N'), 1))
  FROM generalinfo
 WHERE gi_name = 'DropPrecedingCTR'
if @DropPrecedingCTR = 'Y'
begin
	-- delete the row CTD row
	delete from @trlevent_temp
	where seq in
		(
			select seq from @trlevent_temp ctd
			where evt_sequence = 999 and evt_eventcode = 'CTD'
				and exists
					(
						select stp_mfh_sequence from @trlevent_temp
						where stp_mfh_sequence = (ctd.stp_mfh_sequence-1)
							and evt_eventcode in ('DMT','DRL','DLT','DTW')
					)
		)

end

-- since CTD row is deleted, if @DropPrecedingCTR = 'Y', the consecution of seq in @trlevent_temp is broken, would cause problems in the insert statement for the @assethold table.
--		move the data to @trlevent so that the seq will be correct.
insert @trlevent(evt_number, stp_number, evt_sequence,
		evt_eventcode, evt_status, evt_departure_status, evt_startdate,
		evt_enddate, evt_trailer1, evt_trailer2, stp_mfh_sequence, lgh_number,
		evt_tractor, evt_driver1, evt_driver2, evt_carrier, evt_pu_dr,
		evt_chassis, evt_chassis2, evt_dolly, evt_dolly2, evt_trailer3, evt_trailer4)
		select evt_number, stp_number, evt_sequence,
		evt_eventcode, evt_status, evt_departure_status, evt_startdate,
		evt_enddate, evt_trailer1, evt_trailer2, stp_mfh_sequence, lgh_number,
		evt_tractor, evt_driver1, evt_driver2, evt_carrier, evt_pu_dr,
		evt_chassis, evt_chassis2, evt_dolly, evt_dolly2, evt_trailer3, evt_trailer4
	from @trlevent_temp
if @@error <> 0 goto exitpoint
-- PTS 36009 End

/*add trailer1 records */
insert @assethold(lgh_number,  asgn_number, asgn_type, asgn_id,       asgn_date,
		asgn_eventnumber, asgn_controlling, asgn_status, asgn_dispdate,
		asgn_enddate, asgn_dispmethod, mov_number, pyd_status, actg_type,
		evt_number, last_evt_number, first_seq, last_seq,
		completed_seq, started_seq, loaded)
select  firstevent.lgh_number, 0, 'TRL', firstevent.evt_trailer1, firstevent.evt_startdate,
	null, 'Y', '', convert(datetime,null) asgn_dispdate,
	lastevent.evt_enddate, null asgn_dispmethod, @mov_number, 'NPD', isnull((select MAX(trl_actg_type)
										from trailerprofile
										where trl_id = firstevent.evt_trailer1),'N'),
	firstevent.evt_number, lastevent.evt_number, firstevent.seq, lastevent.seq,
	--PTS35229 MBR 11/30/06
	CASE @completeondeparture WHEN 'Y' THEN
	     ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_departure_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN
	     isnull((select max(seq) from @trlevent c
		      where evt_status='DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
	END,
	CASE @completeondeparture WHEN 'Y' then
             ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN -1
	END,
	case when (select count(*)
			from @trlevent x
			where (x.evt_pu_dr in ('PUP','DRP') or
				x.evt_eventcode in ('CTR','HLT','DLT','HCT')) and
				x.seq between firstevent.seq and lastevent.seq) > 0 then 'Y'
	else 'N'
	end
 from @trlevent lastevent, @trlevent firstevent
 where lastevent.evt_trailer1 <> 'UNKNOWN' and
	(lastevent.evt_trailer1 <> isnull((select evt_trailer1
				from @trlevent a
				where a.seq = lastevent.seq + 1),'XXXXXXXXXXX')	or
	lastevent.lgh_number <> isnull((select lgh_number
				from @trlevent a
				where a.seq = lastevent.seq + 1),-123)) and
	firstevent.seq = (select isnull(max(seq)+1,1)
			from @trlevent a
			where a.seq < lastevent.seq and
				(a.evt_trailer1 <> isnull((select evt_trailer1
				from @trlevent b
				where b.seq = a.seq + 1),'XXXXXXXXXXX') or
				lgh_number <> isnull((select lgh_number
							from @trlevent b
							where b.seq = a.seq + 1),-123)))
/*PTS15969 MBR 10/30/02*/
SELECT @use_evt_depart_for_trl_status = gi_string1
  FROM generalinfo
 WHERE gi_name = Upper(IsNULL('USE_EVT_DEPART_FOR_TRL_STATUS','N'))
if @use_evt_depart_for_trl_status = 'Y'
begin
     update @assethold
	set completed_seq = IsNull((Select max(seq)
                                      from @trlevent a
                                     where a.evt_trailer1 = ah.asgn_id and
                                           ((a.evt_departure_status = 'DNE' and
                                           a.evt_sequence = 1) or (a.evt_status = 'DNE' and a.evt_eventcode = 'CTD'))), -1)
	from @assethold ah
    where ah.asgn_type = 'TRL'

     update @assethold
        set completed_seq = IsNull((select max(seq)
                                      from @trlevent a
                                     where a.evt_trailer1 = ah.asgn_id and
                                           a.evt_status = 'DNE' and
                                           a.evt_sequence = 1), -1)
	from @assethold ah
      where asgn_type = 'TRL' and
            completed_seq = -1

     update @assethold
        set completed_seq = IsNull((select seq
                                     from @trlevent a
                                    where a.evt_trailer1 = ah.asgn_id and
                                          a.evt_status = 'DNE' and
                                          a.evt_sequence = -1 and
                                          a.evt_eventcode = 'PUL'),ah.completed_seq)
	from @assethold ah
      where ah.asgn_type = 'TRL' and
            (ah.last_seq - ah.completed_seq = 1)
end
if @@error <> 0 goto exitpoint

/*add trailer2 records */
insert @assethold(lgh_number,  asgn_number, asgn_type, asgn_id,       asgn_date,
		asgn_eventnumber, asgn_controlling, asgn_status, asgn_dispdate,
		asgn_enddate, asgn_dispmethod, mov_number, pyd_status, actg_type,
		evt_number, last_evt_number, first_seq, last_seq,
		completed_seq, started_seq, loaded)
select  firstevent.lgh_number, 0, 'TRL', firstevent.evt_trailer2, firstevent.evt_startdate,
	null, 'N', '', convert(datetime,null) asgn_dispdate,
	lastevent.evt_enddate, null asgn_dispmethod, @mov_number, 'NPD', isnull((select trl_actg_type
										from trailerprofile
										where trl_id = firstevent.evt_trailer2),'N'),
	firstevent.evt_number, lastevent.evt_number, firstevent.seq, lastevent.seq,
	--PTS35229 MBR 11/30/06
	CASE @completeondeparture WHEN 'Y' THEN
	     ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_departure_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN
	     isnull((select max(seq) from @trlevent c
		      where evt_status='DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
	END,
	CASE @completeondeparture WHEN 'Y' then
             ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN -1
	END,
	case when (select count(*)
			from @trlevent x
			where (x.evt_pu_dr in ('PUP','DRP') or
				x.evt_eventcode in ('CTR','HLT','DLT','HCT')) and
				x.seq between firstevent.seq and lastevent.seq) > 0 then 'Y'
	else 'N'
	end
 from @trlevent lastevent, @trlevent firstevent
 where lastevent.evt_trailer2 <> 'UNKNOWN' and
	(lastevent.evt_trailer2 <> isnull((select evt_trailer2
				from @trlevent a
				where a.seq = lastevent.seq + 1),'XXXXXXXXXXX')	or
	lastevent.lgh_number <> isnull((select lgh_number
				from @trlevent a
				where a.seq = lastevent.seq + 1),-123)) and
	firstevent.seq = (select isnull(max(seq)+1,1)
			from @trlevent a
			where a.seq < lastevent.seq and
				(a.evt_trailer2 <> isnull((select evt_trailer2
				from @trlevent b
				where b.seq = a.seq + 1),'XXXXXXXXXXX') or
				lgh_number <> isnull((select lgh_number
							from @trlevent b
							where b.seq = a.seq + 1),-123)))

if @@error <> 0 goto exitpoint

/*add tractor records*/
insert @assethold(lgh_number,  asgn_number, asgn_type, asgn_id,       asgn_date,
		asgn_eventnumber, asgn_controlling, asgn_status, asgn_dispdate,
		asgn_enddate, asgn_dispmethod, mov_number, pyd_status, actg_type,
		evt_number, last_evt_number, first_seq, last_seq,
		completed_seq, started_seq)
select  firstevent.lgh_number, 0, 'TRC', firstevent.evt_tractor, firstevent.evt_startdate,
	null, 'Y', '', convert(datetime,null) asgn_dispdate,
	lastevent.evt_enddate, null asgn_dispmethod, @mov_number, 'NPD', isnull((select trc_actg_type
										from tractorprofile
										where trc_number = firstevent.evt_tractor),'N'),
	firstevent.evt_number, lastevent.evt_number, firstevent.seq, lastevent.seq,
	--PTS35229 MBR 11/30/06
	CASE @completeondeparture WHEN 'Y' THEN
	     ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_departure_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN
	     isnull((select max(seq) from @trlevent c
		      where evt_status='DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
	END,
        CASE @completeondeparture WHEN 'Y' then
             ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN -1
	END
from @trlevent lastevent, @trlevent firstevent, (select lgh_number, evt_tractor, min(seq) minseq, max(seq) maxseq
						 from @trlevent
						 where evt_tractor <> 'UNKNOWN'
						 group by lgh_number, evt_tractor) lookup
where firstevent.seq = lookup.minseq and
	lastevent.seq = lookup.maxseq and
	firstevent.lgh_number = lookup.lgh_number and
	lastevent.lgh_number = lookup.lgh_number

if @@error <> 0 goto exitpoint

/*add driver1 records*/
insert @assethold(lgh_number,  asgn_number, asgn_type, asgn_id,       asgn_date,
		asgn_eventnumber, asgn_controlling, asgn_status, asgn_dispdate,
		asgn_enddate, asgn_dispmethod, mov_number, pyd_status, actg_type,
		evt_number, last_evt_number, first_seq, last_seq,
		completed_seq, started_seq)
select  firstevent.lgh_number, 0, 'DRV', firstevent.evt_driver1, firstevent.evt_startdate,
	null, 'Y', '', convert(datetime,null) asgn_dispdate,
	lastevent.evt_enddate, null asgn_dispmethod, @mov_number, 'NPD', isnull((select mpp_actg_type
										from manpowerprofile
										where mpp_id = firstevent.evt_driver1),'N'),
	firstevent.evt_number, lastevent.evt_number, firstevent.seq, lastevent.seq,
	--PTS35229 MBR 11/30/06
	CASE @completeondeparture WHEN 'Y' THEN
	     ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_departure_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN
	     isnull((select max(seq) from @trlevent c
		      where evt_status='DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
	END,
	CASE @completeondeparture WHEN 'Y' then
             ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN -1
	END
from @trlevent lastevent, @trlevent firstevent, (select lgh_number, evt_driver1, min(seq) minseq, max(seq) maxseq
						 from @trlevent
						 where evt_driver1 <> 'UNKNOWN'
						 group by lgh_number, evt_driver1) lookup
where firstevent.seq = lookup.minseq and
	lastevent.seq = lookup.maxseq  and
	firstevent.lgh_number = lookup.lgh_number and
	lastevent.lgh_number = lookup.lgh_number

if @@error <> 0 goto exitpoint

/*DRIVER 2*/
insert @assethold(lgh_number,  asgn_number, asgn_type, asgn_id,       asgn_date,
		asgn_eventnumber, asgn_controlling, asgn_status, asgn_dispdate,
		asgn_enddate, asgn_dispmethod, mov_number, pyd_status, actg_type,
		evt_number, last_evt_number, first_seq, last_seq,
		completed_seq, started_seq)
select  firstevent.lgh_number, 0, 'DRV', firstevent.evt_driver2, firstevent.evt_startdate,
	null, 'N', '', convert(datetime,null) asgn_dispdate,
	lastevent.evt_enddate, null asgn_dispmethod, @mov_number, 'NPD', isnull((select mpp_actg_type
										from manpowerprofile
										where mpp_id = firstevent.evt_driver2),'N'),
	firstevent.evt_number, lastevent.evt_number, firstevent.seq, lastevent.seq,
	--PTS35229 MBR 11/30/06
	CASE @completeondeparture WHEN 'Y' THEN
	     ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_departure_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN
	     isnull((select max(seq) from @trlevent c
		      where evt_status='DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
	END,
	CASE @completeondeparture WHEN 'Y' then
             ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN -1
	END
from @trlevent lastevent, @trlevent firstevent, (select lgh_number, evt_driver2, min(seq) minseq, max(seq) maxseq
						 from @trlevent
						 where evt_driver2 <> 'UNKNOWN'
						 group by lgh_number, evt_driver2) lookup
where firstevent.seq = lookup.minseq and
	lastevent.seq = lookup.maxseq  and
	firstevent.lgh_number = lookup.lgh_number and
	lastevent.lgh_number = lookup.lgh_number

if @@error <> 0 goto exitpoint

/*Carrier*/
insert @assethold(lgh_number,  asgn_number, asgn_type, asgn_id,       asgn_date,
		asgn_eventnumber, asgn_controlling, asgn_status, asgn_dispdate,
		asgn_enddate, asgn_dispmethod, mov_number, pyd_status, actg_type,
		evt_number, last_evt_number, first_seq, last_seq,
		completed_seq, started_seq)

select  firstevent.lgh_number, 0, 'CAR', firstevent.evt_carrier, firstevent.evt_startdate,
	null, case (select car_board from carrier
			where car_id = firstevent.evt_carrier)
		when 'Y' then 'N'
		else 'Y'
		end, /*got logic from event trigger*/
	'', convert(datetime,null) asgn_dispdate,
	lastevent.evt_enddate, null asgn_dispmethod, @mov_number, 'NPD', isnull((select car_actg_type
										from carrier
										where car_id = firstevent.evt_carrier),'N'),
	firstevent.evt_number, lastevent.evt_number, firstevent.seq, lastevent.seq,
	--PTS35229 MBR 11/30/06
	CASE @completeondeparture WHEN 'Y' THEN
	     ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_departure_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN
	     isnull((select max(seq) from @trlevent c
		      where evt_status='DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
	END,
	CASE @completeondeparture WHEN 'Y' then
             ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN -1
	END
from @trlevent lastevent, @trlevent firstevent, (select lgh_number, evt_carrier, min(seq) minseq, max(seq) maxseq
						 from @trlevent
						 where evt_carrier <> 'UNKNOWN'
						 group by lgh_number, evt_carrier) lookup
where firstevent.seq = lookup.minseq and
	lastevent.seq = lookup.maxseq  and
	firstevent.lgh_number = lookup.lgh_number and
	lastevent.lgh_number = lookup.lgh_number

if @@error <> 0 goto exitpoint

/*JLB PTS 49323*/
--select * from @trlevent
--select * from @trlevent_temp
/*add chassis records */

insert @assethold(lgh_number,  asgn_number, asgn_type, asgn_id,       asgn_date,
		asgn_eventnumber, asgn_controlling, asgn_status, asgn_dispdate,
		asgn_enddate, asgn_dispmethod, mov_number, pyd_status, actg_type,
		evt_number, last_evt_number, first_seq, last_seq,
		completed_seq, started_seq, loaded)
select  firstevent.lgh_number, 0, 'TRL', firstevent.evt_chassis, firstevent.evt_startdate,
	null, 'N', '', convert(datetime,null) asgn_dispdate,
	lastevent.evt_enddate, null asgn_dispmethod, @mov_number, 'XPY', isnull((select trl_actg_type
										from trailerprofile
										where trl_id = firstevent.evt_chassis),'N'),
	firstevent.evt_number, lastevent.evt_number, firstevent.seq, lastevent.seq,
	--PTS35229 MBR 11/30/06
	CASE @completeondeparture WHEN 'Y' THEN
	     ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_departure_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN
	     isnull((select max(seq) from @trlevent c
		      where evt_status='DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
	END,
	CASE @completeondeparture WHEN 'Y' then
             ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN -1
	END,
	case when (select count(*)
			from @trlevent x
			where (x.evt_pu_dr in ('PUP','DRP') or
				x.evt_eventcode in ('CTR','HLT','DLT','HCT')) and
				x.seq between firstevent.seq and lastevent.seq) > 0 then 'Y'
	else 'N'
	end
 from @trlevent lastevent, @trlevent firstevent
 where lastevent.evt_chassis <> 'UNKNOWN' and
	(lastevent.evt_chassis <> isnull((select evt_chassis
				from @trlevent a
				where a.seq = lastevent.seq + 1),'XXXXXXXXXXX')	or
	lastevent.lgh_number <> isnull((select lgh_number
				from @trlevent a
				where a.seq = lastevent.seq + 1),-123)) and
	firstevent.seq = (select isnull(max(seq)+1,1)
			from @trlevent a
			where a.seq < lastevent.seq and
				(a.evt_chassis <> isnull((select evt_chassis
				from @trlevent b
				where b.seq = a.seq + 1),'XXXXXXXXXXX') or
				lgh_number <> isnull((select lgh_number
							from @trlevent b
							where b.seq = a.seq + 1),-123)))

if @@error <> 0 goto exitpoint

/*add chassis2 records */
insert @assethold(lgh_number,  asgn_number, asgn_type, asgn_id,       asgn_date,
		asgn_eventnumber, asgn_controlling, asgn_status, asgn_dispdate,
		asgn_enddate, asgn_dispmethod, mov_number, pyd_status, actg_type,
		evt_number, last_evt_number, first_seq, last_seq,
		completed_seq, started_seq, loaded)
select  firstevent.lgh_number, 0, 'TRL', firstevent.evt_chassis2, firstevent.evt_startdate,
	null, 'N', '', convert(datetime,null) asgn_dispdate,
	lastevent.evt_enddate, null asgn_dispmethod, @mov_number, 'XPY', isnull((select trl_actg_type
										from trailerprofile
										where trl_id = firstevent.evt_chassis2),'N'),
	firstevent.evt_number, lastevent.evt_number, firstevent.seq, lastevent.seq,
	--PTS35229 MBR 11/30/06
	CASE @completeondeparture WHEN 'Y' THEN
	     ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_departure_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN
	     isnull((select max(seq) from @trlevent c
		      where evt_status='DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
	END,
	CASE @completeondeparture WHEN 'Y' then
             ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN -1
	END,
	case when (select count(*)
			from @trlevent x
			where (x.evt_pu_dr in ('PUP','DRP') or
				x.evt_eventcode in ('CTR','HLT','DLT','HCT')) and
				x.seq between firstevent.seq and lastevent.seq) > 0 then 'Y'
	else 'N'
	end
 from @trlevent lastevent, @trlevent firstevent
 where lastevent.evt_chassis2 <> 'UNKNOWN' and
	(lastevent.evt_chassis2 <> isnull((select evt_chassis2
				from @trlevent a
				where a.seq = lastevent.seq + 1),'XXXXXXXXXXX')	or
	lastevent.lgh_number <> isnull((select lgh_number
				from @trlevent a
				where a.seq = lastevent.seq + 1),-123)) and
	firstevent.seq = (select isnull(max(seq)+1,1)
			from @trlevent a
			where a.seq < lastevent.seq and
				(a.evt_chassis2 <> isnull((select evt_chassis2
				from @trlevent b
				where b.seq = a.seq + 1),'XXXXXXXXXXX') or
				lgh_number <> isnull((select lgh_number
							from @trlevent b
							where b.seq = a.seq + 1),-123)))

if @@error <> 0 goto exitpoint

/*add dolly records */
insert @assethold(lgh_number,  asgn_number, asgn_type, asgn_id,       asgn_date,
		asgn_eventnumber, asgn_controlling, asgn_status, asgn_dispdate,
		asgn_enddate, asgn_dispmethod, mov_number, pyd_status, actg_type,
		evt_number, last_evt_number, first_seq, last_seq,
		completed_seq, started_seq, loaded)
select  firstevent.lgh_number, 0, 'TRL', firstevent.evt_dolly, firstevent.evt_startdate,
	null, 'N', '', convert(datetime,null) asgn_dispdate,
	lastevent.evt_enddate, null asgn_dispmethod, @mov_number, 'XPY', isnull((select trl_actg_type
										from trailerprofile
										where trl_id = firstevent.evt_dolly),'N'),
	firstevent.evt_number, lastevent.evt_number, firstevent.seq, lastevent.seq,
	--PTS35229 MBR 11/30/06
	CASE @completeondeparture WHEN 'Y' THEN
	     ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_departure_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN
	     isnull((select max(seq) from @trlevent c
		      where evt_status='DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
	END,
	CASE @completeondeparture WHEN 'Y' then
             ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN -1
	END,
	case when (select count(*)
			from @trlevent x
			where (x.evt_pu_dr in ('PUP','DRP') or
				x.evt_eventcode in ('CTR','HLT','DLT','HCT')) and
				x.seq between firstevent.seq and lastevent.seq) > 0 then 'Y'
	else 'N'
	end
 from @trlevent lastevent, @trlevent firstevent
 where lastevent.evt_dolly <> 'UNKNOWN' and
	(lastevent.evt_dolly <> isnull((select evt_dolly
				from @trlevent a
				where a.seq = lastevent.seq + 1),'XXXXXXXXXXX')	or
	lastevent.lgh_number <> isnull((select lgh_number
				from @trlevent a
				where a.seq = lastevent.seq + 1),-123)) and
	firstevent.seq = (select isnull(max(seq)+1,1)
			from @trlevent a
			where a.seq < lastevent.seq and
				(a.evt_dolly <> isnull((select evt_dolly
				from @trlevent b
				where b.seq = a.seq + 1),'XXXXXXXXXXX') or
				lgh_number <> isnull((select lgh_number
							from @trlevent b
							where b.seq = a.seq + 1),-123)))

if @@error <> 0 goto exitpoint

/*add dolly2 records */
insert @assethold(lgh_number,  asgn_number, asgn_type, asgn_id,       asgn_date,
		asgn_eventnumber, asgn_controlling, asgn_status, asgn_dispdate,
		asgn_enddate, asgn_dispmethod, mov_number, pyd_status, actg_type,
		evt_number, last_evt_number, first_seq, last_seq,
		completed_seq, started_seq, loaded)
select  firstevent.lgh_number, 0, 'TRL', firstevent.evt_dolly2, firstevent.evt_startdate,
	null, 'N', '', convert(datetime,null) asgn_dispdate,
	lastevent.evt_enddate, null asgn_dispmethod, @mov_number, 'XPY', isnull((select trl_actg_type
										from trailerprofile
										where trl_id = firstevent.evt_dolly2),'N'),
	firstevent.evt_number, lastevent.evt_number, firstevent.seq, lastevent.seq,
	--PTS35229 MBR 11/30/06
	CASE @completeondeparture WHEN 'Y' THEN
	     ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_departure_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN
	     isnull((select max(seq) from @trlevent c
		      where evt_status='DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
	END,
	CASE @completeondeparture WHEN 'Y' then
             ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN -1
	END,
	case when (select count(*)
			from @trlevent x
			where (x.evt_pu_dr in ('PUP','DRP') or
				x.evt_eventcode in ('CTR','HLT','DLT','HCT')) and
				x.seq between firstevent.seq and lastevent.seq) > 0 then 'Y'
	else 'N'
	end
 from @trlevent lastevent, @trlevent firstevent
 where lastevent.evt_dolly2 <> 'UNKNOWN' and
	(lastevent.evt_dolly2 <> isnull((select evt_dolly2
				from @trlevent a
				where a.seq = lastevent.seq + 1),'XXXXXXXXXXX')	or
	lastevent.lgh_number <> isnull((select lgh_number
				from @trlevent a
				where a.seq = lastevent.seq + 1),-123)) and
	firstevent.seq = (select isnull(max(seq)+1,1)
			from @trlevent a
			where a.seq < lastevent.seq and
				(a.evt_dolly2 <> isnull((select evt_dolly2
				from @trlevent b
				where b.seq = a.seq + 1),'XXXXXXXXXXX') or
				lgh_number <> isnull((select lgh_number
							from @trlevent b
							where b.seq = a.seq + 1),-123)))

if @@error <> 0 goto exitpoint

/*add trailer3 records */
insert @assethold(lgh_number,  asgn_number, asgn_type, asgn_id,       asgn_date,
		asgn_eventnumber, asgn_controlling, asgn_status, asgn_dispdate,
		asgn_enddate, asgn_dispmethod, mov_number, pyd_status, actg_type,
		evt_number, last_evt_number, first_seq, last_seq,
		completed_seq, started_seq, loaded)
select  firstevent.lgh_number, 0, 'TRL', firstevent.evt_trailer3, firstevent.evt_startdate,
	null, 'N', '', convert(datetime,null) asgn_dispdate,
	lastevent.evt_enddate, null asgn_dispmethod, @mov_number, 'XPY', isnull((select trl_actg_type
										from trailerprofile
										where trl_id = firstevent.evt_trailer3),'N'),
	firstevent.evt_number, lastevent.evt_number, firstevent.seq, lastevent.seq,
	--PTS35229 MBR 11/30/06
	CASE @completeondeparture WHEN 'Y' THEN
	     ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_departure_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN
	     isnull((select max(seq) from @trlevent c
		      where evt_status='DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
	END,
	CASE @completeondeparture WHEN 'Y' then
             ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN -1
	END,
	case when (select count(*)
			from @trlevent x
			where (x.evt_pu_dr in ('PUP','DRP') or
				x.evt_eventcode in ('CTR','HLT','DLT','HCT')) and
				x.seq between firstevent.seq and lastevent.seq) > 0 then 'Y'
	else 'N'
	end
 from @trlevent lastevent, @trlevent firstevent
 where lastevent.evt_trailer3 <> 'UNKNOWN' and
	(lastevent.evt_trailer3 <> isnull((select evt_trailer3
				from @trlevent a
				where a.seq = lastevent.seq + 1),'XXXXXXXXXXX')	or
	lastevent.lgh_number <> isnull((select lgh_number
				from @trlevent a
				where a.seq = lastevent.seq + 1),-123)) and
	firstevent.seq = (select isnull(max(seq)+1,1)
			from @trlevent a
			where a.seq < lastevent.seq and
				(a.evt_trailer3 <> isnull((select evt_trailer3
				from @trlevent b
				where b.seq = a.seq + 1),'XXXXXXXXXXX') or
				lgh_number <> isnull((select lgh_number
							from @trlevent b
							where b.seq = a.seq + 1),-123)))

if @@error <> 0 goto exitpoint

/*add trailer4 records */
insert @assethold(lgh_number,  asgn_number, asgn_type, asgn_id,       asgn_date,
		asgn_eventnumber, asgn_controlling, asgn_status, asgn_dispdate,
		asgn_enddate, asgn_dispmethod, mov_number, pyd_status, actg_type,
		evt_number, last_evt_number, first_seq, last_seq,
		completed_seq, started_seq, loaded)
select  firstevent.lgh_number, 0, 'TRL', firstevent.evt_trailer4, firstevent.evt_startdate,
	null, 'N', '', convert(datetime,null) asgn_dispdate,
	lastevent.evt_enddate, null asgn_dispmethod, @mov_number, 'XPY', isnull((select trl_actg_type
										from trailerprofile
										where trl_id = firstevent.evt_trailer4),'N'),
	firstevent.evt_number, lastevent.evt_number, firstevent.seq, lastevent.seq,
	--PTS35229 MBR 11/30/06
	CASE @completeondeparture WHEN 'Y' THEN
	     ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_departure_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN
	     isnull((select max(seq) from @trlevent c
		      where evt_status='DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
	END,
	CASE @completeondeparture WHEN 'Y' then
             ISNULL((SELECT MAX(seq) FROM @trlevent c
                      WHERE evt_status = 'DNE' and
                            c.lgh_number = firstevent.lgh_number), -1)
             WHEN 'N' THEN -1
	END,
	case when (select count(*)
			from @trlevent x
			where (x.evt_pu_dr in ('PUP','DRP') or
				x.evt_eventcode in ('CTR','HLT','DLT','HCT')) and
				x.seq between firstevent.seq and lastevent.seq) > 0 then 'Y'
	else 'N'
	end
 from @trlevent lastevent, @trlevent firstevent
 where lastevent.evt_trailer4 <> 'UNKNOWN' and
	(lastevent.evt_trailer4 <> isnull((select evt_trailer4
				from @trlevent a
				where a.seq = lastevent.seq + 1),'XXXXXXXXXXX')	or
	lastevent.lgh_number <> isnull((select lgh_number
				from @trlevent a
				where a.seq = lastevent.seq + 1),-123)) and
	firstevent.seq = (select isnull(max(seq)+1,1)
			from @trlevent a
			where a.seq < lastevent.seq and
				(a.evt_trailer4 <> isnull((select evt_trailer4
				from @trlevent b
				where b.seq = a.seq + 1),'XXXXXXXXXXX') or
				lgh_number <> isnull((select lgh_number
							from @trlevent b
							where b.seq = a.seq + 1),-123)))

if @@error <> 0 goto exitpoint
/*end 49323*/

/*find the assetassignemnt number if it on file*/
update @assethold
set asgn_number= assetassignment.asgn_number,
	pyd_status = assetassignment.pyd_status,
	actg_type = case assetassignment.pyd_status
			when 'NPD' then
				ah.actg_type
			else assetassignment.actg_type
			end
from @assethold ah, assetassignment with (nolock)
where ah.asgn_type = assetassignment.asgn_type and
	ah.asgn_id = assetassignment.asgn_id and
	ah.lgh_number = assetassignment.lgh_number and
	ah.evt_number = assetassignment.evt_number and
	ah.asgn_number = 0 and
    isnull(assetassignment.aa_nonprimary_asset, 'N') = 'N'

if @@error <> 0 goto exitpoint

/*second update without event to grab any event number changes*/
update @assethold
set asgn_number = assetassignment.asgn_number,
	pyd_status = assetassignment.pyd_status,
	actg_type = case assetassignment.pyd_status
			when 'NPD' then
				ah.actg_type
			else assetassignment.actg_type
			end
from @assethold ah, assetassignment with (nolock)
where ah.asgn_type = assetassignment.asgn_type and
	ah.asgn_id = assetassignment.asgn_id and
	ah.lgh_number = assetassignment.lgh_number and
	isnull(assetassignment.aa_nonprimary_asset, 'N') = 'N' and
	ah.asgn_number = 0 and
        not exists (select * from @assethold a
			where a.asgn_number = 	assetassignment.asgn_number)

if @@error <> 0 goto exitpoint

/*status update
mf 12428 last and next event*/
--	LOR	PTS# 27738	don't keep CMP status on the started leg
--PTS35229 MBR 11/30/06
IF @completeondeparture = 'Y'
BEGIN
   update @assethold
   set asgn_status = case when started_seq < first_seq then
				case when (select lgh_outstatus
						from legheader
						where legheader.lgh_number = ah.lgh_number) = 'DSP' then 'DSP'
				else
					'PLN'
				end
			when started_seq <= last_seq and completed_seq < last_seq
 				then 'STD'
			when completed_seq >= last_seq
                                then 'CMP'
			end,
	last_dne_evt_number =
			case when completed_seq < first_seq then 0
			when completed_seq < last_seq then /*get event from completed_seq */
				(select min(evt_number) from @trlevent t where t.seq = completed_seq)
			else last_evt_number
			end,
	next_opn_evt_number =
			case when completed_seq < first_seq then evt_number
			when completed_seq < last_seq then /*get event from completed_seq */
				isnull((select min(evt_number) from @trlevent t where t.seq = completed_seq + 1), last_evt_number)
			else 0
			end
   from @assethold ah
END
ELSE
BEGIN
   update @assethold
   set asgn_status = case	when completed_seq < first_seq then
				case when (select lgh_outstatus
						from legheader
						where legheader.lgh_number = ah.lgh_number) = 'DSP' then 'DSP'
				else
					'PLN'
				end
			when completed_seq < last_seq
   /*OR
					(select lgh_outstatus
					from legheader
					where legheader.lgh_number = ah.lgh_number) = 'STD'
   */
				then 'STD'
			else 'CMP'
			end,
	last_dne_evt_number =
			case when completed_seq < first_seq then 0
			when completed_seq < last_seq then /*get event from completed_seq */
				(select min(evt_number) from @trlevent t where t.seq = completed_seq)
			else last_evt_number
			end,
	next_opn_evt_number =
			case when completed_seq < first_seq then evt_number
			when completed_seq < last_seq then /*get event from completed_seq */
				isnull((select min(evt_number) from @trlevent t where t.seq = completed_seq + 1), last_evt_number)
			else 0
			end
   from @assethold ah

END
if @@error <> 0 goto exitpoint

-- RE - 5/16/03 - PTS #18289 BEGIN
DECLARE	@cmp_id_start 	VARCHAR(8),
		@cmp_id_end		VARCHAR(8),
		@lgh_miles		INTEGER,
		@lgh_outstatus	VARCHAR(6)

IF (SELECT	UPPER(LEFT(gi_string1,1))
	  FROM	generalinfo
	 WHERE	gi_name = 'StlRemoveOneLocMTMoves') = 'Y'
BEGIN
	IF (SELECT	COUNT(*)
		  FROM	stops
		 WHERE	mov_number = @mov_number) = 2
	BEGIN
		SELECT	@cmp_id_start = cmp_id_start,
				@cmp_id_end = cmp_id_end,
				@lgh_outstatus = lgh_outstatus
		  FROM	legheader
		 WHERE	mov_number = @mov_number

		IF	((@cmp_id_start = @cmp_id_end) AND (@lgh_outstatus = 'CMP') AND
			((SELECT	SUM(ISNULL(stp_lgh_mileage,0))
			    FROM	stops
			   WHERE	mov_number = @mov_number) = 0))
		BEGIN
			IF (SELECT	COUNT(*)
				  FROM	stops
				 WHERE	mov_number = @mov_number AND
						stp_event IN ('BBT', 'BMT', 'EBT', 'EMT')) = 2
			BEGIN
				UPDATE	@assethold
				   SET	pyd_status = 'PPD'

				IF @@error <> 0 GOTO exitpoint
			END
		END
	END
END
-- RE - 5/16/03 - PTS #18289 END
--vjh 63018 Branches

update @assethold
set asgn_branch = mpp_branch
from manpowerprofile
where asgn_type='DRV'
and mpp_id=asgn_id
and asgn_branch is null 

update @assethold
set asgn_branch = trc_branch
from tractorprofile
where asgn_type='TRC'
and trc_number=asgn_id
and asgn_branch is null 

update @assethold
set asgn_branch = trl_branch
from trailerprofile
where asgn_type='TRL'
and trl_number=asgn_id
and asgn_branch is null 

update @assethold
set asgn_branch = car_branch
from carrier
where asgn_type='CAR'
and car_id=asgn_id
and asgn_branch is null 

--mf 16830 chagne asgn_number to identity
while (select count(*) from @assethold
	where asgn_number=0) > 0
begin
	--Do insert to get identity the let update code fix trl_asgn fields
	select @rec_id = min(rec_id) from @assethold
	where asgn_number=0

	INSERT INTO assetassignment(lgh_number, asgn_type, asgn_id,
		asgn_date, asgn_eventnumber, asgn_controlling, asgn_status,
		asgn_dispdate, asgn_enddate, asgn_dispmethod, mov_number,
		pyd_status, actg_type, evt_number, asgn_trl_first_asgn,
		asgn_trl_last_asgn, last_evt_number, last_dne_evt_number, next_opn_evt_number, asgn_branch)
	select lgh_number, asgn_type, asgn_id,
		asgn_date, asgn_eventnumber, asgn_controlling, asgn_status,
		asgn_dispdate, asgn_enddate, asgn_dispmethod, mov_number,
		pyd_status, actg_type, evt_number, asgn_trl_first_asgn,
		asgn_trl_last_asgn, last_evt_number, last_dne_evt_number, next_opn_evt_number, asgn_branch
	from @assethold ah
	where rec_id = @rec_id

	-- PTS 28186 - DJM + KMM  - Prevent a trigger on the assetassignment from returning
	--	and incorrect identity value.
	select @asgn_number = scope_identity()

	update @assethold
	set asgn_number = @asgn_number
	where rec_id = @rec_id
end

/* do TotalMails consolidate trailer assign stuff for trailer that cross*/
update @assethold
set asgn_trl_first_asgn = (select asgn_number
		from @assethold a
		where a.asgn_type = 'TRL' and
			a.loaded = 'Y' and
			a.asgn_id = ah.asgn_id and
			a.asgn_controlling = ah.asgn_controlling  and
			a.first_seq = cons_trl.first_seq),
 asgn_trl_last_asgn = (select asgn_number
		from @assethold a
		where a.asgn_type = 'TRL' and
			a.loaded = 'Y' and
			a.asgn_id = ah.asgn_id and
			a.asgn_controlling = ah.asgn_controlling  and
			a.first_seq = cons_trl.last_seq)
from @assethold ah, (select asgn_id, asgn_controlling, min(first_seq) first_seq, max(first_seq) last_seq
	from @assethold
	where asgn_type = 'TRL' and
		loaded = 'Y'
	group by asgn_id, asgn_controlling) cons_trl
where ah.asgn_type = 'TRL' and
	ah.loaded = 'Y' and
	ah.asgn_id = cons_trl.asgn_id and
	ah.asgn_controlling = cons_trl.asgn_controlling and
	ah.first_seq between cons_trl.first_seq and cons_trl.last_seq

if @@error <> 0 goto exitpoint

/* do TotalMails consolidate trailer assign stuff for trailer that do not cross*/
update @assethold
set asgn_trl_first_asgn = asgn_number,
 asgn_trl_last_asgn = asgn_number
from @assethold ah
where ah.asgn_type = 'TRL' and
	asgn_trl_first_asgn is null

if @@error <> 0 goto exitpoint

/* PTS 31598 - DJM - 02/02/2006 - Set the correct pyd_status on the assetassignment record		*/
/* PTS 33550 (31021) - DJM - Set the Pay Status to the specified code if the specified condition exists		*/
If Exists (Select gi_string1 from generalinfo where gi_name = 'MinAssetAssignPayCode' and gi_string1 ='Y')
	Begin

		select @donotpay_status = gi_string1,
			@donotpay_type = gi_string2,
			@donotpay_field = isNull(gi_string3, 'lgh_type1')
		from generalinfo
		where gi_name = 'MinAssetAssignPayStatus'


	 	if exists (select 1
			from legheader l inner join @assethold a on l.lgh_number = a.lgh_number
			where @donotpay_type = (Case when @donotpay_field = 'lgh_type1' then l.lgh_type1
										when @donotpay_field = 'lgh_type2' then l.lgh_type2
										when @donotpay_field = 'lgh_type3' then l.lgh_type3
										when @donotpay_field = 'lgh_type4' then l.lgh_type4
										End))

		/* Set the Asset Assignment status to the non-payable status for all the
			AssetAssignment records of the Leg that are not already paid		*/

			Update @assethold
			set pyd_status = @donotpay_status
			from @assethold a inner join legheader l on a.lgh_number = l.lgh_number
			where a.pyd_status <> 'PPD'
				and @donotpay_type = (Case when @donotpay_field = 'lgh_type1' then l.lgh_type1
										when @donotpay_field = 'lgh_type2' then l.lgh_type2
										when @donotpay_field = 'lgh_type3' then l.lgh_type3
										when @donotpay_field = 'lgh_type4' then l.lgh_type4
										End)


	End


SET @asgn_number = 0

while (select count(*) from @assethold where ISNULL(new_row, 'N') <> 'Y'  and asgn_number > @asgn_number) > 0
BEGIN
	select @asgn_number = min(asgn_number) from @assethold where ISNULL(new_row, 'N') <> 'Y'  and asgn_number > @asgn_number

	/*do updates*/
	UPDATE assetassignment
	SET lgh_number= ah.lgh_number,
		asgn_type=ah.asgn_type,
		asgn_id=ah.asgn_id,
		asgn_date=ah.asgn_date,
		asgn_eventnumber=ah.asgn_eventnumber,
		asgn_controlling=ah.asgn_controlling,
		asgn_status=ah.asgn_status,
		asgn_dispdate=ah.asgn_dispdate,
		asgn_enddate=ah.asgn_enddate,
		asgn_dispmethod=ah.asgn_dispmethod,
		mov_number=ah.mov_number,
		pyd_status=ah.pyd_status,
		actg_type=ah.actg_type,
		evt_number=ah.evt_number,
		asgn_trl_first_asgn=ah.asgn_trl_first_asgn,
		asgn_trl_last_asgn=ah.asgn_trl_last_asgn,
		last_evt_number=ah.last_evt_number,
		last_dne_evt_number = ah.last_dne_evt_number,
		next_opn_evt_number = ah.next_opn_evt_number
	from @assethold ah
	WHERE assetassignment.asgn_number =  ah.asgn_number and
		  ah.asgn_number = @asgn_number and
		  isnull(assetassignment.aa_nonprimary_asset, 'N') = 'N' and
		  (ISNULL(assetassignment.lgh_number, -867539) <> ISNULL(ah.lgh_number, -867539) or
		ISNULL(assetassignment.asgn_type, '-867539') <> ISNULL(ah.asgn_type, '-867539') or
		ISNULL(assetassignment.asgn_id, '-867539') <> ISNULL(ah.asgn_id, '-867539') or
		ISNULL(assetassignment.asgn_date, '19490101 00:00') <> ISNULL(ah.asgn_date, '19490101 00:00') or
		ISNULL(assetassignment.asgn_eventnumber, -867539) <> ISNULL(ah.asgn_eventnumber, -867539) or
		ISNULL(assetassignment.asgn_controlling, '-867539') <> ISNULL(ah.asgn_controlling, '-867539') or
		ISNULL(assetassignment.asgn_status, '-867539') <> ISNULL(ah.asgn_status, '-867539') or
		ISNULL(assetassignment.asgn_dispdate, '19490101 00:00') <> ISNULL(ah.asgn_dispdate, '19490101 00:00') or
		ISNULL(assetassignment.asgn_enddate, '19490101 00:00') <> ISNULL(ah.asgn_enddate, '19490101 00:00') or
		ISNULL(assetassignment.asgn_dispmethod, '-867539') <> ISNULL(ah.asgn_dispmethod, '-867539') or
		ISNULL(assetassignment.mov_number, -867539) <> ISNULL(ah.mov_number, -867539) or
		ISNULL(assetassignment.pyd_status, '-867539') <> ISNULL(ah.pyd_status, '-867539') or
		ISNULL(assetassignment.actg_type, '-867539') <> ISNULL(ah.actg_type, '-867539') or
		ISNULL(assetassignment.evt_number, -867539) <> ISNULL(ah.evt_number, -867539) or
		ISNULL(assetassignment.asgn_trl_first_asgn, -867539) <> ISNULL(ah.asgn_trl_first_asgn, -867539) or
		ISNULL(assetassignment.asgn_trl_last_asgn, -867539) <> ISNULL(ah.asgn_trl_last_asgn, -867539) or
		ISNULL(assetassignment.last_evt_number, -867539) <> ISNULL(ah.last_evt_number, -867539) or
		ISNULL(assetassignment.last_dne_evt_number, -867539) <> ISNULL(ah.last_dne_evt_number, -867539) or
		ISNULL(assetassignment.next_opn_evt_number, -867539) <> ISNULL(ah.next_opn_evt_number, -867539))

	if @@error <> 0 goto exitpoint
END

/*put in assignemnts to be deleted*/
insert @assethold(asgn_number, asgn_type, asgn_id, new_row)
select asgn_number, asgn_type, asgn_id, 'D'
from assetassignment with (nolock)
where 	IsNull(assetassignment.asgn_status, 'XXX') NOT IN ('DNR', 'REF') AND
	isnull(assetassignment.aa_nonprimary_asset, 'N') = 'N' and
	assetassignment.lgh_number in (select distinct lgh_number from stops  with (nolock)
					where mov_number = @mov_number) and
      not exists (select * from @assethold ah
			where ah.asgn_number = 	assetassignment.asgn_number)

if @@error <> 0 goto exitpoint

/*remove old assignment records*/
DECLARE @cmd_id VARCHAR (8), @cmd_ord INTEGER, @cmd_date DATETIME, @cmd_mov INTEGER	/* 07/26/2010 MDH PTS 52531: Added */
SET @asgn_number = 0

while (select count(*) from @assethold where new_row = 'D' and asgn_number > @asgn_number) > 0
BEGIN
	select @asgn_number = min(asgn_number)
		from @assethold where new_row = 'D' and asgn_number > @asgn_number
	SELECT 	@asgn_type = asgn_type,
       		@asgn_id = asgn_id
		FROM @assethold
		WHERE @asgn_number = asgn_number

    /* 07/26/2010 MDH PTS 52531: Reset last commodity <<BEGIN>> */
    IF @asgn_type = 'TRL'
    BEGIN
		SET @cmd_id = 'UNKNOWN'
		SELECT	@cmd_mov = mov_number
			  FROM	assetassignment
			 WHERE	asgn_date =
				(select max(assetassignment.asgn_date)
				 FROM assetassignment, stops
				 WHERE stops.mov_number = assetassignment.mov_number
					 AND assetassignment.asgn_type = 'TRL'
					 AND assetassignment.asgn_id = @asgn_id
					 AND stops.stp_type IN ('PUP','DRP')
					 AND stops.trl_id = assetassignment.asgn_id
					 AND assetassignment.asgn_status = 'CMP'
					 AND stops.mov_number <> @mov_number)
		             AND asgn_type = 'TRL'
				     AND asgn_id = @asgn_id
		IF ISNULL(@cmd_mov, 0) <> 0
		BEGIN
		     SELECT @cmd_id = ISNULL(cmd_code, 'UNKNOWN'),
					@cmd_ord = ord_hdrnumber,
					@cmd_date = stp_arrivaldate
		         FROM stops
			     WHERE mov_number = @cmd_mov 
			     AND   stp_mfh_sequence = (SELECT   MAX(stp_mfh_sequence)
										       FROM stops, event
										      WHERE stops.mov_number = @cmd_mov AND
										            stops.ord_hdrnumber <> 0 AND
										            ISNULL(stops.cmd_code, 'UNKNOWN') <> 'UNKNOWN' AND
										            stops.stp_number = event.stp_number AND
										            event.evt_trailer1 = @asgn_id AND
										            event.evt_sequence = 1)
		     IF ISNULL(@cmd_id, 'UNKNOWN') = 'UNKNOWN'
		     BEGIN
		          SELECT @cmd_id = ISNULL(cmd_code, 'UNKNOWN'),
				         @cmd_ord = ord_hdrnumber,
				         @cmd_date = ord_completiondate
		            FROM orderheader
					WHERE ord_hdrnumber = (SELECT TOP 1 ord_hdrnumber
								            FROM stops
								           WHERE mov_number = @cmd_mov AND
													ord_hdrnumber <> 0 AND
								                 stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
												                       FROM stops
												                      WHERE mov_number = @cmd_mov AND
													                    ord_hdrnumber <> 0))
		     END

		END
		UPDATE trailerprofile 
			SET trl_last_cmd      = case when @cmd_id is null then 'UNKNOWN' else @cmd_id   end,
				trl_last_cmd_ord  = @cmd_ord,
				trl_last_cmd_date = @cmd_date
			WHERE trl_id = @asgn_id 
    END
    /* 07/26/2010 MDH PTS 52531: Reset last commodity <<END>> */

	DELETE assetassignment
		WHERE asgn_number = @asgn_number 
		AND isnull(assetassignment.aa_nonprimary_asset, 'N') = 'N'
END

/*PTS13579 MBR 3/14/02  commented out PTS10748 below.*/
/*pts 10748 dsk 5/31/01 -- This may mess up the trlconflictchecklevel=LEG option
update assetassignment
set asgn_status = 'STD'
where mov_number = @mov_number
and asgn_type = 'TRL'
and exists (select asgn_id from assetassignment b where assetassignment.asgn_id = b.asgn_id and b.asgn_type = 'TRL' and b.asgn_status in ('STD', 'CMP') and b.mov_number = @mov_number)
and exists (select asgn_id from assetassignment c where assetassignment.asgn_id = c.asgn_id and c.asgn_type = 'TRL' and c.asgn_status in ('PLN', 'DSP') and c.mov_number = @mov_number)
and not exists (select evt_number from stops where mov_number = @mov_number and stp_event = 'CTR')*/

--drop table #trlevent
--drop table #assethold

-- 32720
delete @tmp
SELECT @minlgh = 0

INSERT INTO @tmp
SELECT distinct lgh_number
FROM stops
WHERE mov_number = @mov_number

SELECT @minlgh = MIN(lgh_number)
FROM @tmp
WHERE lgh_number > @minlgh

while @minlgh is not null and @minlgh > 0
begin
	select @lgh_type5 = lgh_type5, @lgh_type3 = lgh_type3 from legheader where lgh_number = @minlgh
	if @lgh_type5 = 'NoSetl' or @lgh_type3 = 'NoSetl'
	begin
		Update AssetAssignment
		set pyd_status = 'PPD'
		where assetassignment.lgh_number = @minlgh
		  and isnull(assetassignment.aa_nonprimary_asset, 'N') = 'N'
	end

	SELECT @minlgh = MIN(lgh_number)
	FROM @tmp
	WHERE lgh_number > @minlgh
end

-- 32720


return 1

exitpoint:
rollback
return -1
GO
GRANT EXECUTE ON  [dbo].[update_assetassignment] TO [public]
GO
