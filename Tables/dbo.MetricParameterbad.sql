CREATE TABLE [dbo].[MetricParameterbad]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[Heading] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SubHeading] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParmName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParmSort] [int] NULL,
[ParmValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParmDescription] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Format] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricParameterbad] ADD CONSTRAINT [PK__MetricParametero__24298C9F] PRIMARY KEY NONCLUSTERED ([sn]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricParameterbad] ADD CONSTRAINT [idxMetricParametero] UNIQUE NONCLUSTERED ([Heading], [SubHeading], [ParmName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx2MetricParametero] ON [dbo].[MetricParameterbad] ([SubHeading], [Heading], [ParmName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricParameterbad] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricParameterbad] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MetricParameterbad] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricParameterbad] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricParameterbad] TO [public]
GO
