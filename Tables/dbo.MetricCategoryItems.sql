CREATE TABLE [dbo].[MetricCategoryItems]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[CategoryCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [int] NOT NULL CONSTRAINT [DF__MetricCat__Activ__1B94469E] DEFAULT ((1)),
[Sort] [int] NOT NULL CONSTRAINT [DF__MetricCate__Sort__1C886AD7] DEFAULT ((0)),
[ShowLayersByDefault] [int] NULL CONSTRAINT [DF__MetricCat__ShowL__5F4A526D] DEFAULT ((0)),
[LayerFilter] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__MetricCat__Layer__603E76A6] DEFAULT ('ALL')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricCategoryItems] ADD CONSTRAINT [PK__MetricCategoryIt__1AA02265] PRIMARY KEY NONCLUSTERED ([CategoryCode], [MetricCode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricCategoryItems] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricCategoryItems] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MetricCategoryItems] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricCategoryItems] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricCategoryItems] TO [public]
GO
