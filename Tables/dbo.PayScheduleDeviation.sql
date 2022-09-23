CREATE TABLE [dbo].[PayScheduleDeviation]
(
[PayScheduleDeviationId] [int] NOT NULL IDENTITY(1, 1),
[PeriodCutOff] [datetime] NULL,
[CheckIssuance] [datetime] NULL,
[AssignmentId] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssignmentType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayScheduleElementId] [int] NOT NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PaySchedu__Creat__148FAB56] DEFAULT (user_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__PaySchedu__Creat__1583CF8F] DEFAULT (getdate()),
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PaySchedu__LastU__1677F3C8] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL CONSTRAINT [DF__PaySchedu__LastU__176C1801] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayScheduleDeviation] ADD CONSTRAINT [PK_dbo.PayScheduleDeviation] PRIMARY KEY CLUSTERED ([PayScheduleDeviationId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayScheduleDeviation] ADD CONSTRAINT [FK_PayScheduleDeviation_PayScheduleElement] FOREIGN KEY ([PayScheduleElementId]) REFERENCES [dbo].[PayScheduleElements] ([PayScheduleElementId])
GO
GRANT DELETE ON  [dbo].[PayScheduleDeviation] TO [public]
GO
GRANT INSERT ON  [dbo].[PayScheduleDeviation] TO [public]
GO
GRANT SELECT ON  [dbo].[PayScheduleDeviation] TO [public]
GO
GRANT UPDATE ON  [dbo].[PayScheduleDeviation] TO [public]
GO
