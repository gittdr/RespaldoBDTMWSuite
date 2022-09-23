CREATE TABLE [dbo].[can_users]
(
[use_id] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[car_carrierid] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[use_password] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[use_firstname] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[use_middleinitial] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[use_lastname] [char] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[use_securitylevel] [char] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[can_users] ADD CONSTRAINT [pk_can_users] PRIMARY KEY NONCLUSTERED ([use_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[can_users] TO [public]
GO
GRANT INSERT ON  [dbo].[can_users] TO [public]
GO
GRANT REFERENCES ON  [dbo].[can_users] TO [public]
GO
GRANT SELECT ON  [dbo].[can_users] TO [public]
GO
GRANT UPDATE ON  [dbo].[can_users] TO [public]
GO
