CREATE TABLE [dbo].[MR_ReportingSorts]
(
[rs_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rs_reportname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rs_presname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rs_direction] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rs_sequence] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_ReportingSorts] ADD CONSTRAINT [PK_MR_ReportingSorts] PRIMARY KEY CLUSTERED ([rs_name], [rs_reportname]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_ReportingSorts] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_ReportingSorts] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_ReportingSorts] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_ReportingSorts] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_ReportingSorts] TO [public]
GO
