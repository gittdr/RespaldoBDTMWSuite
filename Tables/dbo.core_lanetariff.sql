CREATE TABLE [dbo].[core_lanetariff]
(
[LaneId] [int] NOT NULL,
[BillTo] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_billto] DEFAULT ('UNKNOWN'),
[BillToParent] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_billtoparent] DEFAULT ('UNKNOWN'),
[OrderBy] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_orderby] DEFAULT ('UNKNOWN'),
[RevType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_revtype1] DEFAULT ('UNK'),
[RevType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_revtype2] DEFAULT ('UNK'),
[RevType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_revtype3] DEFAULT ('UNK'),
[RevType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_revtype4] DEFAULT ('UNK'),
[LghType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_lghtype1] DEFAULT ('UNK'),
[LghType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_lghtype2] DEFAULT ('UNK'),
[Terms] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_terms] DEFAULT ('UNK'),
[TrlType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_trltype1] DEFAULT ('UNK'),
[TrlType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_trltype2] DEFAULT ('UNK'),
[TrlType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_trltype3] DEFAULT ('UNK'),
[TrlType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_trltype4] DEFAULT ('UNK'),
[CommodityCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CommodityClass] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlatPayType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PerMilePayType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_lanetariff] ADD CONSTRAINT [PK_core_lanetariff] PRIMARY KEY CLUSTERED ([LaneId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_lanetariff] ADD CONSTRAINT [FK_core_lanetariff_core_lane] FOREIGN KEY ([LaneId]) REFERENCES [dbo].[core_lane] ([laneid]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[core_lanetariff] TO [public]
GO
GRANT INSERT ON  [dbo].[core_lanetariff] TO [public]
GO
GRANT SELECT ON  [dbo].[core_lanetariff] TO [public]
GO
GRANT UPDATE ON  [dbo].[core_lanetariff] TO [public]
GO
