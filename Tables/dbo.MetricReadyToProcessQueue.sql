CREATE TABLE [dbo].[MetricReadyToProcessQueue]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[DateCreated] [datetime] NULL CONSTRAINT [DF__MetricRea__DateC__7DCED98D] DEFAULT (getdate()),
[PlainDateCreated] [datetime] NULL,
[MetricCodePassed] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateStartPassed] [datetime] NULL,
[DateEndPassed] [datetime] NULL,
[ProcessFlags] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricReadyToProcessQueue] ADD CONSTRAINT [AutoPK_MetricReadyToProcessQueue_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_MetricReadyToProcessQueue_MetricCodePassed] ON [dbo].[MetricReadyToProcessQueue] ([MetricCodePassed]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricReadyToProcessQueue] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricReadyToProcessQueue] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MetricReadyToProcessQueue] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricReadyToProcessQueue] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricReadyToProcessQueue] TO [public]
GO
