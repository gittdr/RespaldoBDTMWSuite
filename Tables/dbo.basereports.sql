CREATE TABLE [dbo].[basereports]
(
[brpt_id] [int] NOT NULL,
[brpt_type] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[brpt_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[brpt_datawindow] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[basereports] ADD CONSTRAINT [pk_brpt_id] PRIMARY KEY NONCLUSTERED ([brpt_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[basereports] TO [public]
GO
GRANT INSERT ON  [dbo].[basereports] TO [public]
GO
GRANT REFERENCES ON  [dbo].[basereports] TO [public]
GO
GRANT SELECT ON  [dbo].[basereports] TO [public]
GO
GRANT UPDATE ON  [dbo].[basereports] TO [public]
GO
