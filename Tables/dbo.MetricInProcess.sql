CREATE TABLE [dbo].[MetricInProcess]
(
[batch] [int] NULL,
[sn] [int] NOT NULL IDENTITY(1, 1),
[ins_dt] [datetime] NULL CONSTRAINT [DF__MetricInP__ins_d__51F0574F] DEFAULT (getdate()),
[note] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricInProcess] ADD CONSTRAINT [AutoPK_MetricInProcess_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricInProcess] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricInProcess] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricInProcess] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricInProcess] TO [public]
GO
