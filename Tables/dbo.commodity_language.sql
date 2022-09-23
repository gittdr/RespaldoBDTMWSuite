CREATE TABLE [dbo].[commodity_language]
(
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[language] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[commodity_language] TO [public]
GO
GRANT INSERT ON  [dbo].[commodity_language] TO [public]
GO
GRANT REFERENCES ON  [dbo].[commodity_language] TO [public]
GO
GRANT SELECT ON  [dbo].[commodity_language] TO [public]
GO
GRANT UPDATE ON  [dbo].[commodity_language] TO [public]
GO
