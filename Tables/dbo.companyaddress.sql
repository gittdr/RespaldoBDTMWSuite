CREATE TABLE [dbo].[companyaddress]
(
[car_key] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[car_addrname] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[car_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_address3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_city] [int] NULL,
[car_nmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_edi210] [tinyint] NULL,
[car_retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_contact] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_email_address] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__companyad__car_e__1FA960E4] DEFAULT (null)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[companyaddress] ADD CONSTRAINT [pk_companyaddress] PRIMARY KEY CLUSTERED ([car_key]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [dk_cmpaddrname] ON [dbo].[companyaddress] ([cmp_id], [car_addrname]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[companyaddress] TO [public]
GO
GRANT INSERT ON  [dbo].[companyaddress] TO [public]
GO
GRANT SELECT ON  [dbo].[companyaddress] TO [public]
GO
GRANT UPDATE ON  [dbo].[companyaddress] TO [public]
GO
