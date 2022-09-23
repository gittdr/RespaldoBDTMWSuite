CREATE TABLE [dbo].[cdcheck_header]
(
[cdh_vendor] [int] NOT NULL IDENTITY(1, 1),
[cdh_vendorname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cdh_vendorshortname] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cdh_licensekey] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cdh_match] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdh_pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdcheckheader_cdh_pyt_itemcode] DEFAULT ('EXPCHK')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdcheck_header] ADD CONSTRAINT [pk_cdcheckheader] PRIMARY KEY CLUSTERED ([cdh_vendor]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_cdcheckheader_licensekey] ON [dbo].[cdcheck_header] ([cdh_licensekey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_cdcheckheader_cdhshortname] ON [dbo].[cdcheck_header] ([cdh_vendorshortname]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdcheck_header] ADD CONSTRAINT [fk_cdcheckheader_paytype] FOREIGN KEY ([cdh_pyt_itemcode]) REFERENCES [dbo].[paytype] ([pyt_itemcode])
GO
GRANT DELETE ON  [dbo].[cdcheck_header] TO [public]
GO
GRANT INSERT ON  [dbo].[cdcheck_header] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdcheck_header] TO [public]
GO
GRANT SELECT ON  [dbo].[cdcheck_header] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdcheck_header] TO [public]
GO
