CREATE TABLE [dbo].[TMSBatchMessages]
(
[MsgId] [bigint] NOT NULL IDENTITY(1, 1),
[MsgDate] [datetime] NOT NULL CONSTRAINT [dc_TMSBatchMessages_MsgDate] DEFAULT (getdate()),
[BatchId] [bigint] NOT NULL,
[OrderId] [int] NOT NULL,
[KeyData] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Message] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HasError] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_TMSBatchMessages_HasError] DEFAULT ('N'),
[RawData] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TMSBatchM__RowTy__3049A708] DEFAULT ('M'),
[SerializedOrder] [xml] NULL,
[RecordId] [int] NULL,
[ImpId] [int] NULL,
[ord_hdrnumber] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSBatchMessages] ADD CONSTRAINT [PK_TMSBatchMessages] PRIMARY KEY CLUSTERED ([MsgId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TMSBatchMessage_BatchId] ON [dbo].[TMSBatchMessages] ([BatchId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_tmsbatch_batchid] ON [dbo].[TMSBatchMessages] ([BatchId]) INCLUDE ([Message], [MsgDate], [RawData], [HasError], [OrderId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSBatchMessages] WITH NOCHECK ADD CONSTRAINT [FK_TMSBatchMessages_TMSBatch] FOREIGN KEY ([BatchId]) REFERENCES [dbo].[TMSBatch] ([BatchId])
GO
ALTER TABLE [dbo].[TMSBatchMessages] ADD CONSTRAINT [FK_TMSBatchMessages_TMSImportConfig] FOREIGN KEY ([ImpId]) REFERENCES [dbo].[TMSImportConfig] ([ImpId])
GO
GRANT DELETE ON  [dbo].[TMSBatchMessages] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSBatchMessages] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSBatchMessages] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSBatchMessages] TO [public]
GO
