CREATE TABLE [dbo].[estatScheduledCSReportOptions]
(
[rpt_sched_id] [int] NOT NULL,
[UserName] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Clientid] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CompanyType] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportLevel] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToleranceLateUnit] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToleranceEarlyUnit] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToleranceLate] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToleranceEarly] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[showord_hdrnumber] [bit] NOT NULL CONSTRAINT [DF__estatSche__showo__06AE3851] DEFAULT ((0)),
[ShowOnlyEarlyLoads] [bit] NOT NULL CONSTRAINT [DF__estatSche__ShowO__07A25C8A] DEFAULT ((0)),
[ShowOnlyLateLoads] [bit] NOT NULL CONSTRAINT [DF__estatSche__ShowO__089680C3] DEFAULT ((0)),
[DisplaySummaryOnly] [bit] NOT NULL CONSTRAINT [DF__estatSche__Displ__098AA4FC] DEFAULT ((0)),
[ShowEarlyTimes] [bit] NOT NULL CONSTRAINT [DF__estatSche__ShowE__0A7EC935] DEFAULT ((0)),
[ShowReasonLate] [bit] NOT NULL CONSTRAINT [DF__estatSche__ShowR__0B72ED6E] DEFAULT ((0)),
[ShowStopReferenceNumber] [bit] NOT NULL CONSTRAINT [DF__estatSche__ShowS__0C6711A7] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[estatScheduledCSReportOptions] ADD CONSTRAINT [PK_estatScheduledCSReportOptions] PRIMARY KEY NONCLUSTERED ([rpt_sched_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[estatScheduledCSReportOptions] TO [public]
GO
GRANT INSERT ON  [dbo].[estatScheduledCSReportOptions] TO [public]
GO
GRANT SELECT ON  [dbo].[estatScheduledCSReportOptions] TO [public]
GO
GRANT UPDATE ON  [dbo].[estatScheduledCSReportOptions] TO [public]
GO
