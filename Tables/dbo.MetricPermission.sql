CREATE TABLE [dbo].[MetricPermission]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[GroupSN] [int] NOT NULL,
[MetricCategorySN] [int] NOT NULL CONSTRAINT [DF__MetricPer__Metri__4D2BA232] DEFAULT ((0)),
[ResNowPageSN] [int] NOT NULL CONSTRAINT [DF__MetricPer__ResNo__4E1FC66B] DEFAULT ((0)),
[ResNowSectionSN] [int] NOT NULL CONSTRAINT [DF__MetricPer__ResNo__4F13EAA4] DEFAULT ((0)),
[OverviewPage] [int] NULL CONSTRAINT [DF__MetricPer__Overv__075843C7] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricPermission] ADD CONSTRAINT [AutoPK_MetricPermission_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricPermission] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricPermission] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricPermission] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricPermission] TO [public]
GO
