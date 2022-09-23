CREATE TABLE [dbo].[DedicatedDetailType]
(
[DedicatedDetailTypeId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedDetailType] ADD CONSTRAINT [PK_DedicatedDetailType] PRIMARY KEY CLUSTERED ([DedicatedDetailTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DedicatedDetailType] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedDetailType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DedicatedDetailType] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedDetailType] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedDetailType] TO [public]
GO
