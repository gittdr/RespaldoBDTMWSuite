CREATE TABLE [dbo].[estatScheduledCSRptSummaryOptions]
(
[rpt_sched_id] [int] NOT NULL,
[UserName] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Clientid] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CompanyType] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReportLevel] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToleranceLateUnit] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToleranceEarlyUnit] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToleranceLate] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToleranceEarly] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[estatScheduledCSRptSummaryOptions] ADD CONSTRAINT [PK_estatScheduledCSReportSummaryOptions] PRIMARY KEY NONCLUSTERED ([rpt_sched_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[estatScheduledCSRptSummaryOptions] TO [public]
GO
GRANT INSERT ON  [dbo].[estatScheduledCSRptSummaryOptions] TO [public]
GO
GRANT SELECT ON  [dbo].[estatScheduledCSRptSummaryOptions] TO [public]
GO
GRANT UPDATE ON  [dbo].[estatScheduledCSRptSummaryOptions] TO [public]
GO
