CREATE TABLE [dbo].[PaySchedulePeriod]
(
[PaySchedulePeriodId] [int] NOT NULL IDENTITY(1, 1),
[PayScheduleId] [int] NOT NULL,
[PayScheduleElementId] [int] NOT NULL,
[PeriodCutoff] [datetime] NOT NULL CONSTRAINT [DF__PaySchedu__Perio__15DCFFC7] DEFAULT (getdate()),
[CheckIssuance] [datetime] NOT NULL CONSTRAINT [DF__PaySchedu__Check__16D12400] DEFAULT (getdate()),
[Status] [int] NOT NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PaySchedu__Creat__17C54839] DEFAULT (user_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__PaySchedu__Creat__18B96C72] DEFAULT (getdate()),
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PaySchedu__LastU__19AD90AB] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL CONSTRAINT [DF__PaySchedu__LastU__1AA1B4E4] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PaySchedulePeriod] ADD CONSTRAINT [PK__PaySched__05C37E66786B6968] PRIMARY KEY CLUSTERED ([PaySchedulePeriodId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ScheduleId] ON [dbo].[PaySchedulePeriod] ([PayScheduleId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PaySchedulePeriod] ADD CONSTRAINT [PaySchedulePeriod_PaySchedule] FOREIGN KEY ([PayScheduleId]) REFERENCES [dbo].[PaySchedules] ([PayScheduleId])
GO
ALTER TABLE [dbo].[PaySchedulePeriod] ADD CONSTRAINT [PaySchedulePeriod_PayScheduleElements] FOREIGN KEY ([PayScheduleElementId]) REFERENCES [dbo].[PayScheduleElements] ([PayScheduleElementId]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PaySchedulePeriod] ADD CONSTRAINT [PaySchedulePeriod_PaySchedulePeriodStatus] FOREIGN KEY ([Status]) REFERENCES [dbo].[PaySchedulePeriodStatus] ([PaySchedulePeriodStatusId])
GO
GRANT DELETE ON  [dbo].[PaySchedulePeriod] TO [public]
GO
GRANT INSERT ON  [dbo].[PaySchedulePeriod] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PaySchedulePeriod] TO [public]
GO
GRANT SELECT ON  [dbo].[PaySchedulePeriod] TO [public]
GO
GRANT UPDATE ON  [dbo].[PaySchedulePeriod] TO [public]
GO
