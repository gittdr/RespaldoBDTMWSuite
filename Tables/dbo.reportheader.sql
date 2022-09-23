CREATE TABLE [dbo].[reportheader]
(
[rph_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rph_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rph_procedure] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rth_reporttype] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rph_creationdate] [datetime] NULL,
[rph_description] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [rph_primary] ON [dbo].[reportheader] ([rph_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[reportheader] TO [public]
GO
GRANT INSERT ON  [dbo].[reportheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[reportheader] TO [public]
GO
GRANT SELECT ON  [dbo].[reportheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[reportheader] TO [public]
GO
