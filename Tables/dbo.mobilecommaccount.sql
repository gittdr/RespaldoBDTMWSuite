CREATE TABLE [dbo].[mobilecommaccount]
(
[mba_ident] [int] NOT NULL IDENTITY(1, 1),
[mba_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mba_serviceaddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mba_userid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mba_password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mba_version] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mba_isdefault] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[mobilecommaccount] ADD CONSTRAINT [PK__mobilecommaccoun__4DC30114] PRIMARY KEY CLUSTERED ([mba_ident]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[mobilecommaccount] TO [public]
GO
GRANT INSERT ON  [dbo].[mobilecommaccount] TO [public]
GO
GRANT REFERENCES ON  [dbo].[mobilecommaccount] TO [public]
GO
GRANT SELECT ON  [dbo].[mobilecommaccount] TO [public]
GO
GRANT UPDATE ON  [dbo].[mobilecommaccount] TO [public]
GO
