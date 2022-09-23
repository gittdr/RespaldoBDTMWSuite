CREATE TABLE [dbo].[MetricBranchCasesForQAOnly]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[dt_first] [datetime] NULL CONSTRAINT [DF__MetricBra__dt_fi__00AB4638] DEFAULT (getdate()),
[dt_last] [datetime] NULL CONSTRAINT [DF__MetricBra__dt_la__019F6A71] DEFAULT (getdate()),
[hits] [int] NULL CONSTRAINT [DF__MetricBran__hits__02938EAA] DEFAULT ((1)),
[BranchCase] [int] NULL,
[BranchText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricBranchCasesForQAOnly] ADD CONSTRAINT [AutoPK_MetricBranchCasesForQAOnly_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricBranchCasesForQAOnly] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricBranchCasesForQAOnly] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricBranchCasesForQAOnly] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricBranchCasesForQAOnly] TO [public]
GO
