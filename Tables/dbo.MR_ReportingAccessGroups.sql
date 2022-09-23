CREATE TABLE [dbo].[MR_ReportingAccessGroups]
(
[ag_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ag_reportname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ag_fieldname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ag_countrecords] [bit] NOT NULL,
[ag_pagebreaks] [bit] NOT NULL,
[ag_repeatheadings] [bit] NOT NULL,
[ag_sequence] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_ReportingAccessGroups] ADD CONSTRAINT [PK_MR_ReportingAccessGroups] PRIMARY KEY CLUSTERED ([ag_name], [ag_reportname]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_ReportingAccessGroups] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_ReportingAccessGroups] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_ReportingAccessGroups] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_ReportingAccessGroups] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_ReportingAccessGroups] TO [public]
GO
