CREATE TABLE [dbo].[DedicatedStatus]
(
[DedicatedStatusId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedStatus] ADD CONSTRAINT [PK_DedicatedStatus] PRIMARY KEY CLUSTERED ([DedicatedStatusId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DedicatedStatus] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedStatus] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DedicatedStatus] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedStatus] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedStatus] TO [public]
GO
