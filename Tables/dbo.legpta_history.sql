CREATE TABLE [dbo].[legpta_history]
(
[lph_id] [int] NOT NULL IDENTITY(1, 1),
[lpa_id] [int] NOT NULL,
[lgh_number] [int] NOT NULL,
[pta_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[util_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pta_date] [datetime] NOT NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ApprovalCode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prev_pta_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prev_util_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prev_pta_date] [datetime] NULL,
[prev_trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prev_ApprovalCode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[update_date] [datetime] NOT NULL,
[update_user] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pta_approved] [tinyint] NULL,
[pta_approved_date] [datetime] NULL,
[pta_approved_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pta_denied] [tinyint] NULL,
[pta_denied_date] [datetime] NULL,
[pta_denied_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prev_pta_approved] [tinyint] NULL,
[prev_pta_approved_date] [datetime] NULL,
[prev_pta_approved_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prev_pta_denied] [tinyint] NULL,
[prev_pta_denied_date] [datetime] NULL,
[prev_pta_denied_by] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pta_hard_max] [datetime] NULL,
[requested_date] [datetime] NULL,
[requested_user] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[legpta_history] ADD CONSTRAINT [pk_legptahistory_id] PRIMARY KEY CLUSTERED ([lph_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_legpta_history_lgh_number] ON [dbo].[legpta_history] ([lgh_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_legpta_history_trc_number] ON [dbo].[legpta_history] ([trc_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[legpta_history] TO [public]
GO
GRANT INSERT ON  [dbo].[legpta_history] TO [public]
GO
GRANT SELECT ON  [dbo].[legpta_history] TO [public]
GO
GRANT UPDATE ON  [dbo].[legpta_history] TO [public]
GO
