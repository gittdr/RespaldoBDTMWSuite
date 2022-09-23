CREATE TABLE [dbo].[PaperWorkStatusTable]
(
[LegNumber] [int] NULL,
[OrdNumber] [int] NULL,
[DocType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DocTypeName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Received] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Required] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Pay] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayReceiptNum] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
