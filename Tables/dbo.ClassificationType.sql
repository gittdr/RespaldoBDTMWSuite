CREATE TABLE [dbo].[ClassificationType]
(
[ClassificationId] [smallint] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClassificationType] ADD CONSTRAINT [PK_ClassificationType] PRIMARY KEY CLUSTERED ([ClassificationId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ClassificationType] TO [public]
GO
GRANT INSERT ON  [dbo].[ClassificationType] TO [public]
GO
GRANT SELECT ON  [dbo].[ClassificationType] TO [public]
GO
GRANT UPDATE ON  [dbo].[ClassificationType] TO [public]
GO
