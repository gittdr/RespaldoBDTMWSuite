CREATE TABLE [dbo].[MetricGroup]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[GroupName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Disable] [int] NULL CONSTRAINT [DF__MetricGro__Disab__4A4F3587] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricGroup] ADD CONSTRAINT [AutoPK_MetricGroup_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricGroup] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricGroup] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricGroup] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricGroup] TO [public]
GO
