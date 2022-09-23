CREATE TABLE [dbo].[event]
(
[ord_hdrnumber] [int] NULL,
[stp_number] [int] NULL,
[evt_eventcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_number] [int] NULL,
[evt_startdate] [datetime] NULL,
[evt_enddate] [datetime] NULL,
[evt_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_earlydate] [datetime] NULL,
[evt_latedate] [datetime] NULL,
[evt_weight] [float] NULL,
[evt_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_number] [int] NULL,
[evt_count] [decimal] (10, 2) NULL,
[evt_countunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_volume] [float] NULL,
[evt_volumeunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_pu_dr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_sequence] [int] NULL,
[evt_contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[evt_driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_trailer1] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_trailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_chassis] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_evt_chassis] DEFAULT ('UNKNOWN'),
[evt_dolly] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_evt_dolly] DEFAULT ('UNKNOWN'),
[evt_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_refype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_reason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_enteredby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_hubmiles] [int] NULL,
[skip_trigger] [tinyint] NULL,
[evt_mov_number] [int] NULL,
[evt_departure_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_hubmiles_trailer1] [int] NULL,
[evt_hubmiles_trailer2] [int] NULL,
[evt_chassis2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__event__evt_chass__20BD80AE] DEFAULT ('UNKNOWN'),
[evt_dolly2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_evt_dolly2] DEFAULT ('UNKNOWN'),
[evt_trailer3] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_evt_trailer3] DEFAULT ('UNKNOWN'),
[evt_trailer4] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_evt_trailer4] DEFAULT ('UNKNOWN'),
[stp_mfh_number] [int] NULL,
[stp_transfer_stp] [int] NULL,
[evt_lghtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_lghtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_lghtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_lghtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_mfh_number] [int] NULL CONSTRAINT [DF__event__evt_mfh_n__5198B996] DEFAULT ((0)),
[evt_dock_worker] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_id] [int] NULL CONSTRAINT [DF__event__item_id__528CDDCF] DEFAULT ((0)),
[evt_forklift] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_event_consolidated] ON [dbo].[event] FOR DELETE AS 
/* EXECUTE timerins "dt_event", "START" */
/* 09/05/06 PTS34311 JG consolidate and optimize trigger */
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE @nextevt int,
	@deletedevt int,
	@lgh int

--PTS34311 prevent empty firing
if not exists (select 1 from deleted) return
--PTS34311 end

/* delete any drop empty trailer that corresponds to this if was begin empty, hook empty */
SELECT @lgh = MIN (lgh_number)
FROM stops, deleted
WHERE deleted.stp_number = stops.stp_number
IF @lgh IS NOT null /* would be null if stop was deleted first */
	DELETE event
	FROM stops, deleted
	WHERE stops.lgh_number = @lgh AND
		event.stp_number = stops.stp_number AND
		--PTS79314 JJF 20140806 add IDMT, IHMT
		event.evt_eventcode IN ( 'DMT', 'EMT', 'EBT', 'IDMT' ) AND
		deleted.evt_eventcode IN ( 'HMT', 'BMT', 'BBT', 'IHMT' ) AND
		event.evt_trailer1 = deleted.evt_trailer1 AND
		deleted.stp_number <> event.stp_number AND
		event.evt_sequence > 1
	
/*MF pts 8060 removed asset assignment code now handled by update_assetassignment*/

return

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[it_event_consolidated] ON [dbo].[event] FOR INSERT
as 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/* Revision History:
	Date		Name			PTS #	Label	Description
	-----------	---------------	-------	-------	-------------------------------------------------------------------------
	01/14/2002	Vern Jewett 	12853	vmj1	Update tractorprofile.trc_currenthub if rows are inserted where 
												evt_hubmiles > tractorprofile.trc_currenthub for the associated tractor.
	06/05/2002	Vern Jewett		14374	vmj2	Only update trc_currenthub if evt_status = DNE.
	10/07/2003  	Nate K			20009	ntk		Add trigger for appt 214s on insertion of actual SAPs	
	09/13/2006	JG			34211		consolidate and optimize trigger								
	10/12/06	JJF			32408		trailer hub
*/
declare @eventcode varchar(6),
	@level varchar(2),
	@EDI_Notification_Process_Type int,
	@ediappttriggeroption char(1),
	@match_count int,
	@stp_number int,
	@ord_hdrnumber int,
	@ord_billto varchar(8),
	@ps_activity varchar(8),
	@stp_sequence int,
	@firstlastflags varchar(20),
	@replicateforeachdropflag char(1),
	@auto214flag char(1),
	@stp_latest datetime,
	@insertedstatus varchar(6),
	@appName nvarchar(128),
	@tmwuser varchar(255)

/* JLB PTS 37866 remove all Pallet Tracking from triggers this will be done from now on
                 via stored proc called from update move
--PTS34311 begin, relocated from old trigger IUT_PALLET_TRACKING_EVENT
declare @enhanced varchar(8),
        @count int 
--PTS34311 end
*/

--PTS34311 prevent empty firing
if not exists (select 1 from inserted) return
--PTS34311 end

/* JLB PTS 37866 remove all Pallet Tracking from triggers this will be done from now on
                 via stored proc called from update move
--------------------------------------------------------------------------
--PTS34311 begin, logic relocated from old trigger IUT_PALLET_TRACKING_EVENT
SET @enhanced = ''
select @enhanced= gi_string1 
from generalinfo
where gi_name = 'EnhPltTrkng'

if @enhanced = 'Y'
BEGIN

IF Update(evt_tractor)or update (evt_trailer1) or update (evt_carrier)
BEGIN

select @count =  count (*) 
  from pallet_tracking 
 where pt_fgt_number in (SELECT freightdetail.fgt_number 
                           from freightdetail, inserted
                          where freightdetail.stp_number = inserted.stp_number)

	if @count > 0
		update pallet_tracking
		   set pt_tractor_number = event.evt_tractor, 
	               pt_trailer_number = event.evt_trailer1, 
	               pt_carrier_id     = event.evt_carrier 
		  from event, freightdetail 
		 where event.stp_number IN (SELECT stp_number 
                                              FROM inserted) AND
		       event.evt_sequence = 1 AND 
		       event.stp_number = freightdetail.stp_number AND 
		       freightdetail.fgt_number = pallet_tracking.pt_fgt_number 
	else
		insert into pallet_tracking
			   (pt_pallets_in, pt_pallets_out, pt_pallet_type, pt_fgt_number,
                            pt_tractor_number, pt_trailer_number, pt_carrier_id, pt_company_id,
			    pt_activity_date, pt_ord_number, pt_entry_type)
			SELECT ISNULL(fgt_pallets_in, 0), ISNULL(fgt_pallets_out, 0), 
			       ISNULL(fgt_pallet_type, 'UNK'), freightdetail.fgt_number, 
                               ISNULL(evt_tractor, 'UNKNOWN'), ISNULL (evt_trailer1, 'UNKNOWN'),
                               ISNULL(evt_carrier, 'UNKNOWN'), ISNULL(stops.cmp_id, 'UNKNOWN'),
			       stops.stp_arrivaldate, orderheader.ord_number,
			        (case rtrim(ltrim(lgh_updateapp)) when 'Tmxactui' then 'U' Else 'O' end)
			from event, stops, freightdetail, orderheader, legheader
			where event.stp_number in (select stp_number 
                                                    from inserted) AND
			      EVENT.EVT_SEQUENCE = 1 AND 
			      EVENT.STP_NUMBER = stops.Stp_number and 
                              EVENT.STP_NUMBER = freightdetail.stp_number AND 
			      (fgt_pallets_in > 0 OR fgt_pallets_out > 0) and
                               stops.lgh_number = legheader.lgh_number and
                              stops.stp_status = 'DNE' and
      			      stops.ord_hdrnumber = orderheader.ord_hdrnumber			
END

END
--PTS34311 end
--------------------------------------------------------------------------
*/

-- 20009
SELECT @EDI_Notification_Process_Type = isnull(gi_string1,1)
FROM generalinfo
WHERE gi_name = 'EDI_Notification_Process_Type'	

select @ediappttriggeroption = substring(isnull(gi_string1,'T'),1,1)
from generalinfo 
where gi_name = 'EDI214ApptTrigger'

select @auto214flag = substring(isnull(gi_string1,'N'),1,1)
from generalinfo
where gi_name = 'Auto214Flag'

--20009 ntk trigger appt 214s on sap actualization
if update(evt_status)
begin
	--PTS74227 Include Source of Status
	 exec gettmwuser @tmwuser OUTPUT
	 SELECT @appName = APP_NAME()

	select @eventcode = inserted.evt_eventcode, @insertedstatus = inserted.evt_status from inserted
	
	if @ediappttriggeroption in ('S','B') --ie setting is for SAP trigger or for both
		and @eventcode = 'SAP' 
		and @insertedstatus = 'DNE'
		and @auto214flag = 'Y'
	begin
		--need to ensure we get ord_hdrnumber for parent stop in case event.ord_hdrnumber is null
		select @ord_hdrnumber = stops.ord_hdrnumber from stops, inserted where inserted.stp_number = stops.stp_number

		select @stp_number = inserted.stp_number,
			@ord_billto = orderheader.ord_billto,
			@ps_activity = 'APPT', --appt is the only activity trigger via the event status change now
			@stp_sequence = stops.stp_sequence,
			@firstlastflags = '0,1,99', --stop position criteria aren't implemented; this criterion is also true
			@stp_latest = stops.stp_schdtlatest,
			@level = case stops.stp_type
				when 'PUP' then 'SH'
				when 'DRP' then 'CN'
			else 'NON'
			end
		from inserted, stops, orderheader
		where inserted.stp_number = stops.stp_number and @ord_hdrnumber = orderheader.ord_hdrnumber

		SELECT @match_count=count(*),@ReplicateForEachDropFlag=Max(IsNull(e214_ReplicateForEachDropFlag,'N') ) 
		FROM edi_214_profile
		WHERE e214_cmp_id=@ord_billto and
		e214_level = @level  and 
		CHARINDEX(e214_triggering_activity, @ps_activity) > 0
		IF @EDI_Notification_Process_Type = 1 --trigger rules by billto
		BEGIN
			IF @match_count>0
				INSERT edi_214_pending (
					e214p_ord_hdrnumber,
					e214p_billto,
					e214p_level,
					e214p_ps_status,
					e214p_stp_number,
					e214p_dttm,
					e214p_activity,
					e214p_arrive_earlyorlate,
					e214p_depart_earlyorlate,
					e214p_stpsequence,
					ckc_number,
					e214p_firstlastflags,
					e214p_created,
					e214p_ReplicateForEachDropFlag,
					e214p_source,
					e214p_user)
				VALUES (@ord_hdrnumber,
					@ord_billto,
					@level,
					' ',
					@stp_number,
					@stp_latest,
					@ps_activity,
					' ',
					' ',
					@stp_sequence,
					0,
					@firstlastflags,
					getdate(),
					@ReplicateForEachDropFlag,
					@appName,
					@tmwuser)
		END
		IF @EDI_Notification_Process_Type = 2	--trigger rules by company
		BEGIN 
			INSERT edi_214_pending (
				e214p_ord_hdrnumber,
				e214p_billto,
				e214p_level,
				e214p_ps_status,
				e214p_stp_number,
				e214p_dttm,
				e214p_activity,
				e214p_arrive_earlyorlate,
				e214p_depart_earlyorlate,
				e214p_stpsequence,
				ckc_number,
				e214p_firstlastflags,
				e214p_created,
				e214p_ReplicateForEachDropFlag,
				e214p_source,
				e214p_user)
			SELECT distinct @ord_hdrnumber,
				e214_cmp_id,
				@level,
				' ',
				@stp_number,
				@stp_latest,
				@ps_activity,
				' ',
				' ',
				@stp_sequence,
				0,
				@firstlastflags,
				getdate(),
				@ReplicateForEachDropFlag,
				@appName,
				@tmwuser
				from edi_214_profile, stops
				where e214_level = @level
				and ord_hdrnumber = @ord_hdrnumber
				and stp_type = 'PUP'
				and cmp_id = e214_cmp_id
				and shipper_role_flag = 'Y'
				and e214_triggering_activity = @ps_activity
			UNION
			SELECT distinct @ord_hdrnumber,
				e214_cmp_id,
				@level,
				' ',
				@stp_number,
				@stp_latest,
				@ps_activity,
				' ',
				' ',
				@stp_sequence,
				0,
				@firstlastflags,
				getdate(),
				@ReplicateForEachDropFlag,
				@appName,
				@tmwuser
				from edi_214_profile, stops
				where e214_level = @level
				and ord_hdrnumber = @ord_hdrnumber
				and stp_type = 'DRP'
				and cmp_id = e214_cmp_id
				and consignee_role_flag = 'Y'
				and e214_triggering_activity = @ps_activity
			UNION
			SELECT @ord_hdrnumber,
				e214_cmp_id,
				@level,
				' ',
				@stp_number,
				@stp_latest,
				@ps_activity,
				' ',
				' ',
				@stp_sequence,
				0,
				@firstlastflags,
				getdate(),
				@ReplicateForEachDropFlag,
				@appName,
				@tmwuser
				from edi_214_profile, orderheader
				where e214_level = @level
				and ord_hdrnumber = @ord_hdrnumber
				and e214_triggering_activity = @ps_activity
				and ord_billto = e214_cmp_id 
				and billto_role_flag = 'Y'
			UNION
			SELECT @ord_hdrnumber,
				e214_cmp_id,
				@level,
				' ',
				@stp_number,
				@stp_latest,
				@ps_activity,
				' ',
				' ',
				@stp_sequence,
				0,
				@firstlastflags,
				getdate(),
				@ReplicateForEachDropFlag,
				@appName,
				@tmwuser
				from edi_214_profile, orderheader
				where e214_level = @level
				and ord_hdrnumber = @ord_hdrnumber
				and e214_triggering_activity = @ps_activity
				and ord_company = e214_cmp_id 
				and orderby_role_flag = 'Y'
		END	
	end 
end --end 20009 ntk

/*pts 5944*/
if update(evt_trailer2) 
update event
set evt_trailer2='UNKNOWN'
from inserted
where inserted.evt_number  = event.evt_number and
	isnull(event.evt_trailer2,'') = ''

if update(evt_driver2) 
	update event
	set evt_driver2='UNKNOWN'
	from inserted
	where inserted.evt_number  = event.evt_number and
		isnull(event.evt_driver2,'') = ''


/* PTS 21890 - DJM - Remove the select..into statement to avoid recompiles and improve performance	*/
update	tractorprofile
  set	trc_currenthub = th.evt_hubmiles
  from	tractorprofile tp, (select evt_tractor,max(isnull(evt_hubmiles, 0)) as evt_hubmiles
	  		from inserted
	  		group by evt_tractor) th	
  where	tp.trc_number = th.evt_tractor
	and isnull(tp.trc_currenthub, 0) < th.evt_hubmiles
	and trc_number <> 'UNKNOWN'

--PTS 32408 JJF 10/12/2006
update	trailerprofile
  set	trl_currenthub = th.evt_hubmiles_trailer1
  from	trailerprofile tp, (select evt_trailer1, max(isnull(evt_hubmiles_trailer1, 0)) as evt_hubmiles_trailer1
	  		from inserted
	  		group by evt_trailer1) th	
  where	tp.trl_id = th.evt_trailer1
	and isnull(tp.trl_currenthub, 0) < th.evt_hubmiles_trailer1
	and trl_id <> 'UNKNOWN'

update	trailerprofile
  set	trl_currenthub = th.evt_hubmiles_trailer2
  from	trailerprofile tp, (select evt_trailer2, max(isnull(evt_hubmiles_trailer2, 0)) as evt_hubmiles_trailer2
	  		from inserted
	  		group by evt_trailer2) th	
  where	tp.trl_id = th.evt_trailer2
	and isnull(tp.trl_currenthub, 0) < th.evt_hubmiles_trailer2
	and trl_id <> 'UNKNOWN'

--END PTS 32408 JJF 10/12/2006

-- --vmj1+
-- select	evt_tractor
-- 		,max(isnull(evt_hubmiles, 0)) as evt_hubmiles
--   into	#trc_hub
--   from	inserted
--   --vmj2+
--   where	evt_status = 'DNE'
-- 	and	evt_hubmiles > 0
--   --vmj2-
--   group by evt_tractor
-- 
-- update	tractorprofile
--   set	trc_currenthub = th.evt_hubmiles
--   from	#trc_hub th
-- 		,tractorprofile tp
--   where	tp.trc_number = th.evt_tractor
-- 	and	isnull(tp.trc_currenthub, 0) < th.evt_hubmiles
-- --vmj1-


/*SKIP TRIGGER CODE FOR NEW DISPATCH ONLY IS EXECUTED IF SKIP_TRIGGER COLUMN
	IS SET TO 1*/
declare @skip_trigger int
select @skip_trigger = count(*)
from inserted where skip_trigger = 1
if @skip_trigger > 0 
begin
	UPDATE event  
   	SET skip_trigger = 0
     	FROM inserted
    	WHERE (inserted.evt_number = event.evt_number)
   	
	return
end

update event
set evt_mov_number=stops.mov_number
from inserted,stops
where inserted.stp_number = stops.stp_number and
	inserted.evt_number = event.evt_number and
	event.evt_mov_number is null

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_event_consolidated] ON [dbo].[event] FOR UPDATE  AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/*   MODIFICATION LOG

PTS for CTX changes use evt_departure_status to trigger depart stop 
PTS9814 pull all auto 214 code, depart status moves to stops table
08/23/2001	Vern Jewett (label=vmj1)	PTS 11797: Add fingerprint whenever an order
										clears customs.
01/11/2002	Vern Jewett (label=vmj2)	PTS 12853: update tractorprofile.trc_currenthub if evt_hubmiles is updated.
06/05/2002	Vern Jewett	(label=vmj3)	PTS 14374: Only update trc_currenthub if evt_status is DNE.  Also need to cover the 
										case where evt_hubmiles were updated previously, and now evt_status is changing to DNE.
09/23/2002  Matt Zerefos				PTS 12673: Meijer/Summary Systems trailer change trigger.
02/14/2003	Matt Zerefos				PTS 12673: Removed all Meijer/Summary Systems specific code
03/05/2003	Vern Jewett (label=vmj4)	PTS 14374: SQL7 doesn't allow you to create a temp table inside a trigger, so
										I'm just going to limit it to 1-record updates.
10/02/2003 	Nate Kresge					pts 20009: Putting some auto214 code back in for appt triggers. 
01/07/2004	Vern Jewett	(label=vmj5)	PTS 21252: Some inserts into expedite_audit aren't 
										conditioned on GI.FingerPrintAudit=Y; fix this.
05/31/2006	Brian Hanson - PTS 32790:  insert VIN_EVENT_EXPORT when update to evt_departure_status = 'DNE'
6/20/2006   DPETE = PTS33374 performance change for Junhai Guo
09/13/2006	JG PTS34311, consolidate and optimize trigger
4/`9/08  PTS 40260 DPETE recode Pauls 33536 if tractor changes, clear the hub miles reading
7/29/2009	Jim Teubner					PTS 48417 added carrier to the finger print audit
11/17/2014  Mindy Curnutt			    PTS 84589 - If an update fired but no rows were changed, get out of the trigger.
02/12/2016 Mike Luoma					PTS 98182 - Added support for trailers 3-8 on Activity Audit.
*/

if NOT EXISTS (select top 1 * from inserted)
    return

DECLARE @minevt int,
	@ls_evt_eventcode	varchar(6),
--	@li_trc_hub_count	int,
	@ord int,
	@oldtrailer1 varchar(12),
	@oldtrailer2 varchar(12),	
	@newtrailer1 varchar(12),
	@newtrailer2 varchar(12),	
	@stop int,
	@mov int,
	@lgh int,
	@note varchar(255),
	@eventcode varchar(6),
	@li_update_count int,
	@ls_evt_tractor varchar(8),
	@li_evt_hubmiles int,
	@level varchar(2),
	@EDI_Notification_Process_Type int,
	@ediappttriggeroption char(1),
	@match_count int,
	@stp_number int,
	@ord_hdrnumber int,
	@ord_billto varchar(8),
	@ps_activity varchar(8),
	@stp_sequence int,
	@firstlastflags varchar(20),
	@replicateforeachdropflag char(1),
	@auto214flag char(1),
	@stp_latest datetime,
	@insertedstatus varchar(6),
	@deletedstatus varchar(6),
	@ordereventexport char(1),
	@evt_status varchar(6),
	@stp_departuredate datetime,
	@evt_eventcode varchar(6),
	@id_num int,
	@evt_startdate datetime, 
	@oldcarrier varchar(8), 
	@newcarrier varchar(8),
	@appName nvarchar(128)	--72227 AR

/* JLB PTS 37866 remove all Pallet Tracking from triggers this will be done from now on
                 via stored proc called from update move
--PTS34311 begin, relocated from old trigger IUT_PALLET_TRACKING_EVENT
declare @enhanced varchar(8),
        @count int 
--PTS34311 end
*/
--PTS 32408 JJF 10/12/2006
DECLARE @ls_evt_trailer1 varchar(13),
	@ls_evt_trailer2 varchar(13),
	@li_evt_hubmiles_trailer1 int,
	@li_evt_hubmiles_trailer2 int
--END PTS 32408 JJF 10/12/2006	

--jg prevent empty firing  
if not exists (select 1 from inserted) and not exists (select 1 from deleted) return  
--jg end

/* JLB PTS 37866 remove all Pallet Tracking from triggers this will be done from now on
                 via stored proc called from update move
--------------------------------------------------------------------------
--PTS34311 begin, logic relocated from old trigger IUT_PALLET_TRACKING_EVENT
SET @enhanced = ''
select @enhanced= gi_string1 
from generalinfo
where gi_name = 'EnhPltTrkng'

if @enhanced = 'Y'
BEGIN

IF Update(evt_tractor)or update (evt_trailer1) or update (evt_carrier)
BEGIN

select @count =  count (*) 
  from pallet_tracking 
 where pt_fgt_number in (SELECT freightdetail.fgt_number 
                           from freightdetail, inserted
                          where freightdetail.stp_number = inserted.stp_number)

	if @count > 0
		update pallet_tracking
		   set pt_tractor_number = event.evt_tractor, 
	               pt_trailer_number = event.evt_trailer1, 
	               pt_carrier_id     = event.evt_carrier 
		  from event, freightdetail 
		 where event.stp_number IN (SELECT stp_number 
                                              FROM inserted) AND
		       event.evt_sequence = 1 AND 
		       event.stp_number = freightdetail.stp_number AND 
		       freightdetail.fgt_number = pallet_tracking.pt_fgt_number 
	else
		insert into pallet_tracking
			   (pt_pallets_in, pt_pallets_out, pt_pallet_type, pt_fgt_number,
                            pt_tractor_number, pt_trailer_number, pt_carrier_id, pt_company_id,
			    pt_activity_date, pt_ord_number, pt_entry_type)
			SELECT ISNULL(fgt_pallets_in, 0), ISNULL(fgt_pallets_out, 0), 
			       ISNULL(fgt_pallet_type, 'UNK'), freightdetail.fgt_number, 
                               ISNULL(evt_tractor, 'UNKNOWN'), ISNULL (evt_trailer1, 'UNKNOWN'),
                               ISNULL(evt_carrier, 'UNKNOWN'), ISNULL(stops.cmp_id, 'UNKNOWN'),
			       stops.stp_arrivaldate, orderheader.ord_number,
			        (case rtrim(ltrim(lgh_updateapp)) when 'Tmxactui' then 'U' Else 'O' end)
			from event, stops, freightdetail, orderheader, legheader
			where event.stp_number in (select stp_number 
                                                    from inserted) AND
			      EVENT.EVT_SEQUENCE = 1 AND 
			      EVENT.STP_NUMBER = stops.Stp_number and 
                              EVENT.STP_NUMBER = freightdetail.stp_number AND 
			      (fgt_pallets_in > 0 OR fgt_pallets_out > 0) and
                               stops.lgh_number = legheader.lgh_number and
                              stops.stp_status = 'DNE' and
      			      stops.ord_hdrnumber = orderheader.ord_hdrnumber			
END

END
--PTS34311 end
--------------------------------------------------------------------------
*/


--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output


	
--20009
SELECT @EDI_Notification_Process_Type = isnull(gi_string1,1)
FROM generalinfo
WHERE gi_name = 'EDI_Notification_Process_Type'	

select @ediappttriggeroption = substring(isnull(gi_string1,'T'),1,1)
from generalinfo 
where gi_name = 'EDI214ApptTrigger'

select @auto214flag = substring(isnull(gi_string1,'N'),1,1)
from generalinfo
where gi_name = 'Auto214Flag'

--vmj3+
--vmj4+	Remove the temp table..
/* create table #trc_hub
		(evt_tractor	varchar(8)	null
		,evt_hubmiles	int			null)

select	@li_trc_hub_count = 0	*/


--Check the update's record count, so only single-row updates will cause a tractorprofile update..
select	@li_update_count = count(*)
  from	inserted

select	@ls_evt_tractor = ''
		,@li_evt_hubmiles = 0
--vmj4-
--vmj3-


/*pts 5944*/

/*JLB PTS 35809 This code is now getting moved again from the event to the paperwork tables
-- 32790  5/31/2006 BDH
select 	@ordereventexport = upper(left(isnull(gi_string1, 'N'), 1)) 
from	generalinfo
where	gi_name = 'OrderEventExport'
select	@ordereventexport = isnull(@ordereventexport, 'N')

if @ordereventexport = 'Y'
begin
	if update (evt_status) 
	begin
		select @evt_status = evt_status from inserted
		if ltrim(rtrim(@evt_status)) = 'DNE'
		begin
			select @ord_hdrnumber = ord_hdrnumber, @evt_eventcode = evt_eventcode, @stp_number = stp_number
			from inserted
	
			if @ord_hdrnumber > 0 and @evt_eventcode = 'LUL'
			begin
				select @ord_billto = ord_billto 
				from orderheader
				where ord_hdrnumber = @ord_hdrnumber 
	
				if exists(select 1 from company
					where cmp_id = @ord_billto and
					upper(ltrim(rtrim(cmp_id))) <> 'UNKNOWN' and 
					upper(ltrim(rtrim(cmp_id))) <> 'UNK' and 
					cmp_id <> '' and 
					cmp_id is not null)
				begin
					select @stp_departuredate = stp_departuredate			
					from stops
					where stp_number = @stp_number			
			
					exec dbo.insert_vin_event_export_sp @ord_hdrnumber, 'D', @stp_departuredate, '', ''					
				end
			end	
		end	
	end	
end
-- end 32790
*/

-- KM PTS 14577
if update(evt_trailer1) 
	if (select upper(substring(gi_string1,1,1)) from generalinfo
    	 where gi_name = 'FingerprintAudit') = 'Y'

	begin
		select	@oldtrailer1 = isnull(deleted.evt_trailer1, 'UNKNOWN'),
	                @newtrailer1 = isnull(inserted.evt_trailer1, 'UNKNOWN'),
			-- RE - 01/06/03 - PTS #20833
			--@ord = inserted.ord_hdrnumber,
			@ord = ISNULL(inserted.ord_hdrnumber, 0),
			@stop = inserted.stp_number,
			@mov = inserted.evt_mov_number,
			@lgh = stops.lgh_number,
			@eventcode = inserted.evt_eventcode
	          from  inserted, stops, deleted
		where   inserted.stp_number = stops.stp_number and
			deleted.stp_number = stops.stp_number


		SELECT @note = 'EVENT ' + ltrim(rtrim(@eventcode)) + ' - TRL1 ' + @oldtrailer1 + ' -> ' + @newtrailer1
		
		If @oldtrailer1 <> @newtrailer1
			insert into expedite_audit (ord_hdrnumber, updated_by, updated_dt, activity, 
							mov_number, lgh_number, join_to_table_name, 
							key_value, update_note)
		              values (@ord, UPPER(@tmwuser), GETDATE(), 'Trailer1 Changed', @mov, @lgh, 
							'legheader', @lgh, @note)
	END

-- END PTS 14577


if update(evt_trailer2) 
BEGIN
	update event
	set evt_trailer2='UNKNOWN'
	from inserted
	where inserted.evt_number  = event.evt_number and
		isnull(event.evt_trailer2,'') = ''

-- KM BEGIN PTS 14577
	begin
		select	@oldtrailer2 = isnull(deleted.evt_trailer2, 'UNKNOWN'),
	                @newtrailer2 = isnull(inserted.evt_trailer2, 'UNKNOWN'),
			-- RE - 01/06/03 - PTS #20833
			--@ord = inserted.ord_hdrnumber,
			@ord = ISNULL(inserted.ord_hdrnumber, 0),
			@stop = inserted.stp_number,
			@mov = inserted.evt_mov_number,
			@lgh = stops.lgh_number
	          from  inserted, stops, deleted
		where   inserted.stp_number = stops.stp_number and
			deleted.stp_number = stops.stp_number


		SELECT @note = 'TRL2 ' + @oldtrailer2 + ' -> ' + @newtrailer2

		if @oldtrailer2 <> @newtrailer2
				--vmj5+
				and	(select upper(substring(gi_string1,1,1)) 
					  from	generalinfo
					  where gi_name = 'FingerprintAudit') = 'Y'
				--vmj5-
		
			insert into expedite_audit (ord_hdrnumber, updated_by, updated_dt, activity, 
							mov_number, lgh_number, join_to_table_name, 
							key_value, update_note)
		              values (@ord, UPPER(@tmwuser), GETDATE(), 'Trailer2 Changed', @mov, @lgh, 
							'legheader', @lgh, @note)
	END
END
-- KM END PTS 14577

-- MLUOMA BEGIN PTS 98182

--TRAILER 3
if update(evt_trailer3) 
	if (select upper(substring(gi_string1,1,1)) from generalinfo
    	 where gi_name = 'FingerprintAudit') = 'Y'

	begin	
		Insert into expedite_audit (
			ord_hdrnumber, 
			updated_by, 
			updated_dt, 
			activity, 
			mov_number, 
			lgh_number, 
			join_to_table_name, 
			key_value, 
			update_note)
		Select
			ISNULL(i.ord_hdrnumber, 0)
			, UPPER(@tmwuser)
			, GETDATE()
			, 'Trailer3 Changed'
			, i.evt_mov_number
			, s.lgh_number
			, 'legheader'
			, s.lgh_number
			, 'EVENT ' + ltrim(rtrim(i.evt_eventcode)) + ' - TRL3 ' + d.evt_trailer3 + ' -> ' + i.evt_trailer3
			From inserted i
			Inner Join deleted d on d.stp_Number = i.stp_number
			Inner Join stops s on i.stp_number = s.stp_number and d.stp_Number = s.stp_number
			Where d.evt_trailer3 <> i.evt_trailer3
	END

--TRAILER 4
if update(evt_trailer4) 
	if (select upper(substring(gi_string1,1,1)) from generalinfo
    	 where gi_name = 'FingerprintAudit') = 'Y'

	Begin
		Insert into expedite_audit (
			ord_hdrnumber, 
			updated_by, 
			updated_dt, 
			activity, 
			mov_number, 
			lgh_number, 
			join_to_table_name, 
			key_value, 
			update_note)
		Select
			ISNULL(i.ord_hdrnumber, 0)
			, UPPER(@tmwuser)
			, GETDATE()
			, 'Trailer4 Changed'
			, i.evt_mov_number
			, s.lgh_number
			, 'legheader'
			, s.lgh_number
			, 'EVENT ' + ltrim(rtrim(i.evt_eventcode)) + ' - TRL4 ' + d.evt_trailer4 + ' -> ' + i.evt_trailer4
			From inserted i
			Inner Join deleted d on d.stp_Number = i.stp_number
			Inner Join stops s on i.stp_number = s.stp_number and d.stp_Number = s.stp_number
			Where d.evt_trailer4 <> i.evt_trailer4
	END


--TRAILER 5
if update(evt_chassis) 
	if (select upper(substring(gi_string1,1,1)) from generalinfo
    	 where gi_name = 'FingerprintAudit') = 'Y'

	Begin
		Insert into expedite_audit (
			ord_hdrnumber, 
			updated_by, 
			updated_dt, 
			activity, 
			mov_number, 
			lgh_number, 
			join_to_table_name, 
			key_value, 
			update_note)
		Select
			ISNULL(i.ord_hdrnumber, 0)
			, UPPER(@tmwuser)
			, GETDATE()
			, 'Trailer5 Changed'
			, i.evt_mov_number
			, s.lgh_number
			, 'legheader'
			, s.lgh_number
			, 'EVENT ' + ltrim(rtrim(i.evt_eventcode)) + ' - TRL5 ' + d.evt_chassis + ' -> ' + i.evt_chassis
			From inserted i
			Inner Join deleted d on d.stp_Number = i.stp_number
			Inner Join stops s on i.stp_number = s.stp_number and d.stp_Number = s.stp_number
			Where d.evt_chassis <> i.evt_chassis
	END


--TRAILER 6
if update(evt_chassis2) 
	if (select upper(substring(gi_string1,1,1)) from generalinfo
    	 where gi_name = 'FingerprintAudit') = 'Y'

	Begin
		Insert into expedite_audit (
			ord_hdrnumber, 
			updated_by, 
			updated_dt, 
			activity, 
			mov_number, 
			lgh_number, 
			join_to_table_name, 
			key_value, 
			update_note)
		Select
			ISNULL(i.ord_hdrnumber, 0)
			, UPPER(@tmwuser)
			, GETDATE()
			, 'Trailer6 Changed'
			, i.evt_mov_number
			, s.lgh_number
			, 'legheader'
			, s.lgh_number
			, 'EVENT ' + ltrim(rtrim(i.evt_eventcode)) + ' - TRL6 ' + d.evt_chassis2 + ' -> ' + i.evt_chassis2
			From inserted i
			Inner Join deleted d on d.stp_Number = i.stp_number
			Inner Join stops s on i.stp_number = s.stp_number and d.stp_Number = s.stp_number
			Where d.evt_chassis2 <> i.evt_chassis2
	END

--TRAILER 7
if update(evt_dolly) 
	if (select upper(substring(gi_string1,1,1)) from generalinfo
    	 where gi_name = 'FingerprintAudit') = 'Y'

	BEGIN
		Insert into expedite_audit (
			ord_hdrnumber, 
			updated_by, 
			updated_dt, 
			activity, 
			mov_number, 
			lgh_number, 
			join_to_table_name, 
			key_value, 
			update_note)
		Select
			ISNULL(i.ord_hdrnumber, 0)
			, UPPER(@tmwuser)
			, GETDATE()
			, 'Trailer7 Changed'
			, i.evt_mov_number
			, s.lgh_number
			, 'legheader'
			, s.lgh_number
			, 'EVENT ' + ltrim(rtrim(i.evt_eventcode)) + ' - TRL7 ' + d.evt_dolly + ' -> ' + i.evt_dolly
			From inserted i
			Inner Join deleted d on d.stp_Number = i.stp_number
			Inner Join stops s on i.stp_number = s.stp_number and d.stp_Number = s.stp_number
			Where d.evt_dolly <> i.evt_dolly
	END

--TRAILER 8
if update(evt_dolly2) 
	if (select upper(substring(gi_string1,1,1)) from generalinfo
    	 where gi_name = 'FingerprintAudit') = 'Y'

	BEGIN
		Insert into expedite_audit (
			ord_hdrnumber, 
			updated_by, 
			updated_dt, 
			activity, 
			mov_number, 
			lgh_number, 
			join_to_table_name, 
			key_value, 
			update_note)
		Select
			ISNULL(i.ord_hdrnumber, 0)
			, UPPER(@tmwuser)
			, GETDATE()
			, 'Trailer8 Changed'
			, i.evt_mov_number
			, s.lgh_number
			, 'legheader'
			, s.lgh_number
			, 'EVENT ' + ltrim(rtrim(i.evt_eventcode)) + ' - TRL8 ' + d.evt_dolly2 + ' -> ' + i.evt_dolly2
			From inserted i
			Inner Join deleted d on d.stp_Number = i.stp_number
			Inner Join stops s on i.stp_number = s.stp_number and d.stp_Number = s.stp_number
			Where d.evt_dolly2 <> i.evt_dolly2
	END

-- MLUOMA END PTS 98182

if update(evt_driver2) 
	update event
	set evt_driver2='UNKNOWN'
	from inserted
	where inserted.evt_number  = event.evt_number and
		isnull(event.evt_driver2,'') = ''

-- JET - 7/29/2009 
if update(evt_carrier) 
	if (select upper(substring(gi_string1,1,1)) from generalinfo
    	 where gi_name = 'FingerprintAudit') = 'Y'

	begin
		select @oldcarrier = isnull(deleted.evt_carrier, 'UNKNOWN'), 
               @newcarrier = isnull(inserted.evt_carrier, 'UNKNOWN'), 
               @ord = ISNULL(inserted.ord_hdrnumber, 0), 
			   @stop = inserted.stp_number, 
			   @mov = inserted.evt_mov_number, 
			   @lgh = stops.lgh_number, 
			   @eventcode = inserted.evt_eventcode 
          from inserted, stops, deleted 
         where inserted.stp_number = stops.stp_number 
           and deleted.stp_number = stops.stp_number 
		
		select @note = 'EVENT ' + ltrim(rtrim(@eventcode)) + ' - CAR ' + @oldcarrier + ' -> ' + @newcarrier 
		
		if @oldcarrier <> @newcarrier 
			insert into expedite_audit (ord_hdrnumber, updated_by, updated_dt, activity, 
						mov_number, lgh_number, join_to_table_name, 
						key_value, update_note)
		        values (@ord, UPPER(@tmwuser), GETDATE(), 'Carrier Changed', @mov, @lgh, 
						'legheader', @lgh, @note)
	end
-- JET - 7/29/2009  

DECLARE @event varchar(6),
        @status varchar(6)


if update(evt_status)
begin

	SELECT @appName = APP_NAME()		--74227 AR Source of Status
	
--20009 ntk trigger appt 214s on sap actualization
	select @eventcode = inserted.evt_eventcode, @insertedstatus = inserted.evt_status, @deletedstatus = deleted.evt_status from inserted, deleted
	if @ediappttriggeroption in ('S','B') --ie setting is for SAP trigger or for both
		and @eventcode = 'SAP' 
		and @insertedstatus = 'DNE' and isnull(@deletedstatus, 'OPN') = 'OPN'
		and @auto214flag = 'Y'
	begin
		--need to ensure we get ord_hdrnumber for parent stop in case event.ord_hdrnumber is null
		select @ord_hdrnumber = stops.ord_hdrnumber from stops, inserted where inserted.stp_number = stops.stp_number
	
		select @stp_number = inserted.stp_number,
			@ord_billto = orderheader.ord_billto,
			@ps_activity = 'APPT', --appt is the only activity trigger via the event status change now
			@stp_sequence = stops.stp_sequence,
			@firstlastflags = '0,1,99', --stop position criteria aren't implemented; this criterion is also true
			@stp_latest = stops.stp_schdtlatest,
			@level = case stops.stp_type
				when 'PUP' then 'SH'
				when 'DRP' then 'CN'
			else 'NON'
			end
		from inserted, stops, orderheader
		where inserted.stp_number = stops.stp_number and @ord_hdrnumber= orderheader.ord_hdrnumber

		SELECT @match_count=count(*),@ReplicateForEachDropFlag=Max(IsNull(e214_ReplicateForEachDropFlag,'N') ) 
		FROM edi_214_profile
		WHERE e214_cmp_id=@ord_billto and
		e214_level = @level  and 
		CHARINDEX(e214_triggering_activity, @ps_activity) > 0
		IF @EDI_Notification_Process_Type = 1 --trigger rules by billto
		BEGIN
			IF @match_count>0
				INSERT edi_214_pending (
					e214p_ord_hdrnumber,
					e214p_billto,
					e214p_level,
					e214p_ps_status,
					e214p_stp_number,
					e214p_dttm,
					e214p_activity,
					e214p_arrive_earlyorlate,
					e214p_depart_earlyorlate,
					e214p_stpsequence,
					ckc_number,
					e214p_firstlastflags,
					e214p_created,
					e214p_ReplicateForEachDropFlag,
					e214p_source,
					e214p_user)
				VALUES (@ord_hdrnumber,
					@ord_billto,
					@level,
					' ',
					@stp_number,
					@stp_latest,
					@ps_activity,
					' ',
					' ',
					@stp_sequence,
					0,
					@firstlastflags,
					getdate(),
					@ReplicateForEachDropFlag,
					@appName,
					@tmwuser)
		END
		IF @EDI_Notification_Process_Type = 2	--trigger rules by company
		BEGIN 
			INSERT edi_214_pending (
				e214p_ord_hdrnumber,
				e214p_billto,
				e214p_level,
				e214p_ps_status,
				e214p_stp_number,
				e214p_dttm,
				e214p_activity,
				e214p_arrive_earlyorlate,
				e214p_depart_earlyorlate,
				e214p_stpsequence,
				ckc_number,
				e214p_firstlastflags,
				e214p_created,
				e214p_ReplicateForEachDropFlag,
				e214p_source,
				e214p_user)
			SELECT distinct @ord_hdrnumber,
				e214_cmp_id,
				@level,
				' ',
				@stp_number,
				@stp_latest,
				@ps_activity,
				' ',
				' ',
				@stp_sequence,
				0,
				@firstlastflags,
				getdate(),
				@ReplicateForEachDropFlag,
				@appName,
				@tmwuser
				from edi_214_profile, stops
				where e214_level = @level
				and ord_hdrnumber = @ord_hdrnumber
				and stp_type = 'PUP'
				and cmp_id = e214_cmp_id
				and shipper_role_flag = 'Y'
				and e214_triggering_activity = @ps_activity
			UNION
			SELECT distinct @ord_hdrnumber,
				e214_cmp_id,
				@level,
				' ',
				@stp_number,
				@stp_latest,
				@ps_activity,
				' ',
				' ',
				@stp_sequence,
				0,
				@firstlastflags,
				getdate(),
				@ReplicateForEachDropFlag,
				@appName,
				@tmwuser
				from edi_214_profile, stops
				where e214_level = @level
				and ord_hdrnumber = @ord_hdrnumber
				and stp_type = 'DRP'
				and cmp_id = e214_cmp_id
				and consignee_role_flag = 'Y'
				and e214_triggering_activity = @ps_activity
			UNION
			SELECT @ord_hdrnumber,
				e214_cmp_id,
				@level,
				' ',
				@stp_number,
				@stp_latest,
				@ps_activity,
				' ',
				' ',
				@stp_sequence,
				0,
				@firstlastflags,
				getdate(),
				@ReplicateForEachDropFlag,
				@appName,
				@tmwuser
				from edi_214_profile, orderheader
				where e214_level = @level
				and ord_hdrnumber = @ord_hdrnumber
				and e214_triggering_activity = @ps_activity
				and ord_billto = e214_cmp_id 
				and billto_role_flag = 'Y'
			UNION
			SELECT @ord_hdrnumber,
				e214_cmp_id,
				@level,
				' ',
				@stp_number,
				@stp_latest,
				@ps_activity,
				' ',
				' ',
				@stp_sequence,
				0,
				@firstlastflags,
				getdate(),
				@ReplicateForEachDropFlag,
				@appName,
				@tmwuser
				from edi_214_profile, orderheader
				where e214_level = @level
				and ord_hdrnumber = @ord_hdrnumber
				and e214_triggering_activity = @ps_activity
				and ord_company = e214_cmp_id 
				and orderby_role_flag = 'Y'
		END	
	end --end 20009 ntk

	if (select upper(substring(gi_string1,1,1)) from generalinfo
    	 where gi_name = 'FingerprintAudit') = 'Y'
	begin
		--vmj1+
    	select	-- RE - 01/06/03 - PTS #20833
				--@ord = inserted.ord_hdrnumber,
				@ord = ISNULL(inserted.ord_hdrnumber, 0),
                @event = stp_type,
                @status = evt_status
          from  inserted, stops
       	  where inserted.stp_number = stops.stp_number
--      select 	@ord = deleted.ord_hdrnumber,
--              @event = deleted.evt_eventcode,
--              @status = inserted.evt_status
--        from  inserted,deleted
--        where inserted.ord_hdrnumber = deleted.ord_hdrnumber

		if @status = 'DNE' and @event = 'PUP'
--      if @status = 'DNE' and @event = 'LLD'
		--vmj1-
      	begin
         	insert into expedite_audit (ord_hdrnumber, updated_by, updated_dt, activity)
              values (@ord, UPPER(@tmwuser), GETDATE(), 'ARR_SHIP')
      	end

		--vmj1+
		--Insert fingerprint for Customs event..
	  	select	@ls_evt_eventcode = evt_eventcode
		  from	inserted
	  	if @ls_evt_eventcode in ('NBCST', 'BCST')
	  	begin
		 	insert into expedite_audit
					(ord_hdrnumber
					,updated_by
					,activity
					,updated_dt
					,update_note
					,mov_number
					,lgh_number
					,join_to_table_name
					,key_value)
			  select isnull(ord_hdrnumber, 0)
					,@tmwuser
					,'Event Updated'
					,getdate()
					,'Customs Cleared'
					,isnull(evt_mov_number, 0)
					,0
					,'event'
					,isnull(evt_number, 0)
			  from	inserted
	  	end
	  	--vmj1-

   	end


	--vmj3+	Update tractorprofile.trc_currenthub if any inserted rows have gone to DNE status..
	--vmj4+
	if @li_update_count = 1
	begin
		--PTS 32408 JJF 10/12/2006
		--select	@ls_evt_tractor = isnull(evt_tractor, '')
		--		,@li_evt_hubmiles = isnull(evt_hubmiles, 0)
		-- from	inserted
		--  where	evt_status = 'DNE'
		--	and	evt_hubmiles > 0

		SELECT	@ls_evt_tractor = isnull(evt_tractor, ''),
			@li_evt_hubmiles = isnull(evt_hubmiles, 0),
			@ls_evt_trailer1 = isnull(evt_trailer1, ''),
			@li_evt_hubmiles_trailer1 = isnull(evt_hubmiles_trailer1, 0),
			@ls_evt_trailer2 = isnull(evt_trailer2, ''),
			@li_evt_hubmiles_trailer2 = isnull(evt_hubmiles_trailer2, 0)
		FROM	inserted
		WHERE	evt_status = 'DNE'
		--END PTS 32408 JJF 10/12/2006

		if @ls_evt_tractor <> ''
				and @li_evt_hubmiles > 0
			update	tractorprofile
			  set	trc_currenthub = @li_evt_hubmiles
			  where	trc_number = @ls_evt_tractor
				and	isnull(trc_currenthub, 0) < @li_evt_hubmiles
				and trc_number <> 'UNKNOWN'

		--PTS 32408 JJF 10/12/2006
		IF @ls_evt_trailer1 <> '' and @li_evt_hubmiles_trailer1 > 0 BEGIN
			UPDATE 	trailerprofile
			SET	trl_currenthub = @li_evt_hubmiles_trailer1
			WHERE	trl_id = @ls_evt_trailer1 
				and isnull(trl_currenthub, 0) < @li_evt_hubmiles_trailer1
				and trl_id <> 'UNKNOWN'
		END
		IF @ls_evt_trailer2 <> '' and @li_evt_hubmiles_trailer2 > 0 BEGIN
			UPDATE 	trailerprofile
			SET	trl_currenthub = @li_evt_hubmiles_trailer2
			WHERE	trl_id = @ls_evt_trailer2 
				and isnull(trl_currenthub, 0) < @li_evt_hubmiles_trailer2
				and trl_id <> 'UNKNOWN'
		END
		--END PTS 32408 JJF 10/12/2006
		
	end

/*	insert into #trc_hub
			(evt_tractor
			,evt_hubmiles)
	  select evt_tractor
			,max(isnull(evt_hubmiles, 0)) as evt_hubmiles
	  from	inserted
	  where	evt_status = 'DNE'
		and	evt_hubmiles > 0
	  group by evt_tractor
	select	@li_trc_hub_count = @@rowcount

	update	tractorprofile
	  set	trc_currenthub = th.evt_hubmiles
	  from	#trc_hub th
			,tractorprofile tp
	  where	tp.trc_number = th.evt_tractor
		and	isnull(tp.trc_currenthub, 0) < th.evt_hubmiles	*/
	--vmj4-
	--vmj3-
end 

   --PTS33896 MBR 09/06/06
   IF (SELECT UPPER(SUBSTRING(gi_string1, 1, 1))
         FROM generalinfo
        WHERE gi_name = 'TrailerSpotting') = 'Y'
   BEGIN
      IF @eventcode = 'PUL' AND @insertedstatus = 'DNE' AND @deletedstatus = 'OPN'
      BEGIN
         SELECT @ord_hdrnumber = i.ord_hdrnumber

           FROM inserted i
         IF @ord_hdrnumber > 0
         BEGIN
            SELECT @id_num = t.id_num
              FROM trailerspottingdetail t
             WHERE t.ord_hdrnumber = @ord_hdrnumber


            IF @id_num > 0
            BEGIN
               SELECT @evt_startdate = evt_startdate
                 FROM inserted
               UPDATE trailerspottingdetail
                  SET tsd_end_date = @evt_startdate,
                      tsd_stillspotted = 'N',
                      tsd_status = 'HLD'
                WHERE id_num = @id_num
            END
         END
      END
   END

if update(evt_departure_status)
begin
   	if (select upper(substring(gi_string1,1,1)) from generalinfo
       where gi_name = 'FingerprintAudit') = 'Y'
   	begin
		select	-- RE - 01/06/03 - PTS #20833
				--@ord = deleted.ord_hdrnumber,
				@ord = ISNULL(deleted.ord_hdrnumber, 0),
                @event = deleted.evt_eventcode,
                @status = inserted.evt_departure_status
        from  inserted, deleted
        where inserted.ord_hdrnumber = deleted.ord_hdrnumber

		if @status = 'DNE' and @event = 'LLD'
		begin
        	insert into expedite_audit (ord_hdrnumber, updated_by, updated_dt, activity)
                                   values   (@ord, UPPER(@tmwuser), GETDATE(), 'LOADED')
		end

		if @status = 'DNE' and @event = 'LUL'
      	begin
         	insert into expedite_audit (ord_hdrnumber, updated_by, updated_dt, activity)
                                   values   (@ord, UPPER(@tmwuser), GETDATE(), 'ARV_CONS')
		end
   	end
end

if update(evt_startdate)
begin
if (select upper(substring(gi_string1,1,1)) from generalinfo
       where gi_name = 'FingerprintAudit') = 'Y'
   begin
      select	-- RE - 01/06/03 - PTS #20833
				--@ord = deleted.ord_hdrnumber,
				@ord = ISNULL(deleted.ord_hdrnumber, 0),
                @event = deleted.evt_eventcode
        from  deleted
      if @event = 'NBCST'
      begin
         insert into expedite_audit (ord_hdrnumber, updated_by, updated_dt, activity)
                                   values   (@ord, UPPER(@tmwuser), GETDATE(), 'CLR_CUST')
      end
   end
end


--vmj2+
if update(evt_hubmiles)
	--vmj3+	If there are any rows in #trc_hub, then we know that evt_status was updated in the same statement (which triggered
	--this), so tractorprofile has already been updated in that section of code..
	--vmj4+	Since the temp table has been removed, use the variable to determine this..
	and	@li_evt_hubmiles = 0
--	and @li_trc_hub_count < 1
	--vmj4-
	--vmj3-
begin
	--vmj4+
	if @li_update_count = 1
	begin
		--PTS 32408 JJF 10/12/2006
		--select	@ls_evt_tractor = isnull(evt_tractor, '')
		--		,@li_evt_hubmiles = isnull(evt_hubmiles, 0)
		-- from	inserted
		--  where	evt_status = 'DNE'
		--	and	evt_hubmiles > 0

		SELECT	@ls_evt_tractor = isnull(evt_tractor, ''),
			@li_evt_hubmiles = isnull(evt_hubmiles, 0),
			@ls_evt_trailer1 = isnull(evt_trailer1, ''),
			@li_evt_hubmiles_trailer1 = isnull(evt_hubmiles_trailer1, 0),
			@ls_evt_trailer2 = isnull(evt_trailer2, ''),
			@li_evt_hubmiles_trailer2 = isnull(evt_hubmiles_trailer2, 0)
		FROM	inserted
		WHERE	evt_status = 'DNE'
		--END PTS 32408 JJF 10/12/2006

		if @ls_evt_tractor <> ''
				and @li_evt_hubmiles > 0
			update	tractorprofile
			  set	trc_currenthub = @li_evt_hubmiles
			  where	trc_number = @ls_evt_tractor
				and	isnull(trc_currenthub, 0) < @li_evt_hubmiles

		--PTS 32408 JJF 10/12/2006
		IF @ls_evt_trailer1 <> '' and @li_evt_hubmiles_trailer1 > 0 BEGIN
			UPDATE 	trailerprofile
			SET	trl_currenthub = @li_evt_hubmiles_trailer1
			WHERE	trl_id = @ls_evt_trailer1 
				and isnull(trl_currenthub, 0) < @li_evt_hubmiles_trailer1
				and trl_id <> 'UNKNOWN'
		END
		IF @ls_evt_trailer2 <> '' and @li_evt_hubmiles_trailer2 > 0 BEGIN
			UPDATE 	trailerprofile
			SET	trl_currenthub = @li_evt_hubmiles_trailer2
			WHERE	trl_id = @ls_evt_trailer2 
				and isnull(trl_currenthub, 0) < @li_evt_hubmiles_trailer2
				and trl_id <> 'UNKNOWN'
		END
		--END PTS 32408 JJF 10/12/2006

	end

/*	--vmj3+	Also, only update if evt_status = DNE..
	insert into #trc_hub
			(evt_tractor
			,evt_hubmiles)
	  select evt_tractor
			,max(isnull(evt_hubmiles, 0)) as evt_hubmiles
	  from	inserted
	  where	evt_status = 'DNE'
		and	evt_hubmiles > 0
	  group by evt_tractor
--	select evt_tractor
--			,max(isnull(evt_hubmiles, 0)) as evt_hubmiles
--	  into	#trc_hub
--	  from	inserted
--	  group by evt_tractor
	--vmj3-

	update	tractorprofile
	  set	trc_currenthub = th.evt_hubmiles
	  from	#trc_hub th
			,tractorprofile tp
	  where	tp.trc_number = th.evt_tractor
		and	isnull(tp.trc_currenthub, 0) < th.evt_hubmiles	*/
	--vmj4-
end
--vmj2-

/*****************************************************************************
	PTS 38765 - DJM - Add CBP Processing
******************************************************************************/
Declare @cbp_process char(1),
		@ord_status varchar(6),
		@ord_cbp	int,
		@process_ord	int
select @cbp_process = isnull(gi_string1,'N') from generalinfo where gi_name = 'ComputeCBPProcessingFlag'
if @cbp_process = 'Y'
	if Update(evt_trailer1) or Update(evt_carrier)or Update(evt_tractor)
		Begin
			select @ord_hdrnumber = isNull(ord_hdrnumber,0) from inserted
			--select @ord_status = isNull(ord_status,'AVL') from orderheader where ord_hdrnumber = @ord_hdrnumber and @ord_hdrnumber > 0

			-- Verify that the order is in a status that is eligible for CBP processing.
--			select @process_ord = isNull((select 1 from labelfile 
--										where labeldefinition = 'dispstatus' 
--											and abbr = @ord_status 
--											and code > (select code from labelfile 
--														where labeldefinition = 'dispstatus' 
--														and abbr = 'AVL')),0)

			if @ord_hdrnumber > 0 --and @process_ord > 0 

				Begin
					--Select @ord_status from Orderheader o where o.ord_hdrnumber = @ord_hdrnumber
					exec cbp_is_order_cbp @ord_hdrnumber, '', @ord_cbp out

					Declare @ord_cbp_tablevalue		char(1)
					select @ord_cbp_tablevalue = case 
									when @ord_cbp >= 0 then 'Y'
									when @ord_cbp = -1 then 'N'
									else 'E'		
								end	
					
					Update orderheader
					set ord_cbp = @ord_cbp_tablevalue			
					where ord_hdrnumber = @ord_hdrnumber
						and isNull(ord_cbp,'') <> @ord_cbp_tablevalue
				End
		End
/* if tractor changes and the hubmiles are not being set, clear out hub miles odometer reading from [prior assignment */
if update(evt_tractor) and
  (select min(evt_hubmiles) from inserted) = (select min(evt_hubmiles) from deleted)
  update event
  set evt_hubmiles = NULL
  from inserted 
  where  event.evt_number = inserted.evt_number 
  and inserted.evt_tractor <> event.evt_tractor
  and event.evt_hubmiles is not null

--PTS 48748 JJF 20101005
if update(evt_tractor) begin
	
	declare @oldtractor varchar(8)
	
	SELECT	@oldtractor = isnull(evt_tractor, 'UNKNOWN')
	FROM	deleted
	
	IF @ls_evt_tractor <> @oldtractor AND @oldtractor <> 'UNKNOWN' BEGIN
		--roll back hub reading for prior tractor.
		DECLARE @UpdTrcHubMiles char(3)
		DECLARE @CurrentHubReading int
		
		SELECT	@UpdTrcHubMiles = gi_string1 
		FROM	generalinfo 
		WHERE	gi_name = 'TrpUpdTrcHub'
		
		
		IF @UpdTrcHubMiles = 'YES' BEGIN
			SELECT	@CurrentHubReading = MAX(ISNULL(e.evt_hubmiles, 0))
			FROM	assetassignment asgn
					inner join stops stp on asgn.lgh_number = stp.lgh_number
					inner join event e on stp.stp_number = e.stp_number
			WHERE	asgn.asgn_type = 'TRC'
					AND asgn.asgn_id = @oldtractor
					AND asgn.asgn_status = 'CMP'
					AND stp.stp_status = 'DNE'
					AND e.evt_status = 'DNE'
					AND e.evt_sequence = 1
						
			UPDATE	tractorprofile 
			SET		trc_currenthub = @CurrentHubReading 
			WHERE	trc_number = @oldtractor 
		END
	END 
END 
--END PTS 48748 JJF 20101005

/*SKIP TRIGGER CODE FOR NEW DISPATCH ONLY IS EXECUTED IF SKIP_TRIGGER COLUMN
	IS SET TO 1*/
declare @skip_trigger int
select @skip_trigger = count(*)
from inserted where skip_trigger = 1
if @skip_trigger > 0 
begin
	UPDATE event  
   	SET skip_trigger = 0
     	FROM inserted
    	WHERE (inserted.evt_number = event.evt_number)
   	
	return
end

update event
set evt_mov_number=stops.mov_number
from inserted,stops
where inserted.stp_number = stops.stp_number and
	inserted.evt_number = event.evt_number and
	event.evt_mov_number is null

DECLARE 	@type 		char(6), 
			@id 		char(13), 
			@id2 		char(13), 
			@oldid 	char(13), 
			@recnum 	int, 
			@opn 		smallint, 
			@dne 		smallint, 			@stat 		char (6),			@lowevt	int,
			@minasgn	int,
			@curlgh		int,
			@bug 		char(14),
			@avldate	datetime,
			@avlcmp	char(8),
			@avlcity	int,
			@avlstat	char(6),
			@startdate datetime,
			@enddate datetime,
			@ostartdate datetime,
			@oenddate datetime,
			@primary	char(1),
			@trace varchar (64),
			@cntrl char(1),
			@board char(1)

SELECT @minevt = 0
WHILE ( SELECT COUNT(*) FROM inserted
	WHERE evt_number > @minevt ) > 0
BEGIN
SELECT @minevt = MIN ( evt_number ) FROM inserted
WHERE evt_number > @minevt

-- JET - 3/23/00 - PTS #7530, need to store the move number
SELECT @lgh = lgh_number, 
       @mov = mov_number 
	FROM stops, inserted
	WHERE stops.stp_number = inserted.stp_number AND
	evt_number = @minevt

SELECT @primary = primary_event
FROM inserted, eventcodetable
WHERE abbr = evt_eventcode AND
	evt_number = @minevt

SELECT @startdate = evt_startdate,
	@enddate = evt_enddate
FROM inserted 
WHERE evt_number = @minevt

SELECT @ostartdate = evt_startdate,
	@oenddate = evt_enddate
FROM deleted
WHERE evt_number = @minevt

IF UPDATE ( evt_eventcode )
BEGIN
	IF ( SELECT ect_trlstart FROM deleted, eventcodetable
		WHERE evt_number = @minevt AND evt_eventcode = abbr ) = 'X' 
		IF ( SELECT ect_trlstart FROM inserted, eventcodetable
			WHERE evt_number = @minevt AND evt_eventcode = abbr ) = 'Y'
			BEGIN
			SELECT @id = event.evt_trailer1,
				@id2 = event.evt_trailer2
			FROM event, stops, eventcodetable
			WHERE stops.stp_number = event.stp_number AND
				stops.lgh_number = @lgh AND
				event.evt_eventcode = abbr AND
				ect_trlstart = 'Y'
			IF @id <> 'UNKNOWN' 
				UPDATE event
				SET evt_trailer1 = @id,
					evt_trailer2 = @id2
				WHERE evt_number = @minevt
			END

END

IF UPDATE ( evt_startdate ) OR UPDATE ( evt_enddate ) OR UPDATE ( evt_status )
BEGIN

	IF ( @startdate > @enddate ) OR ( @ostartdate = @oenddate AND @oenddate = @enddate )
		OR @enddate >= '20491231'
	BEGIN
		SELECT @enddate = @startdate
		UPDATE event
		SET evt_enddate = @enddate
		WHERE evt_number = @minevt
	END

/*  EXEC timerins "ut_event", "update evt_startdate"  */ 

/*MF pts 8060 removed asset assignment code now handled by update_assetassignment*/

	IF UPDATE ( evt_status )
	/* set all events for same stop to same status if this is first event on the stop */
	BEGIN
		/* PG 6/12/97 where clause added */
		/* JLB PTS 25530 added SAP event to the exclusion list */
		IF ( SELECT evt_sequence FROM inserted where evt_number = @minevt ) = 1
			UPDATE event
			SET event.evt_status = inserted.evt_status
			FROM inserted
			WHERE event.stp_number = inserted.stp_number AND
				event.evt_sequence > 1 AND
				event.evt_eventcode <> 'PUL' AND
				event.evt_eventcode <> 'SAP'
	END
END
end
/*MF pts 8060 removed asset assignment code now handled by update_assetassignment*/

/* EXEC timerins "ut_event", "END" */

--vmj3+
--vmj4+
--drop table #trc_hub
--vmj4-
--vmj3-
GO
CREATE NONCLUSTERED INDEX [dk_evt_eventcode] ON [dbo].[event] ([evt_eventcode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [evt_mfh_number] ON [dbo].[event] ([evt_mfh_number], [item_id], [evt_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [evt_mov_number] ON [dbo].[event] ([evt_mov_number]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [number] ON [dbo].[event] ([evt_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_evt_pu_dr] ON [dbo].[event] ([evt_pu_dr]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [date] ON [dbo].[event] ([evt_startdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [evt_date_trl1] ON [dbo].[event] ([evt_status], [evt_sequence], [evt_trailer1], [evt_enddate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_evt_status_tractor] ON [dbo].[event] ([evt_status], [evt_tractor], [evt_startdate], [stp_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [evt_stat_start_trl1] ON [dbo].[event] ([evt_status], [evt_trailer1]) INCLUDE ([evt_startdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_evt_status_trailer] ON [dbo].[event] ([evt_status], [evt_trailer1], [evt_startdate], [stp_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EVT_TMTUPDATE] ON [dbo].[event] ([evt_trailer1], [evt_startdate], [stp_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [shipment] ON [dbo].[event] ([ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [stop] ON [dbo].[event] ([stp_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_event_stp_transfer_stp] ON [dbo].[event] ([stp_transfer_stp], [stp_mfh_number]) INCLUDE ([stp_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_event_timestamp] ON [dbo].[event] ([timestamp]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[event] TO [public]
GO
GRANT INSERT ON  [dbo].[event] TO [public]
GO
GRANT REFERENCES ON  [dbo].[event] TO [public]
GO
GRANT SELECT ON  [dbo].[event] TO [public]
GO
GRANT UPDATE ON  [dbo].[event] TO [public]
GO
