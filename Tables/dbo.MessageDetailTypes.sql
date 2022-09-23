CREATE TABLE [dbo].[MessageDetailTypes]
(
[Id] [smallint] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageDetailTypes] ADD CONSTRAINT [PK_MessageDetailTypes] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MessageDetailTypes] TO [public]
GO
GRANT INSERT ON  [dbo].[MessageDetailTypes] TO [public]
GO
GRANT SELECT ON  [dbo].[MessageDetailTypes] TO [public]
GO
GRANT UPDATE ON  [dbo].[MessageDetailTypes] TO [public]
GO
