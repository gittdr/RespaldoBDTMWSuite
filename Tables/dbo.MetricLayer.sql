CREATE TABLE [dbo].[MetricLayer]
(
[LayerSN] [int] NOT NULL IDENTITY(1, 1),
[LayerCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LayerLevel] [int] NULL,
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LayerName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MetricParmName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SqlForSplit] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__MetricLay__SqlFo__3CF53A69] DEFAULT (NULL),
[ValueList] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__MetricLay__Value__3DE95EA2] DEFAULT (NULL),
[ParentLayerSN] [int] NULL CONSTRAINT [DF__MetricLay__Paren__3EDD82DB] DEFAULT ((0)),
[NewMetricCodeFormat] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UseOtherOrigParmsYN] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricLayer] ADD CONSTRAINT [AutoPK_metriclayer_LayerSN] PRIMARY KEY CLUSTERED ([LayerSN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricLayer] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricLayer] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricLayer] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricLayer] TO [public]
GO
