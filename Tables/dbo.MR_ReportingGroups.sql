CREATE TABLE [dbo].[MR_ReportingGroups]
(
[rg_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rg_sequence] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create Trigger [dbo].[trg_mrgroupsondelete] On [dbo].[MR_ReportingGroups] For Delete
As
Delete from MR_ReportingLibrary
From
	MR_ReportingLibrary As ReportingLibrary
     Join
        deleted             As D On ReportingLibrary.rl_group = D.rg_name

GO
ALTER TABLE [dbo].[MR_ReportingGroups] ADD CONSTRAINT [PK_MR_ReportingGroups] PRIMARY KEY CLUSTERED ([rg_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_ReportingGroups] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_ReportingGroups] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_ReportingGroups] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_ReportingGroups] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_ReportingGroups] TO [public]
GO
