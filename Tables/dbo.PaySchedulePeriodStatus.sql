CREATE TABLE [dbo].[PaySchedulePeriodStatus]
(
[PaySchedulePeriodStatusId] [int] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PaySchedulePeriodStatus] ADD CONSTRAINT [PK_dbo.PaySchedulePeriodStatus] PRIMARY KEY CLUSTERED ([PaySchedulePeriodStatusId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PaySchedulePeriodStatusId] ON [dbo].[PaySchedulePeriodStatus] ([PaySchedulePeriodStatusId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PaySchedulePeriodStatus] TO [public]
GO
GRANT INSERT ON  [dbo].[PaySchedulePeriodStatus] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PaySchedulePeriodStatus] TO [public]
GO
GRANT SELECT ON  [dbo].[PaySchedulePeriodStatus] TO [public]
GO
GRANT UPDATE ON  [dbo].[PaySchedulePeriodStatus] TO [public]
GO
