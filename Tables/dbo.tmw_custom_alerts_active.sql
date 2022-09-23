CREATE TABLE [dbo].[tmw_custom_alerts_active]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[dtCreated] [datetime] NULL CONSTRAINT [DF__tmw_custo__dtCre__2C34C2BB] DEFAULT (getdate()),
[dtLastMetCriteria] [datetime] NULL CONSTRAINT [DF__tmw_custo__dtLas__2D28E6F4] DEFAULT (getdate()),
[alrt_recid] [int] NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tmw_custom_alerts_active] TO [public]
GO
GRANT INSERT ON  [dbo].[tmw_custom_alerts_active] TO [public]
GO
GRANT SELECT ON  [dbo].[tmw_custom_alerts_active] TO [public]
GO
GRANT UPDATE ON  [dbo].[tmw_custom_alerts_active] TO [public]
GO
