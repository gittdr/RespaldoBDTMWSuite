CREATE TABLE [dbo].[MR_ReportingRestrictions]
(
[re_name] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[re_presname] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[re_reportname] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[re_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[re_presvalue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[re_datatype] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[re_operator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[re_andor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[re_valuetype] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[re_sequence] [int] NOT NULL,
[re_innersequence] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_ReportingRestrictions] ADD CONSTRAINT [PK_MR_ReportingRestrictions] PRIMARY KEY CLUSTERED ([re_reportname], [re_sequence], [re_innersequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_ReportingRestrictions] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_ReportingRestrictions] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_ReportingRestrictions] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_ReportingRestrictions] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_ReportingRestrictions] TO [public]
GO
