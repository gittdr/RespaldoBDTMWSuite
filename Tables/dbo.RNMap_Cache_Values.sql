CREATE TABLE [dbo].[RNMap_Cache_Values]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[LastUpdate] [datetime] NULL CONSTRAINT [DF__RNMap_Cac__LastU__3B0CF1F7] DEFAULT (getdate()),
[PlainDate] [datetime] NULL,
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Area] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DailyCount1] [decimal] (20, 5) NULL,
[DailyTotal1] [decimal] (20, 5) NULL,
[DailyCount2] [decimal] (20, 5) NULL,
[DailyTotal2] [decimal] (20, 5) NULL,
[DailyCount3] [decimal] (20, 5) NULL,
[DailyTotal3] [decimal] (20, 5) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RNMap_Cache_Values] ADD CONSTRAINT [PK__RNMap_Cache_Valu__3A18CDBE] PRIMARY KEY NONCLUSTERED ([sn]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxRNMap_Cache_Values] ON [dbo].[RNMap_Cache_Values] ([PlainDate], [MetricCode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RNMap_Cache_Values] TO [public]
GO
GRANT INSERT ON  [dbo].[RNMap_Cache_Values] TO [public]
GO
GRANT SELECT ON  [dbo].[RNMap_Cache_Values] TO [public]
GO
GRANT UPDATE ON  [dbo].[RNMap_Cache_Values] TO [public]
GO
