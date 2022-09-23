CREATE TABLE [dbo].[chargetypeaudit]
(
[audit_dttm] [datetime] NOT NULL,
[audit_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[audit_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cht_number] [int] NOT NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cht_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cht_primary] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cht_basis] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cht_basisunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_basisper] [float] NULL,
[cht_quantity] [float] NULL,
[cht_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_rate] [money] NULL,
[cht_editflag] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_glnum] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_sign] [smallint] NULL,
[cht_systemcode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_edicode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_taxtable1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_taxtable2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_taxtable3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_taxtable4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_currunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_remark] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_rollintolh] [int] NULL,
[cht_retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_maxrate] [float] NULL,
[cht_maxenf] [int] NULL,
[cht_minrate] [float] NULL,
[cht_minenf] [int] NULL,
[cht_zeroenf] [int] NULL,
[cht_crchg] [smallint] NOT NULL,
[cht_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[chargetypeaudit_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[chargetypeaudit] ADD CONSTRAINT [prkey_chargetypeaudit] PRIMARY KEY CLUSTERED ([chargetypeaudit_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[chargetypeaudit] TO [public]
GO
GRANT INSERT ON  [dbo].[chargetypeaudit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[chargetypeaudit] TO [public]
GO
GRANT SELECT ON  [dbo].[chargetypeaudit] TO [public]
GO
GRANT UPDATE ON  [dbo].[chargetypeaudit] TO [public]
GO
