CREATE TABLE [dbo].[estatScheduledCLSReportOptions]
(
[rpt_sched_id] [int] NOT NULL,
[UserName] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Clientid] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Ordstatus] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SortbyMove] [bit] NOT NULL CONSTRAINT [DF__estatSche__Sortb__0F437E52] DEFAULT ((0)),
[ShowTRC] [bit] NOT NULL CONSTRAINT [DF__estatSche__ShowT__1037A28B] DEFAULT ((0)),
[ShowTRL] [bit] NOT NULL CONSTRAINT [DF__estatSche__ShowT__112BC6C4] DEFAULT ((0)),
[ShowRefNum] [bit] NOT NULL CONSTRAINT [DF__estatSche__ShowR__121FEAFD] DEFAULT ((0)),
[TRReq] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__estatSche__TRReq__13140F36] DEFAULT (''),
[BillableEventsOnly] [bit] NOT NULL CONSTRAINT [DF__estatSche__Billa__1408336F] DEFAULT ((0)),
[showord_hdrnumber] [bit] NOT NULL CONSTRAINT [DF__estatSche__showo__14FC57A8] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[estatScheduledCLSReportOptions] ADD CONSTRAINT [PK_estatScheduledCLSReportOptions] PRIMARY KEY NONCLUSTERED ([rpt_sched_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[estatScheduledCLSReportOptions] TO [public]
GO
GRANT INSERT ON  [dbo].[estatScheduledCLSReportOptions] TO [public]
GO
GRANT SELECT ON  [dbo].[estatScheduledCLSReportOptions] TO [public]
GO
GRANT UPDATE ON  [dbo].[estatScheduledCLSReportOptions] TO [public]
GO
