CREATE TABLE [dbo].[trigger_control]
(
[tc_id] [int] NOT NULL IDENTITY(1, 1),
[trigger_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[application_name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fire_or_not] [binary] (1) NOT NULL CONSTRAINT [DF__trigger_c__fire___65DDE0ED] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trigger_control] ADD CONSTRAINT [PK__trigger_control__64E9BCB4] PRIMARY KEY CLUSTERED ([tc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_trigger_control] ON [dbo].[trigger_control] ([trigger_name], [application_name], [fire_or_not]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trigger_control] TO [public]
GO
GRANT INSERT ON  [dbo].[trigger_control] TO [public]
GO
GRANT SELECT ON  [dbo].[trigger_control] TO [public]
GO
GRANT UPDATE ON  [dbo].[trigger_control] TO [public]
GO
