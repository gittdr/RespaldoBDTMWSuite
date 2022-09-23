CREATE TABLE [dbo].[ImportErrorData]
(
[ImportErrorDataId] [int] NOT NULL IDENTITY(1, 1),
[ImportErrorId] [int] NOT NULL,
[Data] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sequence] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportErrorData] ADD CONSTRAINT [PK_ImportErrorData] PRIMARY KEY CLUSTERED ([ImportErrorDataId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_ImportErrorData_ImportErrorId] ON [dbo].[ImportErrorData] ([ImportErrorId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportErrorData] ADD CONSTRAINT [FK_ImportErrorData_ImportErrorId] FOREIGN KEY ([ImportErrorId]) REFERENCES [dbo].[ImportError] ([ImportErrorId])
GO
GRANT DELETE ON  [dbo].[ImportErrorData] TO [public]
GO
GRANT INSERT ON  [dbo].[ImportErrorData] TO [public]
GO
GRANT SELECT ON  [dbo].[ImportErrorData] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImportErrorData] TO [public]
GO
