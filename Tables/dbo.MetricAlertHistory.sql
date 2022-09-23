CREATE TABLE [dbo].[MetricAlertHistory]
(
[AlertBatch] [int] NULL,
[AlertBatchIdx] [int] NULL,
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Upd_Daily] [datetime] NULL,
[PlainDate] [datetime] NULL,
[DailyCount] [decimal] (20, 5) NULL,
[DailyTotal] [decimal] (20, 5) NULL,
[DailyValue] [decimal] (20, 5) NULL,
[ThresholdAlertValue] [decimal] (20, 5) NULL,
[ThresholdOperator] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThresholdAlertEmailAddress] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtEmailed] [datetime] NULL,
[StatusCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserComment] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcedureName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLScriptRun] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spid] [int] NULL,
[sn] [int] NOT NULL IDENTITY(1, 1),
[dtInsert] [datetime] NULL CONSTRAINT [DF__MetricAle__dtIns__50080EDD] DEFAULT (getdate()),
[BatchGUID] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricAlertHistory] ADD CONSTRAINT [AutoPK_MetricAlertHistory_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricAlertHistory] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricAlertHistory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MetricAlertHistory] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricAlertHistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricAlertHistory] TO [public]
GO
