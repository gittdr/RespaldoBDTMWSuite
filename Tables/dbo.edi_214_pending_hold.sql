CREATE TABLE [dbo].[edi_214_pending_hold]
(
[e214ph_id] [int] NOT NULL IDENTITY(1, 1),
[e214ph_ord_hdrnumber] [int] NULL,
[e214ph_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214ph_level] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214ph_ps_status] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214ph_stp_number] [int] NULL,
[e214ph_dttm] [datetime] NULL,
[e214ph_activity] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214ph_arrive_earlyorlate] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214ph_depart_earlyorlate] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214ph_stpsequence] [int] NULL,
[e214ph_consolidation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ckc_number] [int] NULL,
[e214ph_firstlastflags] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214ph_created] [datetime] NULL,
[e214ph_ReplicateForEachDropFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214ph_holdreason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214ph_source] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[e214ph_user] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/**
 * 
 * NAME:
 * dbo.dt_edi_214_pending_hold
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * Trigger based on delete event of edi_214_pending_hold table
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * NONE
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 *
 *
 * 
 * REVISION HISTORY:
 * 10/30/2006.01 ? PTS34468 - A. Rossman ? Initial Version
 *
 *
 **/
 
 CREATE TRIGGER [dbo].[dt_edi_214_pending_hold] on [dbo].[edi_214_pending_hold] FOR DELETE
 
 AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
 
 DECLARE @v_ord_hdrnumber int,
 	 @v_record_id int
 
 SELECT @v_ord_hdrnumber = e214ph_ord_hdrnumber,
 	@v_record_id = e214ph_id
 FROM	deleted
 
 
 IF EXISTS(SELECT * FROM edi_214_pending_hold WHERE e214ph_ord_hdrnumber = @v_ord_hdrnumber 
 		AND e214ph_id > @v_record_id and e214ph_holdreason ='ORDHLD')
     BEGIN
     
     
     INSERT INTO edi_214_pending(
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
     			e214p_consolidation,
     			ckc_number,
     			e214p_firstlastflags,
     			e214p_created,
     			e214p_ReplicateForEachDropFlag,
     			e214p_source,
     			e214p_user)
     			
     		SELECT e214ph_ord_hdrnumber,
     		       e214ph_billto,
     		       e214ph_level,
     		       e214ph_ps_status,
     		       e214ph_stp_number,
     		       e214ph_dttm,
     		       e214ph_activity,
     		       e214ph_arrive_earlyorlate,
     		       e214ph_depart_earlyorlate,
     		       e214ph_stpsequence,
     		       e214ph_consolidation,
     		       ckc_number,
     		       e214ph_firstlastflags,
     		       Getdate(),
     		       'N',
     		       e214ph_source,
     		       e214ph_user
     		FROM 	edi_214_pending_hold
     		WHERE 	e214ph_ord_hdrnumber = @v_ord_hdrnumber
			AND e214ph_id > @v_record_id
			AND e214ph_holdreason = 'ORDHLD'
			
			
		--deleted the records from the table
		DELETE FROM edi_214_pending_hold WHERE e214ph_ord_hdrnumber = @v_ord_hdrnumber
							AND e214ph_id > @v_record_id
							AND e214ph_holdreason = 'ORDHLD'
     END							
	
	
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[it_edi_214_pending_hold] on [dbo].[edi_214_pending_hold] for INSERT

AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/****************** Modification Log************************************
*
*	Aross PTS 28572  Created Trigger to check for duplicate entries in hold table
*
**************************************************************************/


declare @stp_number	int,
	@214ph_activity	varchar(8),
	@214ph_created	datetime
	
	
SELECT @stp_number = e214ph_stp_number,
       @214ph_activity = e214ph_activity,
       @214ph_created  = e214ph_created
FROM Inserted
	

If (Select count(*) FROM edi_214_pending_hold WITH(NOLOCK) where e214ph_stp_number = @stp_number and e214ph_activity = @214ph_activity) > 1
	BEGIN
		DELETE FROM edi_214_pending_hold 
		WHERE	e214ph_stp_number = @stp_number
			AND e214ph_activity = @214ph_activity
			AND e214ph_created < @214ph_created
	END 
	
GO
CREATE NONCLUSTERED INDEX [ix_edi_214_pending_hold_stop_activity] ON [dbo].[edi_214_pending_hold] ([e214ph_stp_number], [e214ph_activity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_214_pending_hold] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_214_pending_hold] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_214_pending_hold] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_214_pending_hold] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_214_pending_hold] TO [public]
GO
