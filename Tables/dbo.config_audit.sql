CREATE TABLE [dbo].[config_audit]
(
[con_auditid] [int] NOT NULL IDENTITY(1, 1),
[con_section] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[con_key] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[con_value_old] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[con_value_new] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_grpid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_role] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_trans_date] [datetime] NULL,
[con_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_description] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_con_auditid] ON [dbo].[config_audit] ([con_auditid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[config_audit] TO [public]
GO
GRANT INSERT ON  [dbo].[config_audit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[config_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[config_audit] TO [public]
GO
GRANT UPDATE ON  [dbo].[config_audit] TO [public]
GO
