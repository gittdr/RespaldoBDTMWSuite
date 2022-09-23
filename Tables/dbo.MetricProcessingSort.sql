CREATE TABLE [dbo].[MetricProcessingSort]
(
[ins_dt] [datetime] NULL CONSTRAINT [DF__MetricPro__ins_d__53D89FC1] DEFAULT (getdate()),
[sn] [int] NOT NULL IDENTITY(1, 1),
[spid] [int] NULL,
[sort] [int] NULL,
[metriccode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BatchGUID] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrivateYN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateStartPassed] [datetime] NULL,
[DateEndPassed] [datetime] NULL,
[ProcessFlags] [int] NULL,
[Status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__MetricPro__Statu__7EC2FDC6] DEFAULT ('Queued')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricProcessingSort] ADD CONSTRAINT [AutoPK_MetricProcessingSort_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricProcessingSort] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricProcessingSort] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricProcessingSort] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricProcessingSort] TO [public]
GO
