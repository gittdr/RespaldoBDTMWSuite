CREATE TABLE [dbo].[transcore_filelog]
(
[tcl_id] [int] NOT NULL IDENTITY(1, 1),
[tcl_filename] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tcl_filedate] [datetime] NULL,
[tcl_importdate] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transcore_filelog] TO [public]
GO
GRANT INSERT ON  [dbo].[transcore_filelog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[transcore_filelog] TO [public]
GO
GRANT SELECT ON  [dbo].[transcore_filelog] TO [public]
GO
GRANT UPDATE ON  [dbo].[transcore_filelog] TO [public]
GO
