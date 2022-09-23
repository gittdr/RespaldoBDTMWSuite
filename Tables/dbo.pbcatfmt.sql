CREATE TABLE [dbo].[pbcatfmt]
(
[pbf_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pbf_frmt] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pbf_type] [smallint] NOT NULL,
[pbf_cntr] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pbcatfmt_idx] ON [dbo].[pbcatfmt] ([pbf_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pbcatfmt] TO [public]
GO
GRANT INSERT ON  [dbo].[pbcatfmt] TO [public]
GO
GRANT REFERENCES ON  [dbo].[pbcatfmt] TO [public]
GO
GRANT SELECT ON  [dbo].[pbcatfmt] TO [public]
GO
GRANT UPDATE ON  [dbo].[pbcatfmt] TO [public]
GO
