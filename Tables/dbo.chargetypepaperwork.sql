CREATE TABLE [dbo].[chargetypepaperwork]
(
[cht_number] [int] NOT NULL,
[cpw_paperwork] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpw_sequence] [tinyint] NOT NULL,
[cpw_inv_required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpw_inv_attach] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpwid] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[chargetypepaperwork] ADD CONSTRAINT [PK_chargetypepaperwork] PRIMARY KEY CLUSTERED ([cht_number], [cpw_paperwork]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[chargetypepaperwork] TO [public]
GO
GRANT INSERT ON  [dbo].[chargetypepaperwork] TO [public]
GO
GRANT REFERENCES ON  [dbo].[chargetypepaperwork] TO [public]
GO
GRANT SELECT ON  [dbo].[chargetypepaperwork] TO [public]
GO
GRANT UPDATE ON  [dbo].[chargetypepaperwork] TO [public]
GO
