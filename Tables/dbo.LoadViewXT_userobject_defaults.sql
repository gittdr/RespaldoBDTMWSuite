CREATE TABLE [dbo].[LoadViewXT_userobject_defaults]
(
[uod_id] [int] NOT NULL IDENTITY(1, 1),
[object] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[id] [int] NOT NULL,
[default_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[default_user_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoadViewXT_userobject_defaults] ADD CONSTRAINT [PK_LoadViewXT_userobject_defaults] PRIMARY KEY CLUSTERED ([uod_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LoadViewXT_userobject_defaults] TO [public]
GO
GRANT INSERT ON  [dbo].[LoadViewXT_userobject_defaults] TO [public]
GO
GRANT REFERENCES ON  [dbo].[LoadViewXT_userobject_defaults] TO [public]
GO
GRANT SELECT ON  [dbo].[LoadViewXT_userobject_defaults] TO [public]
GO
GRANT UPDATE ON  [dbo].[LoadViewXT_userobject_defaults] TO [public]
GO
