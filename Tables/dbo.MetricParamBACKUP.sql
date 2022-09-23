CREATE TABLE [dbo].[MetricParamBACKUP]
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
ALTER TABLE [dbo].[MetricParamBACKUP] ADD CONSTRAINT [PK__MetricParamBACKU__6305D4B8] PRIMARY KEY NONCLUSTERED ([sn]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricParamBACKUP] ADD CONSTRAINT [idxMetricParamBACKUP] UNIQUE NONCLUSTERED ([Heading], [SubHeading], [ParmName]) ON [PRIMARY]
GO
