CREATE TABLE [dbo].[licenselog]
(
[lic_logid] [int] NOT NULL IDENTITY(1, 1),
[lic_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lic_datetime] [datetime] NOT NULL,
[lic_msgtype] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lic_description] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[licenselog] ADD CONSTRAINT [pk_licenselog] PRIMARY KEY CLUSTERED ([lic_logid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[licenselog] TO [public]
GO
GRANT INSERT ON  [dbo].[licenselog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[licenselog] TO [public]
GO
GRANT SELECT ON  [dbo].[licenselog] TO [public]
GO
GRANT UPDATE ON  [dbo].[licenselog] TO [public]
GO
