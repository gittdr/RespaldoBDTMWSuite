CREATE TABLE [dbo].[PayScheduleRestrictions]
(
[PayScheduleRestrictionId] [int] NOT NULL IDENTITY(1, 1),
[PayScheduleId] [int] NOT NULL,
[LabelDefinition] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PaySchedu__Creat__427D65DC] DEFAULT (user_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__PaySchedu__Creat__43718A15] DEFAULT (getdate()),
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PaySchedu__LastU__4465AE4E] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL CONSTRAINT [DF__PaySchedu__LastU__4559D287] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayScheduleRestrictions] ADD CONSTRAINT [PK__PayScheduleRestr__418941A3] PRIMARY KEY CLUSTERED ([PayScheduleRestrictionId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PayScheduleId] ON [dbo].[PayScheduleRestrictions] ([PayScheduleId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayScheduleRestrictions] ADD CONSTRAINT [PayScheduleRestriction_PaySchedule] FOREIGN KEY ([PayScheduleId]) REFERENCES [dbo].[PaySchedules] ([PayScheduleId]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[PayScheduleRestrictions] TO [public]
GO
GRANT INSERT ON  [dbo].[PayScheduleRestrictions] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PayScheduleRestrictions] TO [public]
GO
GRANT SELECT ON  [dbo].[PayScheduleRestrictions] TO [public]
GO
GRANT UPDATE ON  [dbo].[PayScheduleRestrictions] TO [public]
GO
