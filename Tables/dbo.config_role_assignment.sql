CREATE TABLE [dbo].[config_role_assignment]
(
[con_asgnid] [int] NOT NULL IDENTITY(1, 1),
[con_asgnrole] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_asgntype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_asgnuser] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_asgngroup] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[config_role_assignment] ADD CONSTRAINT [pk_con_asgnid] PRIMARY KEY CLUSTERED ([con_asgnid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_con_asgnid] ON [dbo].[config_role_assignment] ([con_asgnid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[config_role_assignment] TO [public]
GO
GRANT INSERT ON  [dbo].[config_role_assignment] TO [public]
GO
GRANT REFERENCES ON  [dbo].[config_role_assignment] TO [public]
GO
GRANT SELECT ON  [dbo].[config_role_assignment] TO [public]
GO
GRANT UPDATE ON  [dbo].[config_role_assignment] TO [public]
GO
