CREATE TABLE [dbo].[MetricGroupUsers]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[GroupSN] [int] NULL,
[UserSN] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricGroupUsers] ADD CONSTRAINT [AutoPK_MetricGroupUsers_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricGroupUsers] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricGroupUsers] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricGroupUsers] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricGroupUsers] TO [public]
GO
