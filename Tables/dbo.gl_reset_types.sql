CREATE TABLE [dbo].[gl_reset_types]
(
[glt_resetcode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glt_resetdesc] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glt_ARFlag] [int] NULL,
[glt_APFlag] [int] NULL,
[glt_PRFlag] [int] NULL,
[glt_IDCodeFlag] [int] NULL,
[glt_labeldefinition] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[glt_xfcflags] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[gl_reset_types] TO [public]
GO
GRANT INSERT ON  [dbo].[gl_reset_types] TO [public]
GO
GRANT REFERENCES ON  [dbo].[gl_reset_types] TO [public]
GO
GRANT SELECT ON  [dbo].[gl_reset_types] TO [public]
GO
GRANT UPDATE ON  [dbo].[gl_reset_types] TO [public]
GO
