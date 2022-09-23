CREATE TABLE [dbo].[MetricParameterOrphans]
(
[MetricParameterOrphansSN] [int] NOT NULL IDENTITY(1, 1),
[sn] [int] NOT NULL,
[Heading] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subheading] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParmName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParmSort] [int] NULL,
[ParmValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParmDescription] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Format] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricParameterOrphans] ADD CONSTRAINT [AutoPK_MetricParameterOrphans_MetricParameterOrphansSN] PRIMARY KEY CLUSTERED ([MetricParameterOrphansSN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricParameterOrphans] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricParameterOrphans] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricParameterOrphans] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricParameterOrphans] TO [public]
GO
