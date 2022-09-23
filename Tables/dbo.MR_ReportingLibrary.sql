CREATE TABLE [dbo].[MR_ReportingLibrary]
(
[rl_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rl_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rl_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rl_statusbardesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rl_group] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rl_reference] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rl_referencetype] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rl_runwithstoredproc] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rl_storedprocname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rl_savedaccessreport] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rl_enablesavedaccessreport] [bit] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE   Trigger [dbo].[trg_mrreportsondelete] On [dbo].[MR_ReportingLibrary] For Delete
As
Delete from MR_ReportingColumns
From
	MR_ReportingColumns As ReportingColumns
     Join
        deleted             As D On ReportingColumns.rc_reportname = D.rl_name

Delete from MR_ReportingRestrictions
From
	MR_ReportingRestrictions As ReportingRestrictions
     Join
        deleted             As D On ReportingRestrictions.re_reportname = D.rl_name

Delete from MR_ReportingSorts
From
	MR_ReportingSorts As ReportingSorts
     Join
        deleted             As D On ReportingSorts.rs_reportname = D.rl_name

Delete from MR_ReportingAccessGroups
From   
        MR_ReportingAccessGroups As ReportingAccessGroups
     Join
        deleted             As D On ReportingAccessGroups.ag_reportname = D.rl_name

GO
ALTER TABLE [dbo].[MR_ReportingLibrary] ADD CONSTRAINT [PK_MR_ReportingLibrary] PRIMARY KEY CLUSTERED ([rl_name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MR_ReportingLibrary] ON [dbo].[MR_ReportingLibrary] ([rl_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_ReportingLibrary] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_ReportingLibrary] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_ReportingLibrary] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_ReportingLibrary] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_ReportingLibrary] TO [public]
GO
