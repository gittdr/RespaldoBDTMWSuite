CREATE TABLE [dbo].[PayScheduleElements]
(
[PayScheduleElementId] [int] NOT NULL IDENTITY(1, 1),
[PayScheduleId] [int] NOT NULL,
[PeriodCutOffScheduleId] [int] NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PaySchedu__Creat__3CC48C86] DEFAULT (user_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__PaySchedu__Creat__3DB8B0BF] DEFAULT (getdate()),
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PaySchedu__LastU__3EACD4F8] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL CONSTRAINT [DF__PaySchedu__LastU__3FA0F931] DEFAULT (getdate()),
[FrequencyCheckIssuanceOffSet] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayScheduleElements] ADD CONSTRAINT [PK__PayScheduleEleme__3BD0684D] PRIMARY KEY CLUSTERED ([PayScheduleElementId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PayScheduleId] ON [dbo].[PayScheduleElements] ([PayScheduleId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PeriodCutOffScheduleId] ON [dbo].[PayScheduleElements] ([PeriodCutOffScheduleId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayScheduleElements] ADD CONSTRAINT [PayScheduleElement_PaySchedule] FOREIGN KEY ([PayScheduleId]) REFERENCES [dbo].[PaySchedules] ([PayScheduleId]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PayScheduleElements] ADD CONSTRAINT [PayScheduleElement_PeriodCutOff] FOREIGN KEY ([PeriodCutOffScheduleId]) REFERENCES [dbo].[Schedules] ([ScheduleId])
GO
GRANT DELETE ON  [dbo].[PayScheduleElements] TO [public]
GO
GRANT INSERT ON  [dbo].[PayScheduleElements] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PayScheduleElements] TO [public]
GO
GRANT SELECT ON  [dbo].[PayScheduleElements] TO [public]
GO
GRANT UPDATE ON  [dbo].[PayScheduleElements] TO [public]
GO
