CREATE TABLE [dbo].[webrestrict]
(
[login] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lbl_def] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lbl_abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [login_lbldef] ON [dbo].[webrestrict] ([login], [lbl_def]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[webrestrict] TO [public]
GO
GRANT INSERT ON  [dbo].[webrestrict] TO [public]
GO
GRANT REFERENCES ON  [dbo].[webrestrict] TO [public]
GO
GRANT SELECT ON  [dbo].[webrestrict] TO [public]
GO
GRANT UPDATE ON  [dbo].[webrestrict] TO [public]
GO
