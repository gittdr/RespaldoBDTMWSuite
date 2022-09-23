CREATE TABLE [dbo].[TMSAppianFile]
(
[AppianFileId] [int] NOT NULL IDENTITY(1, 1),
[BatchId] [bigint] NULL,
[FileType] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [varchar] (260) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Contents] [varbinary] (max) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSAppianFile] ADD CONSTRAINT [PK_TMSAppianFile] PRIMARY KEY CLUSTERED ([AppianFileId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSAppianFile] WITH NOCHECK ADD CONSTRAINT [FK_TMSAppianFile_BatchId] FOREIGN KEY ([BatchId]) REFERENCES [dbo].[TMSBatch] ([BatchId])
GO
GRANT DELETE ON  [dbo].[TMSAppianFile] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSAppianFile] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSAppianFile] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSAppianFile] TO [public]
GO
