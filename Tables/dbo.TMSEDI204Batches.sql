CREATE TABLE [dbo].[TMSEDI204Batches]
(
[BatchId] [int] NOT NULL IDENTITY(1, 1),
[Version] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderCount] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSEDI204Batches] ADD CONSTRAINT [PK__TMSEDI204Batches__718D5A80] PRIMARY KEY CLUSTERED ([BatchId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMSEDI204Batches] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSEDI204Batches] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSEDI204Batches] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSEDI204Batches] TO [public]
GO
