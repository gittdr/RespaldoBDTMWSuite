CREATE TABLE [dbo].[Schedules]
(
[ScheduleId] [int] NOT NULL IDENTITY(1, 1),
[FrequencyType] [int] NOT NULL,
[FrequencyInterval] [int] NOT NULL,
[FrequencyRelativePosition] [int] NOT NULL,
[FrequencyRecurrenceFactor] [int] NOT NULL,
[StartDate] [datetime] NOT NULL,
[EndDate] [datetime] NOT NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Schedules__Creat__48363F32] DEFAULT (user_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__Schedules__Creat__492A636B] DEFAULT (getdate()),
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Schedules__LastU__4A1E87A4] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL CONSTRAINT [DF__Schedules__LastU__4B12ABDD] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Schedules] ADD CONSTRAINT [PK__Schedules__47421AF9] PRIMARY KEY CLUSTERED ([ScheduleId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Schedules] TO [public]
GO
GRANT INSERT ON  [dbo].[Schedules] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Schedules] TO [public]
GO
GRANT SELECT ON  [dbo].[Schedules] TO [public]
GO
GRANT UPDATE ON  [dbo].[Schedules] TO [public]
GO
