CREATE TABLE [dbo].[opt_elog_provider_attribute]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[attribute_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[attribute_value] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[provider_discriminator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pid] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[opt_elog_provider_attribute] ADD CONSTRAINT [pk_opt_elog_provider_attribute] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_opt_elog_provider_attribute_pid] ON [dbo].[opt_elog_provider_attribute] ([pid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[opt_elog_provider_attribute] ADD CONSTRAINT [fk_elog_provider_attribute_pid] FOREIGN KEY ([pid]) REFERENCES [dbo].[opt_elog_provider_activity] ([id])
GO
GRANT DELETE ON  [dbo].[opt_elog_provider_attribute] TO [public]
GO
GRANT INSERT ON  [dbo].[opt_elog_provider_attribute] TO [public]
GO
GRANT REFERENCES ON  [dbo].[opt_elog_provider_attribute] TO [public]
GO
GRANT SELECT ON  [dbo].[opt_elog_provider_attribute] TO [public]
GO
GRANT UPDATE ON  [dbo].[opt_elog_provider_attribute] TO [public]
GO
