CREATE TABLE [dbo].[MR_ReportGroupSecurity]
(
[rptgrp_user] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rptgrp_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_ReportGroupSecurity] ADD CONSTRAINT [PK__MR_Repor__7374ADD473CDC200] PRIMARY KEY CLUSTERED ([rptgrp_user], [rptgrp_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_ReportGroupSecurity] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_ReportGroupSecurity] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_ReportGroupSecurity] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_ReportGroupSecurity] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_ReportGroupSecurity] TO [public]
GO
