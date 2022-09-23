CREATE TABLE [dbo].[FullGenLog]
(
[fgl_ident] [int] NOT NULL IDENTITY(1, 1),
[fgl_type] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fgl_event] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fgl_date] [datetime] NOT NULL,
[fgl_user_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fgl_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fgl_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgl_prior_close_date] [datetime] NOT NULL,
[fgl_process_through_date] [datetime] NOT NULL,
[fgl_process_time_seconds] [int] NULL,
[fgl_totalitems_processed] [int] NULL,
[fgl_success] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FullGenLog] ADD CONSTRAINT [PK_FullGenLog] PRIMARY KEY CLUSTERED ([fgl_ident]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_branchtypeeventdate] ON [dbo].[FullGenLog] ([fgl_branch], [fgl_type], [fgl_event], [fgl_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FullGenLog] TO [public]
GO
GRANT INSERT ON  [dbo].[FullGenLog] TO [public]
GO
GRANT SELECT ON  [dbo].[FullGenLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[FullGenLog] TO [public]
GO
