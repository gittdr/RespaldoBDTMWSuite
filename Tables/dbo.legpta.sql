CREATE TABLE [dbo].[legpta]
(
[lpa_id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NOT NULL,
[pta_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[util_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pta_date] [datetime] NOT NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ApprovalCode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_date] [datetime] NOT NULL,
[update_user] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pta_date_calculated] [datetime] NULL,
[create_date] [datetime] NULL,
[create_user] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pta_cancelled] [tinyint] NOT NULL CONSTRAINT [df_pta_cancelled] DEFAULT ((0)),
[pta_cancel_date] [datetime] NULL,
[pta_approved] [tinyint] NOT NULL CONSTRAINT [df_pta_approved] DEFAULT ((0)),
[pta_approved_date] [datetime] NULL,
[pta_approved_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pta_denied] [tinyint] NOT NULL CONSTRAINT [df_pta_denied] DEFAULT ((0)),
[pta_denied_date] [datetime] NULL,
[pta_denied_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pta_hard_max] [datetime] NULL,
[requested_date] [datetime] NULL,
[requested_user] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  TRIGGER [dbo].[dt_legpta] ON [dbo].[legpta]
FOR  DELETE
AS

--generate history record
insert into legpta_history(
	lpa_id, 
	lgh_number, 
	pta_type,
	util_code, 
	pta_date, 
	trc_number, 
	update_date, 
	update_user, 
	prev_pta_type, 
	prev_util_code, 
	prev_pta_date, 
	prev_trc_number, 
	prev_pta_approved, 
	prev_pta_approved_by, 
	prev_pta_approved_date,
	prev_pta_denied, 
	prev_pta_denied_by, 
	prev_pta_denied_date,
	update_type, 
	pta_hard_max,
	requested_date,
	requested_user)
select 
	d.lpa_id, 
	d.lgh_number, 
	'',
	'', 
	'19500101', 
	'', 
	'19500101', 
	'', 
	d.pta_type, 
	d.util_code, 
	d.pta_date, 
	d.trc_number, 
	d.pta_approved, 
	d.pta_approved_by, 
	d.pta_approved_date, 
	d.pta_denied, 
	d.pta_denied_by, 
	d.pta_denied_date,
	'D',
	d.pta_hard_max,
	d.requested_date,
	d.requested_user
 from deleted d
 
DELETE	utilization
 WHERE	lpa_id IN (SELECT lpa_id FROM deleted)
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  TRIGGER [dbo].[ut_legpta] ON [dbo].[legpta]
FOR  UPDATE
AS

--generate history record
insert into legpta_history(
	lpa_id, 
	lgh_number,
	pta_type,
	util_code, 
	pta_date, 
	trc_number, 
	pta_approved, 
	pta_approved_by, 
	pta_approved_date, 
	pta_denied, 
	pta_denied_by, 
	pta_denied_date, 
	update_date, 
	update_user, 
	prev_pta_type, 
	prev_util_code, 
	prev_pta_date, 
	prev_trc_number, 
	prev_pta_approved, 
	prev_pta_approved_by, 
	prev_pta_approved_date, 
	prev_pta_denied, 
	prev_pta_denied_by, 
	prev_pta_denied_date,
	requested_date,
	requested_user,
	update_type)
select 
	i.lpa_id, 
	i.lgh_number, 
	i.pta_type, 
	i.util_code, 
	i.pta_date, 
	i.trc_number, 
	i.pta_approved, 
	i.pta_approved_by, 
	i.pta_approved_date, 
	i.pta_denied, 
	i.pta_denied_by, 
	i.pta_denied_date, 
	i.update_date, 
	i.update_user, 
	d.pta_type, 
	d.util_code, 
	d.pta_date, 
	d.trc_number, 
	d.pta_approved, 
	d.pta_approved_by, 
	d.pta_approved_date, 
	d.pta_denied, 
	d.pta_denied_by, 
	d.pta_denied_date, 
	i.requested_date,
	i.requested_user,
	'U'
 from inserted i join deleted d on (i.lpa_id = d.lpa_id)

--generate utilization record for the previous entry
	insert into utilization (lpa_id, lgh_number, trc_number, util_code, util_start_date, util_end_date, update_date)
	select deleted.lpa_id, inserted.lgh_number, inserted.trc_number, deleted.util_code, deleted.pta_date, inserted.pta_date, GETDATE()
	  from inserted, deleted

--jet - 1/13/14 - PTS 73850, copy the updated PTA date and time back to the tractor profile
 update tractorprofile 
    set trc_pta_date = pta_date 
   from inserted 
  where inserted.trc_number = tractorprofile.trc_number 
		--84095
    --and trc_pta_date <> pta_date 
		and isnull(tractorprofile.trc_pta_date, '1950-01-01') <> isnull(inserted.pta_date, '1950-01-01')
GO
ALTER TABLE [dbo].[legpta] ADD CONSTRAINT [pk_legpta_lpa_id] PRIMARY KEY CLUSTERED ([lpa_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_legpta_lgh_number] ON [dbo].[legpta] ([lgh_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_legpta_trc_number] ON [dbo].[legpta] ([trc_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[legpta] TO [public]
GO
GRANT INSERT ON  [dbo].[legpta] TO [public]
GO
GRANT SELECT ON  [dbo].[legpta] TO [public]
GO
GRANT UPDATE ON  [dbo].[legpta] TO [public]
GO
