CREATE TABLE [dbo].[ini_xref_group_user]
(
[group_user_id] [int] NOT NULL,
[created] [datetime] NOT NULL,
[created_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[group_id] [int] NULL,
[usr_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated] [datetime] NULL,
[updated_by] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ini_xref_group_user] ADD CONSTRAINT [ini_xref_group_user_pk] PRIMARY KEY CLUSTERED ([group_user_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ini_xref_group_user] ADD CONSTRAINT [FK_INI_XREF_REF_19901_INI_GROU] FOREIGN KEY ([group_id]) REFERENCES [dbo].[ini_group] ([group_id])
GO
GRANT DELETE ON  [dbo].[ini_xref_group_user] TO [public]
GO
GRANT INSERT ON  [dbo].[ini_xref_group_user] TO [public]
GO
GRANT SELECT ON  [dbo].[ini_xref_group_user] TO [public]
GO
GRANT UPDATE ON  [dbo].[ini_xref_group_user] TO [public]
GO
