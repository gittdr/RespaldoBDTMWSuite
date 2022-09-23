CREATE TABLE [dbo].[MR_ReportUserAccess]
(
[rpt_user] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rpt_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_create] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_delete] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_CreateColumns] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MR_Report__rpt_C__5BF71BFE] DEFAULT ('F'),
[rpt_DeleteColumns] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MR_Report__rpt_D__5CEB4037] DEFAULT ('F'),
[rpt_UpdateColumns] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MR_Report__rpt_U__5DDF6470] DEFAULT ('F'),
[rpt_CreateRestrictions] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MR_Report__rpt_C__5ED388A9] DEFAULT ('F'),
[rpt_DeleteRestrictions] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MR_Report__rpt_D__5FC7ACE2] DEFAULT ('F'),
[rpt_UpdateNonDateRestrictions] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MR_Report__rpt_U__60BBD11B] DEFAULT ('F'),
[rpt_UpdateDateRestrictions] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MR_Report__rpt_U__61AFF554] DEFAULT ('F'),
[rpt_CreateSort] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MR_Report__rpt_C__62A4198D] DEFAULT ('F'),
[rpt_DeleteSort] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MR_Report__rpt_D__63983DC6] DEFAULT ('F'),
[rpt_UpdateSort] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MR_Report__rpt_U__648C61FF] DEFAULT ('F'),
[rpt_GroupingCreate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MR_Report__rpt_G__08C9C275] DEFAULT ('F'),
[rpt_GroupingDelete] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MR_Report__rpt_G__09BDE6AE] DEFAULT ('F'),
[rpt_GroupingUpdate] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MR_Report__rpt_G__0AB20AE7] DEFAULT ('F'),
[rpt_FixedReportPublishButton] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_ReportUserAccess] ADD CONSTRAINT [PK__MR_Repor__DD69691ABC6C2F3F] PRIMARY KEY CLUSTERED ([rpt_user]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_ReportUserAccess] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_ReportUserAccess] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_ReportUserAccess] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_ReportUserAccess] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_ReportUserAccess] TO [public]
GO
