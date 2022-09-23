CREATE TABLE [dbo].[tmw_custom_alerts_master]
(
[alrt_recid] [int] NOT NULL IDENTITY(1, 1),
[alrt_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[alrt_ctycode] [int] NOT NULL,
[alrt_proximity] [int] NULL,
[alrt_incabalert] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alrt_begindate] [smalldatetime] NOT NULL,
[alrt_enddate] [smalldatetime] NOT NULL,
[alrt_msgtype] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alrt_message] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAG] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tmw_custom_alerts_master] ADD CONSTRAINT [pk_tmwcustalrtmst] PRIMARY KEY NONCLUSTERED ([alrt_recid]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [clx_alrtbegindatestate] ON [dbo].[tmw_custom_alerts_master] ([alrt_begindate], [alrt_state]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_alrtctycode] ON [dbo].[tmw_custom_alerts_master] ([alrt_ctycode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tmw_custom_alerts_master] TO [public]
GO
GRANT INSERT ON  [dbo].[tmw_custom_alerts_master] TO [public]
GO
GRANT SELECT ON  [dbo].[tmw_custom_alerts_master] TO [public]
GO
GRANT UPDATE ON  [dbo].[tmw_custom_alerts_master] TO [public]
GO
