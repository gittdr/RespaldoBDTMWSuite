CREATE TABLE [dbo].[DedicatedType]
(
[DedicatedTypeId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedType] ADD CONSTRAINT [PK_DedicatedType] PRIMARY KEY CLUSTERED ([DedicatedTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DedicatedType] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DedicatedType] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedType] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedType] TO [public]
GO
