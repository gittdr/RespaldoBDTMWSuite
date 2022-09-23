CREATE TABLE [dbo].[MR_ReportSecurity]
(
[rpt_user] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rpt_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rpt_category] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_ReportSecurity] ADD CONSTRAINT [PK__MR_Repor__06BB5A31032D7C48] PRIMARY KEY CLUSTERED ([rpt_user], [rpt_name], [rpt_category]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_ReportSecurity] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_ReportSecurity] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_ReportSecurity] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_ReportSecurity] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_ReportSecurity] TO [public]
GO
