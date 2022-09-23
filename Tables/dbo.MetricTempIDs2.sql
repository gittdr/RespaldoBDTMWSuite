CREATE TABLE [dbo].[MetricTempIDs2]
(
[MetricItem] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spid] [int] NULL,
[dt_inserted] [datetime] NULL CONSTRAINT [DF__MetricTem__dt_in__762DB7C5] DEFAULT (getdate()),
[BatchGUID] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MetricTempIDs2_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricTempIDs2] ADD CONSTRAINT [prkey_MetricTempIDs2] PRIMARY KEY CLUSTERED ([MetricTempIDs2_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricTempIDs2] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricTempIDs2] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricTempIDs2] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricTempIDs2] TO [public]
GO
