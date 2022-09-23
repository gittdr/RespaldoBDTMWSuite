CREATE TABLE [dbo].[TMSBatch]
(
[BatchId] [bigint] NOT NULL IDENTITY(1, 1),
[BatchType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BatchStatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NOT NULL CONSTRAINT [dc_TMSBatch_CreateDate] DEFAULT (getdate()),
[CreateUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dc_TMSBatch_CreateUser] DEFAULT (suser_sname()),
[FileName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ImpId] [int] NULL,
[ProcessedData] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSBatch] ADD CONSTRAINT [PK_TMSBatch] PRIMARY KEY CLUSTERED ([BatchId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSBatch] ADD CONSTRAINT [FK_TMSBatch_TMSImportConfig] FOREIGN KEY ([ImpId]) REFERENCES [dbo].[TMSImportConfig] ([ImpId])
GO
GRANT DELETE ON  [dbo].[TMSBatch] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSBatch] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSBatch] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSBatch] TO [public]
GO
