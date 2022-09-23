CREATE TABLE [dbo].[chargetypepaperworkcmp]
(
[cht_number] [int] NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpwcid] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[chargetypepaperworkcmp] ADD CONSTRAINT [PK_chargetypepaperworkcompany] PRIMARY KEY CLUSTERED ([cpwcid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[chargetypepaperworkcmp] TO [public]
GO
GRANT INSERT ON  [dbo].[chargetypepaperworkcmp] TO [public]
GO
GRANT REFERENCES ON  [dbo].[chargetypepaperworkcmp] TO [public]
GO
GRANT SELECT ON  [dbo].[chargetypepaperworkcmp] TO [public]
GO
GRANT UPDATE ON  [dbo].[chargetypepaperworkcmp] TO [public]
GO
