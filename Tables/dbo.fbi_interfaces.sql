CREATE TABLE [dbo].[fbi_interfaces]
(
[fbii_id] [int] NOT NULL,
[fbii_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fbii_desc] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fbii_license_key] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fbii_license_key2] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fbi_interfaces] ADD CONSTRAINT [PK_fbi_interfaces] PRIMARY KEY CLUSTERED ([fbii_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fbi_interfaces] TO [public]
GO
GRANT INSERT ON  [dbo].[fbi_interfaces] TO [public]
GO
GRANT REFERENCES ON  [dbo].[fbi_interfaces] TO [public]
GO
GRANT SELECT ON  [dbo].[fbi_interfaces] TO [public]
GO
GRANT UPDATE ON  [dbo].[fbi_interfaces] TO [public]
GO
