CREATE TABLE [dbo].[opt_elog_provider_activity]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[activity_started] [datetime] NULL,
[current_activity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[provider] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[provider_record_id] [bigint] NULL,
[provider_username] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[calculated_on] [datetime] NULL,
[updated] [datetime] NULL,
[valid] [smallint] NULL,
[truck_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[opt_elog_provider_activity] ADD CONSTRAINT [pk_opt_elog_provider_activity] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_opt_elog_provider_activity_driver_id] ON [dbo].[opt_elog_provider_activity] ([driver_id], [calculated_on]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_opt_elog_provider_activity_provider] ON [dbo].[opt_elog_provider_activity] ([provider], [provider_record_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[opt_elog_provider_activity] TO [public]
GO
GRANT INSERT ON  [dbo].[opt_elog_provider_activity] TO [public]
GO
GRANT REFERENCES ON  [dbo].[opt_elog_provider_activity] TO [public]
GO
GRANT SELECT ON  [dbo].[opt_elog_provider_activity] TO [public]
GO
GRANT UPDATE ON  [dbo].[opt_elog_provider_activity] TO [public]
GO
