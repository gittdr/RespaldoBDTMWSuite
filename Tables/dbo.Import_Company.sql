CREATE TABLE [dbo].[Import_Company]
(
[cmp_id] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_city_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_nmstct] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_zip] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_state] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_country] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_terminal] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_bookingterminal] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_primaryphone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_secondaryphone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_faxphone] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_shipper] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_consignee] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_billto] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_currency] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_opens_mo] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_closes_mo] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_contact] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_altid] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pay_terms] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isloaded] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Import_Co__isloa__607D6C78] DEFAULT ('N'),
[err_msg] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Import_Company] ADD CONSTRAINT [PK__Import_C__CD425FDDA6782BC3] PRIMARY KEY CLUSTERED ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Import_Company] TO [public]
GO
GRANT INSERT ON  [dbo].[Import_Company] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Import_Company] TO [public]
GO
GRANT SELECT ON  [dbo].[Import_Company] TO [public]
GO
GRANT UPDATE ON  [dbo].[Import_Company] TO [public]
GO
