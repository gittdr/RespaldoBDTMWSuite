CREATE TABLE [dbo].[RNTrial_Cache_TopValues]
(
[RecNum] [int] NOT NULL IDENTITY(1, 1),
[LastUpdate] [datetime] NULL CONSTRAINT [DF__RNTrial_C__LastU__36483CDA] DEFAULT (getdate()),
[DateStart] [datetime] NULL,
[DateEnd] [datetime] NULL,
[ItemCategory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemDescription] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Count] [int] NULL,
[Percentage] [decimal] (24, 5) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RNTrial_Cache_TopValues] ADD CONSTRAINT [PK__RNTrial_Cache_To__355418A1] PRIMARY KEY NONCLUSTERED ([RecNum]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxRNTrial_Cache_TopValues] ON [dbo].[RNTrial_Cache_TopValues] ([DateStart], [DateEnd], [ItemID]) ON [PRIMARY]
GO
