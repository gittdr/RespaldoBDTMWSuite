CREATE TABLE [dbo].[cdadvanceprofiles]
(
[fap_type] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_type] DEFAULT ('BillTo'),
[fap_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_id] DEFAULT ('UNKNOWN'),
[fap_slacktime] [int] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_slacktime] DEFAULT (0),
[fap_cashlimittype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_cashlimittype] DEFAULT ('N'),
[fap_cashlimitpercent] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_cashlimitpercent] DEFAULT (0),
[fap_cashlimit] [money] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_cashlimit] DEFAULT (0.0),
[fap_cashrenewaldaily] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_cashrenewaldaily] DEFAULT (0),
[fap_cashrenewalsun] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_cashrenewalsun] DEFAULT (0),
[fap_cashrenewalmon] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_cashrenewalmon] DEFAULT (0),
[fap_cashrenewaltue] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_cashrenewaltue] DEFAULT (0),
[fap_cashrenewalwed] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_cashrenewalwed] DEFAULT (0),
[fap_cashrenewalthu] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_cashrenewalthu] DEFAULT (0),
[fap_cashrenewalfri] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_cashrenewalfri] DEFAULT (0),
[fap_cashrenewalsat] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_cashrenewalsat] DEFAULT (0),
[fap_cashrenewaltrip] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_cashrenewaltrip] DEFAULT (0),
[fap_purchaselimittype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_purchaselimittype] DEFAULT ('N'),
[fap_purchaselimitpercent] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_purchaselimitpercent] DEFAULT (0),
[fap_purchaselimit] [money] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_purchaselimit] DEFAULT (0.0),
[fap_purchaserenewaldaily] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_purchaserenewaldaily] DEFAULT (0),
[fap_purchaserenewalsun] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_purchaserenewalsun] DEFAULT (0),
[fap_purchaserenewalmon] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_purchaserenewalmon] DEFAULT (0),
[fap_purchaserenewaltue] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_purchaserenewaltue] DEFAULT (0),
[fap_purchaserenewalwed] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_purchaserenewalwed] DEFAULT (0),
[fap_purchaserenewalthu] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_purchaserenewalthu] DEFAULT (0),
[fap_purchaserenewalfri] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_purchaserenewalfri] DEFAULT (0),
[fap_purchaserenewalsat] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_purchaserenewalsat] DEFAULT (0),
[fap_purchaserenewaltrip] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_purchaserenewaltrip] DEFAULT (0),
[fap_fuelhubmilesmin] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_fuelhubmilesmin] DEFAULT (0),
[fap_fuelhubmilesmax] [tinyint] NOT NULL CONSTRAINT [df_cdadvanceprofiles_fap_fuelhubmilesmax] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdadvanceprofiles] ADD CONSTRAINT [ckc_cdadvanceprofiles_fap_cashlimittype] CHECK (([fap_cashlimittype]='P' OR [fap_cashlimittype]='C' OR [fap_cashlimittype]='N'))
GO
ALTER TABLE [dbo].[cdadvanceprofiles] ADD CONSTRAINT [ckc_cdadvanceprofiles_fap_purchaselimittype] CHECK (([fap_purchaselimittype]='P' OR [fap_purchaselimittype]='C' OR [fap_purchaselimittype]='N'))
GO
ALTER TABLE [dbo].[cdadvanceprofiles] ADD CONSTRAINT [pk_cdadvanceprofiles] PRIMARY KEY CLUSTERED ([fap_type], [fap_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cdadvanceprofiles] TO [public]
GO
GRANT INSERT ON  [dbo].[cdadvanceprofiles] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdadvanceprofiles] TO [public]
GO
GRANT SELECT ON  [dbo].[cdadvanceprofiles] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdadvanceprofiles] TO [public]
GO
