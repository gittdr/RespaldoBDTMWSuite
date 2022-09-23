CREATE TABLE [dbo].[paytypeaudit]
(
[audit_dttm] [datetime] NOT NULL,
[audit_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[audit_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pyt_number] [int] NOT NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pyt_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_basis] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_basisunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_quantity] [float] NULL,
[pyt_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_rate] [money] NULL,
[pyt_pretax] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_minus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_editflag] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_pr_glnum] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_ap_glnum] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_agedays] [int] NULL,
[pyt_fee1] [money] NULL,
[pyt_fee2] [money] NULL,
[pyt_accept_negatives] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_fservprocess] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_expchk] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_systemcode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_maxrate] [float] NULL,
[pyt_maxenf] [int] NULL,
[pyt_minrate] [float] NULL,
[pyt_minenf] [int] NULL,
[pyt_zeroenf] [int] NULL,
[pyt_incexcoth] [int] NULL,
[pyt_retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_paying_to] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_offset_percent] [float] NULL,
[pyt_offset_for] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_editindispatch] [int] NOT NULL,
[paytypeaudit_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[paytypeaudit] ADD CONSTRAINT [prkey_paytypeaudit] PRIMARY KEY CLUSTERED ([paytypeaudit_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[paytypeaudit] TO [public]
GO
GRANT INSERT ON  [dbo].[paytypeaudit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[paytypeaudit] TO [public]
GO
GRANT SELECT ON  [dbo].[paytypeaudit] TO [public]
GO
GRANT UPDATE ON  [dbo].[paytypeaudit] TO [public]
GO
