CREATE TABLE [dbo].[can_Contact]
(
[con_id] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[car_carrierid] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_firstname] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_lastname] [char] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_phone] [char] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_fax] [char] (14) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_address1] [char] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_address2] [char] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_city] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_state] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[can_Contact] ADD CONSTRAINT [pk_can_contact] PRIMARY KEY NONCLUSTERED ([con_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[can_Contact] TO [public]
GO
GRANT INSERT ON  [dbo].[can_Contact] TO [public]
GO
GRANT REFERENCES ON  [dbo].[can_Contact] TO [public]
GO
GRANT SELECT ON  [dbo].[can_Contact] TO [public]
GO
GRANT UPDATE ON  [dbo].[can_Contact] TO [public]
GO
