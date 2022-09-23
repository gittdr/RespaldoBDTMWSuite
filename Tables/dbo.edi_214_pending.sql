CREATE TABLE [dbo].[edi_214_pending]
(
[e214p_id] [int] NOT NULL IDENTITY(1, 1),
[e214p_ord_hdrnumber] [int] NULL,
[e214p_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214p_level] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214p_ps_status] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214p_stp_number] [int] NULL,
[e214p_dttm] [datetime] NULL,
[e214p_activity] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214p_arrive_earlyorlate] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214p_depart_earlyorlate] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214p_stpsequence] [int] NULL,
[e214p_consolidation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_number] [int] NULL,
[e214p_firstlastflags] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214p_created] [datetime] NULL,
[e214p_ReplicateForEachDropFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214p_source] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214p_user] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_edi_214_pending] on [dbo].[edi_214_pending] for INSERT

AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/*
 * 
 * NAME:
 * dbo.it_edi_214_pending
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * Trigger on the insert of records added to the edi_214_pending table
 *
 * RETURNS:
 * None
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 *
 *
 * REFERENCES:  
 *
 *
 * 
 * REVISION HISTORY:
 * 03/01/2005.01 ? PTS28572 - A.Rossman ? Created Trigger
 * 06/16/2006.02 - PTS33408 - A.Rossman - Trigger creation of ETAX6 location report messages based on general info setting when an ESTA is inserted.
 * 06/16/2011 - PTS57481 - MTC. Add nolocks to help avoid deadlocks that occur at some customers.
 * 01/14/2014 - PTS 74227 - AR. Updated for source of status columns.
 *
 */

declare @stp_number	int,
	@214p_activity	varchar(8),
	@214p_created	datetime,
	@v_LocationRep	char(1),
	@v_lgh_number	int,
	@v_tractor	varchar(8),
	@v_driver	varchar(8),
	@v_last_ckcall	datetime,
	@v_ckcall	int,
	@v_e214pID	int,
	@match_count	int,
	@billto		varchar(8),
	@e214p_dttm	datetime
	
SELECT @v_LocationRep =  UPPER(LEFT(ISNULL(gi_string1,'N'),1)) FROM generalinfo WHERE gi_name = 'EDI214_ETALocationReport'	
	
	
SELECT @stp_number = e214p_stp_number,
       @214p_activity = e214p_activity,
       @214p_created  = e214p_created,
       @v_e214pID     = e214p_id,
       @billto	      = e214p_billto
FROM Inserted
	

If (Select count(*) FROM edi_214_pending with (nolock) where e214p_stp_number = @stp_number and e214p_activity = @214p_activity) > 1
	BEGIN
		DELETE FROM edi_214_pending 
		WHERE	e214p_stp_number = @stp_number
			AND e214p_activity = @214p_activity
			AND e214p_created < @214p_created
	END 

   SELECT 	@match_count=count(*)
   FROM 	edi_214_profile  with (nolock)
   WHERE 	e214_cmp_id=@billto 
	 AND CHARINDEX(e214_triggering_activity, @214p_activity) > 0
	
If @v_LocationRep in ('Y','O')	and @214p_activity = 'ESTA' and @match_count > 0	--PTS 33408 ETA Location Report
BEGIN
	SELECT	 @v_lgh_number = stops.lgh_number,
		 @v_tractor    = legheader.lgh_tractor,
		 @v_driver     = legheader.lgh_driver1,
		 @e214p_dttm   = stops.stp_arrivaldate
	FROM stops  with (nolock)
		JOIN legheader  with (nolock)
			ON legheader.lgh_number = stops.lgh_number
	 WHERE stops.stp_number = @stp_number

	 SELECT @v_last_ckcall = MAX(ckc_date)
	 FROM checkcall  with (nolock)
	 WHERE ckc_tractor = @v_tractor
		AND ckc_asgnid = @v_driver
		AND ckc_asgntype = 'DRV'
		AND ckc_event = 'TRP'
		
	   IF @v_last_ckcall IS NOT NULL
	   	SELECT @v_ckcall = ckc_number
	   	FROm	checkcall  with (nolock)
		WHERE ckc_tractor = @v_tractor
			AND ckc_asgnid = @v_driver
			AND ckc_asgntype = 'DRV'
			AND ckc_event = 'TRP'
			AND ckc_date = @v_last_ckcall	
			
	INSERT INTO edi_214_pending(e214p_ord_hdrnumber,e214p_billto,e214p_level,e214p_ps_status,e214p_stp_number,e214p_dttm,e214p_activity,
					e214p_arrive_earlyorlate,e214p_depart_earlyorlate,e214p_stpsequence,e214p_consolidation,ckc_number,
					e214p_firstlastflags,e214p_created,e214p_ReplicateForEachDropFlag,e214p_source,e214p_user)
	SELECT 	  inserted.e214p_ord_hdrnumber,
		  inserted.e214p_billto,
		  inserted.e214p_level,
		  inserted.e214p_ps_status,
		  inserted.e214p_stp_number,
		  @e214p_dttm,
		  'ETAX6',
		  inserted.e214p_arrive_earlyorlate,
		  inserted.e214p_depart_earlyorlate,
		  inserted.e214p_stpsequence,
		  inserted.e214p_consolidation,
		  @v_ckcall,
		  inserted.e214p_firstlastflags,
		  GETDATE(),
		  inserted.e214p_replicateforeachdropflag,
		  inserted.e214p_source,
		  inserted.e214p_user
	FROM	  inserted
	
	--remove the original ESTA if required
	IF @v_LocationRep = 'O'
		DELETE FROM edi_214_pending WHERE e214p_id = @v_e214pID
		
END		

GO
GRANT DELETE ON  [dbo].[edi_214_pending] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_214_pending] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_214_pending] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_214_pending] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_214_pending] TO [public]
GO
