CREATE TABLE [dbo].[reporttemplate_header]
(
[rth_reporttype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rth_whereclause] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rth_description] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [rth_primary] ON [dbo].[reporttemplate_header] ([rth_reporttype]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[reporttemplate_header] TO [public]
GO
GRANT INSERT ON  [dbo].[reporttemplate_header] TO [public]
GO
GRANT REFERENCES ON  [dbo].[reporttemplate_header] TO [public]
GO
GRANT SELECT ON  [dbo].[reporttemplate_header] TO [public]
GO
GRANT UPDATE ON  [dbo].[reporttemplate_header] TO [public]
GO
