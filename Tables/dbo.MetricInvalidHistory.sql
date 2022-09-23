CREATE TABLE [dbo].[MetricInvalidHistory]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[BatchGUID] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dt_insert] [datetime] NULL CONSTRAINT [DF__MetricInv__dt_in__047BD71C] DEFAULT (getdate()),
[PlainDate] [datetime] NULL,
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricInvalidHistory] ADD CONSTRAINT [AutoPK_MetricInvalidHistory_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricInvalidHistory] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricInvalidHistory] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricInvalidHistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricInvalidHistory] TO [public]
GO
